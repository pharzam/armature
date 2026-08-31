#!/bin/sh
#
# link-lint.sh — keep the documents' own links honest, as part of the quality gate.
#
# A domain-free discipline test: it resolves every in-tree Markdown link and
# heading anchor, so a renamed heading or a moved file turns the gate red instead
# of leaving a document pointing at nothing. It reads only text and needs no
# network and no toolchain, so it runs anywhere the other linters do — in the
# pre-commit hook and in CI (see docs/ci/).
#
# WHAT IT PROVES, AND WHAT IT DOES NOT
# It proves that a link's TARGET EXISTS and that a fragment names a real heading.
# It does NOT prove the link is the RIGHT one: a link to the wrong existing file,
# or to a real heading that does not say what the sentence claims, passes every
# assertion here. That is a review responsibility — the semantic-agreement pass in
# docs/engineering-discipline.md, not this script.
#
# WHAT IT ASSERTS
#   L1  every relative link target resolves to a path that exists.
#   L2  every `#fragment` on an in-tree .md target names a heading in that file.
#   L3  every same-file `#fragment` names a heading in the linking file.
#   L4  no link target escapes the repository root.
#   L5  coverage floor — a run that resolved ZERO links fails, so a glob that
#       matches nothing cannot report OK. (The same fail-open the discipline-test
#       runner's own floor exists to catch.)
#
# WHAT IT SKIPS, BY DESIGN
#   - External links (http, https, mailto). Resolving them needs the network,
#     which would cost the offline property every discipline test depends on.
#   - Placeholder targets: `‹…›` adopter markers, `<…>` shapes, and the ADR
#     template's `NNNN-…` form. Flagging one would push an author to "fix" a
#     template by inventing a filename — the placeholder-integrity failure
#     AGENTS.md warns about.
#   - Fenced code blocks and HTML comments, whose links are examples, not
#     navigation.
#   - Fixture CASE directories — any path with a `good*` or `bad-*` component,
#     the naming docs/tests/run-discipline-tests.sh already dispatches on. Their
#     links are deliberately broken: `docs/agents/tests/bad-dead-link/` exists to
#     make agents-lint reject a dead link, and linting it would report that
#     suite's success as failure. The limit this leaves is real and named: a
#     genuinely broken link in a fixture's own prose goes unseen. Fixture SUITE
#     READMEs are NOT skipped — they are prose a reader follows.
#
# The slug rule is the trap. GitHub lowercases, drops punctuation, and replaces
# EACH space with a hyphen — it does not collapse runs. So `## R5 — Deterministic
# over LLM-based` becomes `r5--deterministic-over-llm-based`, with TWO hyphens,
# because stripping the em-dash leaves two spaces. The slug() below is copied from
# agents-lint.sh's A19 so the two can never disagree; it also drops underscores,
# which GitHub keeps — harmless while no heading in the tree uses one, and stated
# here rather than left as a surprise.
#
# Usage:  sh docs/links/link-lint.sh [ROOT]
#   ROOT defaults to the repository root (this script's own ../..).
#
# Exit status: 0 = clean, 1 = one or more violations. Every failure names its
# assertion ID and the file:line the link sits on.
#
# How to adapt: nothing here is domain-specific. If you add a placeholder form,
# add it to is_placeholder() in the same change.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=${1:-$script_dir/../..}
[ -d "$root" ] || { printf 'FAIL  link-lint: root not found: %s\n' "$root" >&2; exit 1; }
root=$(CDPATH= cd -- "$root" && pwd)

fail=0
n_links=0
nl='
'

err() { printf 'FAIL  %s: %s\n' "$1" "$2" >&2; fail=1; }

# is_placeholder TARGET — a marker only an adopter can fill, never a real path.
is_placeholder() {
	case $1 in
	*'‹'*|*'›'*) return 0 ;;
	'<'*)        return 0 ;;
	NNNN-*)      return 0 ;;
	'...')       return 0 ;;
	esac
	return 1
}

# anchors_of FILE — the GitHub slug of every heading, one per line, fences skipped.
anchors_of() {
	awk '
		function slug(s,   x) {
			x = tolower(s)
			sub(/^#+[ \t]*/, "", x)
			gsub(/[^a-z0-9 -]/, "", x)
			gsub(/ /, "-", x)
			return x
		}
		function isfence(s) {
			return (s ~ /^```/    || s ~ /^~~~/ ||
			        s ~ /^ ```/   || s ~ /^ ~~~/ ||
			        s ~ /^  ```/  || s ~ /^  ~~~/ ||
			        s ~ /^   ```/ || s ~ /^   ~~~/)
		}
		isfence($0) { fence = !fence }
		!fence && /^#+ / { print slug($0) }
	' "$1"
}

# Collect the Markdown files to lint: everything under ROOT except .git and
# fixture case directories. The skip is measured on the path RELATIVE to ROOT, so
# pointing the linter AT a fixture case (as the test runner does) still lints it.
files=$(find "$root" -name .git -prune -o -type f -name '*.md' -print | sort)

lint_file() {
	_f=$1
	_rel=${_f#"$root"/}
	_dir=$(dirname "$_f")

	# extract: LINE<TAB>TARGET, skipping fenced blocks and HTML comments
	_links=$(awk '
		function isfence(s) { return (s ~ /^[ ]{0,3}(```|~~~)/) }
		isfence($0) { fence = !fence; next }
		fence { next }
		/<!--/ { incomment = 1 }
		incomment { if ($0 ~ /-->/) incomment = 0; next }
		{
			line = $0
			while (match(line, /\[[^]]*\]\([^)]*\)/)) {
				m = substr(line, RSTART, RLENGTH)
				sub(/^\[[^]]*\]\(/, "", m)
				sub(/\)$/, "", m)
				sub(/[ \t].*$/, "", m)
				if (m != "") printf "%d\t%s\n", FNR, m
				line = substr(line, RSTART + RLENGTH)
			}
		}
	' "$_f")

	[ -n "$_links" ] || return 0

	_oldIFS=$IFS
	IFS=$nl
	for _entry in $_links; do
		IFS=$_oldIFS
		_lineno=${_entry%%	*}
		_target=${_entry#*	}

		case $_target in
		http://*|https://*|mailto:*) IFS=$nl; continue ;;
		esac
		is_placeholder "$_target" && { IFS=$nl; continue; }

		_path=${_target%%#*}
		case $_target in
		*#*) _frag=${_target#*#} ;;
		*)   _frag='' ;;
		esac

		# a bare `#anchor` points into the linking file itself (L3)
		if [ -z "$_path" ]; then
			[ -n "$_frag" ] || { IFS=$nl; continue; }
			n_links=$((n_links + 1))
			case $nl$(anchors_of "$_f")$nl in
			*"$nl$_frag$nl"*) : ;;
			*) err L3 "$_rel:$_lineno links #$_frag, but this file has no heading with that anchor" ;;
			esac
			IFS=$nl
			continue
		fi

		n_links=$((n_links + 1))
		_abs=$(cd "$_dir" 2>/dev/null && printf '%s' "$PWD/$_path")
		_norm=$(printf '%s' "$_abs" | awk '
			BEGIN { FS = "/" }
			{
				n = 0
				for (i = 1; i <= NF; i++) {
					if ($i == "" || $i == ".") continue
					if ($i == "..") { if (n > 0) n--; else out[++n] = ".."; continue }
					out[++n] = $i
				}
				s = ""
				for (i = 1; i <= n; i++) s = s "/" out[i]
				print (s == "" ? "/" : s)
			}
		')

		# L4 — the target must stay inside the root
		case $_norm/ in
		"$root"/*) : ;;
		*) err L4 "$_rel:$_lineno links $_target, which escapes the repository root"
		   IFS=$nl; continue ;;
		esac

		# L1 — it must exist
		if [ ! -e "$_norm" ]; then
			err L1 "$_rel:$_lineno links $_target, but that path does not exist"
			IFS=$nl
			continue
		fi

		# L2 — a fragment on an in-tree .md must name a heading in it
		if [ -n "$_frag" ]; then
			case $_norm in
			*.md)
				case $nl$(anchors_of "$_norm")$nl in
				*"$nl$_frag$nl"*) : ;;
				*) err L2 "$_rel:$_lineno links $_target, but that file has no heading with that anchor" ;;
				esac
				;;
			esac
		fi
		IFS=$nl
	done
	IFS=$_oldIFS
}

oldIFS=$IFS
IFS=$nl
for f in $files; do
	IFS=$oldIFS
	rel=${f#"$root"/}
	skip=0
	# skip fixture CASE directories, by path component, relative to ROOT
	case /$rel in
	*/good/*|*/good-*/*|*/bad-*/*) skip=1 ;;
	esac
	[ "$skip" -eq 1 ] && { IFS=$nl; continue; }
	lint_file "$f"
	IFS=$nl
done
IFS=$oldIFS

# L5 — a run that resolved nothing proves nothing
[ "$n_links" -gt 0 ] || err L5 'no in-tree link was resolved — this run checked nothing'

if [ "$fail" -eq 0 ]; then
	printf 'link-lint: OK  %d links resolved\n' "$n_links"
	exit 0
fi
exit 1
