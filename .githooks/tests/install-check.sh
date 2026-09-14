#!/bin/sh
#
# install-check.sh — behaviour test for .githooks/install.sh.
#
# Like its sibling provenance-check.sh, this is HAND-RUN and is NOT wired into
# docs/tests/run-discipline-tests.sh: it builds throwaway git repositories and runs
# real `git` commands, which is past the "reads only text, needs no toolchain" bar
# every auto-dispatched check meets. Run it by hand when install.sh changes:
#
#   sh .githooks/tests/install-check.sh
#
set -u

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
install="$script_dir/../install.sh"
fail=0

if [ ! -f "$install" ]; then
	printf 'FAIL  install.sh not found at %s\n' "$install" >&2
	exit 1
fi

# Case 1 — a fresh repo with a .githooks/ directory: core.hooksPath becomes .githooks.
repo=$(mktemp -d)
( cd "$repo" && git init -q && mkdir .githooks && sh "$install" >/dev/null 2>&1 )
val=$(cd "$repo" && git config core.hooksPath 2>/dev/null || true)
if [ "$val" = ".githooks" ]; then
	printf 'ok    sets core.hooksPath to the relative .githooks\n'
else
	printf 'FAIL  expected core.hooksPath=.githooks, got "%s"\n' "$val" >&2
	fail=1
fi

# Case 2 — idempotent: a second run exits 0 and leaves the same value.
( cd "$repo" && sh "$install" >/dev/null 2>&1 ); rc=$?
val2=$(cd "$repo" && git config core.hooksPath 2>/dev/null || true)
if [ "$rc" -eq 0 ] && [ "$val2" = ".githooks" ]; then
	printf 'ok    idempotent on a second run\n'
else
	printf 'FAIL  second run rc=%s value="%s"\n' "$rc" "$val2" >&2
	fail=1
fi

# Case 3 — no git repository at all (git rev-parse fails outright): refuse.
nonrepo=$(mktemp -d)
( cd "$nonrepo" && sh "$install" >/dev/null 2>&1 ); rc=$?
if [ "$rc" -ne 0 ]; then
	printf 'ok    refuses with no git repository (exit %s)\n' "$rc"
else
	printf 'FAIL  did not refuse with no git repository\n' >&2
	fail=1
fi

# Case 4 — a bare repository (inside a git dir but with no work tree):
# `git rev-parse --is-inside-work-tree` prints "false" yet exits 0, so refuse.
bare=$(mktemp -d)
( cd "$bare" && git init -q --bare && sh "$install" >/dev/null 2>&1 ); rc=$?
if [ "$rc" -ne 0 ]; then
	printf 'ok    refuses in a bare repository (no work tree, exit %s)\n' "$rc"
else
	printf 'FAIL  did not refuse in a bare repository\n' >&2
	fail=1
fi

rm -rf "$repo" "$nonrepo" "$bare"

if [ "$fail" -eq 0 ]; then
	printf 'install-check: OK\n'
else
	printf 'install-check: FAILED\n' >&2
fi
exit "$fail"
