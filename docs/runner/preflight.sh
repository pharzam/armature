#!/bin/sh
#
# preflight.sh — refuse to start a run when a precondition is missing, naming the
# one that is missing and the command that fixes it.
#
# A precondition checked where it is USED is discovered after the work that needed
# it is already spent. Issue #80 lost 1 h 40 m to a push rejected for a missing
# token scope, found only once the build was done. Checking the same thing first
# costs seconds and turns that stall into an immediate, named failure that a
# successor session can act on with no human message — R5, a deterministic check in
# place of discovering the fault the expensive way.
#
# It stops at the FIRST unmet precondition. Reporting all of them at once reads as
# more helpful and is not: a later check often fails only BECAUSE an earlier one
# did, so a list invites the operator to fix four things when one was wrong.
#
# It never prints a credential value. The forge tool's own output is read and
# never echoed; only scope NAMES, which are not secret, appear in a message.
#
# Order is cheapest-first, so the ten-second bound survives: repository-local
# configuration, then the filesystem, then the forge tool, then the one check that
# reaches the network. A run whose configuration is wrong never pays for a fetch.
#
# ADOPTER VALUES. Four values belong to the adopter, and none is guessed here.
# They are read from repository-local configuration, and an unset one IS an unmet
# precondition — reported with the command that sets it, rather than defaulted to
# something this kit invented:
#
#   armature.forgeCli      the forge command-line tool
#   armature.forgeScopes   the scopes the run needs, space-separated
#   armature.worktreeDir   the `‹worktree dir›` of docs/engineering-discipline.md
#   armature.baseRef       the branch a task branches off; defaults to origin/main,
#                          which the quality gate already fixes, so it is the one
#                          value this kit may supply
#
# THE FORGE TOOL CONTRACT. The configured tool must answer `auth status`: a
# non-zero exit means no authenticated account, and a `Token scopes:` line lists
# the scopes held. Both `gh` and `glab` behave this way. The output is read from
# standard output and standard error together, because the tools disagree about
# which one it goes to and have changed their minds between versions.
#
# Usage:  sh docs/runner/preflight.sh TASK [ROOT]
#   TASK  the task ID whose worktree the run will take, for example T-heh3
#   ROOT  the working tree to check; defaults to the one holding this script
# Exit status: 0 = every precondition met, 1 = one is unmet, 2 = bad usage.
#
# Its own cases are docs/runner/tests/preflight-cases.sh, run by
# docs/tests/run-discipline-tests.sh in the pre-commit hook and in CI. This script
# is NOT in that hook: it reaches a credential and the network, and the hook is the
# fast, offline gate.

set -u

# The working tree to check is an ARGUMENT, so an inherited GIT_DIR can only be
# wrong: git exports it to every hook it runs, and it silently redirects `git -C`
# at the repository that did the exporting. A pre-flight that reported on a
# different tree than the one it named would be worse than no pre-flight.
for _v in GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
	GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_PREFIX; do
	unset "$_v" 2>/dev/null || :
done
# Never block on a credential prompt: this check has a ten-second bound, and an
# unattended run has nobody to answer one.
GIT_TERMINAL_PROMPT=0
export GIT_TERMINAL_PROMPT

usage() {
	printf 'usage: sh docs/runner/preflight.sh TASK [ROOT]\n' >&2
	exit 2
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage
task=$1
case $task in
	''|-*) usage ;;
esac
root=${2:-}
if [ -z "$root" ]; then
	script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
	root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
fi

# refuse WHAT FIX — name the unmet precondition, then the one command that fixes
# it, then stop. Every refusal in this script goes through here, so none of them
# can forget the fix line.
refuse() {
	printf 'preflight: %s\n' "$1" >&2
	printf '           fix: %s\n' "$2" >&2
	exit 1
}

command -v git >/dev/null 2>&1 \
	|| refuse 'git is not on PATH, so no repository precondition can be read' \
	          'install git, or run this where git is on PATH'

top=$(git -C "$root" rev-parse --show-toplevel 2>/dev/null || :)
[ -n "$top" ] \
	|| refuse "not a working tree: $root" \
	          "run this inside the checkout, or pass the working tree as ROOT"

cfg() { git -C "$top" config "$1" 2>/dev/null || :; }

# --- 1. the hooks path is configured, and resolves inside THIS tree ---------
#
# Configured, not merely resolvable: with core.hooksPath unset git falls back to
# .git/hooks, which resolves inside a primary working tree and would pass — while
# a LINKED worktree reaches that same directory through the shared common git
# directory, so a check added on a branch would not run on that branch. Requiring
# the setting refuses both, and the pre-commit hook's provenance step refuses the
# rest at commit time.
hooks_cfg=$(cfg core.hooksPath)
[ -n "$hooks_cfg" ] \
	|| refuse 'core.hooksPath is not configured, so the quality gate would not run on this branch' \
	          'git config core.hooksPath .githooks'

# A relative value is resolved against the working tree, which is what makes the
# relative install correct per worktree. Resolve BOTH sides through `cd … && pwd -P`:
# git echoes the configured path back unresolved but resolves --show-toplevel, so a
# repository reached through a symlink would otherwise look foreign to itself.
# `pwd -P` is POSIX; `readlink -f` is not.
case $hooks_cfg in
	/*) hooks_cand=$hooks_cfg ;;
	*)  hooks_cand=$top/$hooks_cfg ;;
esac
hooks_res=$(CDPATH= cd -- "$hooks_cand" 2>/dev/null && pwd -P || :)
top_res=$(CDPATH= cd -- "$top" 2>/dev/null && pwd -P || :)
[ -n "$hooks_res" ] \
	|| refuse "core.hooksPath names $hooks_cfg, which is not a directory" \
	          'git config core.hooksPath .githooks'
case $hooks_res/ in
	"$top_res"/*) : ;;
	*) refuse "core.hooksPath resolves to $hooks_res, outside this working tree ($top_res)" \
	          'git config core.hooksPath .githooks' ;;
esac

# --- 2. the worktree directory is configured, writable, and free -----------
wt_cfg=$(cfg armature.worktreeDir)
[ -n "$wt_cfg" ] \
	|| refuse 'armature.worktreeDir is not configured, so the run has nowhere to isolate the task' \
	          'git config armature.worktreeDir <your ‹worktree dir›>'

case $wt_cfg in
	/*) wt_dir=$wt_cfg ;;
	*)  wt_dir=$top/$wt_cfg ;;
esac

# Absent is not a fault — the first run of a fresh clone creates it — but the
# parent must be writable, or it will fail at the point the run cannot recover.
if [ -d "$wt_dir" ]; then
	[ -w "$wt_dir" ] \
		|| refuse "the worktree directory $wt_dir is not writable" \
		          "chmod u+w $wt_dir"
else
	wt_parent=$(dirname -- "$wt_dir")
	[ -d "$wt_parent" ] && [ -w "$wt_parent" ] \
		|| refuse "the worktree directory $wt_dir does not exist and its parent is not writable" \
		          "mkdir -p $wt_dir"
fi

# "Not already in use" is a statement about THIS task's directory: two runs of one
# task would land in the same tree and overwrite each other's work.
wt_task=$wt_dir/$task
if [ -e "$wt_task" ]; then
	refuse "the worktree for $task is already in use: $wt_task" \
	       "finish or remove that run first: git worktree remove $wt_task"
fi

# --- 3. the forge tool, the credential, and the scopes ---------------------
forge=$(cfg armature.forgeCli)
[ -n "$forge" ] \
	|| refuse 'armature.forgeCli is not configured, so no forge credential can be checked' \
	          'git config armature.forgeCli <your forge command-line tool>'

command -v "$forge" >/dev/null 2>&1 \
	|| refuse "the configured forge tool ($forge) is not on PATH" \
	          "install $forge, or point armature.forgeCli at the tool you use"

scopes_want=$(cfg armature.forgeScopes)
[ -n "$scopes_want" ] \
	|| refuse 'armature.forgeScopes is not configured, so no scope can be checked' \
	          'git config armature.forgeScopes "<the scopes the run needs>"'

# Captured, never echoed: this output carries the token on the tools that print
# one. Only scope names reach a message below, and a scope name is not secret.
if ! auth_out=$("$forge" auth status 2>&1); then
	refuse "$forge reports no authenticated account" \
	       "$forge auth login"
fi

# One `Token scopes:` line, reduced to bare names. Quotes and commas are the
# tools' presentation, not part of a scope.
scopes_have=$(printf '%s\n' "$auth_out" \
	| sed -n 's/.*[Tt]oken scopes:[[:space:]]*//p' \
	| tr -d "'\"" | tr ',' ' ')

for want in $scopes_want; do
	found=0
	for have in $scopes_have; do
		[ "$want" = "$have" ] && { found=1; break; }
	done
	[ "$found" -eq 1 ] \
		|| refuse "the forge credential is missing scope: $want" \
		          "$forge auth refresh -s $want"
done

# --- 4. the base branch is fetchable (the one network check) ---------------
base_ref=$(cfg armature.baseRef)
[ -n "$base_ref" ] || base_ref=origin/main
base_remote=${base_ref%%/*}
base_branch=${base_ref#*/}
if [ "$base_remote" = "$base_ref" ] || [ -z "$base_branch" ]; then
	refuse "armature.baseRef ($base_ref) is not a <remote>/<branch> pair" \
	       'git config armature.baseRef origin/main'
fi

git -C "$top" ls-remote --exit-code --heads "$base_remote" "$base_branch" >/dev/null 2>&1 \
	|| refuse "the base branch $base_ref is not fetchable" \
	          "check the remote and the branch: git ls-remote --heads $base_remote $base_branch"

printf 'preflight: OK — %s may start in %s\n' "$task" "$wt_task"
