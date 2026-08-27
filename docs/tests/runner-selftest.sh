#!/bin/sh
#
# runner-selftest.sh — test the thing that tests the tests.
#
# THE GAP THIS CLOSES. docs/tests/discipline-tests.sh calls itself "the gate for
# the gate", and it shipped with no tests of its own. A gate-step-5 review round
# then found four ways it reports OK while covering less than it claims: a fixture
# whose contents are deleted still "passes" (the linter exits 1 for a missing
# file, not for the rule the fixture is named for), a deleted linter becomes a
# NOTE, a renamed fixture vanishes in silence, and an empty bad-* directory counts
# as a passing case. See issue #37.
#
# This script mutates a COPY of the repository in each of those ways and asserts
# that the runner rejects it. A runner that stays green under any of these
# mutations is not a gate.
#
# Usage:  sh docs/tests/runner-selftest.sh [REPO_ROOT]
#   REPO_ROOT defaults to two directories above this script.
#
# Exit status: 0 = the runner behaved on every scenario, 1 = it did not.
#
# How to adapt: add a scenario whenever you find another way the runner could
# report a pass it did not earn. Each scenario is a mutation plus the expectation
# that the runner FAILS on it.

set -u
LC_ALL=C
export LC_ALL

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=${1:-$(dirname "$(dirname "$script_dir")")}

if [ ! -f "$repo_root/docs/tests/discipline-tests.sh" ]; then
	printf 'FAIL  no runner at %s/docs/tests/discipline-tests.sh\n' "$repo_root" >&2
	exit 1
fi

tmp=$(mktemp -d) || { printf 'FAIL  cannot create a temp dir\n' >&2; exit 1; }
trap 'rm -rf "$tmp"' EXIT INT TERM

pass=0
fail=0

# Make a fresh copy of the tree the runner needs, and echo its path.
#
# The copy is a git repository with everything staged, because glossary-lint
# reads its file list from `git ls-files` — in a copy with no index it fails on
# every scenario, which would make every "must reject" case pass for the wrong
# reason. That is the exact defect this self-test exists to catch, and it caught
# it here first: the control scenario below is what makes the others mean
# anything.
fresh_copy() {
	_dir=$tmp/$1
	rm -rf "$_dir"
	mkdir -p "$_dir"
	cp -R "$repo_root/docs" "$_dir/docs"
	( cd "$_dir" \
		&& git init -q . \
		&& git add -A ) >/dev/null 2>&1
	printf '%s\n' "$_dir"
}

# Run the runner inside a copy. Echoes its exit status.
run_runner() {
	sh "$1/docs/tests/discipline-tests.sh" "$1" >"$tmp/out" 2>"$tmp/err"
	printf '%s\n' "$?"
}

# scenario <name> <copy dir> <want: reject|accept>
# The mutation has already been applied to the copy at $2.
#
# Each scenario copies a tree and runs the whole linter suite over it, so the
# whole run takes about ten seconds. Gate step 4 says anything that can run that
# long shows which step it is on and that it is still alive, so each scenario
# announces itself before it starts rather than after it finishes.
check() {
	_name=$1; _dir=$2; _want=$3
	total=${total:-7}
	step=$((${step:-0} + 1))
	printf '  [%d/%d] %s\n' "$step" "$total" "$_name" >&2
	_got=$(run_runner "$_dir")

	if [ "$_want" = reject ]; then
		if [ "$_got" -ne 0 ]; then
			pass=$((pass + 1))
		else
			fail=$((fail + 1))
			printf 'FAIL  %s: the runner reported a pass on a tree it must reject\n' "$_name" >&2
			printf '      it said: %s\n' "$(cat "$tmp/out" "$tmp/err" | tr '\n' ' ')" >&2
		fi
	else
		if [ "$_got" -eq 0 ]; then
			pass=$((pass + 1))
		else
			fail=$((fail + 1))
			printf 'FAIL  %s: the runner rejected a tree that violates nothing\n' "$_name" >&2
			printf '      it said: %s\n' "$(cat "$tmp/out" "$tmp/err" | tr '\n' ' ')" >&2
		fi
	fi
}

# --- scenario 0: the control ------------------------------------------------
# An unmutated copy must pass. Without this, every other scenario could be
# passing for the trivial reason that the runner is broken everywhere.
d=$(fresh_copy control)
check "control (unmutated tree)" "$d" accept

# --- scenario 1: a fixture's contents are deleted ---------------------------
# The directory stays, so the runner still counts a case. The linter exits 1
# because its input is missing — not because it caught the defect the fixture is
# named for. That is a pass the fixture did not earn.
d=$(fresh_copy gutted-fixture)
rm -f "$d"/docs/tasks/tests/bad-dup-id/*.md
check "a bad-* fixture whose input files are deleted" "$d" reject

# --- scenario 2: a linter is deleted ----------------------------------------
# The largest possible linter regression. It must never be a NOTE.
d=$(fresh_copy missing-linter)
rm -f "$d/docs/glossary-lint.sh"
check "a linter script that is gone" "$d" reject

# --- scenario 3: a whole fixture root is deleted ----------------------------
d=$(fresh_copy missing-fixture-root)
rm -rf "$d/docs/prd/tests"
check "a fixture root that is gone" "$d" reject

# --- scenario 4: a fixture is renamed out of the convention -----------------
# It matches neither good* nor bad-*, so it is never run. The case count falls
# and nothing says so.
d=$(fresh_copy renamed-fixture)
mv "$d/docs/adr/tests/bad-status" "$d/docs/adr/tests/bad_status"
check "a fixture renamed out of the good*/bad-* convention" "$d" reject

# --- scenario 5: an empty bad-* directory ------------------------------------
# The linter exits 1 because it cannot find its input, and the runner scores it
# as a rejection it never made.
d=$(fresh_copy empty-bad-fixture)
mkdir -p "$d/docs/adr/tests/bad-empty-dir"
check "an empty bad-* directory counted as a passing case" "$d" reject

# --- scenario 6: a linter stops catching what its fixture is named for -------
# The sharpest one. The linter still exists, the fixture still exists, and the
# linter still exits 1 — but for the wrong reason. Here the duplicate-id check is
# disabled, so bad-dup-id can only fail on something else.
d=$(fresh_copy wrong-reason)
sed 's/^	d=$(uniq -d < "$tmp\/backlog.ids")/	d=""/' \
	"$d/docs/tasks/backlog-lint.sh" > "$d/docs/tasks/backlog-lint.new" \
	&& mv "$d/docs/tasks/backlog-lint.new" "$d/docs/tasks/backlog-lint.sh"
check "a linter whose duplicate-id check is disabled" "$d" reject

# --- report ------------------------------------------------------------------
if [ "$((pass + fail))" -eq 0 ]; then
	printf 'FAIL  no scenarios ran at all — this self-test is broken\n' >&2
	exit 1
fi

if [ "$fail" -eq 0 ]; then
	printf 'runner-selftest: OK (%d scenarios)\n' "$pass"
	exit 0
fi

printf 'runner-selftest: %d of %d scenarios failed\n' "$fail" "$((pass + fail))" >&2
exit 1
