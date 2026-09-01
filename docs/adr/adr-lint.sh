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
# discussing it, not linking it, and does not satisfy the check (#73).
#
# How to adapt: the checks below mirror docs/adr/template.md and README.md. If
# you change the template — add a required section, change the Status vocabulary
# — change the matching check here in the SAME change. The linter and the
# template must always agree; that is the whole point of it.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
adr_dir=${1:-$script_dir}
readme="$adr_dir/README.md"

fail=0
err()  { printf 'FAIL  %s\n' "$*" >&2; fail=1; }
note() { printf 'WARN  %s\n' "$*" >&2; }

[ -d "$adr_dir" ] || { printf 'FAIL  ADR directory not found: %s\n' "$adr_dir" >&2; exit 1; }
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
# on a real file is link-lint's single job (ADR-0007), and the two compose: this
# proves a link to the record exists, that one proves it points at something.
#
# Three limits follow from matching rather than resolving, and are stated rather
# than left to be found. A link to a DIFFERENT file that happens to share the
# record's filename counts, and a reference DEFINITION with no use anywhere
# counts although it renders as nothing (link-lint's L6 catches only the
# reverse); both need a file deliberately shaped to defeat the check. The third
# is not contrived at all: the two checks compose only for an IN-TREE target.
# link-lint skips http, https and mailto by design, because resolving them needs
# the network, so a record whose only inbound link is an absolute forge URL reads
# as cross-linked here and is resolved by nothing -- the URL can name a file that
# does not exist and both checks stay green.
#
# The fence and indent tests are spelled out rather than written `{0,3}`, for the
# awks with no interval expressions — the same reason anchors_of() in
# link-lint.sh unrolls its own. A fence test that silently never matched would
# read a fenced example as a link, which is the defect this function exists to
# remove.
links_to_record() {
	_needle=$1
	shift
	[ "$#" -gt 0 ] || return 1
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
		FNR == 1 { fence = 0; incomment = 0 }
		isfence($0) { fence = !fence; next }
		fence { next }
		/<!--/ { incomment = 1 }
		incomment { if ($0 ~ /-->/) incomment = 0; next }
		{
			line = $0
			# an inline code span holds a citation, not navigation
			gsub(/`[^`]*`/, "", line)

			# a reference definition:  [label]: destination
			if (match(line, /^[ ]?[ ]?[ ]?\[[^]]+\][ \t]*:[ \t]*[^ \t]+/)) {
				tgt = line
				sub(/^[ ]?[ ]?[ ]?\[[^]]+\][ \t]*:[ \t]*/, "", tgt)
				sub(/[ \t].*$/, "", tgt)
				if (names(tgt)) { found = 1; exit }
				# a definition line can carry a trailing link; keep reading it
				line = substr(line, RSTART + RLENGTH)
			}

			# every "](" opens a destination. Scanning for the OPENER rather than
			# matching a whole link is what finds both halves of a nested link.
			rest = line
			while ((p = index(rest, "](")) > 0) {
				rest = substr(rest, p + 2)
				e = index(rest, ")")
				if (e == 0) break
				t = substr(rest, 1, e - 1)
				sub(/[ \t].*$/, "", t)
				if (names(t)) { found = 1; exit }
				rest = substr(rest, e + 1)
			}

			# raw HTML anchors
			r2 = line
			while (match(r2, /href="[^"]*"/)) {
				h = substr(r2, RSTART + 6, RLENGTH - 7)
				if (names(h)) { found = 1; exit }
				r2 = substr(r2, RSTART + RLENGTH)
			}
		}
		END { exit(found ? 0 : 1) }
	' "$@"
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
# check was quietest exactly where it was needed (#73).
is_cross_linked() {
	_name=$1
	_docs=$(dirname "$adr_dir")
	_root=$(dirname "$_docs")

	_oldIFS=$IFS
	IFS=$nl
	# Fixture CASES are skipped: their links are test DATA, not navigation a
	# reader follows, and some are deliberately broken, so a link planted in one
	# would satisfy this check for a real record -- the same defect class as the
	# mention it stopped accepting. That reason is link-lint.sh's, for the same
	# files; the NAMING is the test runner's, which is the authority on what a
	# fixture is called: docs/tests/run-discipline-tests.sh dispatches on the
	# prefix globs good* and bad*, so the patterns below match those and not the
	# narrower good, good-*, bad-* that link-lint happens to use. A directory
	# called goodX is a fixture to the runner, and has to be one here too.
	# Both shapes the runner drives are covered: a case DIRECTORY, and a case
	# FILE under a tests/ directory. Fixture SUITE READMEs are NOT skipped: they
	# are prose, and one of them is this check's own fixture.
	#
	# Two limits. The convention is the whole mechanism, so fixture data named
	# neither good* nor bad* -- docs/prd/tests/facts/ in this tree -- is still
	# read, and a link to a record from there would count. And a REAL directory
	# whose name starts with good or bad is skipped with the fixtures; nothing
	# in this tree does, and the cost of the reverse error is higher.
	# The fixture patterns are measured on the path RELATIVE to the documents
	# root, as link-lint.sh measures its own. Matching the absolute path would
	# read the OPERATOR directory names: a checkout in a directory called
	# bad-anything or good would delete the whole tree from the search space and
	# report every record as an orphan.
	# shellcheck disable=SC2046  # the split is deliberate and IFS is newline
	set -- $(find "$_docs" -type f -name '*.md' 2>/dev/null \
		| grep -v "^$adr_dir/" \
		| awk -v docs="$_docs/" '
			{
				rel = $0
				if (index(rel, docs) == 1) rel = substr(rel, length(docs) + 1)
				if (rel ~ /(^|\/)(good|bad)[^\/]*\//) next
				if (rel ~ /(^|\/)tests\/(.*\/)?(good|bad)[^\/]*\.md$/) next
				print
			}')
	IFS=$_oldIFS
	[ -f "$_root/README.md" ] && set -- "$@" "$_root/README.md"

	links_to_record "$_name" "$@"
}

# --- 1. filenames; collect the valid ADR files -----------------------------
adr_files=""
for path in "$adr_dir"/*.md; do
	[ -e "$path" ] || continue
	name=$(basename "$path")
	[ "$name" = "README.md" ] && continue
	[ "$name" = "template.md" ] && continue
	if printf '%s' "$name" | grep -Eq '^[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$'; then
		adr_files="$adr_files $path"
	else
		err "$name: filename must be NNNN-kebab-case.md (four digits, zero-padded)"
	fi
done

if [ -z "${adr_files# }" ]; then
	# No ADRs yet is a valid state for a fresh project.
	[ "$fail" -eq 0 ] && exit 0 || exit 1
fi

# --- 2. sequential + unique numbering --------------------------------------
numbers=$(for p in $adr_files; do basename "$p" | cut -c1-4; done | sort)
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

# --- 3. per-file structure -------------------------------------------------
for path in $adr_files; do
	name=$(basename "$path")
	num=$(printf '%s' "$name" | cut -c1-4)
	numval=$(printf '%s' "$num" | sed 's/^0*//'); [ -z "$numval" ] && numval=0

	# 3a. title: first non-blank line is "# NNNN. <title>" (padded or unpadded).
	title=$(awk 'NF{print; exit}' "$path")
	printf '%s' "$title" | grep -Eq "^# 0*${numval}\. " \
		|| err "$name: first non-blank line must be '# $num. <title>' (got: ${title:-<empty>})"

	# 3b. Date: a plain 'Date: YYYY-MM-DD' line — a real date or the unfilled
	#     placeholder (the kit ships the placeholder so it self-lints green).
	dateline=$(grep -E '^Date:' "$path" | head -n1)
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
		statusval=$(awk '/^## Status[[:space:]]*$/{f=1; next} f && NF {print; exit}' "$path")
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
		|| note "$name: nothing outside $(basename "$adr_dir")/ LINKS it — a mention of $name or ADR-$num is not one; cross-link it from the plan/spec it supports"
done

[ "$fail" -eq 0 ] && { printf 'adr-lint: OK\n'; exit 0; } || exit 1
