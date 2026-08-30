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
#   directory — the linter is pointed at a case directory (adr-lint, prd-lint)
#   file      — the linter reads a single file argument     (pr-link-lint, commit-msg)
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
run_file_suite .githooks/commit-msg    .githooks/tests/commit-msg  .txt  commit-msg
run_dir_suite  docs/tasks/audit-record-lint.sh docs/tasks/tests    audit-record-lint

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
