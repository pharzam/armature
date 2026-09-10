#!/bin/sh
#
# install.sh — point this clone's git at the quality-gate hooks in .githooks/, so
# they run before every commit. Run once per clone; safe to re-run. Part of the
# quality gate: the hooks run only when core.hooksPath names them.
#
# It sets core.hooksPath to the RELATIVE path ".githooks", never an absolute one.
# Linked worktrees share .git/config, and a relative value resolves per working
# tree, so each worktree runs its own hooks — which the pre-commit provenance check
# requires (see docs/guardrails.md).
set -eu

# 1. Must run inside a git work tree.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "install.sh: not inside a git work tree — run it from a clone of this repository." >&2
	exit 1
fi

# 2. Work from the repository top, so the .githooks check below tests the root
#    whatever subdirectory the script was called from. (The stored value is a
#    literal string and does not depend on the current directory.)
cd "$(git rev-parse --show-toplevel)"

# 3. The hooks must be present to point at.
if [ ! -d .githooks ]; then
	echo "install.sh: no .githooks/ directory at the repository root — nothing to install." >&2
	exit 1
fi

# 4. Pin the relative path, never an absolute one. A plain set replaces the value,
#    so re-running is idempotent.
git config core.hooksPath .githooks

echo "install.sh: core.hooksPath set to '$(git config core.hooksPath)' — the hooks in .githooks/ now run on commit."
