#!/bin/sh
#
# runner-selftest.sh — test the thing that tests the tests.
#
# THE GAP THIS CLOSES. docs/tests/discipline-tests.sh calls itself "the gate for
# the gate", and it shipped with no tests of its own. Review rounds then found
# several ways it reported OK while covering less than it claimed. Each way is a
# scenario below: the tree is mutated on a copy, and the runner must reject it.
#
# EVERY SCENARIO ASSERTS THE MESSAGE, NOT ONLY THE EXIT STATUS. The first draft
# of this file checked "the runner exited non-zero", which is the very defect it
# was written to catch, one level up: a scenario could pass because the mutation
# broke something unrelated. A review round demonstrated exactly that — one
# environment change made six of seven scenarios pass for the wrong reason at
# once. So each scenario names the message the runner must produce.
#
# THE CONTROL COMES FIRST, AND A CONTROL FAILURE ABORTS THE RUN. If an unmutated
# tree does not pass, every "must reject" scenario after it is meaningless — they
# would all be rejected for the contaminating reason rather than the mutation.
# Reporting "1 of 7 failed" in that state tells the reader six things were
# covered when nothing was.
#
# Usage:  sh docs/tests/runner-selftest.sh [REPO_ROOT]
#   REPO_ROOT defaults to two directories above this script.
#
# Exit status: 0 = the runner behaved on every scenario, 1 = it did not.
#
# How to adapt: add a scenario whenever you find another way the runner could
# report a pass it did not earn. A scenario is a mutation, the expectation
# (reject/accept), and the message that must appear.

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
step=0
total=12

# Make a fresh copy of the tree the runner needs, and echo its path.
#
# The copy is a git repository with everything staged, because glossary-lint
# reads its file list from `git ls-files` — in a copy with no index it fails on
# every scenario, which would make every "must reject" case pass for the wrong
# reason.
#
# The copy is HERMETIC. The caller's git environment and the developer's global
# git configuration are both cleared: a global core.excludesFile matching
# anything under docs/ would leave fixtures untracked, and an exported GIT_DIR
# would make `git init` act on the wrong repository. Both were demonstrated by a
# review round to produce a red CI run on a tree that violates nothing. Failures
# of cp/init/add are checked, not discarded.
fresh_copy() {
	_dir=$tmp/$1
	rm -rf "$_dir"
	mkdir -p "$_dir" || return 1
	cp -R "$repo_root/docs" "$_dir/docs" || return 1
	(
		cd "$_dir" || exit 1
		unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY
		GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
		export GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM
		git init -q . && git add -A
	) >/dev/null 2>&1 || return 1
	printf '%s\n' "$_dir"
}

# check <name> <copy dir> <reject|accept> [message the runner must print]
#
# Each scenario copies a tree and runs the whole linter suite over it, so the
# whole run takes about ten seconds. Gate step 4 says anything that can run that
# long shows which step it is on, so each scenario announces itself first.
check() {
	_name=$1; _dir=$2; _want=$3; _msg=${4:-}
	step=$((step + 1))
	printf '  [%d/%d] %s\n' "$step" "$total" "$_name" >&2

	sh "$_dir/docs/tests/discipline-tests.sh" "$_dir" >"$tmp/out" 2>"$tmp/err"
	_got=$?
	_all=$(cat "$tmp/out" "$tmp/err")

	if [ "$_want" = accept ]; then
		if [ "$_got" -eq 0 ]; then
			pass=$((pass + 1))
		else
			fail=$((fail + 1))
			printf 'FAIL  %s: the runner rejected a tree that violates nothing\n' "$_name" >&2
			printf '      it said: %s\n' "$(printf '%s' "$_all" | tr '\n' ' ')" >&2
		fi
		return 0
	fi

	if [ "$_got" -eq 0 ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s: the runner reported a pass on a tree it must reject\n' "$_name" >&2
		printf '      it said: %s\n' "$(printf '%s' "$_all" | tr '\n' ' ')" >&2
		return 0
	fi

	# Rejected — but for the right reason? Any breakage makes the runner exit
	# non-zero, so without this a scenario proves nothing about its own mutation.
	if [ -n "$_msg" ] && ! printf '%s\n' "$_all" | grep -qF -e "$_msg"; then
		fail=$((fail + 1))
		printf 'FAIL  %s: rejected, but not for the reason this scenario tests\n' "$_name" >&2
		printf '      wanted a message containing: %s\n' "$_msg" >&2
		printf '      got: %s\n' "$(printf '%s' "$_all" | tr '\n' ' ')" >&2
		return 0
	fi
	pass=$((pass + 1))
}

# --- scenario 1: the control ------------------------------------------------
d=$(fresh_copy control) || { printf 'FAIL  cannot build a copy of the tree\n' >&2; exit 1; }
check "control (unmutated tree)" "$d" accept
if [ "$fail" -ne 0 ]; then
	printf 'FAIL  the control failed, so every later scenario would be meaningless — aborting\n' >&2
	printf 'runner-selftest: aborted after the control\n' >&2
	exit 1
fi

# --- scenario 2: a fixture's contents are deleted ---------------------------
d=$(fresh_copy gutted-fixture)
rm -f "$d"/docs/tasks/tests/bad-dup-id/*.md
check "a bad-* fixture whose input files are deleted" "$d" reject \
	"is an empty bad-* directory"

# --- scenario 3: a linter is deleted ----------------------------------------
d=$(fresh_copy missing-linter)
rm -f "$d/docs/glossary-lint.sh"
check "a linter script that is gone" "$d" reject \
	"docs/glossary-lint.sh is not present"

# --- scenario 4: a whole fixture root is deleted ----------------------------
d=$(fresh_copy missing-fixture-root)
rm -rf "$d/docs/prd/tests"
check "a fixture root that is gone" "$d" reject \
	"has no fixtures at docs/prd/tests"

# --- scenario 5: a fixture is renamed out of the convention -----------------
d=$(fresh_copy renamed-fixture)
mv "$d/docs/adr/tests/bad-status" "$d/docs/adr/tests/bad_status"
check "a fixture renamed out of the good*/bad-* convention" "$d" reject \
	"matches neither good* nor bad-*"

# --- scenario 6: a fixture renamed to a dotfile -----------------------------
# The glob `"$root"/*` never matches a dotfile, so this one disappeared in
# silence and the case count simply fell.
d=$(fresh_copy dotfile-fixture)
mv "$d/docs/adr/tests/bad-status" "$d/docs/adr/tests/.bad-status"
check "a fixture renamed to a dotfile" "$d" reject \
	"matches neither good* nor bad-*"

# --- scenario 7: a fixture replaced by a broken symlink ---------------------
d=$(fresh_copy broken-symlink)
rm -rf "$d/docs/adr/tests/bad-status"
ln -s /nonexistent-target "$d/docs/adr/tests/bad-status"
check "a fixture replaced by a broken symlink" "$d" reject \
	"docs/adr/tests"

# --- scenario 8: a fixture is deleted outright ------------------------------
# Nothing in the walk can see a deletion: the entry is simply not in the glob.
# The orphaned .expect beside it, and the pinned case count, are what catch it.
d=$(fresh_copy deleted-fixture)
rm -rf "$d/docs/adr/tests/bad-status"
check "a bad-* fixture deleted outright" "$d" reject \
	"has no fixture beside it"

# --- scenario 9: every good* fixture deleted --------------------------------
# A linter is two claims — it rejects what is wrong AND accepts what is right.
# Deleting the accept half used to leave a green.
d=$(fresh_copy no-good-fixtures)
rm -rf "$d"/docs/adr/tests/good "$d"/docs/prd/tests/good "$d"/docs/tasks/tests/good \
	"$d"/docs/tests/glossary-lint/good
rm -f "$d"/docs/ci/tests/pr-link/good-*.md
check "every good* fixture deleted" "$d" reject \
	"nothing checks that the linter accepts valid input"

# --- scenario 10: an empty bad-* directory ----------------------------------
# Given an .expect quoting the linter's "cannot open input" message, this used to
# be scored as a passing case — and the count went UP.
d=$(fresh_copy empty-bad-fixture)
mkdir -p "$d/docs/adr/tests/bad-empty-dir"
printf 'missing docs/adr/tests/bad-empty-dir/README.md\n' > "$d/docs/adr/tests/bad-empty-dir.expect"
check "an empty bad-* directory with a crafted expectation" "$d" reject \
	"is an empty bad-* directory"

# --- scenario 11: a blank line in an .expect file ---------------------------
# `grep -f` reads one pattern per line and an empty line matches everything, so
# one stray newline turned a fixture back into an exit-status-only check. This is
# the mutation that defeated the first version of the reason-assertion.
# The fixture is left INTACT on purpose. Gutting it as well would make the
# empty-directory check fire first, and this scenario would then pass without
# ever reaching the pattern validation it exists to test — which is how the
# message assertion earned its place: it caught that mistake in this very file.
d=$(fresh_copy blank-line-expect)
printf "Status 'Maybe' is not one of\n\n" > "$d/docs/adr/tests/bad-status.expect"
check "a blank line in an .expect file" "$d" reject \
	"must hold exactly one non-blank line"

# --- scenario 12: SKIP_SETS as a glob ---------------------------------------
# An unquoted expansion was pathname-expanded, so one plausible pattern skipped
# four of the five sets and still exited 0.
d=$(fresh_copy skipsets-glob)
if SKIP_SETS='docs/*/*-lint.sh' sh "$d/docs/tests/discipline-tests.sh" "$d" >"$tmp/out" 2>"$tmp/err"; then
	fail=$((fail + 1))
	step=$((step + 1))
	printf '  [%d/%d] SKIP_SETS given a glob\n' "$step" "$total" >&2
	printf 'FAIL  SKIP_SETS given a glob: the runner reported a pass\n' >&2
	printf '      it said: %s\n' "$(cat "$tmp/out" "$tmp/err" | tr '\n' ' ')" >&2
else
	pass=$((pass + 1))
	step=$((step + 1))
	printf '  [%d/%d] SKIP_SETS given a glob\n' "$step" "$total" >&2
fi

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
