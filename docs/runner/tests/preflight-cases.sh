#!/bin/sh
#
# preflight-cases.sh — drive ../preflight.sh against one built environment per
# precondition class, and assert what it NAMED, not only that it failed.
#
# Each case is BUILT rather than committed: one template environment is made once,
# then copied per case and mutated in exactly one way, so every case is otherwise
# valid and fails for its own single reason. No committed fixture could hold these
# preconditions — a fixture cannot carry a nested repository directory.
# docs/runner/README.md records why this suite has its own CI job instead of a place
# in run-discipline-tests.sh.
#
# WHY THE CASES ASSERT A CODE AND NOT PROSE. Round 1 measured `bad-forge-cli-unset`
# passing with the very check it existed for deleted, because the substring
# `armature.forgeCli` it asserted also appears in a DIFFERENT refusal's fix line. A
# loose substring cannot tell one precondition class from another, which is the one
# thing the Definition of Done asks these cases to do.
#
# Five assertions run on every case, not only the ones that motivate them:
#
#   exit status   exactly 1 — the documented "a precondition is unmet" code — so a
#                 crashed script is not mistaken for a refusal.
#   the code      the refusal names the class the case exists for.
#   a fix line    round 1 measured the whole suite staying green with the fix line
#                 deleted from `refuse`, leaving half the criterion untested.
#   no credential the stub prints a secret-shaped token on every successful `auth
#                 status`, and no case's output may contain it. One assertion
#                 applied everywhere is what makes "never prints a credential" a
#                 property of the script rather than of one case.
#   ten seconds   per case, the unit the acceptance criterion uses.
#
# Usage:  sh docs/runner/tests/preflight-cases.sh [-v]
# Exit status: 0 = every case behaved, 1 = one or more did not.
#
# It needs git and a POSIX shell, and reaches NO network — the reachable "remote"
# is a bare repository in the same temporary directory, and the unreachable one is
# git's `ext::` transport running `sleep`, which hangs locally and deterministically
# rather than depending on a black-holed address answering the way a test hopes.

set -u

verbose=0
case ${1:-} in
	-v|--verbose) verbose=1 ;;
	'') : ;;
	*)  printf 'preflight-cases: unknown argument: %s\n' "$1" >&2; exit 2 ;;
esac

# Cut this suite loose from any repository that invoked it.
#
# git exports GIT_DIR, GIT_INDEX_FILE and friends to the hooks it runs. An
# inherited GIT_DIR silently redirects every `git init`, `git -C` and `git config`
# below at the REAL repository — the first symptom was `remote origin already
# exists` while building a repository that had just been created empty. Left
# unfixed, a suite meant to build throwaway repositories would have been writing
# configuration into the one that invoked it.
for v in GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
	GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_PREFIX \
	GIT_CONFIG GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_INDEX_VERSION \
	GIT_AUTHOR_DATE GIT_COMMITTER_DATE XDG_CONFIG_HOME; do
	unset "$v" 2>/dev/null || :
done
# XDG_CONFIG_HOME is in that list because git reads $XDG_CONFIG_HOME/git/config as
# GLOBAL configuration once GIT_CONFIG_GLOBAL is unset — repointing HOME does not
# reach it. Round 1 measured a global `commit.gpgsign` breaking the template build
# and a global `armature.worktreeDir` making a case name the wrong precondition:
# the operator's own machine deciding whether this suite passes.
GIT_CONFIG_NOSYSTEM=1
GIT_TERMINAL_PROMPT=0
export GIT_CONFIG_NOSYSTEM GIT_TERMINAL_PROMPT

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
preflight="$script_dir/../preflight.sh"
[ -f "$preflight" ] || {
	printf 'FAIL  cannot find the pre-flight at %s\n' "$preflight" >&2; exit 1; }

command -v git >/dev/null 2>&1 || {
	printf 'FAIL  git is not on PATH; this suite builds real repositories\n' >&2; exit 1; }

base=$(mktemp -d) || { printf 'FAIL  mktemp -d failed\n' >&2; exit 1; }
cleanup() { cd / || :; chmod -R u+w "$base" 2>/dev/null || :; rm -rf "$base"; }
trap cleanup EXIT

# HOME last: it is what git resolves ~/.gitconfig against, and it has to point
# somewhere writable, so it points inside the directory this suite already removes.
HOME=$base
export HOME

pass=0
fail=0
codes_seen=''

# The secret-shaped value the stub prints. A literal here and in the stub; a shared
# variable would let both drift to empty together and assert nothing.
SENTINEL='ghp_SENTINEL00000000000000000000000000'

# The task slug every case asks about. Fixed, because "already in use" is a
# statement about one task's directory.
TASK=T-demo

# --- the template environment ---------------------------------------------
#
# Built once. Everything a good run needs, and nothing a case has to undo.

mkdir -p "$base/remote" || exit 1
git init -q --bare "$base/remote/origin.git" >/dev/null 2>&1 || {
	printf 'FAIL  could not create the bare remote\n' >&2; exit 1; }

t=$base/template
mkdir -p "$t/bin" "$t/repo" || exit 1

git init -q "$t/repo" >/dev/null 2>&1 || {
	printf 'FAIL  could not create the template repository\n' >&2; exit 1; }

# Prove the repository this suite is about to write to is the one it just created,
# BEFORE anything writes. Unsetting the inherited GIT_* variables above should make
# this impossible to fail; it is asserted anyway because the failure mode is not a
# red test — it is `git add -A` and `git commit` landing in the caller's own
# repository. That happened once, during this task: the suite committed over the
# branch it was being written on. A check that costs one command is worth keeping
# in front of a mistake that expensive.
_saw=$(git -C "$t/repo" rev-parse --show-toplevel 2>/dev/null || :)
_want=$(CDPATH= cd -- "$t/repo" && pwd -P)
if [ "$_saw" != "$_want" ]; then
	printf 'FAIL  refusing to build: git resolves %s to %s, not the temporary repository\n' \
		"$t/repo" "${_saw:-nothing}" >&2
	printf '      something in the environment is redirecting git; no case has run.\n' >&2
	exit 1
fi

git -C "$t/repo" config user.email preflight@test.invalid
git -C "$t/repo" config user.name 'preflight test'
mkdir -p "$t/repo/.githooks" "$t/repo/.worktree"
echo 'seed' > "$t/repo/seed.txt"
git -C "$t/repo" add -A >/dev/null 2>&1
git -C "$t/repo" commit -q -m 'seed' >/dev/null 2>&1 || {
	printf 'FAIL  could not commit in the template repository\n' >&2; exit 1; }
# Two remotes, because they answer two different questions and a real clone answers
# them with one URL that this suite cannot have. `origin` supplies the FORGE HOST,
# so it carries an https URL and is never fetched. `local` supplies FETCHABILITY,
# so it is the bare repository beside us and keeps the suite off the network.
git -C "$t/repo" remote add origin 'https://forge.invalid/demo/repo.git'
git -C "$t/repo" remote add local "$base/remote/origin.git"
git -C "$t/repo" push -q local HEAD:refs/heads/main >/dev/null 2>&1 || {
	printf 'FAIL  could not publish main to the bare remote\n' >&2; exit 1; }

# A second remote that never answers, for the timeout cases. `ext::` runs a helper
# command instead of speaking to a host, so `sleep` hangs the fetch locally and for
# a known duration. git refuses the ext transport unless a repository opts in, so
# the opt-in is here in the fixture and NOT in the pre-flight.
git -C "$t/repo" config protocol.ext.allow always
git -C "$t/repo" remote add blackhole 'ext::sleep 30'

# The configuration a correct clone carries. Each bad case removes or changes one.
git -C "$t/repo" config core.hooksPath .githooks
git -C "$t/repo" config armature.forgeCli forge-stub
git -C "$t/repo" config armature.forgeScopes 'repo workflow'
git -C "$t/repo" config armature.worktreeDir .worktree
git -C "$t/repo" config armature.baseRef local/main
git -C "$t/repo" config armature.preflightTimeout 2

# The stub forge tool. It answers `auth status` the way the real tools do — a
# "Token scopes:" line, and a token line this suite asserts is never echoed — and
# refuses everything else, so a pre-flight that asks it something undocumented
# fails here rather than silently succeeding against a real tool. `hang=1` makes it
# sleep instead of answering, which is how the credential step's cap is measured.
cat > "$t/bin/forge-stub" <<STUB
#!/bin/sh
d=\$(CDPATH= cd -- "\$(dirname -- "\$0")/.." && pwd)
authed=\$(sed -n 's/^authed=//p' "\$d/forge-state")
hang=\$(sed -n 's/^hang=//p' "\$d/forge-state")
if [ "\${1:-}" = auth ] && [ "\${2:-}" = status ]; then
	[ "\$hang" = 1 ] && sleep 30
	if [ "\$authed" != 1 ]; then
		echo 'You are not logged in to any hosts. Run: forge-stub auth login' >&2
		exit 1
	fi
	sed -n '/^accounts\$/,\$p' "\$d/forge-state" | sed '1d;s/@TOKEN@/$SENTINEL/'
	exit 0
fi
echo "forge-stub: unsupported invocation: \$*" >&2
exit 2
STUB
chmod +x "$t/bin/forge-stub"

# The state file holds the account blocks verbatim after an `accounts` marker, so a
# case can hand the stub any shape a real tool prints — one account, several, or
# several with none marked active.
{
	printf 'authed=1\nhang=0\naccounts\n'
	printf 'forge.invalid\n'
	printf '  * Logged in to forge.invalid account demo (keyring)\n'
	printf '  - Active account: true\n'
	printf '  - Token: @TOKEN@\n'
	printf "  - Token scopes: 'repo', 'workflow'\n"
} > "$t/forge-state"

# block HOST ACTIVE SCOPES — one account block in the shape the real tools print.
# Used by the multi-account cases below so their shape is stated once.
block() {
	printf '%s\n' "$1"
	printf '  * Logged in to %s account demo (keyring)\n' "$1"
	[ "$2" = active ] && printf '  - Active account: true\n'
	printf '  - Token: @TOKEN@\n'
	printf "  - Token scopes: %s\n" "$3"
	printf '\n'
}

# --- the cases -------------------------------------------------------------

# run_case NAME WANT_STATUS EXPECT_CODE
# EXPECT_CODE is the `code:` the refusal must carry; for the good case it is the
# literal the success line starts with.
run_case() {
	_name=$1; _want=$2; _expect=$3
	_w=$base/$_name
	cp -R "$t" "$_w" || { printf 'FAIL  %s: could not copy the template\n' "$_name" >&2; fail=$((fail + 1)); return; }
	_r=$_w/repo

	# The one mutation that makes this case its case.
	case $_name in
	good) : ;;
	bad-forge-cli-unset)   git -C "$_r" config --unset armature.forgeCli ;;
	bad-forge-cli-missing) git -C "$_r" config armature.forgeCli no-such-forge-tool ;;
	bad-scopes-unset)      git -C "$_r" config --unset armature.forgeScopes ;;
	bad-credential)        sed 's/^authed=1/authed=0/' "$_w/forge-state" > "$_w/s" && mv "$_w/s" "$_w/forge-state" ;;
	bad-scope-revoked)     sed "s/'repo', 'workflow'/'workflow'/" "$_w/forge-state" > "$_w/s" && mv "$_w/s" "$_w/forge-state" ;;
	bad-scope-union)
		# Two accounts on ONE host, the active one holding `repo` and the other
		# `workflow`. Neither holds both; only their union does. This is #80's
		# shape, and the defect round 1 measured passing.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block forge.invalid active   "'gist', 'read:org', 'repo'"
			block forge.invalid inactive "'read:org', 'workflow'"
		} > "$_w/forge-state" ;;
	bad-account-ambiguous)
		# Two accounts on the TARGET host and neither marked active. Nothing
		# names a winner, so the script must refuse rather than pick.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block forge.invalid inactive "'repo', 'workflow'"
			block forge.invalid inactive "'repo'"
		} > "$_w/forge-state" ;;
	good-enterprise-other-host-short)
		# The shape round 2 measured being falsely refused. Two hosts, both with an
		# active account — which is what `gh` prints, because it marks one active
		# PER HOST. The target host holds every wanted scope; an unrelated
		# enterprise host holds fewer, as enterprise tokens routinely do. Nothing
		# about that other host can harm a run against this one, so this must PASS.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block forge.invalid active "'repo', 'workflow'"
			block enterprise.invalid active "'repo'"
		} > "$_w/forge-state" ;;
	bad-target-host-short)
		# The mirror image: the OTHER host is fully scoped and the target host is
		# short. The run would use the short one, so this must refuse — and name
		# the host, so the operator fixes the right account.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block forge.invalid active "'repo'"
			block enterprise.invalid active "'repo', 'workflow'"
		} > "$_w/forge-state" ;;
	bad-active-account-broken)
		# The real shape `gh` prints when GH_TOKEN holds an invalid token — which
		# is the DEFINING condition of an unattended run, since GitHub Actions and
		# most agent harnesses set it. `gh` marks the env token active and the
		# working keyring account INACTIVE, and the active block carries no scopes
		# line because that credential is broken. `auth status` still exits 0.
		#
		# Two traps in one: the failure line reads "Failed to log **in to**", which
		# does not match the "Logged in to" block reset, so the active flag is not
		# cleared before it is set; and the only scopes line in the transcript
		# belongs to an account the tool would NOT use. Reading it was a false PASS
		# — #80's failure produced by the check written to prevent it.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			printf 'forge.invalid\n'
			printf '  X Failed to log in to forge.invalid using token (GH_TOKEN)\n'
			printf '  - Active account: true\n'
			printf '  - The token in GH_TOKEN is invalid.\n'
			printf '\n'
			printf '  * Logged in to forge.invalid account demo (keyring)\n'
			printf '  - Active account: false\n'
			printf '  - Token: @TOKEN@\n'
			printf "  - Token scopes: 'repo', 'workflow'\n"
		} > "$_w/forge-state" ;;
	good-other-host-broken)
		# The target host is fully authenticated and fully scoped; an UNRELATED
		# host has an active account with no scopes line — a bot token in the
		# environment, say. Round 3 measured the first version of the broken-account
		# guard refusing this, because `pending` was global to the transcript rather
		# than attributed to a host. Nothing here can harm a run against
		# forge.invalid, so it must pass.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block forge.invalid active "'repo', 'workflow'"
			printf 'enterprise.invalid\n'
			printf '  * Logged in to enterprise.invalid account bot (env)\n'
			printf '  - Active account: true\n'
			printf '  - Token: @TOKEN@\n'
			printf '\n'
		} > "$_w/forge-state" ;;
	bad-target-host-broken-no-header)
		# The mirror, and the one that must NOT be lost to host attribution: the
		# TARGET host's own active account is broken. Its failure block carries no
		# "Logged in to" line, so its host comes from the section header above it —
		# which is why that header is parsed at all.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			printf 'forge.invalid\n'
			printf '  X Failed to log in to forge.invalid using token (GH_TOKEN)\n'
			printf '  - Active account: true\n'
			printf '  - The token in GH_TOKEN is invalid.\n'
			printf '\n'
			block enterprise.invalid active "'repo', 'workflow'"
		} > "$_w/forge-state" ;;
	bad-broken-overwritten-by-other-host)
		# Round 3's measured false pass. The TARGET host's block failed and is
		# active; a second failed block on another host follows, and a working but
		# INACTIVE account for the target host follows that. Judging an unresolved
		# block only at the next login line let the second failure overwrite the
		# first before it was ever looked at, and the run passed on the inactive
		# account's scopes. Every block boundary must close the block.
		#
		# The shape is built so it DISCRIMINATES: the unresolved block belongs to
		# the target host, but the next section header names another host that is
		# genuinely logged in. Close the block late and it is attributed to that
		# other host, is trusted because that host was seen, and the run passes on
		# the target's inactive account. Close it at the section boundary and it
		# keeps the host it actually had.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			printf 'forge.invalid\n'
			printf '  X Failed to log in to forge.invalid using token (GH_TOKEN)\n'
			printf '  - Active account: true\n'
			printf 'enterprise.invalid\n'
			printf '  * Logged in to enterprise.invalid account bot (keyring)\n'
			printf '  - Active account: false\n'
			printf '  - Token: @TOKEN@\n'
			printf "  - Token scopes: 'repo'\n"
			printf 'forge.invalid\n'
			printf '  * Logged in to forge.invalid account demo (keyring)\n'
			printf '  - Active account: false\n'
			printf '  - Token: @TOKEN@\n'
			printf "  - Token scopes: 'repo', 'workflow'\n"
		} > "$_w/forge-state" ;;
	bad-broken-under-stray-header)
		# The same false pass reached by a stray line at column 0 that looks like a
		# host. It becomes the section header, so the failed block is attributed to
		# a host nothing ever logged in to. A guessed host is trusted only when it
		# was actually seen on a login line; otherwise the block fails closed.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			printf 'notice.invalid\n'
			printf '  X Failed to log in to forge.invalid using token (GH_TOKEN)\n'
			printf '  - Active account: true\n'
			printf '\n'
			printf '  * Logged in to forge.invalid account demo (keyring)\n'
			printf '  - Active account: false\n'
			printf '  - Token: @TOKEN@\n'
			printf "  - Token scopes: 'repo', 'workflow'\n"
		} > "$_w/forge-state" ;;
	bad-installation-token)
		# What `GH_TOKEN` holds inside GitHub Actions. `gh` prints the scopes line
		# only for classic and OAuth tokens, so an installation (`ghs_`) or
		# fine-grained token authenticates, exits 0, and reports NO scopes. Calling
		# that credential "broken" would be false — it works; its permissions
		# simply are not OAuth scopes. It gets its own refusal, because the scope
		# precondition genuinely cannot be checked from `auth status`.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			printf 'forge.invalid\n'
			printf '  * Logged in to forge.invalid account demo (GH_TOKEN)\n'
			printf '  - Active account: true\n'
			printf '  - Token: @TOKEN@\n'
		} > "$_w/forge-state" ;;
	bad-no-account-for-host)
		# Authenticated, correctly scoped — but to a forge the run does not use.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block enterprise.invalid active "'repo', 'workflow'"
		} > "$_w/forge-state" ;;
	bad-origin-hostless)
		# origin points at a local path, so no block can be matched to it. With
		# several accounts reported the script must say that rather than guess.
		git -C "$_r" remote set-url origin "$_w/plain.git"
		{
			printf 'authed=1\nhang=0\naccounts\n'
			block forge.invalid active "'repo', 'workflow'"
			block enterprise.invalid active "'repo', 'workflow'"
		} > "$_w/forge-state" ;;
	bad-no-scope-line)
		# Real `glab`'s shape, measured: it reports a login and a "Token found"
		# line and never a `Token scopes:` line, and marks no account active. A
		# tool that cannot answer the scope question must be refused BY NAME
		# rather than mistaken for a credential missing a scope.
		{
			printf 'authed=1\nhang=0\naccounts\n'
			printf 'forge.invalid\n'
			printf '  * Logged in to forge.invalid as demo (/dev/null/config.yml)\n'
			printf '  * Token found: ****************\n'
		} > "$_w/forge-state" ;;
	bad-forge-hangs)       sed 's/^hang=0/hang=1/' "$_w/forge-state" > "$_w/s" && mv "$_w/s" "$_w/forge-state" ;;
	bad-worktree-unset)    git -C "$_r" config --unset armature.worktreeDir ;;
	bad-worktree-unwritable) chmod 500 "$_r/.worktree" ;;
	bad-worktree-not-a-dir) rmdir "$_r/.worktree"; echo 'a regular file' > "$_r/.worktree" ;;
	bad-worktree-occupied) mkdir -p "$_r/.worktree/$TASK"; echo x > "$_r/.worktree/$TASK/in-progress" ;;
	bad-base-unfetchable)  git -C "$_r" config armature.baseRef local/no-such-branch ;;
	bad-base-hangs)        git -C "$_r" config armature.baseRef blackhole/main ;;
	bad-hookspath-unset)   git -C "$_r" config --unset core.hooksPath ;;
	bad-hookspath-outside) mkdir -p "$_w/foreign"; git -C "$_r" config core.hooksPath "$_w/foreign" ;;
	*) printf 'FAIL  %s: no mutation defined for this case\n' "$_name" >&2; fail=$((fail + 1)); return ;;
	esac

	_start=$(date +%s)
	_out=$(PATH="$_w/bin:$PATH" sh "$preflight" "$TASK" "$_r" 2>&1)
	_got=$?
	_elapsed=$(( $(date +%s) - _start ))

	_why=''
	[ "$_got" -eq "$_want" ] || _why="wanted exit $_want, got $_got"

	if [ -z "$_why" ] && [ "$_want" -eq 0 ]; then
		printf '%s\n' "$_out" | grep -q "^$_expect" \
			|| _why="exit 0 was right, but the output does not start: $_expect"
	fi

	if [ -z "$_why" ] && [ "$_want" -ne 0 ]; then
		_code=$(printf '%s\n' "$_out" | sed -n 's/^ *code: *//p')
		if [ "$_code" != "$_expect" ]; then
			_why="refused with code '${_code:-none}', wanted '$_expect'"
		else
			codes_seen="$codes_seen$_code
"
			printf '%s\n' "$_out" | grep -q '^ *fix: *[^ ]' \
				|| _why='refused with no fix: line'
		fi
	fi

	if [ -z "$_why" ]; then
		printf '%s\n' "$_out" | grep -q -- "$SENTINEL" \
			&& _why='the output leaked the credential value'
	fi
	if [ -z "$_why" ] && [ "$_elapsed" -gt 10 ]; then
		_why="took ${_elapsed}s, over the ten-second bound"
	fi

	if [ -z "$_why" ]; then
		pass=$((pass + 1))
		# Printed by DEFAULT, not only under -v. Two cases wait for a cap to fire,
		# so this suite runs over ten seconds, and gate step 4 requires anything
		# that can do that to show which step runs and that it is alive. `-v` adds
		# the elapsed seconds on top.
		if [ "$verbose" -eq 1 ]; then
			printf 'ok    %-24s %-28s %ss\n' "$_name" "$_expect" "$_elapsed"
		else
			printf 'ok    %-24s %s\n' "$_name" "$_expect"
		fi
	else
		fail=$((fail + 1))
		printf 'FAIL  %s: %s\n' "$_name" "$_why" >&2
		printf '%s\n' "$_out" | sed 's/^/      | /' >&2
	fi
}

run_case good                    0 'preflight: OK'
run_case bad-hookspath-unset     1 hooks-path-unset
run_case bad-hookspath-outside   1 hooks-path-foreign
run_case bad-worktree-unset      1 worktree-dir-unset
run_case bad-worktree-not-a-dir  1 worktree-dir-not-a-directory
run_case bad-worktree-occupied   1 worktree-in-use
run_case bad-forge-cli-unset     1 forge-cli-unset
run_case bad-forge-cli-missing   1 forge-cli-missing
run_case bad-scopes-unset        1 forge-scopes-unset
run_case bad-credential          1 forge-no-credential
run_case bad-forge-hangs         1 forge-auth-timeout
run_case bad-no-scope-line       1 forge-no-scope-line
run_case bad-account-ambiguous   1 forge-ambiguous-account
run_case good-enterprise-other-host-short 0 'preflight: OK'
run_case bad-target-host-short   1 forge-missing-scope
run_case bad-active-account-broken 1 forge-active-account-broken
run_case good-other-host-broken   0 'preflight: OK'
run_case bad-target-host-broken-no-header 1 forge-active-account-broken
run_case bad-broken-overwritten-by-other-host 1 forge-active-account-broken
run_case bad-broken-under-stray-header 1 forge-active-account-broken
run_case bad-installation-token   1 forge-scopes-unverifiable
run_case bad-no-account-for-host 1 forge-no-account-for-host
run_case bad-origin-hostless     1 forge-host-unknown
run_case bad-scope-union         1 forge-missing-scope
run_case bad-scope-revoked       1 forge-missing-scope
run_case bad-base-unfetchable    1 base-ref-unfetchable
run_case bad-base-hangs          1 base-ref-timeout

# Root can write through a 0500 directory, so the case would assert nothing there.
# Skipped loudly rather than silently: a suite that quietly drops a case is the
# false green this kit keeps meeting.
if [ "$(id -u)" = 0 ]; then
	printf 'skip  bad-worktree-unwritable: running as root, which writes through a read-only directory\n'
else
	run_case bad-worktree-unwritable 1 worktree-dir-unwritable
fi

# Two precondition classes sharing one code would make the code assertion as blunt
# as the prose it replaced. A code reached by more than one case is fine — several
# routes to one refusal is coverage, not collision — but each such code is NAMED
# here, so a NEW duplicate still goes red instead of the check being weakened to
# allow any:
#
#   forge-missing-scope          a revoked scope, a union across accounts, and a
#                                short token on the target host: one refusal, three
#                                routes.
#   forge-active-account-broken  the target host's broken account with a section
#                                header supplying its host, and the same fault where
#                                the block carries its own login line.
dupes=$(printf '%s' "$codes_seen" | sort | uniq -d \
	| grep -v -e '^forge-missing-scope$' -e '^forge-active-account-broken$' || :)
if [ -n "$dupes" ]; then
	printf 'FAIL  two precondition classes share one code: %s\n' "$(printf '%s' "$dupes" | tr '\n' ' ')" >&2
	fail=$((fail + 1))
fi

# Coverage floor. A suite that ran nothing, or that lost every refusal case to a
# rename, would otherwise report success having proved nothing. This runner is not
# inside run-discipline-tests.sh's good*/bad* accounting, so the floor lives here.
if [ "$((pass + fail))" -lt 10 ]; then
	printf 'FAIL  only %d cases ran; the suite is misconfigured\n' "$((pass + fail))" >&2
	fail=$((fail + 1))
fi

printf 'preflight-cases: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && exit 0 || exit 1
