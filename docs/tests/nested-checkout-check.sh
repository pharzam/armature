#!/bin/sh
#
# nested-checkout-check.sh — prove that link-lint.sh reads THIS repository's files
# and never a nested checkout's, in a throwaway repository that holds one.
#
# WHY THIS IS NOT A FIXTURE. A fixture directory cannot hold a nested checkout:
# `git add` drops a `.git` path silently, refuses a checkout with no commit, and
# stores one with a commit as a gitlink without its contents. Neither shape
# run-discipline-tests.sh dispatches -- run_dir_suite, a case directory, or
# run_file_suite, a single file -- can carry one. So this builds a repository, adds
# a nested checkout with `git init` and one commit, a linked worktree whose `.git`
# is a FILE, and a plain directory, and drives link-lint against each. It reports
# how many cases it ran rather than carrying a count here to go stale.
#
# What link-lint lists is what git lists for THIS repository -- tracked, plus
# untracked and not ignored -- so a copy of the tree inside a nested checkout or a
# linked worktree is one directory entry and its Markdown is never read. A dead
# link placed inside one must therefore stay invisible, while a dead link in a
# PLAIN directory, a quoted filename, or the kit vendored inside a larger repository
# must still be found. Those are the two directions this exercises.
#
# It works in a fresh `mktemp -d`, removed afterwards; it never touches the
# repository it lives in and never reads or writes your git config. It is NOT in
# the pre-commit hook: it needs `git init`, a temp directory and real commits, past
# the "reads only text" bar every hook step meets. CI runs it, on GNU find, which
# is what exercises the fallback walk (.github/workflows/ci.yml).
#
# Usage:  sh docs/tests/nested-checkout-check.sh
# Exit status: 0 = every case behaved, 1 = one or more did not.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
L_src="$script_dir/../links/link-lint.sh"
[ -f "$L_src" ] || { printf 'FAIL  cannot find %s\n' "$L_src" >&2; exit 1; }
base=$(mktemp -d) || { printf 'FAIL  mktemp -d failed\n' >&2; exit 1; }
repo="$base/repo"
bad=0
seen=0
skipped=0
cleanup() { cd / || :; rm -rf "$base"; }
trap cleanup EXIT
# Git must never find a repository ABOVE the throwaway tree: the fallback cases
# remove the root .git and rely on git then seeing nothing.
export GIT_CEILING_DIRECTORIES="$base"

mkdir -p "$repo/docs/links" || exit 1
cp "$L_src" "$repo/docs/links/" || exit 1
# One clean document with one resolvable link, so a clean tree passes and prints
# the baseline summary every "not read" case below must reproduce, count included.
# A same-file anchor keeps it self-contained -- no second file to move or copy.
printf '# Home\n\nBack to [the top](#home).\n' > "$repo/docs/home.md"
# The dead link the nested checkout, worktree, plain directory and odd names carry.
# Its `[gone](no-such-file.md)` sits on line 3, so a case that reads it fails L1 at
# that file's :3.
dead='# dead

See [gone](no-such-file.md).
'
mkrepo() {
	git -C "$1" init -q && git -C "$1" add -A \
		&& git -C "$1" -c user.email=nested@test.invalid -c user.name=nested commit -qm init
}
mkrepo "$repo" || exit 1

# check LABEL WANT-STATUS WANT-TEXT SCRIPT — run SCRIPT, judge its exit status and,
# when WANT-TEXT is not empty, demand that text in its output. Status AND wording:
# a linter that prints the right FAIL and exits 0 must not read as ok, nor one
# that exits 1 for some other reason.
check() {
	seen=$((seen + 1))
	last_out=$(sh "$4" 2>&1) && _st=0 || _st=$?
	if [ "$_st" -ne "$2" ]; then
		printf 'FAIL  %s: wanted exit %s, got %s\n' "$1" "$2" "$_st" >&2
	elif [ -n "$3" ] && ! printf '%s\n' "$last_out" | grep -Fq -- "$3"; then
		printf 'FAIL  %s: exit %s as wanted, but the output does not say: %s\n' "$1" "$2" "$3" >&2
	else
		printf 'ok    %s\n' "$1"
		return 0
	fi
	printf '%s\n' "$last_out" | sed 's/^/      /' >&2
	bad=1
}
L="$repo/docs/links/link-lint.sh"

# 1. control: the clean tree, before any nested checkout exists. The link summary
# it prints is the one every later case must reproduce, count included.
check '1 control: clean tree' 0 'link-lint: OK' "$L"
clean_links=$(printf '%s\n' "$last_out" | grep '^link-lint: OK')

# The nested checkout: a real git checkout (`.git` is a DIRECTORY) holding a dead
# link that exists nowhere in this repository's own tree.
mkdir -p "$repo/nested/docs"
printf '%s' "$dead" > "$repo/nested/docs/dead.md"
mkrepo "$repo/nested" || exit 1

# 2. a plain nested directory with no .git entry is still walked, so ITS dead link
#    is found -- the read direction.
mkdir -p "$repo/plain/docs"
printf '%s' "$dead" > "$repo/plain/docs/dead.md"
check '2 plain directory: its dead link is found' 1 'L1: plain/docs/dead.md:3' "$L"
rm -rf "$repo/plain"

# 3. link-lint does not read the dead link inside the nested checkout.
check '3 dead link inside the nested checkout is not read' 0 "$clean_links" "$L"

# 4. the same, with a linked worktree, whose .git is a FILE.
git -C "$repo" worktree add -q "$repo/.claude/worktrees/W" -b w || exit 1
printf '%s' "$dead" > "$repo/.claude/worktrees/W/docs/dead.md"
check '4 dead link inside a linked worktree is not read' 0 "$clean_links" "$L"

# 5-6. root .git removed: the same verdicts, through the fallback walk.
mv "$repo/.git" "$base/parked.git" || exit 1
check '5 no checkout: nested dead link still not read' 0 "$clean_links" "$L"
mkdir -p "$repo/plain/docs"
printf '%s' "$dead" > "$repo/plain/docs/dead.md"
check '6 no checkout: plain directory still walked' 1 'L1: plain/docs/dead.md:3' "$L"
rm -rf "$repo/plain"
mv "$base/parked.git" "$repo/.git" || exit 1

# 7. the kit vendored inside a larger repository, its path gitignored: git answers
#    (rev-parse succeeds) and lists nothing, and link-lint must still work off the
#    fallback walk because THIS directory is not the repository root.
outer="$base/outer"
mkdir -p "$outer" && printf 'kit/\n' > "$outer/.gitignore"
cp -R "$repo" "$outer/kit" && rm -rf "$outer/kit/.git"
mkrepo "$outer" || exit 1
n=$(cd "$outer/kit" && git ls-files --cached --others --exclude-standard | wc -l | tr -d ' ')
if ! git -C "$outer/kit" rev-parse --show-toplevel >/dev/null 2>&1 || [ "$n" -ne 0 ]; then
	printf 'FAIL  case 7 setup: wanted a checkout that lists nothing under the ignored path, got %s files listed\n' "$n" >&2
	bad=1
fi
check '7 vendored and gitignored: link-lint' 0 "$clean_links" "$outer/kit/docs/links/link-lint.sh"

# 8. a SYMLINK is not followed, so one pointing into the nested checkout cannot put
#    back the hiding this walk removes.
if ln -s "../nested/docs/dead.md" "$repo/docs/linked.md" 2>/dev/null; then
	check '8 symlink into the nested checkout is not read' 0 "$clean_links" "$L"
	rm -f "$repo/docs/linked.md"
else
	skipped=$((skipped + 1))
	printf 'skip  8 symlink into the nested checkout (this file system took no symlink)\n'
fi

# 9. a filename holding a quote and a backslash is still read. Without `-z` git
#    prints such a name quoted, and a quoted name matches no file, so the document
#    is silently skipped; the NUL-delimited list keeps it readable.
odd='docs/od"d\\name.md'
if printf '%s' "$dead" > "$repo/$odd" 2>/dev/null && [ -f "$repo/$odd" ]; then
	check '9 a quoted filename is still read' 1 'L1: docs/od' "$L"
	rm -f "$repo/$odd"
else
	skipped=$((skipped + 1))
	printf 'skip  9 a quoted filename (this file system took no quote in a name)\n'
fi

# 10. the kit vendored where the outer ignore names something OTHER than the kit
#     path. The list is non-empty and still not this repository's, which the root
#     test closes: THIS directory is not the toplevel, so the fallback walk stands
#     in and reads the clean tree.
outer2="$base/outer2"
mkdir -p "$outer2" && printf 'kit/docs/links/\n' > "$outer2/.gitignore"
cp -R "$repo" "$outer2/kit" && rm -rf "$outer2/kit/.git"
mkrepo "$outer2" || exit 1
check '10 vendored, a partial outer ignore: link-lint' 0 "$clean_links" "$outer2/kit/docs/links/link-lint.sh"

[ "$seen" -gt 0 ] || { printf 'FAIL  no case ran -- this proved nothing\n' >&2; exit 1; }
if [ "$bad" -eq 0 ]; then
	if [ "$skipped" -gt 0 ]; then
		printf 'nested-checkout-check: OK  %d cases behaved, %d skipped\n' "$seen" "$skipped"
	else
		printf 'nested-checkout-check: OK  %d cases behaved\n' "$seen"
	fi
	exit 0
fi
exit 1
