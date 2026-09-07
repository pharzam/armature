#!/bin/sh
#
# link-lint.sh — keep the documents' own links honest, as part of the quality gate.
#
# A domain-free discipline test: it resolves every in-tree Markdown link and
# heading anchor, so a renamed heading or a moved file turns the gate red instead
# of leaving a document pointing at nothing. It reads only text and needs no
# network and no toolchain, so it runs in the pre-commit hook and in CI.
#
# It proves a link's TARGET EXISTS and that a fragment names a real heading. It
# does NOT prove the link is the RIGHT one — a link to the wrong existing file, or
# to a real heading that does not match the sentence, passes here. That is the
# semantic-agreement review in docs/engineering-discipline.md, not this script.
# docs/links/README.md is the authoritative account; this header is the summary.
#
# WHAT IT ASSERTS
#   L1  every relative link target resolves to a path that exists.
#   L2  every `#fragment` on an in-tree .md target names a heading in that file.
#   L3  every same-file `#fragment` names a heading in the linking file.
#   L4  no link target escapes the repository root.
#   L5  coverage floor — a run that resolved ZERO links fails, so a glob that
#       matches nothing cannot report OK.
#   L6  every reference-style use `[text][label]` has a matching `[label]: target`
#       in the same file; without one the forge renders the brackets as text.
#   L7  no in-tree target is an absolute path — a forge resolves `/x.md` against
#       the SITE root and a local viewer against the FILESYSTEM root, wrong either
#       way, and it would resolve silently for any file at the repository root.
#
# Four link forms are read: inline `[x](t)`, NESTED `[![alt](i.png)](t)` (found by
# scanning for each `](` opener, so the inner and outer are both seen), reference
# definitions `[label]: t`, and raw HTML `href="t"`. Inline code spans are stripped
# first, so a link-shaped EXAMPLE in backticks is not resolved.
#
# PLAIN IN-TREE LINKS ONLY. A destination is read as a bare path: a CommonMark
# angle destination `<path.md>` has its wrapper stripped and resolves, but a
# destination is otherwise cut at its first blank. A spaced, angle-with-junk or
# empty destination is therefore not diagnosed — it simply does not resolve as a
# link (or fails L1 if a cut leaves a plain path not in the tree). A template's own
# navigation does not use those spellings, so the CommonMark spelling-variant
# machinery a general checker would need is deliberately not here.
#
# WHAT IT SKIPS, BY DESIGN
#   - External links (http, https, mailto) — resolving them needs the network.
#   - Placeholder targets: `‹…›` adopter markers, `<…>` shapes, and the ADR
#     template's `NNNN-…` form. Flagging one would push an author to "fix" a
#     template by inventing a filename. THE REPO'S OWN DOCS DEPEND ON THIS:
#     docs/tasks carry `[detail](<id>.md)` and `‹…›`-marked example shapes.
#   - Fenced code blocks and HTML comments — examples, not navigation.
#   - Fixture CASE directories — any path with a `good`, `good-*` or `bad-*`
#     component, whose links are deliberately broken. Fixture SUITE READMEs are
#     NOT skipped — they are prose a reader follows.
#   - A nested checkout under ROOT (worktree, clone, submodule) — the file list is
#     what git lists for THIS repository, so a copy inside one is never read.
#
# The slug rule is the trap. GitHub lowercases, drops punctuation, and replaces
# EACH space with a hyphen — it does not collapse runs — so `## R5 — Deterministic
# over LLM-based` slugs to `r5--deterministic-over-llm-based`, with TWO hyphens.
# slug() also drops underscores, which GitHub keeps: harmless while no heading uses
# one. It has no mechanism behind it (links/README.md limit 1).
#
# Usage:  sh docs/links/link-lint.sh [ROOT]   (ROOT defaults to this script's ../..)
# Exit status: 0 = clean, 1 = one or more violations, each naming its ID and file:line.
# To adapt: add any new placeholder form to is_placeholder() in the same change.

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
	# A CommonMark angle destination wraps the WHOLE target — `<a path.md>` — and is
	# a real link, its wrapper stripped before this is called. An adopter marker only
	# OPENS with `<`, as in `<id>.md`, and closes it somewhere. Telling them apart on
	# the closing `>` is what stops a real link being skipped: a `<…>` that has more
	# after the `>` is a marker, a bare `<…>` is not (and never reaches here wrapped).
	'<'*'>')     return 1 ;;
	'<'*'>'*)    return 0 ;;
	NNNN-*)      return 0 ;;
	'...')       return 0 ;;
	esac
	return 1
}

# anchors_of FILE — the GitHub slug of every heading, one per line, fences skipped.
# No carriage return is stripped here and none needs to be: slug() keeps only
# [a-z0-9 -], so a CRLF file's trailing carriage return is dropped with the rest
# of the punctuation. Stated because it is true by CONSEQUENCE rather than by
# intent — narrow that character class and this becomes wrong, silently.
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
# fixture case directories. The list is RELATIVE to ROOT (the skip is measured on
# the relative path, so pointing the linter AT a fixture case still lints it), and
# staying relative keeps the operator's own directory names — which may hold a
# newline that the IFS split below would break on — out of the list.
#
# What is listed is what git lists when THIS directory is itself the repository
# root: tracked plus untracked and not ignored, so a nested checkout is one
# directory entry and its Markdown is never read. `-z` makes the names safe (a
# quoted name resolves to nothing, and NUL-delimited output is never quoted), and
# `[ ! -L ]` refuses a symlink, which nested-checkout-check.sh asserts. Where this
# is NOT the repository root — a kit vendored in a larger repo — git's view is the
# outer repo's, filtered by an ignore file the kit does not own, so the `find`
# fallback walks instead, pruning any directory that holds a `.git` entry. The
# empty-list test is a second guard. `[ -f ]` is defensive: neither path emits a
# non-regular file (links/README.md limit 7).
_top=$(cd "$root" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null) || _top=
_here=$(cd "$root" 2>/dev/null && pwd -P) || _here=
files=
if [ -n "$_top" ] && [ "$_top" = "$_here" ]; then
	files=$(cd "$root" && git -c core.quotePath=false ls-files -z --cached --others --exclude-standard -- '*.md' 2>/dev/null \
		| tr '\0' '\n' \
		| while IFS= read -r _f; do [ -f "$_f" ] && [ ! -L "$_f" ] && printf '%s\n' "$_f"; done | sort)
fi
if [ -z "$files" ]; then
	files=$(cd "$root" \
		&& find . -name .git -prune -o -type d ! -path . -exec sh -c 'test -e "$1/.git"' _ {} \; -prune -o -type f -name '*.md' -print | sed 's|^\./||' | sort)
fi

lint_file() {
	_f=$1
	_rel=${_f#"$root"/}
	_dir=$(dirname "$_f")

	# extract: LINE<TAB>KIND<TAB>VALUE, skipping fences, HTML comments and code spans.
	# KIND is LINK (a destination to resolve), DEF (a reference definition, carrying
	# label<TAB>target — the target is resolved and the label counts toward L6) or
	# USE (a reference label, checked against the definitions). A destination is read
	# as a plain path: an angle wrapper is kept for the shell to strip, and a bare
	# destination is otherwise cut at its first blank.
	_links=$(awk '
		function isfence(s) { return (s ~ /^[ ]{0,3}(```|~~~)/) }
		# A CRLF file ends every line with a carriage return. Strip it FIRST, so
		# every rule below reads a clean line and there is one behaviour rather
		# than one per form. adr-lint.sh:links_to_record() strips it the same way,
		# and the two must agree about what a link is (links/README.md limit 6).
		{ sub(/\r$/, "") }
		isfence($0) { fence = !fence; next }
		fence { next }
		/<!--/ { incomment = 1 }
		incomment { if ($0 ~ /-->/) incomment = 0; next }
		{
			line = $0
			# an inline code span holds an EXAMPLE, not navigation
			gsub(/`[^`]*`/, "", line)

			# a reference definition:  [label]: target
			if (match(line, /^[ ]{0,3}\[[^]]+\][ \t]*:[ \t]*[^ \t]+/)) {
				lbl = line; sub(/^[ ]{0,3}\[/, "", lbl); sub(/\].*$/, "", lbl)
				tgt = line; sub(/^[ ]{0,3}\[[^]]+\][ \t]*:[ \t]*/, "", tgt)
				sub(/[ \t]+$/, "", tgt)
				# a bare destination ends at the first blank (a title may follow)
				sub(/[ \t].*$/, "", tgt)
				if (tgt != "") printf "%d\tDEF\t%s\t%s\n", FNR, tolower(lbl), tgt
				# do NOT stop here: a definition line can carry a trailing link,
				# and returning early would drop every link after it on the line.
				line = substr(line, RSTART + RLENGTH)
			}

			# every "](" opens a destination. Scanning for the OPENER rather than
			# matching a whole link is what makes a nested link work: in
			# [![alt](img.png)](target.md) the inner and the outer are both found.
			rest = line
			while ((p = index(rest, "](")) > 0) {
				rest = substr(rest, p + 2)
				e = index(rest, ")")
				if (e == 0) break
				t = substr(rest, 1, e - 1)
				sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
				# a bare destination ends at the first blank
				sub(/[ \t].*$/, "", t)
				if (t != "") printf "%d\tLINK\t%s\n", FNR, t
				rest = substr(rest, e + 1)
			}

			# raw HTML anchors
			r2 = line
			while (match(r2, /href="[^"]*"/)) {
				h = substr(r2, RSTART + 6, RLENGTH - 7)
				if (h != "") printf "%d\tLINK\t%s\n", FNR, h
				r2 = substr(r2, RSTART + RLENGTH)
			}

			# reference USES:  [text][label] and the COLLAPSED form [text][],
			# whose label is its own text. Reading the label from the second
			# bracket alone makes the collapsed form invisible -- an empty label
			# that silently drops out -- which is a false green on exactly what
			# L6 exists to catch.
			r3 = line
			while (match(r3, /\[[^]]*\]\[[^]]*\]/)) {
				u = substr(r3, RSTART, RLENGTH)
				txt = u; sub(/^\[/, "", txt); sub(/\]\[[^]]*\]$/, "", txt)
				lbl = u; sub(/^\[[^]]*\]\[/, "", lbl); sub(/\]$/, "", lbl)
				if (lbl == "") lbl = txt
				if (lbl != "") printf "%d\tUSE\t%s\n", FNR, tolower(lbl)
				r3 = substr(r3, RSTART + RLENGTH)
			}
		}
	' "$_f")

	[ -n "$_links" ] || return 0

	# pass 1 — the reference labels this file defines, so a USE can be checked.
	# A definition whose target is an adopter marker still defines its label: the
	# target is judged when the DEF is resolved below, but the label counts here.
	_defs=$(printf '%s\n' "$_links" | awk -F'\t' '$2 == "DEF" { print $3 }')

	_oldIFS=$IFS
	IFS=$nl
	for _entry in $_links; do
		IFS=$_oldIFS
		_lineno=${_entry%%	*}
		_rest=${_entry#*	}
		_kind=${_rest%%	*}
		_target=${_rest#*	}

		# L6 — a reference USE whose label nothing defines is not a link at all
		if [ "$_kind" = USE ]; then
			case $nl$_defs$nl in
			*"$nl$_target$nl"*) : ;;
			*) err L6 "$_rel:$_lineno uses reference label [$_target], but this file defines no [$_target]: target" ;;
			esac
			IFS=$nl
			continue
		fi

		# a DEF carries label<TAB>target; the target is what resolves
		[ "$_kind" = DEF ] && _target=${_target#*	}

		# a CommonMark angle destination — strip the wrapper, keep the path
		case $_target in
		'<'*'>') _target=${_target#<}; _target=${_target%>} ;;
		esac

		case $_target in
		http://*|https://*|mailto:*) IFS=$nl; continue ;;
		esac
		is_placeholder "$_target" && { IFS=$nl; continue; }

		# L7 — an absolute target is a portability defect, not a path to resolve.
		# It is rejected rather than resolved: joining it onto the linking file's
		# directory would resolve to the real file whenever that file sits at the
		# repository root, which is exactly where an entry point lives — so the
		# common case is the one that would pass silently.
		case $_target in
		/*)	n_links=$((n_links + 1))
			err L7 "$_rel:$_lineno links $_target, an absolute path; a link inside the tree must be relative to the file that carries it"
			IFS=$nl; continue ;;
		esac

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
		# The path arrives through the ENVIRONMENT and is split by hand in BEGIN,
		# so awk never reads a record: a checkout under a directory whose name
		# holds a NEWLINE would otherwise arrive as two records and normalise to
		# something that was never a path, failing L4 for every link in the tree.
		# ENVIRON, not `-v`, because awk runs escape processing on a -v value and
		# would mangle a backslash in the path. The segments are walked with
		# index/substr, not split(), which also breaks on a newline on this awk.
		_norm=$(LINK_LINT_ABS="$_abs" awk '
			BEGIN {
				p = ENVIRON["LINK_LINT_ABS"]
				m = 0
				while (1) {
					i = index(p, "/")
					if (i == 0) { seg = p; p = "" }
					else { seg = substr(p, 1, i - 1); p = substr(p, i + 1) }
					if (seg != "" && seg != ".") {
						if (seg == "..") { if (m > 0) m-- ; else out[++m] = ".." }
						else out[++m] = seg
					}
					if (i == 0) break
				}
				s = ""
				for (j = 1; j <= m; j++) s = s "/" out[j]
				print (s == "" ? "/" : s)
			}
		' </dev/null)

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
	# $f is already relative to ROOT; the absolute form is built where it is
	# needed, so the operator's directory names never enter the split above.
	rel=$f
	skip=0
	# skip fixture CASE directories, by path component, relative to ROOT
	case /$rel in
	*/good/*|*/good-*/*|*/bad-*/*) skip=1 ;;
	esac
	[ "$skip" -eq 1 ] && { IFS=$nl; continue; }
	lint_file "$root/$f"
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
