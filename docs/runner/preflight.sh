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
# EVERY REFUSAL CARRIES A CODE. `refuse` takes one and prints it on its own `code:`
# line. The codes, not the prose, are the stable contract the cases assert on; the
# header of docs/runner/tests/preflight-cases.sh records what that fixed.
#
# THE TEN-SECOND BOUND IS ENFORCED, NOT HOPED FOR. Round 1 measured this script
# running 44 s and printing nothing against a remote that never answers, so both
# steps that can reach the network run under a wall-clock cap (`run_bounded`). Two
# capped steps at the default 4 s keep the worst case inside ten;
# `GIT_TERMINAL_PROMPT=0` closes the prompt hang. Order is cheapest-first so a wrong
# configuration never PAYS for a fetch — a cost argument, not a correctness one.
#
# ADOPTER VALUES. Five `armature.*` keys are the adopter's, and none is guessed
# here: they are read from repository-local configuration, and an unset one IS an
# unmet precondition. docs/runner/README.md tabulates them with their defaults and
# records why configuration is the channel; issue #126 holds the alternatives that
# were rejected. An ADR falls due on the first change that makes a SECOND mechanism
# read that namespace.
#
# THE FORGE TOOL CONTRACT is in that README too, with the measurement of which
# tools meet it — `gh` does, `glab` does not. The part that matters at this line is
# that the output is read from standard output and standard error together, because
# forge tools disagree about which one it goes to between versions.
#
# THE HOST SELECTS THE ACCOUNT, and scope sets are never merged. Round 1 measured
# the first version taking a work account's `repo` and a personal account's
# `workflow` as though one token held both — #80's shape, passed by the check
# written to catch it. Round 2 then measured two activeness-keyed fixes each refusing
# a valid multi-host setup, because `gh` marks one account active PER HOST. The
# account is now the one whose host matches `origin`'s; see the README.
#
# Usage:  sh docs/runner/preflight.sh TASK [ROOT]
#   TASK  the task ID whose worktree the run will take, for example T-heh3
#   ROOT  the working tree to check; defaults to the one holding this script
# Exit status: 0 = every precondition met, 1 = one is unmet, 2 = bad usage.
#
# Its own cases are docs/runner/tests/preflight-cases.sh, which has its own CI job
# for the reason docs/runner/README.md gives. This script is NOT in the pre-commit
# hook and NOT in that suite's runner: it reaches a credential and the network.

set -u

# The working tree to check is an ARGUMENT, so an inherited GIT_DIR can only be
# wrong: git exports it to every hook it runs, and it silently redirects `git -C`
# at the repository that did the exporting. A pre-flight that reported on a
# different tree than the one it names would be worse than no pre-flight.
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

# refuse CODE WHAT FIX — name the unmet precondition, the machine-readable code
# for its class, and the one command that fixes it, then stop. Every refusal goes
# through here, so none can forget the fix line or the code.
refuse() {
	printf 'preflight: %s\n' "$2" >&2
	printf '           code: %s\n' "$1" >&2
	printf '           fix: %s\n' "$3" >&2
	exit 1
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

command -v git >/dev/null 2>&1 \
	|| refuse no-git 'git is not on PATH, so no repository precondition can be read' \
	          'install git, or run this where git is on PATH'

tmp=$(mktemp -d) || {
	printf 'preflight: cannot create a temporary directory\n' >&2; exit 1; }
trap 'rm -rf "$tmp"' EXIT
rb_flag=$tmp/timed-out
rb_out=$tmp/out

top=$(git -C "$root" rev-parse --show-toplevel 2>/dev/null || :)
[ -n "$top" ] \
	|| refuse not-a-worktree "not a working tree: $root" \
	          "run this inside the checkout, or pass the working tree as ROOT"

cfg() { git -C "$top" config "$1" 2>/dev/null || :; }

# run_bounded SECONDS COMMAND… — run COMMAND under a wall-clock cap, its combined
# output captured in $rb_out. Returns the command's own status, or 124 when the cap
# fired.
#
# POSIX has no `timeout`, so this is a watchdog: the command runs in the
# background and a second background shell kills it after SECONDS. The flag file is
# load-bearing — a killed command and a command that failed on its own both come
# back non-zero, and without the flag the refusal would name the wrong cause.
run_bounded() {
	_limit=$1; shift
	rm -f "$rb_flag"
	: > "$rb_out"
	"$@" > "$rb_out" 2>&1 &
	_cmd=$!
	{
		_n=0
		while [ "$_n" -lt "$_limit" ]; do
			kill -0 "$_cmd" 2>/dev/null || exit 0
			sleep 1
			_n=$((_n + 1))
		done
		if kill -0 "$_cmd" 2>/dev/null; then
			: > "$rb_flag"
			kill "$_cmd" 2>/dev/null
		fi
	} &
	_watch=$!
	wait "$_cmd" 2>/dev/null
	_st=$?
	kill "$_watch" 2>/dev/null
	wait "$_watch" 2>/dev/null
	[ -f "$rb_flag" ] && return 124
	return "$_st"
}

cap=$(cfg armature.preflightTimeout)
[ -n "$cap" ] || cap=4
case $cap in
	''|*[!0-9]*|0) refuse bad-timeout "armature.preflightTimeout is not a positive whole number of seconds: $cap" \
	                     'git config armature.preflightTimeout 4' ;;
esac

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
	|| refuse hooks-path-unset 'core.hooksPath is not configured, so the quality gate would not run on this branch' \
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
	|| refuse hooks-path-missing "core.hooksPath names $hooks_cfg, which is not a directory" \
	          'git config core.hooksPath .githooks'
case $hooks_res/ in
	"$top_res"/*) : ;;
	*) refuse hooks-path-foreign "core.hooksPath resolves to $hooks_res, outside this working tree ($top_res)" \
	          'git config core.hooksPath .githooks' ;;
esac

# --- 2. the worktree directory is configured, usable, and free -------------
wt_cfg=$(cfg armature.worktreeDir)
[ -n "$wt_cfg" ] \
	|| refuse worktree-dir-unset 'armature.worktreeDir is not configured, so the run has nowhere to isolate the task' \
	          'git config armature.worktreeDir <your ‹worktree dir›>'

case $wt_cfg in
	/*) wt_dir=$wt_cfg ;;
	*)  wt_dir=$top/$wt_cfg ;;
esac

# A path that EXISTS and is not a directory is its own fault, and was reaching the
# `else` branch below as though it were absent — round 1 measured the run then
# failing at `could not create leading directories`, which is precisely the
# discovered-too-late failure this script exists to move forward.
if [ -e "$wt_dir" ] && [ ! -d "$wt_dir" ]; then
	refuse worktree-dir-not-a-directory "the worktree directory $wt_dir exists and is not a directory" \
	       "remove or move that path, then: mkdir -p $wt_dir"
fi

# Absent is not a fault — the first run of a fresh clone creates it — but the
# parent must be writable, or it will fail at the point the run cannot recover.
if [ -d "$wt_dir" ]; then
	[ -w "$wt_dir" ] \
		|| refuse worktree-dir-unwritable "the worktree directory $wt_dir is not writable" \
		          "chmod u+w $wt_dir"
else
	wt_parent=$(dirname -- "$wt_dir")
	[ -d "$wt_parent" ] && [ -w "$wt_parent" ] \
		|| refuse worktree-dir-uncreatable "the worktree directory $wt_dir does not exist and its parent is not writable" \
		          "mkdir -p $wt_dir"
fi

# "Not already in use" is a statement about THIS task's directory: two runs of one
# task would land in the same tree and overwrite each other's work.
if [ -e "$wt_dir/$task" ]; then
	refuse worktree-in-use "the worktree for $task is already in use: $wt_dir/$task" \
	       "finish or remove that run first: git worktree remove $wt_dir/$task"
fi

# --- 3. the forge tool, the credential, and the scopes ---------------------
forge=$(cfg armature.forgeCli)
[ -n "$forge" ] \
	|| refuse forge-cli-unset 'armature.forgeCli is not configured, so no forge credential can be checked' \
	          'git config armature.forgeCli <your forge command-line tool>'

command -v "$forge" >/dev/null 2>&1 \
	|| refuse forge-cli-missing "the configured forge tool ($forge) is not on PATH" \
	          "install $forge, or point armature.forgeCli at the tool you use"

scopes_want=$(cfg armature.forgeScopes)
[ -n "$scopes_want" ] \
	|| refuse forge-scopes-unset 'armature.forgeScopes is not configured, so no scope can be checked' \
	          'git config armature.forgeScopes "<the scopes the run needs>"'

# Capped: `auth status` calls the forge API on both `gh` and `glab`, so it can hang
# exactly as the fetch below can. Captured, never echoed: this output carries the
# token on the tools that print one.
run_bounded "$cap" "$forge" auth status
auth_st=$?
[ "$auth_st" -ne 124 ] \
	|| refuse forge-auth-timeout "$forge auth status did not answer within ${cap}s" \
	          "check the forge is reachable, or raise: git config armature.preflightTimeout <seconds>"

# THE EXIT CODE IS A SIGNAL, NOT A VERDICT, so it is not acted on here. Both tools
# set a failure status when ANY configured host fails, and `glab` was measured
# exiting 1 with the host in question fully authenticated — so refusing here would
# refuse a run whose own forge is fine because an unrelated one is not. The
# transcript is parsed first; the status is consulted only where the parse finds
# nothing usable for this host, below. It is NEVER a licence to fall back to some
# other block that looks healthy: selection stays first, the scope check second.

# THE HOST IS THE SELECTOR, not activeness. `gh` marks one account active PER HOST
# — "Each host section will indicate the active account, which will be used when
# targeting that host" — so a two-host login has two active accounts and neither is
# wrong. Round 2 measured two rules failing on that axis: "exactly one active"
# refused every two-host setup outright, and "every active account holds every
# scope" still refused a run against a fine `github.com` because an unrelated
# enterprise token carried fewer scopes. Selecting by host turns the question from
# a guess into a lookup.
#
# The host is `origin`'s, because that is where a run pushes and opens its pull
# request. `armature.baseRef` may name a different remote — it answers a different
# question, whether the base branch can be fetched.
origin_url=$(git -C "$top" remote get-url origin 2>/dev/null || :)
# scheme, then any user@, then everything from the first `:` or `/`. A local path
# ("/srv/repo.git", "file:///srv/repo.git") correctly yields the empty string: it
# names no host, and this must not invent one.
forge_host=$(printf '%s\n' "$origin_url" \
	| sed -e 's#^[a-zA-Z][a-zA-Z0-9+.-]*://##' -e 's#^[^/@]*@##' -e 's#[:/].*$##')

# One block per account, keyed by the host its own "Logged in to <host>" line
# names — the line both `gh` and `glab` emit. Scope sets are never merged, which is
# what keeps round 1's union closed.
scopes_read=$(awk -v want_host="$forge_host" '
	# A bare hostname at column 0 opens a host section. It is the ONLY thing that
	# gives a FAILED block a host: `gh` writes such a block as "Failed to log in
	# to …", which carries no "Logged in to" line, so without the section header
	# its host is unknowable and the refusal below would be attributed to whatever
	# block came before it.
	# close_block — an active block that never reached a scopes line is UNRESOLVED,
	# and is recorded rather than judged, because judging it needs `seen`, which is
	# only complete at END. It runs at EVERY block boundary — a section header as
	# well as a login line. Judging at the login line alone let a later unresolved
	# block on another host overwrite the target host s own before it was ever
	# looked at, which round 3 measured as a false pass.
	function close_block() {
		if (pending) {
			np++
			p_host[np] = host      # certain, from this block s own login line
			p_sec[np]  = section   # a guess, for a block that has no login line
			p_fail[np] = blockfailed
		}
		pending = 0
	}
	/^[A-Za-z0-9][A-Za-z0-9.-]*\.[A-Za-z][A-Za-z]+[ \t]*\r?$/ {
		close_block()
		section = $0
		sub(/[ \t\r]+$/, "", section)
		host = ""
	}
	# ANY line reporting a login attempt is a block boundary, success or failure:
	# `gh` writes a success as "Logged in to <host> …" and a failure as "Failed to
	# log in to <host> …". Matching only the success form left a failure block
	# sharing the PREVIOUS block s host, which END then trusted as certain — a
	# false pass whenever the section-header pattern did not recognise the host,
	# which it does not for a single-label name or an IP address.
	/[Ll]og(ged)? in to/ {
		close_block()
		active = 0
		blockfailed = ($0 ~ /[Ff]ailed/)
		host = $0
		sub(/^.*[Ll]og(ged)? in to[ \t]+/, "", host)
		sub(/[ \t].*$/, "", host)
		# `seen` means a host something logged IN to, and so may vouch for a
		# section header. A failure proves the opposite.
		if (!blockfailed) seen[host] = 1
	}
	/[Aa]ctive account:[ \t]*true/ { active = 1; pending = 1 }
	/[Tt]oken scopes:/ {
		line = $0
		sub(/.*[Tt]oken scopes:[ \t]*/, "", line)
		gsub(/[\047"]/, "", line)
		gsub(/,/, " ", line)
		if (active) pending = 0
		n++
		all[n] = line
		if (want_host != "" && host == want_host) {
			nh++; hostline[nh] = line
			if (active) { nha++; hostactive = line }
		}
	}
	END {
		close_block()
		# Judge every unresolved active block, now that `seen` is complete.
		#
		# A block WITH its own login line has a certain host and is authenticated:
		# it reported no scopes because its token carries none. `gh` prints the
		# scopes line only for classic and OAuth tokens, so an installation
		# (`ghs_`) or fine-grained token lands here — and calling that "broken"
		# would be false.
		#
		# A block with NO login line is a failure block, and its host is a guess
		# from the section header above it. The guess is trusted ONLY when that
		# header is a host actually seen on some login line and is not the target.
		# Anything else fails closed: an unresolved block whose host cannot be
		# established is treated as the target s, because a wrong guess in the
		# other direction is a false pass.
		for (i = 1; i <= np; i++) {
			if (p_host[i] != "") {
				mine = (want_host == "" || p_host[i] == want_host)
			} else {
				s = p_sec[i]
				mine = (want_host == "" || s == "" || !(s in seen) || s == want_host)
			}
			if (!mine) continue
			# A block that FAILED, or one that cannot be tied to a successful
			# login at all, is a broken credential. A block that did log in and
			# simply reported no scopes is a working credential whose permissions
			# are not OAuth scopes.
			if (p_fail[i] || p_host[i] == "") broken = 1
			else unverifiable = 1
		}
		# Before everything else, and `broken` before `unverifiable`: an active
		# account that failed means the credential the tool would USE is unusable,
		# and any scopes line found elsewhere belongs to an account it would NOT
		# use. Reading those would be a false PASS — the direction that costs a
		# whole build.
		if (broken)      { print "broken";       exit }
		if (unverifiable) { print "unverifiable"; exit }
		if (n == 0) { print "none"; exit }
		if (want_host == "") {
			# origin names no host, so no block can be matched to it. One
			# account is unambiguous; several are not, and saying so is
			# better than picking.
			if (n == 1) { print "ok"; print all[1]; exit }
			print "hostless " n; exit
		}
		if (nh == 0)  { print "nohost";                    exit }
		if (nh == 1)  { print "ok"; print hostline[1];     exit }
		if (nha == 1) { print "ok"; print hostactive;      exit }
		print "ambiguous " nh
	}' < "$rb_out")

case $scopes_read in
	broken)
		refuse forge-active-account-broken "the account $forge marks active for $forge_host failed to authenticate, so the credential a run would actually use is not usable" \
		       "repair or unset that credential — an invalid GH_TOKEN produces exactly this; check with: $forge auth status" ;;
	unverifiable)
		refuse forge-scopes-unverifiable "the account $forge marks active for $forge_host is authenticated but reports no scopes, so the scopes this run needs cannot be verified — an installation (\`ghs_\`) or fine-grained token carries none" \
		       "use a classic or OAuth token for the run; see the scope-model limit in docs/runner/README.md" ;;
	none)
		# Nothing usable anywhere: NOW the exit status tells the two causes apart.
		[ "$auth_st" -eq 0 ] \
			|| refuse forge-no-credential "$forge reports no authenticated account (it exited $auth_st and reported no scopes for any account)" \
			          "$forge auth login"
		refuse forge-no-scope-line "$forge answered auth status but reported no \`Token scopes:\` line" \
		       "check that $forge is a supported forge tool; see docs/runner/README.md" ;;
	nohost)
		[ "$auth_st" -eq 0 ] \
			|| refuse forge-no-credential "$forge exited $auth_st and reports no account for $forge_host, which is where origin points" \
			          "$forge auth login --hostname $forge_host"
		refuse forge-no-account-for-host "$forge reports no account for $forge_host, which is where origin points" \
		       "$forge auth login --hostname $forge_host" ;;
	hostless*)
		refuse forge-host-unknown "origin's URL ($origin_url) names no host, and $forge reports ${scopes_read#hostless } accounts, so the one the run would use cannot be told apart" \
		       "point origin at the forge you push to" ;;
	ambiguous*)
		refuse forge-ambiguous-account "$forge reports ${scopes_read#ambiguous } accounts for $forge_host and marks none of them active" \
		       "select one: $forge auth switch --hostname $forge_host" ;;
esac
scopes_have=$(printf '%s\n' "$scopes_read" | sed '1d')

# The fix names the scope, not a subcommand: `auth refresh` is gh's spelling and
# glab has no such command, so printing it at every tool would be an invented
# command — the thing this kit forbids.
for want in $scopes_want; do
	found=0
	for have in $scopes_have; do
		[ "$want" = "$have" ] && { found=1; break; }
	done
	[ "$found" -eq 1 ] \
		|| refuse forge-missing-scope "the forge account for $forge_host is missing scope: $want" \
		          "grant $want to that account (with gh: gh auth refresh -s $want)"
done

# --- 4. the base branch is fetchable (the one fetch) -----------------------
base_ref=$(cfg armature.baseRef)
[ -n "$base_ref" ] || base_ref=origin/main
base_remote=${base_ref%%/*}
base_branch=${base_ref#*/}
if [ "$base_remote" = "$base_ref" ] || [ -z "$base_branch" ]; then
	refuse bad-base-ref "armature.baseRef ($base_ref) is not a <remote>/<branch> pair" \
	       'git config armature.baseRef origin/main'
fi

run_bounded "$cap" git -C "$top" ls-remote --exit-code --heads "$base_remote" "$base_branch"
ls_st=$?
[ "$ls_st" -ne 124 ] \
	|| refuse base-ref-timeout "the remote $base_remote did not answer within ${cap}s" \
	          "check the remote is reachable, or raise: git config armature.preflightTimeout <seconds>"
[ "$ls_st" -eq 0 ] \
	|| refuse base-ref-unfetchable "the base branch $base_ref is not fetchable" \
	          "check the remote and the branch: git ls-remote --heads $base_remote $base_branch"

printf 'preflight: OK — %s may start in %s\n' "$task" "$wt_dir/$task"
