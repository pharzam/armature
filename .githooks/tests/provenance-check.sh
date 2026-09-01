#!/bin/sh
#
# provenance-check.sh — prove the pre-commit hook's provenance check (block 0)
# accepts a correct install and refuses the fault, in a throwaway repository with
# a real git worktree.
#
# WHY THIS IS NOT A FIXTURE. Every other check in this kit is tested by pointing a
# linter at a directory of files and asserting an exit code. This one cannot be:
# the thing under test is *which hook file git chose to run*, which depends on
# `core.hooksPath` and on being inside a real worktree. There is no directory of
# text that reproduces it. So this builds a repository, adds a worktree, and drives
# real commits under each setting worth distinguishing. It reports how many cases it
# ran rather than carrying a count in this header, where the count goes stale the
# first time a case is added -- which is exactly what happened to it once already.
#
# It creates its work in a fresh `mktemp -d` and removes it afterwards. It never
# touches the repository it lives in, and it never reads or writes your git config.
#
# WHY IT IS NOT WIRED INTO THE GATE. It needs `git init`, a writable temp
# directory and real commits — far past the "reads only text, needs no
# toolchain" bar every check in docs/tests/run-discipline-tests.sh meets. Running
# it in the pre-commit hook would put a repository-creating test inside the commit
# path. Run it by hand when block 0 changes, the way docs/links/tests/expect-check.sh
# is run when that suite changes.
#
# Usage:  sh .githooks/tests/provenance-check.sh
# Exit status: 0 = every case behaved, 1 = one or more did not.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
hook="$script_dir/../pre-commit"
[ -f "$hook" ] || { printf 'FAIL  cannot find the hook at %s\n' "$hook" >&2; exit 1; }

base=$(mktemp -d) || { printf 'FAIL  mktemp -d failed\n' >&2; exit 1; }
bad=0
seen=0

cleanup() { cd / || :; rm -rf "$base"; }
trap cleanup EXIT

cd "$base" || exit 1
git init -q main || exit 1
cd main || exit 1
git config user.email provenance@test.invalid
git config user.name 'provenance test'
mkdir -p .githooks

# Take only block 0 from the real hook — everything from "# 1." onward runs the
# kit's linters, which have nothing to do with this test and would fail in a repo
# that holds none of the kit's files.
awk '/^# 1\. ADR discipline/{exit} {print}' "$hook" > .githooks/pre-commit
# The marker proves the hook RAN. Without it, "git found no hook to run" and "the
# hook ran and passed" are the same observation, and a case whose hooks path holds
# no hook would silently assert nothing -- the false green this kit keeps meeting.
{ echo 'echo PROVENANCE-RAN'; echo 'exit 0'; } >> .githooks/pre-commit
if ! grep -q 'hook provenance' .githooks/pre-commit; then
	printf 'FAIL  extraction produced no provenance check -- has block 0 moved, or step 1 been renamed?\n' >&2
	exit 1
fi
chmod +x .githooks/pre-commit

echo a > a.txt
git add -A
git config core.hooksPath .githooks
git commit -q -m init >/dev/null 2>&1

git worktree add -q ../wt -b feature || exit 1
# A foreign hooks dir reachable by a RELATIVE path. It must hold a real hook: git
# runs nothing when the path holds no hook, and "no hook ran" is indistinguishable
# from "the hook passed" — which would make this case test nothing.
mkdir -p "$base/foreign"
cp .githooks/pre-commit "$base/foreign/pre-commit"
chmod +x "$base/foreign/pre-commit"
cd ../wt || exit 1
mkdir -p .githooks

# case CONFIG_VALUE EXPECT(pass|refuse) LABEL
case_run() {
	git config core.hooksPath "$1"
	seen=$((seen + 1))
	_f="probe-$3.txt"
	echo probe > "$_f"
	git add -A
	# Capture the STATUS as well as the output. Classifying on text alone lets a
	# hook that prints a refusal and then exits 0 read as "refused" while the commit
	# actually succeeded -- the case would report ok having proved nothing. The
	# status and the wording must agree, or the verdict is `contradictory`.
	_out=$(git commit -q -m "$3" 2>&1) && _st=0 || _st=$?
	if printf '%s\n' "$_out" | grep -q 'hook provenance'; then
		if [ "$_st" -ne 0 ]; then _got=refuse; else _got=contradictory-printed-refusal-but-committed; fi
	elif printf '%s\n' "$_out" | grep -q 'PROVENANCE-RAN'; then
		if [ "$_st" -eq 0 ]; then _got=pass; else _got=contradictory-ran-but-commit-failed; fi
	elif [ "$_st" -eq 0 ]; then
		_got=no-hook-ran
	else
		# The commit failed and the hook said nothing recognisable. That is not the
		# same as no hook running, and calling it that would misname the cause the
		# way a refusal blaming an unset setting did.
		_got=hook-failed-silently
	fi
	if [ "$_got" = "$2" ]; then
		printf 'ok    %s (%s)\n' "$3" "$_got"
	else
		printf 'FAIL  %s: wanted %s, got %s\n' "$3" "$2" "$_got" >&2
		bad=1
	fi
}

case_run '.githooks'            pass   relative-in-worktree
case_run "$base/main/.githooks" refuse absolute-foreign-checkout
case_run "$base/wt/.githooks"   pass   absolute-inside-this-worktree
# A RELATIVE value escapes just as surely as an absolute one. The first version of
# this check branched on absolute-vs-relative and treated every relative value as
# safe, so this case passed silently -- a false negative in a check whose whole
# claim is "hooks outside the working tree".
case_run '../foreign'           refuse relative-escaping-worktree
case_run '.githooks/../.githooks' pass relative-with-dotdot-staying-inside

# The classic install -- a hook copied into .git/hooks, core.hooksPath never set --
# is the SAME fault by another route: a linked worktree reaches .git/hooks through
# the shared common git directory, so a check added on the branch does not run here
# either. Block 0 must refuse it AND must not blame a setting the operator never set:
# `git config core.hooksPath` prints nothing, so a message naming it sends them off to
# read an empty value. This case asserts the WORDING, not only the refusal, because a
# refusal that misnames its cause is the honest-reporting failure this check exists
# to prevent.
git config --unset core.hooksPath || :
mkdir -p "$base/main/.git/hooks"
cp "$base/main/.githooks/pre-commit" "$base/main/.git/hooks/pre-commit"
chmod +x "$base/main/.git/hooks/pre-commit"
echo probe > probe-hookspath-unset.txt
git add -A
_out=$(git commit -q -m hookspath-unset 2>&1) && _st=0 || _st=$?
seen=$((seen + 1))
if [ "$_st" -eq 0 ]; then
	printf 'FAIL  hookspath-unset-in-worktree: the commit SUCCEEDED; whatever the hook printed, it did not refuse\n' >&2
	bad=1
elif printf '%s\n' "$_out" | grep -q 'core.hooksPath is unset'; then
	printf 'ok    hookspath-unset-in-worktree (refuse, and names the real source)\n'
elif printf '%s\n' "$_out" | grep -q 'hook provenance'; then
	printf 'FAIL  hookspath-unset-in-worktree: refused, but blamed core.hooksPath, which is unset\n' >&2
	bad=1
elif printf '%s\n' "$_out" | grep -q 'PROVENANCE-RAN'; then
	printf 'FAIL  hookspath-unset-in-worktree: wanted refuse, got pass\n' >&2
	bad=1
else
	printf 'FAIL  hookspath-unset-in-worktree: wanted refuse, got no-hook-ran\n' >&2
	bad=1
fi

# Block 0 must survive being run where git can tell it nothing. This runs the whole
# hook outside any repository: `git rev-parse` fails, so `_hooks` is empty and block
# 0 skips, and the linters below it are skipped by their own `if [ -f ]` guards.
#
# Say plainly what this does NOT cover: the `cd`-failure path, where a path exists
# for git but cannot be entered. Under `set -e` an assignment inherits its command
# substitution's status, so a failing `cd` killed the hook with a bare exit before
# reaching the branch written to explain that very case. That is fixed with `|| :`
# inside each substitution and verified by a direct shell test, NOT by a case here --
# contorting git into producing an unresolvable toplevel is not worth the fixture.
outside=$(mktemp -d)
cp .githooks/pre-commit "$outside/blk0"
if ( cd "$outside" && GIT_CEILING_DIRECTORIES="$outside" sh ./blk0 >/dev/null 2>&1 ); then
	printf 'ok    outside-a-repository (clean exit)\n'
else
	printf 'FAIL  outside-a-repository: block 0 exited non-zero where git can tell it nothing\n' >&2
	bad=1
fi
seen=$((seen + 1))
rm -rf "$outside"

if [ "$seen" -eq 0 ]; then
	printf 'FAIL  no case ran -- this proved nothing\n' >&2
	exit 1
fi
if [ "$bad" -eq 0 ]; then
	printf 'provenance-check: OK  %d cases behaved\n' "$seen"
	exit 0
fi
exit 1
