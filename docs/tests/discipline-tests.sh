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
# WHAT A REVIEW ROUND THEN FOUND (issue #37). The first version of this runner
# asserted only that a bad-* fixture made the linter exit 1 — never WHY. Exit 1 is
# the only rejection code every linter has, so it could not tell "the linter
# caught the defect" from "the linter could not find the file". Four consequences,
# all reported as OK: a fixture whose input files were deleted still passed; a
# deleted linter became a NOTE; a renamed fixture vanished in silence; an empty
# bad-* directory counted as a passing case. Every one of those is now a failure.
# docs/tests/runner-selftest.sh holds the scenarios and is the test for this file.
#
# Usage:  sh docs/tests/discipline-tests.sh [REPO_ROOT]
#   REPO_ROOT defaults to two directories above this script.
#   SKIP_SETS  space-separated linter paths to skip on purpose — see below.
#
# Exit status: 0 = every case behaved, 1 = one or more did not.
#
# THE CONVENTION. A fixture's name states what it must do:
#   good*  -> the linter must accept it   (exit 0)
#   bad-*  -> the linter must reject it   (exit 1) AND say why
# For every bad-* fixture there is a sibling <name>.expect file holding a fixed
# substring of the message that fixture must provoke. Exit status alone is not
# evidence: a linter that cannot open its input also exits 1.
#
# A fixture may be a directory (the linter is pointed at the directory) or a
# single file (the linter is pointed at the file). Both shapes already exist.
#
# NOTHING IS SKIPPED BY ACCIDENT. A missing linter, a missing fixture root, a
# fixture root that yields no cases, and an entry that matches neither naming
# convention are all failures. An adopter who deletes a whole section names it in
# SKIP_SETS, so the skip is a decision someone wrote down rather than a silent
# hole:
#     SKIP_SETS='docs/prd/prd-lint.sh' sh docs/tests/discipline-tests.sh
#
# How to adapt: add a row to the manifest below when you add a linter. A row is
# "linter fixture-root [entries to ignore]" — the third field is for a directory
# inside the fixture root that is shared input rather than a case of its own.

set -u
LC_ALL=C
export LC_ALL

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=${1:-$(dirname "$(dirname "$script_dir")")}
SKIP_SETS=${SKIP_SETS:-}

cd "$repo_root" || { printf 'FAIL  cannot enter repo root: %s\n' "$repo_root" >&2; exit 1; }

pass=0
fail=0
skipped=0

# Is this linter named in SKIP_SETS?
is_skipped() {
	for _s in $SKIP_SETS; do
		[ "$_s" = "$1" ] && return 0
	done
	return 1
}

# Run one fixture and check both halves of what its name promises.
run_case() {
	_linter=$1
	_target=$2
	_name=$(basename "$_target")
	_name=${_name%.md}
	_expect=${_target%.md}.expect

	case "$_name" in
		good*) _want=0 ;;
		bad-*) _want=1 ;;
		*)     return 0 ;;   # the caller has already vetted the name
	esac

	_out=$(sh "$_linter" "$_target" 2>&1)
	_got=$?

	if [ "$_got" -ne "$_want" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s on %s: exit %d, expected %d\n' \
			"$(basename "$_linter")" "$_target" "$_got" "$_want" >&2
		return 0
	fi

	# A good* fixture is finished: it was accepted, which is the whole claim.
	if [ "$_want" -eq 0 ]; then
		pass=$((pass + 1))
		return 0
	fi

	# A bad-* fixture must be rejected for its OWN reason. Without this, deleting
	# the fixture's input files leaves a case that still "passes" — on "file not
	# found" rather than on the rule the fixture is named for.
	if [ ! -f "$_expect" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s: no %s — a bad-* fixture must state the message it expects\n' \
			"$_target" "$(basename "$_expect")" >&2
		return 0
	fi

	if printf '%s\n' "$_out" | grep -qF -f "$_expect"; then
		pass=$((pass + 1))
	else
		fail=$((fail + 1))
		printf 'FAIL  %s was rejected, but not for its own reason\n' "$_target" >&2
		printf '      wanted a message containing: %s\n' "$(head -n1 "$_expect")" >&2
		printf '      got: %s\n' "$(printf '%s\n' "$_out" | head -n1)" >&2
	fi
}

# Walk one fixture root. Directories that hold a case are cases; so are files.
run_set() {
	_linter=$1
	_root=$2
	_ignore=${3:-}

	if is_skipped "$_linter"; then
		printf 'NOTE  %s skipped on purpose (SKIP_SETS)\n' "$_linter" >&2
		skipped=$((skipped + 1)); return 0
	fi

	# A missing linter is the largest possible linter regression. It was a NOTE
	# once; that let a renamed script pass the hook and this runner at the same
	# time.
	if [ ! -f "$_linter" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s is not present — name it in SKIP_SETS if that is deliberate\n' "$_linter" >&2
		return 0
	fi
	if [ ! -d "$_root" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s has no fixtures at %s — name it in SKIP_SETS if that is deliberate\n' \
			"$(basename "$_linter")" "$_root" >&2
		return 0
	fi

	_before=$((pass + fail))

	for _entry in "$_root"/*; do
		[ -e "$_entry" ] || continue
		_base=$(basename "$_entry")

		# Not cases, and never were: the index README, the expectation files, and
		# whatever this row declares as shared input.
		case "$_base" in
			README.md|*.expect) continue ;;
		esac
		_is_ignored=0
		for _i in $_ignore; do
			[ "$_i" = "$_base" ] && _is_ignored=1
		done
		[ "$_is_ignored" -eq 1 ] && continue

		# Anything else must be a case. An entry that matches neither convention
		# used to be dropped in silence, so a renamed fixture stopped testing
		# anything and the count quietly fell.
		case "${_base%.md}" in
			good*|bad-*) run_case "$_linter" "$_entry" ;;
			*)
				fail=$((fail + 1))
				printf 'FAIL  %s matches neither good* nor bad-* — it would never run\n' "$_entry" >&2
				;;
		esac
	done

	# A fixture root that contributes nothing is a broken walk, not a clean set.
	if [ "$((pass + fail))" -eq "$_before" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s yielded no cases at all — the walk is broken, not the linter\n' "$_root" >&2
	fi
}

# --- the manifest ----------------------------------------------------------
# One row per linter: the script, the directory holding its fixtures, and any
# entry in that directory which is shared input rather than a case.
run_set docs/adr/adr-lint.sh       docs/adr/tests
run_set docs/prd/prd-lint.sh       docs/prd/tests          facts
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
	[ "$skipped" -gt 0 ] && printf ', %d set(s) skipped on purpose' "$skipped"
	printf ')\n'
	exit 0
fi

printf 'discipline-tests: %d of %d cases failed\n' "$fail" "$((pass + fail))" >&2
exit 1
