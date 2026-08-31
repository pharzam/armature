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
# real commits under three settings.
#
# It creates its work in a fresh `mktemp -d` and removes it afterwards. It never
# touches the repository it lives in, and it never reads or writes your git config.
#
# WHY IT IS NOT WIRED INTO THE GATE. It needs `git init`, a writable temp
# directory and three real commits — far past the "reads only text, needs no
# toolchain" bar every check in docs/tests/run-discipline-tests.sh meets. Running
# it in the pre-commit hook would put a repository-creating test inside the commit
# path. Run it by hand when block 0 changes, the way docs/links/tests/expect-check.sh
# is run when that suite changes.
#
# Usage:  sh .githooks/tests/provenance-check.sh
# Exit status: 0 = all three cases behaved, 1 = one or more did not.

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
	_out=$(git commit -q -m "$3" 2>&1 || :)
	if printf '%s\n' "$_out" | grep -q 'hook provenance'; then
		_got=refuse
	elif printf '%s\n' "$_out" | grep -q 'PROVENANCE-RAN'; then
		_got=pass
	else
		_got=no-hook-ran
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

if [ "$seen" -eq 0 ]; then
	printf 'FAIL  no case ran -- this proved nothing\n' >&2
	exit 1
fi
if [ "$bad" -eq 0 ]; then
	printf 'provenance-check: OK  %d cases behaved\n' "$seen"
	exit 0
fi
exit 1
