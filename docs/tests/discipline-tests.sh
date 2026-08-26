#!/bin/sh
#
# discipline-tests.sh — run every discipline linter against its own fixtures.
#
# THE GAP THIS CLOSES. The kit's linters shipped with fixtures and no runner. A
# per-directory README listed the cases and told a human to run them one at a
# time, so nothing failed when a linter regressed. Fixtures nobody runs are
# documentation, not tests — and an untested linter is exactly the "test that
# passes for the wrong reason" that guardrails.md warns about, sitting inside the
# gate itself. This script is the gate for the gate.
#
# Usage:  sh docs/tests/discipline-tests.sh [REPO_ROOT]
#   REPO_ROOT defaults to two directories above this script.
#
# Exit status: 0 = every case behaved, 1 = one or more did not.
#
# THE CONVENTION. A fixture's name states what it must do:
#   good*  -> the linter must accept it   (exit 0)
#   bad-*  -> the linter must reject it   (exit 1)
# That is the naming the existing fixture sets already use, so this runner reads
# them without any of them changing.
#
# A fixture may be a directory (the linter is pointed at the directory) or a
# single file (the linter is pointed at the file). Both shapes already exist.
#
# How to adapt: add a row to the manifest below when you add a linter. If a
# linter's fixture directory is missing, its row is skipped with a NOTE rather
# than a failure — a project that deletes a section should not fail this run.

set -u
LC_ALL=C
export LC_ALL

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=${1:-$(dirname "$(dirname "$script_dir")")}

cd "$repo_root" || { printf 'FAIL  cannot enter repo root: %s\n' "$repo_root" >&2; exit 1; }

pass=0
fail=0
skipped=0

# Run one fixture and check its exit status against what its name promises.
run_case() {
	_linter=$1
	_target=$2
	_name=$(basename "$_target")
	_name=${_name%.md}

	case "$_name" in
		good*) _want=0 ;;
		bad-*) _want=1 ;;
		*)     return 0 ;;   # not a fixture (a README, a shared facts/ dir)
	esac

	sh "$_linter" "$_target" >/dev/null 2>&1
	_got=$?

	if [ "$_got" -eq "$_want" ]; then
		pass=$((pass + 1))
	else
		fail=$((fail + 1))
		printf 'FAIL  %s on %s: exit %d, expected %d\n' \
			"$(basename "$_linter")" "$_target" "$_got" "$_want" >&2
	fi
}

# Walk one fixture root. Directories that hold a case are cases; so are files.
run_set() {
	_linter=$1
	_root=$2

	if [ ! -f "$_linter" ]; then
		printf 'NOTE  %s not present — skipped\n' "$_linter" >&2
		skipped=$((skipped + 1)); return 0
	fi
	if [ ! -d "$_root" ]; then
		printf 'NOTE  %s has no fixtures at %s — skipped\n' "$(basename "$_linter")" "$_root" >&2
		skipped=$((skipped + 1)); return 0
	fi

	for _entry in "$_root"/*; do
		[ -e "$_entry" ] || continue
		run_case "$_linter" "$_entry"
	done
}

# --- the manifest ----------------------------------------------------------
# One row per linter: the script, and the directory holding its fixtures.
run_set docs/adr/adr-lint.sh       docs/adr/tests
run_set docs/prd/prd-lint.sh       docs/prd/tests
run_set docs/tasks/backlog-lint.sh docs/tasks/tests
run_set docs/ci/pr-link-lint.sh    docs/ci/tests/pr-link
run_set docs/glossary-lint.sh      docs/tests/glossary-lint

# --- the runner's own sanity check -----------------------------------------
# Zero cases means the walk broke, not that everything passed. A green with no
# work done is the failure this whole script exists to prevent.
if [ "$((pass + fail))" -eq 0 ]; then
	printf 'FAIL  no fixture cases ran at all — the runner is broken, not the linters\n' >&2
	exit 1
fi

if [ "$fail" -eq 0 ]; then
	printf 'discipline-tests: OK (%d cases' "$pass"
	[ "$skipped" -gt 0 ] && printf ', %d set(s) skipped' "$skipped"
	printf ')\n'
	exit 0
fi

printf 'discipline-tests: %d of %d cases failed\n' "$fail" "$((pass + fail))" >&2
exit 1
