#!/bin/sh
#
# preflight-cases.sh — drive ../preflight.sh against one built environment per
# precondition class, and assert what it NAMED, not only that it failed.
#
# The other discipline suites point a linter at a directory of text, so their
# fixtures can be committed. Four of this check's five preconditions are properties
# of a live repository and a credential — a configured hooks path, a writable
# worktree directory, a reachable base branch, a scoped token — and no committed
# directory can hold them; a fixture cannot carry a nested repository directory.
# So each case is BUILT here: one template environment is made once, then copied
# per case and mutated in exactly one way. Every case is otherwise valid, so it
# fails for its own single reason.
#
# Three assertions run on every case, not only the ones that motivate them:
#
#   exit status   a bad case must exit exactly 1 — the documented "a precondition
#                 is unmet" code — so a crashed script (a syntax error, a
#                 not-found) is caught rather than mistaken for a refusal.
#   naming        the output must hold the case's expected substring. Without this
#                 every bad case passes on any refusal, and a check that named the
#                 wrong precondition would read as green. That was the defect
#                 `bad-hookspath-unset` and `bad-hookspath-outside` exist as a pair
#                 to catch: both refuse, and only the wording tells them apart.
#   no credential the stub forge tool prints a secret-shaped token on every
#                 successful `auth status`. No case's output may contain it. One
#                 assertion, applied everywhere, is what makes "it never prints a
#                 credential value" a property of the script rather than of the one
#                 case someone thought to write.
#
# It also bounds each case at ten seconds, which is the acceptance criterion the
# issue states, so a pre-flight that grows a slow check goes red here.
#
# Usage:  sh docs/runner/tests/preflight-cases.sh [-v]
# Exit status: 0 = every case behaved, 1 = one or more did not.
#
# It needs git and a POSIX shell, and reaches no network: the "remote" is a bare
# repository in the same temporary directory.

set -u

verbose=0
case ${1:-} in
	-v|--verbose) verbose=1 ;;
	'') : ;;
	*)  printf 'preflight-cases: unknown argument: %s\n' "$1" >&2; exit 2 ;;
esac

# Cut this suite loose from any repository that invoked it.
#
# git exports GIT_DIR, GIT_INDEX_FILE and friends to the hooks it runs, and this
# suite runs inside run-discipline-tests.sh, which runs in the pre-commit hook. An
# inherited GIT_DIR silently redirects every `git init`, `git -C` and `git config`
# below at the REAL repository — the first symptom was `remote origin already
# exists` while building a repository that had just been created empty. Left
# unfixed, a suite meant to build throwaway repositories would have been writing
# configuration into the one being committed.
for v in GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
	GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_PREFIX \
	GIT_CONFIG GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_INDEX_VERSION \
	GIT_AUTHOR_DATE GIT_COMMITTER_DATE; do
	unset "$v" 2>/dev/null || :
done
# The operator's own configuration is not part of any assertion here: a global
# commit.gpgsign, a template directory, or an alias would decide whether this suite
# passes on their machine and not on anyone else's.
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

# The secret-shaped value the stub prints. It is a literal here and in the stub;
# a shared variable would let both drift to empty together and assert nothing.
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
git -C "$t/repo" remote add origin "$base/remote/origin.git"
git -C "$t/repo" push -q origin HEAD:refs/heads/main >/dev/null 2>&1 || {
	printf 'FAIL  could not publish main to the bare remote\n' >&2; exit 1; }

# The configuration a correct clone carries. Each bad case removes exactly one.
git -C "$t/repo" config core.hooksPath .githooks
git -C "$t/repo" config armature.forgeCli forge-stub
git -C "$t/repo" config armature.forgeScopes 'repo workflow'
git -C "$t/repo" config armature.worktreeDir .worktree
git -C "$t/repo" config armature.baseRef origin/main

# The stub forge tool. It answers `auth status` the way the real tools do — a
# "Token scopes:" line, and a token line this suite asserts is never echoed — and
# refuses everything else, so a pre-flight that asks it something undocumented
# fails here rather than silently succeeding against a real tool.
cat > "$t/bin/forge-stub" <<STUB
#!/bin/sh
d=\$(CDPATH= cd -- "\$(dirname -- "\$0")/.." && pwd)
authed=\$(sed -n 's/^authed=//p' "\$d/forge-state")
scopes=\$(sed -n 's/^scopes=//p' "\$d/forge-state")
if [ "\${1:-}" = auth ] && [ "\${2:-}" = status ]; then
	if [ "\$authed" != 1 ]; then
		echo 'You are not logged in to any hosts. Run: forge-stub auth login' >&2
		exit 1
	fi
	echo 'forge.invalid'
	echo '  Logged in to forge.invalid account demo (keyring)'
	echo '  - Active account: true'
	echo '  - Token: $SENTINEL'
	echo "  - Token scopes: \$scopes"
	exit 0
fi
echo "forge-stub: unsupported invocation: \$*" >&2
exit 2
STUB
chmod +x "$t/bin/forge-stub"
printf 'authed=1\nscopes=%s\n' "'repo', 'workflow'" > "$t/forge-state"

# --- the cases -------------------------------------------------------------

# run_case NAME WANT_STATUS EXPECT_SUBSTRING
# NAME's good*/bad* prefix is not what sets the expectation here — WANT_STATUS is,
# and the prefix only names the case. EXPECT_SUBSTRING is asserted against the
# combined output.
run_case() {
	_name=$1; _want=$2; _expect=$3
	_w=$base/$_name
	cp -R "$t" "$_w" || { printf 'FAIL  %s: could not copy the template\n' "$_name" >&2; fail=$((fail + 1)); return; }
	_r=$_w/repo

	# The one mutation that makes this case its case.
	case $_name in
	good) : ;;
	bad-forge-cli-unset)   git -C "$_r" config --unset armature.forgeCli ;;
	bad-scopes-unset)      git -C "$_r" config --unset armature.forgeScopes ;;
	bad-credential)        printf 'authed=0\nscopes=\n' > "$_w/forge-state" ;;
	bad-scope-revoked)     printf 'authed=1\nscopes=%s\n' "'workflow'" > "$_w/forge-state" ;;
	bad-worktree-unset)    git -C "$_r" config --unset armature.worktreeDir ;;
	bad-worktree-unwritable) chmod 500 "$_r/.worktree" ;;
	bad-worktree-occupied) mkdir -p "$_r/.worktree/$TASK"; echo x > "$_r/.worktree/$TASK/in-progress" ;;
	bad-base-unfetchable)  git -C "$_r" config armature.baseRef origin/no-such-branch ;;
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
	if [ -z "$_why" ]; then
		printf '%s\n' "$_out" | grep -q -- "$_expect" \
			|| _why="exit $_got was right, but the output never named: $_expect"
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
		[ "$verbose" -eq 1 ] && printf 'ok    %s\n' "$_name"
	else
		fail=$((fail + 1))
		printf 'FAIL  %s: %s\n' "$_name" "$_why" >&2
		printf '%s\n' "$_out" | sed 's/^/      | /' >&2
	fi
}

run_case good                    0 'preflight: OK'
run_case bad-forge-cli-unset     1 'armature.forgeCli'
run_case bad-scopes-unset        1 'armature.forgeScopes'
run_case bad-credential          1 'no authenticated account'
run_case bad-scope-revoked       1 'missing scope: repo'
run_case bad-worktree-unset      1 'armature.worktreeDir'
run_case bad-worktree-occupied   1 'already in use'
run_case bad-base-unfetchable    1 'no-such-branch'
run_case bad-hookspath-unset     1 'core.hooksPath'
run_case bad-hookspath-outside   1 'outside this working tree'

# Root can write through a 0500 directory, so the case would assert nothing there.
# Skipped loudly rather than silently: a suite that quietly drops a case is the
# false green this kit keeps meeting.
if [ "$(id -u)" = 0 ]; then
	printf 'skip  bad-worktree-unwritable: running as root, which writes through a read-only directory\n'
else
	run_case bad-worktree-unwritable 1 'not writable'
fi

# Coverage floor. A suite that ran nothing, or that lost every refusal case to a
# rename, would otherwise report success having proved nothing.
if [ "$((pass + fail))" -lt 2 ]; then
	printf 'FAIL  fewer than two cases ran — the suite is misconfigured\n' >&2
	fail=$((fail + 1))
fi

printf 'preflight-cases: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && exit 0 || exit 1
