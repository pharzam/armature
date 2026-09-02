#!/bin/sh
#
# nested-checkout-check.sh — prove that audit-record-lint.sh and link-lint.sh read
# THIS repository's files and never a nested checkout's, in a throwaway repository
# that holds one.
#
# WHY THIS IS NOT A FIXTURE. A fixture directory cannot hold a nested checkout:
# `git add` drops a `.git` path silently, refuses a checkout with no commit, and
# stores one with a commit as a gitlink without its contents. Neither shape
# run-discipline-tests.sh dispatches -- run_dir_suite, a case directory, or
# run_file_suite, a single file -- can carry one. So this builds a repository, adds
# a nested checkout with `git init` and one commit, a linked worktree whose `.git`
# is a FILE, and a plain directory, and drives both linters against each. It
# reports how many cases it ran rather than carrying a count here to go stale.
#
# The record it lints is its own, not the docs/tasks/tests/good set: that record's
# two `.sh` citations name comment lines of the real adr-lint.sh, and with the
# glossary at docs/glossary.md, which turns the drift check on, every case would
# report a comment where the row names a construct. So the cited file is written
# here, six lines of code, and the record cites two of them.
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
for f in "$script_dir/../tasks/audit-record-lint.sh" "$script_dir/../links/link-lint.sh"; do
	[ -f "$f" ] || { printf 'FAIL  cannot find %s\n' "$f" >&2; exit 1; }
done
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

mkdir -p "$repo/docs/tasks" "$repo/docs/links" "$repo/docs/tools" || exit 1
cp "$script_dir/../tasks/audit-record-lint.sh" "$repo/docs/tasks/" || exit 1
cp "$script_dir/../links/link-lint.sh" "$repo/docs/links/" || exit 1
# The cited file, every line code; the glossary, backlog and completed log the
# record needs; then the record itself, with the two citations block 2b resolves.
awk 'BEGIN { for (i = 1; i <= 6; i++) print "x=" i }' > "$base/cited.clean"
cp "$base/cited.clean" "$repo/docs/tools/cited.sh"
printf '| Term | Abbr. | Description | Example |\n|--|--|--|--|\n| Identifier | `ID` | The handle that names one record. | The task ID. |\n' > "$repo/docs/glossary.md"
printf '# Backlog\n\n## Next\n\n- **T-8b4r** — Add fixtures ([#45](https://github.com/pharzam/armature/issues/45)); see [completed](completed.md)\n' > "$repo/docs/tasks/backlog.md"
printf '# Completed\n\n## Log\n\n- **2026-09-02** — **T-3v9q** — Recorded ([#55](https://github.com/pharzam/armature/issues/55))\n' > "$repo/docs/tasks/completed.md"
cat > "$base/record.clean" <<'EOF'
# T-3v9q — the self-test's own record

## In plain terms

> Two of their three claims stand.

## Why

**Verification result.** 2 of 3 claims stand — 1 as written, 1 with a correction.
One is refuted.

## Definition of Done

This task has **two** Definition of Done items.

| # | Item | Covered by |
| - | ---- | ---------- |
| 1 | All 3 claims recorded with a verdict | `audit-record-lint.sh` block 1 |
| 2 | Every standing claim cites a file and a line | `audit-record-lint.sh` block 2 |

## Test traceability

| Test ID | Level | Covers | Guardrail | Task | Status |
| ------- | ----- | ------ | --------- | ---- | ------ |
| `audit-record-lint.sh` block 1 | discipline | DoD 1 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 2 | discipline | DoD 2 | — | `T-3v9q` | green |

## Findings

| ID | Finding | Verdict | Severity |
| -- | ------- | ------- | -------- |
| M1 | The construct is at `cited.sh:3`. | Stands | low |
| M2 | The other construct is at `cited.sh:5`, one line lower than reported. | Corrected | low |
| M3 | The two paths diverge. | Refuted | none |

## Already recorded — finding to abandoned issue

| Findings here | Already written up in |
| ------------- | --------------------- |
| M1, M2 | [#45](https://github.com/pharzam/armature/issues/45) |

## Corrections to the reports

- The other construct is at `cited.sh:5`.

## Out of scope (follow-ups)

Scheduled under **Next**: `T-8b4r`.
EOF
# cite CITATION — install the record with its first citation replaced by CITATION.
cite() { sed "s|cited.sh:3|$1|" "$base/record.clean" > "$repo/docs/tasks/T-3v9q.md"; }
cite cited.sh:3
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
A="$repo/docs/tasks/audit-record-lint.sh"
L="$repo/docs/links/link-lint.sh"

# control: the clean tree, before any nested checkout exists. The link summary it
# prints is the one every later link case must reproduce, count included.
check 'control: clean tree, audit-record-lint' 0 'audit-record-lint: OK' "$A"
check 'control: clean tree, link-lint' 0 'link-lint: OK' "$L"
clean_links=$(printf '%s\n' "$last_out" | grep '^link-lint: OK')

# The nested checkout: a file that exists nowhere else, a dead link, and an
# undrifted copy of the cited file.
mkdir -p "$repo/nested/tools" "$repo/nested/docs/tools"
printf 'x=1\n' > "$repo/nested/tools/nested-only.sh"
printf '%s' "$dead" > "$repo/nested/docs/dead.md"
# The nested copy is LONGER than the real file on purpose. Block 2b picks the
# first candidate with enough lines, so a citation past the real file's end
# resolves through a longer nested copy and passes -- silently, and whatever
# order the directories happen to come back in. A drift-and-blank-line case does
# not test that: which candidate wins there depends on directory order, so it can
# pass against the unfixed linter on some disks. Length is order-independent.
awk 'BEGIN { for (i = 1; i <= 40; i++) print "x=" i }' > "$repo/nested/docs/tools/cited.sh"
mkrepo "$repo/nested" || exit 1

# 1. a citation that resolves only inside the nested checkout must fail
cite nested-only.sh:1
check '1 citation resolving only inside the nested checkout' 1 'citation nested-only.sh:1 names no file in the tree' "$A"
# 2. a citation past the real file's end fails, with a longer copy sitting inside
#    the nested checkout.
cite cited.sh:20
check '2 line past the real file, longer nested copy' 1 'citation cited.sh:20 points at a BLANK line' "$A"
# 2b. a drift in the real file is reported although the nested copy holds the
#     construct.
cite cited.sh:3
awk 'NR == 3 { print "" } { print }' "$base/cited.clean" > "$repo/docs/tools/cited.sh"
check '2b drift in the real file, undrifted nested copy' 1 'citation cited.sh:3 points at a BLANK line' "$A"
cp "$base/cited.clean" "$repo/docs/tools/cited.sh"
#
# Neither of those two proves the SILENT direction -- that a nested copy cannot
# HIDE a real drift -- because both pass against the unfixed linter as well. Case
# 7 below does prove it: block 2b accepts ANY candidate with enough lines rather
# than the first, and block 2c, the one that reads the first, runs only for a
# `*.sh` suffix, so a `.md` citation past the real file's end is resolved by a
# longer nested copy whatever order the walk returns. An earlier draft of this
# comment argued no fixture could prove it; that was reasoning where measuring was
# available, and case 7 is the measurement.
# 3. a plain nested directory with no .git entry is still walked, both ways
mkdir -p "$repo/plain/docs"
printf '%s' "$dead" > "$repo/plain/docs/dead.md"
printf 'x=1\n' > "$repo/plain/plain-only.sh"
cite plain-only.sh:1
check '3 plain directory: its dead link is found' 1 'L1: plain/docs/dead.md:3' "$L"
check '3 plain directory: its file resolves a citation' 0 'audit-record-lint: OK' "$A"
rm -rf "$repo/plain"
cite cited.sh:3
# 4. link-lint does not read the dead link inside the nested checkout
check '4 dead link inside the nested checkout is not read' 0 "$clean_links" "$L"
# 4'. the same, with a linked worktree, whose .git is a FILE
git -C "$repo" worktree add -q "$repo/.claude/worktrees/W" -b w || exit 1
printf '%s' "$dead" > "$repo/.claude/worktrees/W/docs/dead.md"
check "4' dead link inside a linked worktree is not read" 0 "$clean_links" "$L"
# 5. root .git removed: the same verdicts, through the fallback walk
mv "$repo/.git" "$base/parked.git" || exit 1
cite nested-only.sh:1
check '5 no checkout: nested-only citation still fails' 1 'names no file in the tree' "$A"
check '5 no checkout: nested dead link still not read' 0 "$clean_links" "$L"
mkdir -p "$repo/plain/docs"
printf '%s' "$dead" > "$repo/plain/docs/dead.md"
check '5 no checkout: plain directory still walked' 1 'L1: plain/docs/dead.md:3' "$L"
rm -rf "$repo/plain"
cite cited.sh:3
mv "$base/parked.git" "$repo/.git" || exit 1
# 6. the kit vendored inside a larger repository, its path gitignored: git answers
#    (rev-parse succeeds) and lists nothing, and the linters must still work
outer="$base/outer"
mkdir -p "$outer" && printf 'kit/\n' > "$outer/.gitignore"
cp -R "$repo" "$outer/kit" && rm -rf "$outer/kit/.git"
mkrepo "$outer" || exit 1
n=$(cd "$outer/kit" && git ls-files --cached --others --exclude-standard | wc -l | tr -d ' ')
if ! git -C "$outer/kit" rev-parse --show-toplevel >/dev/null 2>&1 || [ "$n" -ne 0 ]; then
	printf 'FAIL  case 6 setup: wanted a checkout that lists nothing under the ignored path, got %s files listed\n' "$n" >&2
	bad=1
fi
check '6 vendored and gitignored: audit-record-lint' 0 'audit-record-lint: OK' "$outer/kit/docs/tasks/audit-record-lint.sh"
check '6 vendored and gitignored: link-lint' 0 "$clean_links" "$outer/kit/docs/links/link-lint.sh"

# 7. the SILENT direction, order-independently. Block 2b accepts ANY candidate
#    with enough lines rather than the first, and block 2c -- the one that reads
#    the first candidate -- runs only for a `*.sh` suffix. So a citation into a
#    `.md` past the real file's end is resolved by a LONGER copy inside the
#    nested checkout, whatever order the walk returns. An earlier draft of this
#    script recorded the silent direction as unprovable; it is provable, and this
#    is the construction.
printf '# Doc\n\nshort\n' > "$repo/docs/short.md"
awk 'BEGIN { print "# Doc"; for (i = 1; i <= 40; i++) print "line " i }' > "$repo/nested/docs/short.md"
cite short.md:20
check '7 silent: .md line past the real file, longer nested copy' 1 'citation short.md:20' "$A"
rm -f "$repo/docs/short.md" "$repo/nested/docs/short.md"
cite cited.sh:3
# 8. a SYMLINK is not followed, so one pointing into the nested checkout cannot
#    put back the hiding this fix removes.
if ln -s "../nested/docs/dead.md" "$repo/docs/linked.md" 2>/dev/null; then
	check '8 symlink into the nested checkout is not read' 0 "$clean_links" "$L"
	rm -f "$repo/docs/linked.md"
else
	skipped=$((skipped + 1))
	printf 'skip  8 symlink into the nested checkout (this file system took no symlink)\n'
fi
# 9. a filename holding a quote and a backslash is still read. Without `-z` git
#    prints such a name quoted, and a quoted name matches no file, so the document
#    is silently skipped. An earlier draft of this script said no case could reach
#    this; round 3 built one, and this is it.
odd='docs/od"d\\name.md'
if printf '%s' "$dead" > "$repo/$odd" 2>/dev/null && [ -f "$repo/$odd" ]; then
	check '9 a quoted filename is still read' 1 'L1: docs/od' "$L"
	rm -f "$repo/$odd"
else
	skipped=$((skipped + 1))
	printf 'skip  9 a quoted filename (this file system took no quote in a name)\n'
fi
# 10. the kit vendored where the outer ignore names something OTHER than the kit
#     path. The list is non-empty and still not this repository's, which a guard
#     testing only for `docs/` in the list did not catch.
outer2="$base/outer2"
mkdir -p "$outer2" && printf 'kit/docs/tasks/\n' > "$outer2/.gitignore"
cp -R "$repo" "$outer2/kit" && rm -rf "$outer2/kit/.git"
mkrepo "$outer2" || exit 1
check '10 vendored, a partial outer ignore: audit-record-lint' 0 'audit-record-lint: OK' "$outer2/kit/docs/tasks/audit-record-lint.sh"
check '10 vendored, a partial outer ignore: link-lint' 0 "$clean_links" "$outer2/kit/docs/links/link-lint.sh"

# A. the audit side of the root guard: the outer ignore hides the CITED file's
#    directory, so a list taken from the outer repository cannot resolve the
#    citation; with the root test the walk stands in and it resolves.
outer3="$base/outer3"
mkdir -p "$outer3" && printf 'kit/docs/tools/\n' > "$outer3/.gitignore"
cp -R "$repo" "$outer3/kit" && rm -rf "$outer3/kit/.git"
mkrepo "$outer3" || exit 1
check 'A vendored, outer ignore hides the cited file: audit-record-lint' 0 'audit-record-lint: OK' "$outer3/kit/docs/tasks/audit-record-lint.sh"

# B. the audit side of the symlink refusal: a symlink pointing into the nested
#    checkout must not resolve a citation.
cite nested-only.sh:1
if ln -s "../../nested/tools/nested-only.sh" "$repo/docs/tools/nested-only.sh" 2>/dev/null; then
	check 'B symlink into the nested checkout does not resolve a citation' 1 'names no file in the tree' "$A"
	rm -f "$repo/docs/tools/nested-only.sh"
else
	skipped=$((skipped + 1))
	printf 'skip  B symlink into the nested checkout (this file system took no symlink)\n'
fi
cite cited.sh:3

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
