#!/bin/sh
#
# run-discipline-tests.sh — run every discipline linter against its fixtures and
# assert the exit code. This is the discipline-test level applied to the
# discipline tests themselves: the kit's own conventions-enforcers get tested.
#
# Each linter already self-lints the REAL repo green (in the pre-commit hook and
# in CI). This runner does the complementary job — it proves each linter correctly
# REJECTS bad input — by running its good/bad fixtures and checking the outcome:
#
#   a fixture whose name starts with  good…  must exit 0  (accepted)
#   a fixture whose name starts with  bad…   must exit 1  (rejected for a violation)
#
# A bad case must exit exactly 1 — the linters' documented "one or more violations"
# code — not merely non-zero, so a crashed linter (a syntax error, a not-found, a
# bad-argument exit) is caught rather than mistaken for a rejection.
#
# Fixtures come in two shapes, so the runner dispatches per suite:
#   directory — the linter is pointed at a case directory
#   file      — the linter reads a single file argument
# Which suite takes which shape is the dispatch list at the foot of this file.
# That list is deliberately the only place it is written down: naming the suites
# here as well gives a second copy that goes stale the next time one is added.
#
# Coverage floor. A test that never runs proves nothing, so the runner fails if a
# wired suite yields no recognized cases — it requires every present suite to keep
# at least one good AND one bad fixture, and fails if no case runs at all. That
# turns a silently-disabled suite (fixtures emptied, or renamed out of the
# good*/bad* convention) into a red, instead of a green with no coverage. It does
# not police the exact count, so a single fixture renamed out of the convention is
# still skipped silently as long as one good and one bad remain — keep fixture
# names within good*/bad*, and see each suite's README for the cases it expects.
#
# A suite whose linter or fixtures are ABSENT is skipped, not failed, so a slimmed
# adopter kit (one that dropped prd/ or ships no ADRs) still runs green. Entries
# that are neither good* nor bad* — the shared prd facts/ dir, a suite README — are
# skipped too.
#
# Usage:  sh docs/tests/run-discipline-tests.sh [-v]
#   -v, --verbose  print an "ok" line per passing case; by default only failures
#                  and a one-line summary are shown (quiet enough for the hook).
# Exit status: 0 = every case matched its expected outcome, 1 = one or more did not.
#
# It reads only text and drives the same POSIX-sh linters, so it needs no
# toolchain. It runs in the pre-commit hook and in CI, alongside those linters.

set -u

verbose=0
case ${1:-} in
	-v|--verbose) verbose=1 ;;
	'') : ;;
	*)  printf 'run-discipline-tests: unknown argument: %s\n' "$1" >&2; exit 2 ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo=$(CDPATH= cd -- "$script_dir/../.." && pwd)
cd "$repo" || { printf 'FAIL  cannot cd to repo root: %s\n' "$repo" >&2; exit 1; }

pass=0
fail=0
skipped=0
sgood=0   # good cases seen in the suite currently running
sbad=0    # bad cases seen in the suite currently running

# assert_case EXPECTED_NAME LABEL CMD...
# EXPECTED_NAME is the fixture basename; its good*/bad* prefix sets the expectation
# and counts toward the running suite's coverage.
assert_case() {
	_exp=$1; _label=$2
	shift 2
	case $_exp in
		good*) _want=0; sgood=$((sgood + 1)) ;;
		bad*)  _want=1; sbad=$((sbad + 1)) ;;
		*)     return ;;   # not a fixture (facts/, a README) — skip silently
	esac
	"$@" >/dev/null 2>&1
	_got=$?
	if [ "$_got" -eq "$_want" ]; then
		pass=$((pass + 1))
		[ "$verbose" -eq 1 ] && printf 'ok    %s\n' "$_label"
	else
		fail=$((fail + 1))
		printf 'FAIL  %s (wanted exit %s, got exit %s)\n' "$_label" "$_want" "$_got"
	fi
}

# check_floor LABEL — a wired suite must keep at least one good and one bad case.
check_floor() {
	if [ "$sgood" -eq 0 ] || [ "$sbad" -eq 0 ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s: coverage floor — need >=1 good and >=1 bad fixture (have %d good, %d bad)\n' \
			"$1" "$sgood" "$sbad"
	fi
}

# suite_available LINTER FIXTURE_ROOT LABEL — true if both exist; else note a skip.
suite_available() {
	if [ -f "$1" ] && [ -d "$2" ]; then
		return 0
	fi
	skipped=$((skipped + 1))
	printf 'skip  %s (linter or fixtures absent)\n' "$3"
	return 1
}

# bare_files PATH… — the paths under here holding no carriage return, one per
# line. A `.sh` is skipped: the executable rules pin those to line feeds on
# purpose, because a shell script with carriage returns will not run.
#
# The `(*.sh)` pattern is written with its opening parenthesis because this runs
# inside a `$( )`, where a bare `*.sh)` closes the substitution and the script
# stops parsing.
bare_files() {
	find "$@" -type f 2>/dev/null | while IFS= read -r _f; do
		case $_f in
		(*.sh) continue ;;
		esac
		tr -dc '\r' < "$_f" | grep -q '.' || printf '%s\n' "$_f"
	done
}

# check_crlf — the fixtures whose Windows line endings ARE the assertion still
# have them, and are still pinned.
#
# Those files are tests only while they keep their returns. The pin was once
# documented in three places and enforced by NOTHING: strip the returns and the
# CRLF cases degrade into duplicates of their `good` twins, every linter still
# exits 0, and this runner still reported `101 passed, 0 failed`. A green with no
# assertion behind it — the exact defect those fixtures exist to close.
#
# TWO SOURCES OF TRUTH, DELIBERATELY, because either alone is silent on a real
# way to lose the endings:
#
#   the case NAME    a directory named `*crlf*` claims to be a CRLF fixture.
#                    Independent of .gitattributes, so it survives the pin being
#                    DELETED. Deriving only from .gitattributes looked cleaner
#                    and was wrong in the way that matters -- delete the line and
#                    the check that would have complained goes with it. Measured:
#                    with only the derived check, dropping a pin and stripping
#                    the files scored a full green -- every case passing, the
#                    stripped fixtures included.
#   the PINS         every path .gitattributes names eol=crlf. Covers what no
#                    naming convention can see, and covers a pin added later on
#                    the day it is written.
#
# The two sets are unioned and each file is reported ONCE, with the cause it
# actually has. Reporting from both checks independently gave an adopter two
# lines per file that contradicted each other: "copy .gitattributes" directly
# above ".gitattributes pins it".
#
# PER FILE, not per directory. Summing across a directory passed as long as ONE
# file kept its returns, so a case could lose them on every file but the first
# and stay green — and in adr-lint/good-crlf the second record is the one that
# reaches the date check's other branch, so half that assertion would go silent.
check_crlf() {
	_nl='
'
	# The paths .gitattributes pins, resolved: `dir/**` is the directory, and
	# anything else is taken as a single file.
	# A pin that resolves to nothing is reported INDIVIDUALLY. Dropping it from
	# the list and reporting only when the whole list came back empty was the
	# same silence this section exists to end: rename one fixture directory and
	# its pin becomes decoration, with every other pin still holding the run
	# green. The two lists are carried out of the subshell on tagged lines
	# because a pipeline body cannot assign to its caller.
	_pins=''
	_dead=''
	if [ -f .gitattributes ]; then
		_resolved=$(awk '$0 !~ /^#/ && $0 ~ /eol=crlf/ { print $1 }' .gitattributes \
			| while IFS= read -r _p; do
				[ -n "$_p" ] || continue
				_t=$_p
				case $_t in
				(*/'**') _t=${_t%/'**'} ;;
				esac
				# The pattern is EXPANDED before it is tested, not tested as a
				# literal string. gitattributes cannot express a space, so the
				# only way to pin a spaced path is the `?` wildcard -- which
				# .gitattributes recommends. `[ -e ]` does no globbing, so that
				# recommendation resolved to nothing and the dead-pin report
				# fired on the kit's own advice: a trap that springs on the first
				# person who follows it.
				#
				# IFS is emptied for the expansion so the RESULT is not split on
				# spaces -- which is the whole point, since the paths being
				# matched contain them. Positional parameters inside a function
				# are local, so nothing outside is disturbed.
				_oi=$IFS; IFS=
				set -- $_t
				IFS=$_oi
				if [ -e "$1" ]; then
					for _m do
						[ -e "$_m" ] && printf 'OK %s\n' "$_m"
					done
				else
					printf 'DEAD %s\n' "$_p"
				fi
			done)
		_pins=$(printf '%s\n' "$_resolved" | sed -n 's/^OK //p')
		_dead=$(printf '%s\n' "$_resolved" | sed -n 's/^DEAD //p')
	fi
	if [ -n "$_dead" ]; then
		printf '%s\n' "$_dead" | while IFS= read -r _p; do
			printf 'FAIL  crlf: .gitattributes pins %s eol=crlf and no such path exists — the rule is decoration; fix the pattern or drop the line\n' "$_p"
		done
		fail=$((fail + $(printf '%s\n' "$_dead" | awk 'END { print NR }')))
	fi

	# Every case that CLAIMS to be a CRLF fixture must also be pinned. Reported
	# here rather than waiting for the endings to go, because an unpinned case is
	# one commit away from silently becoming a duplicate of its `good` twin.
	_cases=0
	for _d in docs/*/tests/*crlf*/; do
		[ -d "$_d" ] || continue
		_cases=$((_cases + 1))
		case $_nl$_pins$_nl in
		*"$_nl${_d%/}$_nl"*) : ;;
		*)	fail=$((fail + 1))
			printf 'FAIL  crlf: %s needs Windows line endings and no .gitattributes rule pins them — copy the kit .gitattributes into your repository root\n' "$_d" ;;
		esac
	done
	if [ "$_cases" -eq 0 ]; then
		fail=$((fail + 1))
		printf 'FAIL  crlf: no fixture case named crlf was found — the line-ending coverage is gone, not passing\n'
	fi

	# And a file with no eol=crlf line at all, which is the adopter who copied
	# fixture directories and left the root file behind.
	if [ -f .gitattributes ] && [ -z "$_pins" ] && [ -z "$_dead" ]; then
		fail=$((fail + 1))
		printf 'FAIL  crlf: .gitattributes names no eol=crlf path — the CRLF fixtures are pinned by nothing. Copy the kit .gitattributes into your repository root\n'
	fi

	# The union: everything under a crlf-named case, and everything pinned.
	_bad=$(for _d in docs/*/tests/*crlf*/; do
			[ -d "$_d" ] && bare_files "$_d"
		done
		printf '%s\n' "$_pins" | while IFS= read -r _p; do
			[ -n "$_p" ] && bare_files "$_p"
		done)
	_bad=$(printf '%s\n' "$_bad" | grep -v '^$' | sort -u)
	[ -n "$_bad" ] || return

	printf '%s\n' "$_bad" | while IFS= read -r _b; do
		# Lead with the cause this reader actually has. A pinned file that lost
		# its returns was rewritten locally -- a formatter, dos2unix, an
		# editorconfig -- and `git checkout` is the whole fix. An unpinned one
		# needs the rule first, or the next commit undoes the restore.
		case $_nl$_pins$_nl in
		*"$_nl$_b$_nl"*) _pinned=1 ;;
		*) _pinned=0 ;;
		esac
		# IFS is set to a newline for this loop, not left at the default. A
		# pinned path holding a SPACE would otherwise split into pieces here and
		# the file be misclassified as unpinned -- which would print the wrong
		# cause, in the one script whose subject is paths that split on spaces.
		# Nothing pins a spaced path today; the loop does not depend on that.
		if [ "$_pinned" -eq 0 ]; then
			_oi=$IFS; IFS=$_nl
			for _p in $_pins; do
				IFS=$_oi
				case $_b in
				("$_p"/*) _pinned=1 ;;
				esac
				IFS=$_nl
			done
			IFS=$_oi
		fi
		if [ "$_pinned" -eq 1 ]; then
			printf 'FAIL  crlf: %s lost its carriage returns — .gitattributes pins it eol=crlf, so something rewrote it locally (a formatter, dos2unix, an .editorconfig). Restore with: git checkout -- %s\n' "$_b" "$_b"
		else
			printf 'FAIL  crlf: %s holds no carriage return and no rule pins it — its line endings ARE the assertion. Copy the kit .gitattributes into your repository root, then: git checkout -- %s\n' "$_b" "$_b"
		fi
	done
	fail=$((fail + $(printf '%s\n' "$_bad" | awk 'END { print NR }')))
}

# run_dir_suite LINTER FIXTURE_ROOT LABEL — each case is a directory under the root.
run_dir_suite() {
	suite_available "$1" "$2" "$3" || return 0
	sgood=0; sbad=0
	for case_dir in "$2"/*/; do
		[ -d "$case_dir" ] || continue
		name=$(basename "$case_dir")
		assert_case "$name" "$3/$name" sh "$1" "$case_dir"
	done
	check_floor "$3"
}

# run_file_suite LINTER FIXTURE_ROOT EXT LABEL — each case is an *EXT file.
run_file_suite() {
	suite_available "$1" "$2" "$4" || return 0
	sgood=0; sbad=0
	for f in "$2"/*"$3"; do
		[ -f "$f" ] || continue
		name=$(basename "$f" "$3")
		assert_case "$name" "$4/$name" sh "$1" "$f"
	done
	check_floor "$4"
}

run_dir_suite  docs/adr/adr-lint.sh    docs/adr/tests              adr-lint
run_dir_suite  docs/prd/prd-lint.sh    docs/prd/tests              prd-lint
run_file_suite docs/ci/pr-link-lint.sh docs/ci/tests/pr-link  .md  pr-link-lint
run_file_suite docs/ci/review-record-lint.sh docs/ci/tests/review-record .md review-record-lint
run_file_suite .githooks/commit-msg    .githooks/tests/commit-msg  .txt  commit-msg
run_dir_suite  docs/tasks/audit-record-lint.sh docs/tasks/tests    audit-record-lint
run_dir_suite  docs/agents/agents-lint.sh      docs/agents/tests   agents-lint
run_dir_suite  docs/links/link-lint.sh        docs/links/tests    link-lint

# Repository-wide, so they run once rather than per suite. Both, for the reason
# written above them: the case-name check survives a deleted pin, the pin check
# sees what no naming convention can.
check_crlf

# Global floor: if nothing ran at all, the runner is misconfigured (wrong working
# directory, an invocation via a symlink, or a kit with every suite deleted) — a
# green with zero assertions would be a lie.
if [ "$((pass + fail))" -eq 0 ]; then
	fail=$((fail + 1))
	printf 'FAIL  no discipline-test cases ran (wrong directory, or every suite absent)\n'
fi

printf '\nrun-discipline-tests: %d passed, %d failed' "$pass" "$fail"
[ "$skipped" -gt 0 ] && printf ', %d suite(s) skipped' "$skipped"
printf '\n'

[ "$fail" -eq 0 ] && exit 0 || exit 1
