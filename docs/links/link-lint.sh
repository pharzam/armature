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
#   L6  every reference-style use `[text][label]` has a matching `[label]: target`
#       definition in the same file. Without one the forge renders the brackets as
#       literal text, so the link is not broken — it is not a link at all.
#   L7  no in-tree target is an absolute path. A forge resolves `/x.md` against the
#       SITE root and a local viewer against the FILESYSTEM root, so it is wrong
#       either way — and joining it onto the linking file's directory would let it
#       resolve for any file at the repository root, which is where entry points
#       live. Inherited from agents-lint's A19, which this check replaced.
#   L8  a bare destination holding a space or a tab is not a link at all. CommonMark
#       ends a bare destination at the first blank and lets only a quoted title
#       follow, so the forge renders the text as written (spec example 488). The
#       message names the two spellings that ARE links, `<a b.md>` and `a%20b.md`,
#       and says so conditionally: the author may have meant prose. A reference
#       definition of this shape defines nothing, so a `[text][label]` that uses
#       it draws L6 beside this L8 -- two reports where there was one, both true --
#       unless its target is an adopter marker holding a blank, as in
#       `[runner]: ‹the test runner›/run.sh`, which is skipped like every marker
#       and whose label stays defined.
#
# Four link forms are read, because a checker blind to a form is worse than no
# checker: the reader trusts it. Inline `[x](t)`, NESTED `[![alt](i.png)](t)` —
# found by scanning for each `](` opener rather than matching a whole link —
# reference definitions `[label]: t`, and raw HTML `href="t"`. Inline code spans
# are stripped first, so a link-shaped EXAMPLE in backticks is not resolved.
#
# HOW A DESTINATION IS READ, since #78. An angle destination `<a b.md>` runs to its
# closing `>`, blanks and all, and that `>` ends it -- before, it was cut at the
# first blank to `<a`, which read as an adopter marker and was skipped in SILENCE,
# the one silent false green among the spaced forms. A `<` that never closes -- an
# angle destination cut short at a `)` -- is kept whole and fails L1 with the whole
# cut text; before, what survived the cut passed as a marker. A bare destination
# is cut at the first blank only when a title follows; otherwise it is L8. Blanks
# padding a destination, `[x]( t.md )`, are trimmed, where the cut used to leave
# nothing and the link vanished. A `%20` is decoded once, after the wrapper strip:
# it is what a forge writes for a space and what a browser follows. Every other
# percent-encoding is looked up as written and fails L1 loudly; a failure on a
# decoded path shows both spellings. adr-lint.sh's links_to_record() reads the
# angle form and the padding the same way (links/README.md limit 6) and does NOT
# decode `%20`: it compares basenames only, and no record filename may hold a
# space, so an encoded one can only sit in the directory part it drops.
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
#   - Fixture CASE directories — any path with a `good`, `good-*` or `bad-*`
#     component,
#     the naming docs/tests/run-discipline-tests.sh already dispatches on. Their
#     links are deliberately broken: `docs/agents/tests/bad-dead-link/` exists to
#     make agents-lint reject a dead link, and linting it would report that
#     suite's success as failure. The limit this leaves is real and named: a
#     genuinely broken link in a fixture's own prose goes unseen. Fixture SUITE
#     READMEs are NOT skipped — they are prose a reader follows.
#   - A nested checkout under ROOT — a linked worktree, a clone, a submodule. The
#     file list is what git lists for THIS repository, so a copy of the tree inside
#     one is never read. Limit: `--exclude-standard` reads .git/info/exclude and
#     the global ignore file, neither versioned, so two operators on one commit can
#     get different lists. docs/tests/nested-checkout-check.sh proves it.
#
# The slug rule is the trap. GitHub lowercases, drops punctuation, and replaces
# EACH space with a hyphen — it does not collapse runs. So `## R5 — Deterministic
# over LLM-based` becomes `r5--deterministic-over-llm-based`, with TWO hyphens,
# because stripping the em-dash leaves two spaces. The slug() below began as a copy
# of agents-lint.sh's A19. That assertion was removed (#67), and the named function
# went with it -- what survives there is the same rule written inline in the
# rule-anchor derivation (`RULES=$(text "$workflow" | awk …`, the `gsub(/[^a-z0-9
# -]/, "", s)` inside it at agents-lint.sh:540). The two must be
# kept in step by hand: if one changes, the other resolves anchors the other
# rejects. Nothing enforces that today. It also drops underscores,
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
	# A CommonMark angle destination wraps the WHOLE target — `<a path.md>` — and is
	# a real link. An adopter marker only OPENS with `<`, as in `<id>.md`, and closes
	# it somewhere. Telling them apart on the closing `>` is what stops a real link
	# being skipped silently. A target that opens `<` and never closes it is neither:
	# it is an angle destination cut short, which the extractor keeps whole, and it
	# fails L1 with the whole cut text shown -- never L8, never a silent skip.
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
# fixture case directories. The skip is measured on the path RELATIVE to ROOT, so
# pointing the linter AT a fixture case (as the test runner does) still lints it.
# The list is RELATIVE to ROOT, and that is what keeps the operator's own
# directory names out of it. This list is newline-joined and split with IFS
# below, so any newline INSIDE an entry splits it -- and $root is absolute by
# construction (the default is this script's own ../..), so with absolute
# entries a checkout under a directory whose name contains a newline fed that
# name through the split and killed the run: `awk: can't open file …`, exit 1,
# plus the L5 floor firing because nothing resolved. A dead gate, on a
# repository that violates nothing.
#
# Making the entries relative is the same shape that already keeps
# audit-record-lint.sh safe, where the file list is relative to the repository
# root for exactly this reason. It does not make a newline in an IN-TREE
# filename safe -- nothing here does, and no such file exists -- but the
# operator's path is not the kit's business to survive by luck.
#
# What is listed is what git lists -- tracked, plus untracked and not ignored --
# so a nested checkout is one directory entry and its Markdown is never read. `-z`
# is what makes the names safe: git quotes a name holding a quote, a backslash or a
# control character whatever core.quotePath says, and a quoted name resolves to
# nothing. NUL-delimited output is never quoted. `[ ! -L ]` refuses a symlink, as
# the walk it replaced did: following one reads a file outside the repository.
#
# git's list is trusted only when THIS directory is itself the repository root.
# Where it is not -- a kit vendored inside a larger repository -- the list is the
# OUTER repository's view, filtered by an ignore file the kit does not own, and it
# can be missing anything: a vendor path under `.gitignore` gives nothing, `tests/`
# leaves 370 documents and 163 links unread, `*.md` leaves every one. An earlier
# form of this guard tested for `docs/` in the list and closed only the
# patterns that reached `docs/`; the root test closes the class, because the question is not which files
# are missing but whose ignore rules decided. The empty-list test stays as a second
# guard. The walk prunes any directory that holds a `.git` ENTRY: a linked
# worktree's is a file. The same shape as audit-record-lint.sh's, kept in step by
# hand (links/README.md limit 9).
# `[ -f ]` below is DEFENSIVE rather than load-bearing, and #113 measured why no
# fixture kills it: neither listing path can emit a non-regular file. `git
# ls-files --cached --others --exclude-standard` does not list a FIFO at all --
# measured, a named pipe beside a tracked file simply does not appear -- and the
# `find` fallback selects `-type f`. Nothing the loop receives can fail it. It is
# kept because it is one test and it holds if either path is ever widened.
# `[ ! -L ]` is different: git DOES list a symlink, so that half is reachable, and
# nested-checkout-check.sh asserts it.
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
	# KIND is LINK (a destination to resolve), DEF (a reference definition's target,
	# also resolved), USE (a reference label, checked against the definitions),
	# NOTLINK (a bare destination holding a blank, L8) or NOTDEF (the same on a
	# definition line, carrying label<TAB>target so the label can still count).
	_links=$(awk '
		function isfence(s) { return (s ~ /^[ ]{0,3}(```|~~~)/) }
		# A CRLF file ends every line with a carriage return. Strip it FIRST, so
		# every rule below reads a clean line and there is one behaviour rather
		# than one per form. Only the reference definition was ever wrong -- the
		# other three destinations are closed by a `)` or a `"` that separates the
		# carriage return from the path -- but patching that one branch would
		# leave the next form added here to find the defect again.
		# adr-lint.sh:links_to_record() strips it the same way, and the two must
		# agree about what a link is (links/README.md limit 6).
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
				# an angle destination runs to its closing `>`, an unclosed `<` is
				# kept whole, and a bare one ends at the first blank, after which
				# only a title may follow -- else the line defines NOTHING (L8). It
				# goes out as NOTDEF with its label, because a target that is an
				# adopter marker holding a blank still defines it, and that is
				# decided in the shell, where is_placeholder() lives
				if (tgt ~ /^<[^>]*>([ \t]|$)/) sub(/>.*$/, ">", tgt)
				else if (tgt ~ /^</) { }
				else if (tgt ~ /[ \t]/ && tgt !~ /^[^ \t]+[ \t]+[\042\047(]/) { printf "%d\tNOTDEF\t%s\t%s\n", FNR, tolower(lbl), tgt; tgt = "" }
				else sub(/[ \t].*$/, "", tgt)
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
				# blanks may pad a destination; trimming them is what keeps
				# `[x]( t.md )` from being cut to nothing and dropped in silence
				sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
				# a CommonMark angle destination runs to its closing `>`, blanks and
				# all, and that `>` ends it: `<id>.md` is a marker, not this form. A
				# `<` that never closes -- an angle destination cut short at a `)` --
				# is kept WHOLE, so L1 shows the whole cut text rather than L8
				# advising `<<...>`. A bare one ends at the first blank, where only
				# a title may follow
				if (t ~ /^<[^>]*>/) {
					# An angle destination ends at its `>`. CommonMark allows only
					# whitespace and a title after it, so anything else means the
					# line is NOT a link -- and reading the part before the `>` as
					# a path is this linter disagreeing with the renderer in
					# silence. Both shapes go out as ANGLEJUNK (L9): `<a b>junk`,
					# which used to reach is_placeholder() and be skipped, and
					# `<a b> junk`, which used to truncate to `a b` and resolve.
					tail = t
					sub(/^<[^>]*>[ \t]*/, "", tail)
					if (tail != "" && tail !~ /^[\042\047(]/) {
						printf "%d\tANGLEJUNK\t%s\n", FNR, t
						rest = substr(rest, e + 1)
						continue
					}
					sub(/>.*$/, ">", t)
				}
				else if (t ~ /^</) { }
				else if (t ~ /[ \t]/ && t !~ /^[^ \t]+[ \t]+[\042\047(]/) {
					# a blank in a bare destination with no title after it is not
					# a link at all (L8): the forge renders the text as written
					printf "%d\tNOTLINK\t%s\n", FNR, t
					rest = substr(rest, e + 1)
					continue
				}
				else sub(/[ \t].*$/, "", t)
				# An EMPTY destination is a link -- pandoc renders `[a]()` and
				# `[a](   )` as `<a href="">`. Dropping it is the silence the
				# trimming above exists to prevent, one step further on.
				if (t != "") printf "%d\tLINK\t%s\n", FNR, t
				else printf "%d\tEMPTYDEST\t%s\n", FNR, "-"
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

	# pass 1 — the reference labels this file defines, so a USE can be checked
	_defs=$(printf '%s\n' "$_links" | awk -F'\t' '$2 == "DEF" { print $3 }')
	# A spaced definition defines nothing (L8) -- UNLESS its target is an adopter
	# marker, which may hold a blank: `[runner]: ‹the test runner›/run.sh` is a
	# placeholder, not a defect. Dropping its label drew a false L6 that no edit
	# short of discovering the angle form could satisfy (#78, review round 1).
	_oldIFS=$IFS
	IFS=$nl
	for _entry in $_links; do
		IFS=$_oldIFS
		case $_entry in
		*"	NOTDEF	"*)
			_t=${_entry#*	NOTDEF	}
			is_placeholder "${_t#*	}" && _defs=$_defs$nl${_t%%	*} ;;
		esac
		IFS=$nl
	done
	IFS=$_oldIFS

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

		# L8 — a bare destination holding a blank is not a link at all. The
		# placeholder test comes first: `‹adopter doc›.md` holds a blank too. A
		# NOTDEF carries label<TAB>target, and only the target is judged here.
		# The remedy wraps the WHOLE target and echoes back no title. An earlier
		# form split a trailing title off first, so that `a b "t"` was advised
		# `<a b> "t"`. That split cost more than it bought: it truncated a path
		# holding ` (`, advising `<Design Notes>` for `Design Notes (v2)/x.md`,
		# which then resolved SILENTLY to a directory; and it turned a two-title
		# string into a line CommonMark still does not read as a link. Two inputs,
		# run at 56d4f06, say what the wrapping does. `[x](a b "t")`, with `a b` in
		# the tree, is advised `<a b "t">`, and the followed line fails L1 -- links
		# a b "t", but that path does not exist -- loud, on a path the author did
		# not mean. `[x](target.md> a/b.md)`, with target.md in the tree, is advised
		# `<target.md> a/b.md>`; the extractor ends an angle destination at its
		# first `>` when a blank or a tab follows, so the advice reads back as
		# target.md and RESOLVES, exit 0, on a line CommonMark shows as text. That
		# hole is the extractor's rather than the remedy's, and it is #97's.
		# docs/links/README.md limit 7 lists the inputs grouped by the character the
		# target carries -- a `<`, a `>`, a backslash escape, truncation being the
		# `>` sub-case where a blank or a tab follows -- and records which path each
		# `>` row resolved. Two inputs named in THIS comment are not in that table,
		# and their runs are on #98: `[x](<id>.md x)` draws neither L8 nor L1,
		# because is_placeholder() skips it -- `OK  1 links resolved` beside one
		# control link, exit 0; and `[lbl]: <Design Notes/target.md` fails L1 with
		# the whole cut text.
		if [ "$_kind" = ANGLEJUNK ]; then
			# An adopter marker opens `<` and closes it somewhere -- `<id>.md` is
			# a marker, not an angle destination followed by junk -- so the same
			# guard the NOTLINK branch carries applies here. Omitting it made
			# every `<id>.md` in the kit go red.
			#
			# But is_placeholder() reads ANY `<...>` with trailing text as a
			# marker, and that is what made `<a b>junk` silent in the first place.
			# A blank inside the angles is the tell: a marker's name has none, an
			# angle destination holding a path may. So a blank there means this is
			# a destination and the guard does not apply.
			_inner=${_target#<}
			_inner=${_inner%%>*}
			case $_inner in
			*' '*|*"$(printf '\t')"*) : ;;
			*) is_placeholder "$_target" && { IFS=$nl; continue; } ;;
			esac
			n_links=$((n_links + 1))
			err L9 "$_rel:$_lineno has an angle destination followed by something that is not a title, $_target, which CommonMark does not render as a link; write the destination alone as <path> with only a title after it, or drop the angle brackets"
			IFS=$nl; continue
		fi

		if [ "$_kind" = EMPTYDEST ]; then
			n_links=$((n_links + 1))
			err L10 "$_rel:$_lineno has a link with an empty destination, which renders as <a href=\"\"> and goes nowhere; give it a target or make it plain text"
			IFS=$nl; continue
		fi

		if [ "$_kind" = NOTLINK ] || [ "$_kind" = NOTDEF ]; then
			[ "$_kind" = NOTDEF ] && _target=${_target#*	}
			is_placeholder "$_target" && { IFS=$nl; continue; }
			n_links=$((n_links + 1))
			err L8 "$_rel:$_lineno has a bare destination holding a space or a tab, $_target, which CommonMark does not read as a link, so the forge shows the text as written. If a link was meant, write it as <$_target> or percent-encode the blanks; if prose was meant, nothing needs to change"
			IFS=$nl; continue
		fi

		# a DEF carries label<TAB>target; the target is what resolves
		[ "$_kind" = DEF ] && _target=${_target#*	}

		# a CommonMark angle destination — strip the wrapper, keep the path
		case $_target in
		'<'*'>') _target=${_target#<}; _target=${_target%>} ;;
		esac

		# a percent-encoded space is what a forge writes for a spaced path and
		# what a browser decodes when it follows the link. Only `%20`: a general
		# decode would turn a `%23` into the `#` the fragment split below reads,
		# and decodes a byte above 127 differently on two awks. The written form
		# is kept so a message can show both spellings when they differ.
		_written=$_target
		while case $_target in *%20*) ;; *) false ;; esac; do
			_target="${_target%%"%20"*} ${_target#*"%20"}"
		done
		_shown=$_target
		[ "$_target" = "$_written" ] || _shown="$_written, decoded to $_target"

		case $_target in
		http://*|https://*|mailto:*) IFS=$nl; continue ;;
		esac
		is_placeholder "$_target" && { IFS=$nl; continue; }

		# L7 — an absolute target is a portability defect, not a path to resolve.
		# A forge resolves `/x.md` against the SITE root, not the repository; a
		# local viewer resolves it against the FILESYSTEM root. Wrong either way.
		# It has to be rejected rather than resolved, because joining it onto the
		# linking file's directory makes it resolve to the real file whenever that
		# file sits at the repository root -- which is exactly where an entry point
		# lives, so the common case is the one that would pass silently.
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
		# so awk never reads a record and record splitting cannot happen at all.
		#
		# It used to come in on standard input. With the default RS, a checkout
		# under a directory whose name holds a NEWLINE arrived as two records,
		# was normalised twice, and came back as two lines -- so the L4 test
		# below compared against something that was never a path, and every link
		# in the tree reported as escaping the root. A draft fixed that with
		# `RS = "\001"` and a comment calling that "a byte no path can hold". It
		# is not: APFS accepts it in a filename, and a checkout under such a name
		# reproduced the identical dead gate -- 669 L4 failures. Betting on a
		# byte was the wrong shape of fix; not reading records is the right one.
		#
		# ENVIRON, not `-v`: awk runs ESCAPE PROCESSING on a -v value, so a path
		# holding a backslash would arrive mangled. collect_search_space() in
		# adr-lint.sh carries the same note for the same reason.
		#
		# The segments are walked with index/substr rather than split(). Measured
		# on the awk this kit runs against: `split(p, seg, "/")` breaks on a
		# NEWLINE as well as on the separator, so the very path this rewrite
		# exists to carry came back with its newline turned into a slash --
		# `/a/we ird` + `name/b` rejoined as `/a/we ird/name/b`. index() and
		# substr() have no separator semantics to surprise anyone. Verified
		# across nine path shapes: plain, `.`, `..`, `..` past the root, a double
		# slash, a space, a newline, a SOH byte, and `/` alone.
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
		*) err L4 "$_rel:$_lineno links $_shown, which escapes the repository root"
		   IFS=$nl; continue ;;
		esac

		# L1 — it must exist
		if [ ! -e "$_norm" ]; then
			err L1 "$_rel:$_lineno links $_shown, but that path does not exist"
			IFS=$nl
			continue
		fi

		# L2 — a fragment on an in-tree .md must name a heading in it
		if [ -n "$_frag" ]; then
			case $_norm in
			*.md)
				case $nl$(anchors_of "$_norm")$nl in
				*"$nl$_frag$nl"*) : ;;
				*) err L2 "$_rel:$_lineno links $_shown, but that file has no heading with that anchor" ;;
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
