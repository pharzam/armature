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
#   a fixture whose name starts with  good…  must exit 0        (accepted)
#   a fixture whose name starts with  bad…   must exit non-zero (rejected)
#
# Fixtures come in two shapes, so the runner dispatches per suite:
#   directory — the linter is pointed at a case directory (adr-lint, prd-lint)
#   file      — the linter reads a single file argument     (pr-link-lint, commit-msg)
#
# A suite whose linter or fixtures are absent is skipped, not failed, so a slimmed
# adopter kit (one that dropped prd/ or ships no ADRs) still runs green. Entries
# that are neither good* nor bad* — the shared prd facts/ dir, a suite README — are
# skipped too.
#
# Usage:  sh docs/tests/run-discipline-tests.sh
# Exit status: 0 = every case matched its expected outcome, 1 = one or more did not.
#
# It reads only text and drives the same POSIX-sh linters, so it needs no
# toolchain. It runs in the pre-commit hook and in CI, alongside those linters.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo=$(CDPATH= cd -- "$script_dir/../.." && pwd)
cd "$repo" || { printf 'FAIL  cannot cd to repo root: %s\n' "$repo" >&2; exit 1; }

pass=0
fail=0
skipped=0

# assert_case EXPECTED_NAME LABEL CMD...
# EXPECTED_NAME is the fixture basename; its good*/bad* prefix sets the expectation.
assert_case() {
	_exp=$1; _label=$2
	shift 2
	case $_exp in
		good*) _want=0 ;;
		bad*)  _want=1 ;;
		*)     return ;;   # not a fixture (facts/, a README) — skip silently
	esac
	"$@" >/dev/null 2>&1
	_got=$?
	if { [ "$_want" -eq 0 ] && [ "$_got" -eq 0 ]; } \
	|| { [ "$_want" -eq 1 ] && [ "$_got" -ne 0 ]; }; then
		pass=$((pass + 1))
		printf 'ok    %s\n' "$_label"
	else
		fail=$((fail + 1))
		[ "$_want" -eq 0 ] && _wtxt='exit 0' || _wtxt='non-zero exit'
		printf 'FAIL  %s (wanted %s, got exit %s)\n' "$_label" "$_wtxt" "$_got"
	fi
}

# suite_available LINTER FIXTURE_ROOT NAME — true if both exist; else note a skip.
suite_available() {
	if [ -f "$1" ] && [ -d "$2" ]; then
		return 0
	fi
	skipped=$((skipped + 1))
	printf 'skip  %s (linter or fixtures absent)\n' "$3"
	return 1
}

# --- adr-lint: fixtures are directories under docs/adr/tests/ -----------------
if suite_available docs/adr/adr-lint.sh docs/adr/tests adr-lint; then
	for case_dir in docs/adr/tests/*/; do
		[ -d "$case_dir" ] || continue
		name=$(basename "$case_dir")
		assert_case "$name" "adr-lint/$name" sh docs/adr/adr-lint.sh "$case_dir"
	done
fi

# --- prd-lint: fixtures are directories under docs/prd/tests/ (facts/ skipped) -
if suite_available docs/prd/prd-lint.sh docs/prd/tests prd-lint; then
	for case_dir in docs/prd/tests/*/; do
		[ -d "$case_dir" ] || continue
		name=$(basename "$case_dir")
		assert_case "$name" "prd-lint/$name" sh docs/prd/prd-lint.sh "$case_dir"
	done
fi

# --- pr-link-lint: fixtures are *.md files under docs/ci/tests/pr-link/ -------
if suite_available docs/ci/pr-link-lint.sh docs/ci/tests/pr-link pr-link-lint; then
	for body in docs/ci/tests/pr-link/*.md; do
		[ -f "$body" ] || continue
		name=$(basename "$body" .md)
		assert_case "$name" "pr-link-lint/$name" sh docs/ci/pr-link-lint.sh "$body"
	done
fi

# --- commit-msg: fixtures are *.txt files under .githooks/tests/commit-msg/ ---
if suite_available .githooks/commit-msg .githooks/tests/commit-msg commit-msg; then
	for msg in .githooks/tests/commit-msg/*.txt; do
		[ -f "$msg" ] || continue
		name=$(basename "$msg" .txt)
		assert_case "$name" "commit-msg/$name" sh .githooks/commit-msg "$msg"
	done
fi

printf '\nrun-discipline-tests: %d passed, %d failed' "$pass" "$fail"
[ "$skipped" -gt 0 ] && printf ', %d suite(s) skipped' "$skipped"
printf '\n'

[ "$fail" -eq 0 ] && exit 0 || exit 1
