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
#
# EACH SCENARIO NAMES A FIXTURE FROM THE RUNNER'S MANIFEST. Armature is a
# template, and an adopter who keeps no PRD practice deletes docs/prd/ and its
# manifest row — which the runner explicitly invites. A scenario whose target no
# longer exists is reported as "not applicable" rather than as a failure, because
# a red meta-gate on a correctly adapted kit teaches an adopter to switch the
# gate off. If you remove a linter, the scenarios that used it will say so.

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
noted=0
step=0
total=22

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
	_name=$1; _dir=$2; _want=$3; _msg=${4:-}; _needs=${5:-}
	step=$((step + 1))
	printf '  [%d/%d] %s\n' "$step" "$total" "$_name" >&2

	# This adoption does not have the thing the scenario mutates. Not a failure —
	# see "EACH SCENARIO NAMES A FIXTURE FROM THE RUNNER'S MANIFEST" above.
	#
	# Asked of the REPOSITORY, not of "$_dir": the scenario has already applied its
	# mutation to the copy, and several mutations are deletions, so asking the copy
	# would report every such scenario as not applicable and skip it.
	if [ -n "$_needs" ] && [ ! -e "$repo_root/$_needs" ] && [ ! -L "$repo_root/$_needs" ]; then
		noted=$((noted + 1))
		printf 'NOTE  %s: this adoption has no %s — not applicable\n' "$_name" "$_needs" >&2
		return 0
	fi

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
	"is an empty bad-* directory" docs/tasks/tests/bad-dup-id

# --- scenario 3: a linter is deleted ----------------------------------------
d=$(fresh_copy missing-linter)
rm -f "$d/docs/glossary-lint.sh"
check "a linter script that is gone" "$d" reject \
	"docs/glossary-lint.sh is not present" docs/glossary-lint.sh

# --- scenario 4: a whole fixture root is deleted ----------------------------
d=$(fresh_copy missing-fixture-root)
rm -rf "$d/docs/prd/tests"
check "a fixture root that is gone" "$d" reject \
	"has no fixtures at docs/prd/tests" docs/prd/tests

# --- scenario 5: a fixture is renamed out of the convention -----------------
d=$(fresh_copy renamed-fixture)
mv "$d/docs/adr/tests/bad-status" "$d/docs/adr/tests/bad_status"
check "a fixture renamed out of the good*/bad-* convention" "$d" reject \
	"matches neither good* nor bad-*" docs/adr/tests/bad-status

# --- scenario 6: a fixture renamed to a dotfile -----------------------------
# The glob `"$root"/*` never matches a dotfile, so this one disappeared in
# silence and the case count simply fell.
d=$(fresh_copy dotfile-fixture)
mv "$d/docs/adr/tests/bad-status" "$d/docs/adr/tests/.bad-status"
check "a fixture renamed to a dotfile" "$d" reject \
	"matches neither good* nor bad-*" docs/adr/tests/bad-status

# --- scenario 7: a fixture replaced by a broken symlink ---------------------
d=$(fresh_copy broken-symlink)
rm -rf "$d/docs/adr/tests/bad-status"
ln -s /nonexistent-target "$d/docs/adr/tests/bad-status"
check "a fixture replaced by a broken symlink" "$d" reject \
	"ADR directory not found: docs/adr/tests/bad-status" docs/adr/tests/bad-status

# --- scenario 8: a fixture is deleted outright ------------------------------
# Nothing in the walk can see a deletion: the entry is simply not in the glob.
# The orphaned .expect beside it, and the pinned case count, are what catch it.
d=$(fresh_copy deleted-fixture)
rm -rf "$d/docs/adr/tests/bad-status"
check "a bad-* fixture deleted outright" "$d" reject \
	"has no fixture beside it" docs/adr/tests/bad-status.expect

# --- scenario 9: every good* fixture deleted --------------------------------
# A linter is two claims — it rejects what is wrong AND accepts what is right.
# Deleting the accept half used to leave a green.
d=$(fresh_copy no-good-fixtures)
rm -rf "$d"/docs/adr/tests/good "$d"/docs/prd/tests/good "$d"/docs/tasks/tests/good \
	"$d"/docs/tests/glossary-lint/good
rm -f "$d"/docs/ci/tests/pr-link/good-*.md
check "every good* fixture deleted" "$d" reject \
	"nothing checks that the linter accepts valid input" docs/adr/tests/good

# --- scenario 10: an empty bad-* directory ----------------------------------
# Given an .expect quoting the linter's "cannot open input" message, this used to
# be scored as a passing case — and the count went UP.
d=$(fresh_copy empty-bad-fixture)
mkdir -p "$d/docs/adr/tests/bad-empty-dir"
printf 'missing docs/adr/tests/bad-empty-dir/README.md\n' > "$d/docs/adr/tests/bad-empty-dir.expect"
check "an empty bad-* directory with a crafted expectation" "$d" reject \
	"is an empty bad-* directory" docs/adr/tests

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
	"must hold exactly one non-blank line" docs/adr/tests/bad-status.expect

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

# --- scenario 13: an .expect that names a message no linter emits -----------
# THE headline capability of this change, and until now nothing tested it. With
# the comparison neutered, all twelve earlier scenarios stayed green while every
# .expect named a message that never appears.
d=$(fresh_copy wrong-message-expect)
printf 'THIS-MESSAGE-NEVER-APPEARS-ANYWHERE\n' > "$d/docs/adr/tests/bad-status.expect"
check "an .expect naming a message no linter emits" "$d" reject \
	"was rejected, but not for its own reason" docs/adr/tests/bad-status.expect

# --- scenario 14: an .expect deleted, the fixture left intact ---------------
d=$(fresh_copy missing-expect)
rm -f "$d/docs/adr/tests/bad-status.expect"
check "a bad-* fixture whose .expect is deleted" "$d" reject \
	"a bad-* fixture must state the message it expects" docs/adr/tests/bad-status.expect

# --- scenario 15: a linter that rejects valid input -------------------------
# The exit-status half of the contract. Neutering the comparison used to leave
# every scenario green while a linter failed everything put to it.
d=$(fresh_copy linter-rejects-good)
cp "$d/docs/adr/adr-lint.sh" "$d/docs/adr/real-adr-lint.sh"
printf '#!/bin/sh\nsh docs/adr/real-adr-lint.sh "$@" >/dev/null 2>&1\nexit 1\n' > "$d/docs/adr/adr-lint.sh"
check "a linter that rejects valid input" "$d" reject \
	"exit 1, expected 0" docs/adr/adr-lint.sh

# --- scenario 16: every bad-* fixture in a set deleted ----------------------
d=$(fresh_copy no-bad-fixtures)
rm -rf "$d"/docs/tests/glossary-lint/bad-*
check "every bad-* fixture in a set deleted" "$d" reject \
	"has no bad-* fixture" docs/tests/glossary-lint

# --- scenario 17: a case added, so a count goes UP --------------------------
# The pinned counts are the guarantee that covers mechanisms nobody thought of,
# and they were the least-covered lines in the runner.
d=$(fresh_copy extra-fixture)
cp -R "$d/docs/adr/tests/good" "$d/docs/adr/tests/good-2"
check "an extra fixture that makes a count go up" "$d" reject \
	"holds 2 good* fixtures, expected 1" docs/adr/tests/good

# --- scenario 19: a bad-* fixture deleted WITH its .expect ------------------
# The orphan loop has nothing to find and both floors are satisfied, so the
# pinned bad-* count is the only guard left — and nothing tested it.
d=$(fresh_copy deleted-with-expect)
rm -rf "$d/docs/adr/tests/bad-numbering" "$d/docs/adr/tests/bad-numbering.expect"
check "a bad-* fixture deleted together with its .expect" "$d" reject \
	"holds 4 bad-* fixtures, expected 5" docs/adr/tests/bad-numbering

# --- scenario 20: a one-character .expect -----------------------------------
d=$(fresh_copy short-expect)
printf 'a\n' > "$d/docs/adr/tests/bad-status.expect"
check "an .expect too short to be evidence" "$d" reject \
	"must hold exactly one non-blank line of at least 8 characters" \
	docs/adr/tests/bad-status.expect

# --- scenario 21: an .expect quoting a "cannot read the input" message ------
# The regression test for the sharpest defect in this whole change: an .expect
# naming a message the linter also gives for a missing file passes every other
# guard, and the rule it names can then be deleted from the linter entirely.
d=$(fresh_copy cannot-read-expect)
printf '(the ADR index)\n' > "$d/docs/adr/tests/bad-status.expect"
rm -f "$d/docs/adr/tests/bad-status/README.md"
check "an .expect quoting a cannot-read-the-input message" "$d" reject \
	"names a message this linter also gives when it cannot read its input" \
	docs/adr/tests/bad-status.expect

# --- scenario 22: the manifest ignoring a real fixture ----------------------
d=$(fresh_copy ignore-a-fixture)
python3 - "$d/docs/tests/discipline-tests.sh" <<'EOF' 2>/dev/null || \
	sed -i.bak "s|run_set docs/adr/adr-lint.sh       docs/adr/tests           ''      1 5|run_set docs/adr/adr-lint.sh       docs/adr/tests           'bad-numbering'      1 4|" "$d/docs/tests/discipline-tests.sh"
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("run_set docs/adr/adr-lint.sh       docs/adr/tests           ''      1 5",
              "run_set docs/adr/adr-lint.sh       docs/adr/tests           'bad-numbering'      1 4", 1)
open(p, "w").write(s)
EOF
check "the manifest ignoring a real fixture" "$d" reject \
	"which is a fixture name" docs/adr/tests/bad-numbering

# --- scenario 18: SKIP_SETS naming every linter -----------------------------
# An adopter cannot opt out of the whole gate and still get a green.
d=$(fresh_copy skip-everything)
step=$((step + 1))
printf '  [%d/%d] SKIP_SETS naming every linter\n' "$step" "$total" >&2
# Read the linters out of the manifest rather than repeating them here: with
# literals this scenario went red for any adopter who dropped any linter, because
# SKIP_SETS then named something the manifest did not have.
_all_linters=$(grep '^run_set ' "$d/docs/tests/discipline-tests.sh" | awk '{print $2}' | tr '\n' ' ')
if SKIP_SETS="$_all_linters" \
	sh "$d/docs/tests/discipline-tests.sh" "$d" >"$tmp/out" 2>"$tmp/err"; then
	fail=$((fail + 1))
	printf 'FAIL  SKIP_SETS naming every linter: the runner reported a pass\n' >&2
elif grep -qF -e 'no fixture cases ran at all' "$tmp/out" "$tmp/err"; then
	pass=$((pass + 1))
else
	fail=$((fail + 1))
	printf 'FAIL  SKIP_SETS naming every linter: rejected, but not for that reason\n' >&2
	printf '      got: %s\n' "$(cat "$tmp/out" "$tmp/err" | tr '\n' ' ')" >&2
fi

# --- report ------------------------------------------------------------------
if [ "$((pass + fail))" -eq 0 ]; then
	printf 'FAIL  no scenarios ran at all — this self-test is broken\n' >&2
	exit 1
fi

if [ "$fail" -eq 0 ]; then
	printf 'runner-selftest: OK (%d scenarios' "$pass"
	[ "$noted" -gt 0 ] && printf ', %d not applicable to this adoption' "$noted"
	printf ')\n'
	# A "not applicable" is legitimate for an adopter who dropped a linter, and a
	# silent hole for anyone else: a typo in a scenario's requirement would turn it
	# into a permanent NOTE with a green exit. The kit ships all five linters, so
	# any skip here is a defect in this file.
	if [ "$noted" -gt 0 ] && [ -f "$repo_root/docs/glossary-lint.sh" ] \
		&& [ -f "$repo_root/docs/prd/prd-lint.sh" ] && [ -f "$repo_root/docs/adr/adr-lint.sh" ]; then
		printf 'FAIL  %d scenario(s) were skipped on a complete kit — a requirement names the wrong path\n' \
			"$noted" >&2
		exit 1
	fi
	exit 0
fi

printf 'runner-selftest: %d of %d scenarios failed\n' "$fail" "$((pass + fail))" >&2
exit 1
