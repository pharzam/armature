#!/bin/sh
#
# adr-lint.sh — keep docs/adr/ honest, as part of the quality gate.
#
# A domain-free discipline test: it lints the Architecture Decision Records
# against the conventions in template.md and README.md, so the ADR log cannot
# quietly drift. It reads only Markdown, so it needs no toolchain and can be the
# project's first test — before any product code exists. It runs in the
# pre-commit hook and in CI (see docs/ci/), and is the reference the
# "Testing" gate step points to.
#
# Usage:  sh docs/adr/adr-lint.sh [ADR_DIR]
#   ADR_DIR defaults to this script's own directory.
#
# Exit status: 0 = clean, 1 = one or more violations. A missing inbound
# cross-link is a non-fatal WARNing (a brand-new ADR may not be linked yet).
#
# An inbound cross-link is a LINK whose destination names the record's file, from
# a Markdown file outside this directory. A document that only NAMES a record —
# the `ADR-NNNN` shorthand, or its filename in a citation or an example — is
# discussing it, not linking it, and does not satisfy the check.
#
# How to adapt: the checks below mirror docs/adr/template.md and README.md. If
# you change the template — add a required section, change the Status vocabulary
# — change the matching check here in the SAME change. The linter and the
# template must always agree; that is the whole point of it.

set -u

# Logical, deliberately: this is only a default for adr_dir, and the canonical
# form built below is the one thing ever compared as a string. Do not "align"
# the two by making that one logical as well -- it is -P so that a symlinked
# directory resolves to the path find prints.
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
adr_dir=${1:-$script_dir}
readme="$adr_dir/README.md"

fail=0
err()  { printf 'FAIL  %s\n' "$*" >&2; fail=1; }
note() { printf 'WARN  %s\n' "$*" >&2; }

[ -d "$adr_dir" ] || { printf 'FAIL  ADR directory not found: %s\n' "$adr_dir" >&2; exit 1; }

# A canonical form of the directory, used ONLY where the path is compared as a
# STRING. $adr_dir itself is still left exactly as the caller spelled it, and it
# is now a free choice rather than a forced one: the reason used to be that the
# record list at section 1 was space-joined and looped unquoted, so forcing this
# absolute would have pushed the operator checkout prefix through that loop and
# broken every run at a path containing a space. That list is positional
# parameters now and carries any path safely, so nothing here depends on the
# spelling any more. The caller's spelling is kept because the messages read
# better with the path the operator typed.
#
# The comparison needs one spelling because $adr_dir is used both as a path --
# handed to find and dirname -- and as a prefix matched against what find prints.
# Five spellings of one directory broke that, and each made the ADR directory
# fail to exclude ITSELF, so its own index README entered the search space and
# linked every record: a trailing slash made the prefix end in //, a bare
# relative name left find printing a ./ the prefix did not carry, "." prefixed
# everything, a path holding .. never matched, and a SYMLINKED directory named a
# path find never prints. All five are silent -- the check reports OK on a tree
# full of orphans. -P resolves the symlink; a logical cd would keep it and leave
# that fifth spelling broken.
adr_dir_canon=$(CDPATH= cd -P -- "$adr_dir" 2>/dev/null && pwd -P)
[ -n "$adr_dir_canon" ] || { printf 'FAIL  ADR directory cannot be entered: %s\n' "$adr_dir" >&2; exit 1; }
[ -f "$readme" ]  || err "missing $readme (the ADR index)"

nl='
'

# links_to_record NEEDLE FILE... — does any FILE carry a Markdown link whose
# DESTINATION names NEEDLE (a record's filename)? The three destination forms are
# link-lint.sh's, read the same way: inline `](dest)`, a reference definition
# `[label]: dest`, and a raw `href="dest"`. A fenced block and an HTML comment
# are skipped whole and an inline code span is stripped from the line, so a
# link-SHAPED example is not a link.
#
# It matches link syntax; it does not RESOLVE it. Whether the destination lands
# on a real file is link-lint's single job, and the two compose: this
# proves a link to the record exists, that one proves it points at something.
#
# TEN LIMITS, stated rather than left to be found. This is the full list; the
# README states only the one an adopter has to know. Limits 1 to 7 and 10 are
# about what the MATCHING reads; 8 and 9 are about the SHAPE of the tree.
#
#   1. The two checks compose only for an IN-TREE target. link-lint skips http,
#      https and mailto by design, because resolving them needs the network, so a
#      record whose only inbound link is an absolute forge URL reads as
#      cross-linked here and is resolved by nothing -- that URL can name a file
#      that does not exist and both checks stay green. This is the one that is
#      not contrived, and the one the README carries.
#   2. A link to a DIFFERENT file that happens to share the record's filename
#      counts. Resolving the path would answer it, and resolving is link-lint's
#      job, not this one.
#   3. A reference DEFINITION nothing uses counts, although it renders as
#      nothing at all. link-lint's L6 catches only the reverse case.
#   4. A link-shaped example in a FOUR-SPACE indented code block counts. Only
#      fences, HTML comments and inline code spans are excluded. Skipping every
#      indented line would drop real links from list continuations, which is the
#      more expensive error; link-lint reads indented blocks the same way.
#   5. A real link is MISSED on a line that also opens an HTML comment, even one
#      that closes on the same line, because the whole line is skipped. This
#      fails loud -- a spurious warning, not a silent pass -- and link-lint.sh
#      carries the identical construct.
#   6. Stripping code spans REWRITES the line before any destination is read,
#      which cuts both ways: `[x]`foo`(../adr/0001-x.md)` is not a link and is
#      counted as one, and a line carrying an odd backtick -- an apostrophe
#      written as one, say -- can have a real link eaten and the record reported
#      an orphan. link-lint strips the same way.
#   7. Filenames are compared with ==, so on a case-insensitive filesystem a
#      link written [x](0001-Thing.md) resolves for link-lint and does not count
#      here. Loud, and the mirror of link-lint limit 3.
#   8. A SECOND COPY of the ADR directory anywhere under the documents root --
#      a worktree, a vendored submodule, a build cache -- is not excluded: the
#      exclusion is one literal path prefix. Its index README then links every
#      record, and every record reads as cross-linked. This one is SILENT, which
#      makes it the worst of the ten. An adopter who puts the per-task worktree
#      directory under docs/ walks straight into it.
#   9. The ADR directory is assumed to sit DIRECTLY under the documents root:
#      the search space is its parent, and the extra file read is that parent
#      directory of THAT. Move it to docs/architecture/adr/ and the space
#      narrows to docs/architecture/, so every record warns. Loud, and no
#      adopter has to keep the layout -- but nothing tells them, so it is here.
#  10. A destination containing a SPACE names the record only in the two forms
#      CommonMark reads as a link: the angle form `<dir with space/0001-x.md>`,
#      read to its closing `>` since #78, and the raw HTML form, whose quoted
#      value was always captured whole. Before #78 the `](` and definition
#      branches cut the angle form at the first blank and the record drew a
#      false orphan WARN; measured on five ADR trees identical but for the link
#      form, and re-measured after. A bare spaced destination is not a link on
#      the forge, so not counting it is correct -- link-lint reports it as L8.
#      A `%20` is NOT decoded here, deliberately: names() compares BASENAMES,
#      and the filename check below forbids a space in a record's name, so an
#      encoded space can only sit in the directory part the comparison drops.
#      Measured: `[x](dir%20with%20space/0001-x.md)` counted before #78 and
#      counts after. link-lint decodes it because it resolves the whole path.
#      That is a reasoned asymmetry between the two extractors, written on both
#      sides (links/README.md limit 6), because a limit recorded on one side
#      only IS the drift that entry describes. An earlier draft of both entries
#      said "both extractors cut at the first space" without qualification --
#      wrong on BOTH sides, arrived at by reasoning rather than measuring. What
#      remains: an angle destination holding a `)` is cut at that `)` in both
#      scripts (links/README.md limit 7), and here reads as no link.
#
# Limits 4, 5 and 6 hold for link-lint too: it is the same reading of the same
# forms. The sharing is BY HAND, though, not by construction -- the fence and
# indent tests are unrolled here for the awks that lack interval expressions
# while link-lint still writes {0,3}, so on such an awk the two disagree about an
# indented fence. If one is fixed, fix both (links/README.md limit 6).
#
# COST: one pass over the search space per record, so O(records x files). The
# search space itself is built once. Measured on a 10,000-file tree with 40
# records it is about 18 seconds -- past the ten that gate step 4 says must show
# progress, and the pre-commit hook shows none. The kit's own tree runs in under
# a second, and the honest shape of the fix is one pass collecting every linked
# filename, not a faster loop.
#
# The fence and indent tests are spelled out rather than written `{0,3}`, for the
# awks with no interval expressions — the same reason anchors_of() in
# link-lint.sh unrolls its own. A fence test that silently never matched would
# read a fenced example as a link, which is the defect this function exists to
# remove.
links_to_record() {
	_needle=$1
	# The needle is safe on -v: it is a record FILENAME, already forced to
	# NNNN-kebab-case.md by the filename check, so it holds no backslash.
	awk -v needle="$_needle" '
		function isfence(s) {
			return (s ~ /^```/    || s ~ /^~~~/ ||
			        s ~ /^ ```/   || s ~ /^ ~~~/ ||
			        s ~ /^  ```/  || s ~ /^  ~~~/ ||
			        s ~ /^   ```/ || s ~ /^   ~~~/)
		}
		# The FILENAME at the end of a destination has to BE the record, not
		# merely hold it: a link to 0001-foo-0002-bar.md -- a legal ADR
		# filename -- would otherwise satisfy the check for 0002-bar.md.
		# NO APOSTROPHE may appear in this awk program: it is a single-quoted
		# shell string, so one would end the quote, and a matching second one
		# would reopen it and leave the file still parsing as valid sh.
		function names(t,   b) {
			# a CommonMark angle destination wraps the whole target --
			# link-lint.sh strips the wrapper, so this has to as well or the
			# two disagree about the same link.
			if (t ~ /^</ && t ~ />$/) t = substr(t, 2, length(t) - 2)
			sub(/#.*$/, "", t)
			b = t
			sub(/^.*\//, "", b)
			return (b == needle)
		}
		# Each input LINE is a path to read, not content: the file list arrives
		# on standard input rather than as arguments, so a tree large enough to
		# overflow ARG_MAX cannot turn this check into a wall of false orphans.
		{
			if ($0 == "") next
			f = $0
			fence = 0
			incomment = 0
			while ((getline line < f) > 0) {
				# a CRLF file ends every line with a carriage return, which
				# would otherwise ride along on a reference definition target
				# and stop it naming the record. An inline destination is
				# unaffected -- the closing paren separates it.
				#
				# NO FIXTURE COVERS THIS ONE, and it is not for want of trying.
				# Delete this line and the whole suite still reports
				# `109 passed, 0 failed`. Two things compound to make it
				# unreachable:
				#
				#   1. What it serves is the no-orphan WARNING, which is
				#      non-fatal. The runner compares EXIT CODES, so no
				#      arrangement of fixtures can see the difference -- the same
				#      gap docs/adr/tests/README.md records for is_cross_linked,
				#      and the one `T-9c5t` would close by asserting output.
				#   2. Even by eye it does not move. The search space for a case
				#      is its PARENT directory, whose only file is the suite
				#      README -- which is line feeds, and is the one file that
				#      README says must never link a fixture record. So there is
				#      nowhere in scope to put the CRLF reference definition
				#      that would exercise this.
				#
				# Measured both ways: the good-crlf case draws two warnings with
				# this line and two without. Recorded rather than papered over
				# with a fixture that would not fail.
				sub(/\r$/, "", line)
				if (isfence(line)) { fence = !fence; continue }
				if (fence) continue
				if (line ~ /<!--/) incomment = 1
				if (incomment) {
					if (line ~ /-->/) incomment = 0
					continue
				}
				# an inline code span holds a citation, not navigation
				gsub(/`[^`]*`/, "", line)

				# a reference definition:  [label]: destination
				if (match(line, /^[ ]?[ ]?[ ]?\[[^]]+\][ \t]*:[ \t]*[^ \t]+/)) {
					tgt = line
					sub(/^[ ]?[ ]?[ ]?\[[^]]+\][ \t]*:[ \t]*/, "", tgt)
					if (tgt ~ /^<[^>]*>([ \t]|$)/) sub(/>.*$/, ">", tgt)
					else sub(/[ \t].*$/, "", tgt)
					if (names(tgt)) { found = 1; close(f); exit }
					# a definition line can carry a trailing link
					line = substr(line, RSTART + RLENGTH)
				}

				# every "](" opens a destination. Scanning for the OPENER
				# rather than matching a whole link is what finds both halves
				# of a nested link.
				rest = line
				while ((p = index(rest, "](")) > 0) {
					rest = substr(rest, p + 2)
					e = index(rest, ")")
					if (e == 0) break
					t = substr(rest, 1, e - 1)
					# a CommonMark angle destination runs to its closing `>`, blanks
					# and all, and that `>` ends it: `<id>.md` is a marker, not this
					# form. A bare one ends at the first blank, where a title may
					# follow. Padding blanks are trimmed first, as link-lint does.
					sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
					if (t ~ /^<[^>]*>([ \t]|$)/) sub(/>.*$/, ">", t)
					else sub(/[ \t].*$/, "", t)
					if (names(t)) { found = 1; close(f); exit }
					rest = substr(rest, e + 1)
				}

				# raw HTML anchors
				r2 = line
				while (match(r2, /href="[^"]*"/)) {
					h = substr(r2, RSTART + 6, RLENGTH - 7)
					if (names(h)) { found = 1; close(f); exit }
					r2 = substr(r2, RSTART + RLENGTH)
				}
			}
			close(f)
		}
		END { exit(found ? 0 : 1) }
	'
}

# Is the record whose filename is $1 LINKED from a Markdown file outside the ADR
# directory, or from the repo-root README? Non-ADR inbound links are what keep the
# "what" and the "why" connected.
#
# A link, not a mention. A document that merely NAMES a record — by its
# `ADR-NNNN` shorthand, or by its bare filename in a citation — is talking about
# it: a task record, a review note, an audit finding. Reading one of those as an
# inbound link reported "cross-linked" for a record nothing linked, and the
# shorthand is short and generic enough to appear in any prose about ADRs, so the
# check was quietest exactly where it was needed.
collect_search_space() {
	_docs=$(dirname "$adr_dir_canon")
	_root=$(dirname "$_docs")

	# Four things below are load-bearing, and each one is the fix for a defect
	# that was measured. Do not simplify any of them without reading this.
	#
	# 1. The list is TEXT and is PIPED, never expanded by the shell.
	#    `set -- $(find ...)` word-splits it, and -- because IFS does not
	#    disable pathname expansion and this script never sets -f -- also GLOBS
	#    it: a linking file named [a-z].md vanished from the list, and a sibling
	#    directory named ad[r] could expand back into the very ADR directory
	#    excluded below. Passing the list as ARGUMENTS also broke on a large
	#    tree, a regression against the grep -R this replaced: past ARG_MAX awk
	#    never ran and every record read as an orphan.
	# 2. Both operator paths reach awk through the ENVIRONMENT, never `-v`.
	#    `awk -v x=VALUE` runs ESCAPE PROCESSING on the value, so a checkout
	#    under a directory holding a backslash arrives mangled: measured, that
	#    SILENCED a genuine orphan in one tree and reported every record as an
	#    orphan in another.
	# 3. The fixture patterns are measured on `rel`, the path RELATIVE to the
	#    documents root -- never the absolute path, which carries the operator
	#    directory names. A checkout in a directory called good/ or bad-anything/
	#    otherwise deleted the whole tree from the search space.
	# 4. The ADR directory is excluded by a LITERAL prefix comparison, because a
	#    directory argument is an operator path and can hold a regex
	#    metacharacter: a checkout under x[y once excluded nothing. The
	#    comparison is safe only because it runs against the canonical form
	#    built at the head of this script; without that, five spellings of the
	#    same directory each made it exclude nothing, silently.
	_files=$(find "$_docs" -type f -name '*.md' 2>/dev/null \
		| ADR_LINT_DOCS="$_docs/" ADR_LINT_SELF="$adr_dir_canon/" awk '
			BEGIN { docs = ENVIRON["ADR_LINT_DOCS"]; self = ENVIRON["ADR_LINT_SELF"] }
			{
				if (index($0, self) == 1) next
				rel = $0
				if (index(rel, docs) == 1) rel = substr(rel, length(docs) + 1)
				# the good*/bad* globs the TEST RUNNER dispatches on -- it
				# is the authority on what a fixture is called, and is wider
				# than the good, good-*, bad-* link-lint happens to use, so a
				# directory called goodX is a fixture here as it is there
				if (rel ~ /(^|\/)(good|bad)[^\/]*\//) next
				# the same naming for the other shape the runner drives: a case
				# FILE under a tests/ directory
				if (rel ~ /(^|\/)tests\/(.*\/)?(good|bad)[^\/]*\.md$/) next
				print
			}')

	# Concatenating unconditionally would put an EMPTY FIRST ENTRY in the list
	# when find matched nothing, and an empty filename is a FATAL awk error --
	# so the one file that was found would never be read. That is the minimal
	# adopter tree this script advertises for: a root README, an ADR directory,
	# and nothing else under docs/ yet.
	if [ -f "$_root/README.md" ]; then
		if [ -n "$_files" ]; then
			_files=$_files$nl$_root/README.md
		else
			_files=$_root/README.md
		fi
	fi
	printf '%s' "$_files"
}

# The search space does not vary per record, so it is built ONCE -- and a run
# that read NOTHING has to say so. Without this, an empty search space is
# indistinguishable from a tree of genuine orphans: every record warns, the run
# exits 0, and the wall of warnings looks like a correct answer. Three separate
# defects presented exactly that way (a file list past ARG_MAX, an operator path
# that matched everything, an ADR directory moved a level deeper), which is why
# the kit puts a coverage floor under link-lint (L5) and under the test runner.
cross_files=$(collect_search_space)
[ -n "$cross_files" ] && cross_files_seen=1 || cross_files_seen=0

is_cross_linked() {
	[ "$cross_files_seen" -eq 1 ] || return 1
	printf '%s\n' "$cross_files" | links_to_record "$1"
}

# --- 1. filenames; collect the valid ADR files -----------------------------
# The record list is held in the POSITIONAL PARAMETERS, not in a string.
#
# It was a SPACE-JOINED string looped over unquoted, so a path split into one
# word per space: at a checkout under `…/sp ace/` the run reported
# `FAIL duplicate ADR number: sp` and 89 more, on a repository that violates
# nothing, and a two-space prefix such as `…/a b c/` gave 138. Both measured
# against the pre-fix script; a draft here paired the one-space EXAMPLE with the
# two-space COUNT, which read as consistent because the first clause was right.
# The exposed invocations were the ones the gate itself uses -- the
# no-argument default is $script_dir, absolute by construction at the head of
# this file -- so the pre-commit hook and every CI job met it on every run.
#
# Positional parameters are the POSIX way to carry a list of paths. They need no
# separator, so they close the whole class rather than the reported symptom:
# a space, a tab, a newline and a glob character are all safe. The alternative
# considered and rejected was a newline-joined string with IFS, which fixes the
# space and leaves the glob -- IFS does not disable pathname expansion, and this
# script never sets -f. collect_search_space() note 1 above is that same trap,
# measured.
#
# $1 is read into $adr_dir at the head of this script and is not wanted again,
# so overwriting the parameters here costs nothing.
set --
for path in "$adr_dir"/*.md; do
	[ -e "$path" ] || continue
	name=$(basename "$path")
	[ "$name" = "README.md" ] && continue
	[ "$name" = "template.md" ] && continue
	if printf '%s' "$name" | grep -Eq '^[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$'; then
		set -- "$@" "$path"
	else
		err "$name: filename must be NNNN-kebab-case.md (four digits, zero-padded)"
	fi
done

if [ "$#" -eq 0 ]; then
	# No ADRs yet is a valid state for a fresh project.
	[ "$fail" -eq 0 ] && exit 0 || exit 1
fi

# --- 2. sequential + unique numbering --------------------------------------
numbers=$(for p in "$@"; do basename "$p" | cut -c1-4; done | sort)
prev=""
expected=1
for n in $numbers; do
	[ "$n" = "$prev" ] && err "duplicate ADR number: $n"
	if [ "$prev" != "$n" ]; then
		nval=$(printf '%s' "$n" | sed 's/^0*//'); [ -z "$nval" ] && nval=0
		if [ "$nval" -ne "$expected" ]; then
			err "ADR numbers must be contiguous from 0001; expected $(printf '%04d' "$expected"), found $n"
		fi
		expected=$((expected + 1))
	fi
	prev="$n"
done

# A search space of nothing is a defect in the run, not a tree of orphans.
if [ "$cross_files_seen" -eq 0 ]; then
	note "no document outside $(basename "$adr_dir_canon")/ was read, so every record below reports as an orphan — check the directory argument and where the ADR directory sits"
fi

# --- 3. per-file structure -------------------------------------------------
for path do
	name=$(basename "$path")
	num=$(printf '%s' "$name" | cut -c1-4)
	numval=$(printf '%s' "$num" | sed 's/^0*//'); [ -z "$numval" ] && numval=0

	# 3a. title: first non-blank line is "# NNNN. <title>" (padded or unpadded).
	#     The strip is here for the same reason it is inside 3c's awk, not for
	#     the reason 3b gives below. This rule selects a line by NF, and on a
	#     CRLF file an empty line is the record `\r`, which is NOT a blank under
	#     the default FS -- so NF is 1 and the FIRST BLANK LINE was chosen as the
	#     "first non-blank" one. A record with a leading blank line then failed
	#     with `got: ` and an invisible character, which is precisely the report
	#     shape this whole change exists to remove.
	title=$(awk '{ sub(/\r$/, "") } NF { print; exit }' "$path")
	printf '%s' "$title" | grep -Eq "^# 0*${numval}\. " \
		|| err "$name: first non-blank line must be '# $num. <title>' (got: ${title:-<empty>})"

	# 3b. Date: a plain 'Date: YYYY-MM-DD' line — a real date or the unfilled
	#     placeholder (the kit ships the placeholder so it self-lints green).
	#
	#     The strip is what makes this read a CRLF file. This check and 3c
	#     compare the value as a WHOLE STRING, so a trailing carriage return
	#     made every record in such a file fail -- and the report was worse than
	#     the failure, because the character does not print:
	#     `Date must be YYYY-MM-DD ...; got 'YYYY-MM-DD'`, a linter appearing to
	#     reject the value it asks for. 3d and 3e are the two that really were
	#     never affected: they match a PREFIX or a substring, which a trailing
	#     character cannot reach. 3a is NOT in that group, although an earlier
	#     draft of this comment said it was — it selects a line by NF rather than
	#     matching within one, and a carriage return is not a blank. See the note
	#     at 3a. links_to_record() above already stripped the return, so one
	#     script disagreed with itself about the same file.
	#
	#     ONE IDIOM for all three, `{ sub(/\r$/, "") }` as awk's first rule. A
	#     draft used `grep | head | tr -d '\r'` here, which made this the only
	#     one of the three that stripped differently, and cost a paragraph
	#     explaining why. It also cost two extra processes: awk selects the first
	#     matching line itself. Rejected on the way: `sed 's/\r$//'`, because
	#     sed's \r is not POSIX (the seds tested here happen to accept it), and
	#     routing all three through a `text()` helper like the two big linters
	#     use, which measured SLOWER -- 3a and 3c already run an awk, so a helper
	#     turns one process into two apiece, +21 ms per run over ten runs -- and
	#     would have put a third hand-maintained copy of the same helper in the
	#     kit.
	dateline=$(awk '{ sub(/\r$/, "") } /^Date:/ { print; exit }' "$path")
	if [ -z "$dateline" ]; then
		err "$name: missing 'Date: YYYY-MM-DD' line"
	else
		dateval=$(printf '%s' "$dateline" | sed -E 's/^Date:[[:space:]]*//')
		if [ "$dateval" = "YYYY-MM-DD" ]; then
			:
		elif printf '%s' "$dateval" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
			:
		else
			err "$name: Date must be YYYY-MM-DD (a real date or the placeholder); got '$dateval'"
		fi
	fi

	# 3c. Status: a '## Status' section whose value is in the allowed set.
	if ! grep -Eq '^## Status[[:space:]]*$' "$path"; then
		err "$name: missing '## Status' section"
	else
		# The strip runs INSIDE awk, and it has to. Piping the result through
		# `tr` instead leaves the blank line after the heading holding a
		# carriage return, and a carriage return is not a blank under the
		# default FS -- so NF is 1, awk takes that line as the status value, and
		# the check reports `Status '<empty>'`. Measured: it turned one wrong
		# answer into a worse one. Stripping first makes the line genuinely
		# empty, which is what `f && NF` was always reading it as.
		statusval=$(awk '{ sub(/\r$/, "") } /^## Status[[:space:]]*$/{f=1; next} f && NF {print; exit}' "$path")
		case "$statusval" in
			Proposed|Accepted|Deprecated) : ;;
			"Superseded by "*|"Accepted. Amended by "*) : ;;
			*) err "$name: Status '${statusval:-<empty>}' is not one of: Proposed | Accepted | Deprecated | Superseded by … | Accepted. Amended by …" ;;
		esac
	fi

	# 3d. required sections (Nygard shape as fixed by template.md).
	for sec in '## Context' '## Decision' '## Consequences'; do
		grep -Eq "^${sec}[[:space:]]*$" "$path" || err "$name: missing section '$sec'"
	done

	# 3e. index row in README.
	grep -Fq "$name" "$readme" || err "$name: no row for it in $(basename "$readme")'s index table"

	# 3f. no-orphan cross-link (non-fatal warning). A LINK to the record, not a
	#     mention of it: see is_cross_linked() above for why the difference is the
	#     whole check.
	is_cross_linked "$name" \
		|| note "$name: nothing outside $(basename "$adr_dir_canon")/ LINKS it — a mention of $name or ADR-$num is not one; cross-link it from the plan/spec it supports"
done

[ "$fail" -eq 0 ] && { printf 'adr-lint: OK\n'; exit 0; } || exit 1
