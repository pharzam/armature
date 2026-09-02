# T-x1zp — The linters read this repository's files, not a nested checkout's

Tracks [issue #80](https://github.com/pharzam/armature/issues/80). Completed line:
[completed.md](completed.md). No backlog line ever named this task.

## Why

`audit-record-lint.sh` listed every file under the root with `find`, and
`link-lint.sh` did the same for Markdown. Both walked into a nested checkout — a
per-task worktree under `.claude/worktrees/`, a vendored copy, a submodule — so a
stale copy of a cited file could outrank the real one, or an undrifted copy could
hide a real drift in silence. `agents-lint.sh` globs two levels deep and never
walks the tree, so this is one fix in two places, not three.

## Decision (R3)

**Selected:** the file list is what git lists for this repository —
`git ls-files -z --cached --others --exclude-standard`, NUL-delimited so git never
quotes a name holding a quote, a backslash or a control character, with
`[ -f ] && [ ! -L ]` so a deleted-but-indexed path is not a candidate and a symlink
is not followed — and a POSIX `find` that prunes any directory holding a `.git`
entry stands in whenever that list cannot be trusted. Git's
index is the deterministic definition of "this repository's files" (R5); a nested
checkout is one entry to it and is never descended. The plan review confirmed it
over `find`-only, a heuristic that misses a vendored copy with no metadata and
forks a shell per directory on every run, and over pruning `.claude/` by name, the
wrong class: a nested checkout at `vendor/D` still resolved. The fallback triggers when this directory
is not itself the repository root, and again on an empty list. Testing `rev-parse`
alone was wrong — a kit vendored inside a larger repository gets a successful
`rev-parse`, and the first prototype left 83 `FAIL` lines there (plan review,
finding 1). Testing for an empty list alone was also wrong, and only round 2
measured why: an outer ignore of `tests/` leaves the list non-empty and 163
documents unread, and one of `*.md` leaves every document unread. What decides is
not which files are missing but whose ignore rules chose them, so the guard asks
whether the kit owns the repository it is being listed from. The shape is copied into both linters, not shared;
[`links/README.md`](../links/README.md) limit 9 records that cost.

**Limit.** `--exclude-standard` reads `.git/info/exclude` and the global ignore
file, neither versioned, so two operators on one commit can get different lists.
The operator's checkout drops its worktrees through that exclude file
(`**/.claude/worktrees/`), not through the nested-checkout collapse; the self-test
shows the collapse in a clean tree instead.

## Measured, 2026-09-02

| Tree | `audit-record-lint`, before → after | `link-lint`, before → after |
|---|---|---|
| Clean clone of `6c3f5d0` | `OK  44 claims` → same; 1.6 s → 2.6 s | `OK  739 links resolved` → same; 4.4 s → 4.3 s |
| Byte copy of the operator's checkout at `6c3f5d0`, **nine** worktrees under `.claude/worktrees/`, taken at 14:27 | exit 1, **14** `FAIL` lines, the first `FAIL  citation adr-lint.sh:315 points at a BLANK line -- it has DRIFTED; re-derive it from the construct, not by arithmetic (DoD 2)` → `OK  44 claims`; 3.1 s → 2.5 s | `OK  7395 links resolved` in 43.5 s → `OK  739 links resolved` in 4.2 s |
| The operator's checkout itself, read-only, the fixed `link-lint` pointed at it | — | `OK  743 links resolved`, 4.4 s |
| Worktree `T-x1zp` at the fix | `OK  44 claims` | `OK  750 links resolved`; seven links added by this task's documents |

In the byte copy the fixed list holds **530** entries, every one a regular file.
The self-test, `docs/tests/nested-checkout-check.sh`, runs **18** cases: 6 were red
against the linters at `6c3f5d0` — cases 1, 4, 4′, two of the three in 5, and the
`link-lint` half of 6; the exact lines are on #80 — and all 18 are green at the fix,
on macOS with BSD `find`. CI runs it on GNU `find`. The other checks stayed green
in the worktree throughout: `adr-lint`, `prd-lint`, `agents-lint`, and
`run-discipline-tests` at 104 passed.

**Withdrawn** from the plan comment, replaced by the plan review's measurements of
2026-09-02 on a clean clone of `6c3f5d0`: "8 of the 14 failures" (all 14 were a
line past the end of the 139-line `resolve-72` copy), "7 ignored files" (15 files
across 6 collapsed entries), "580 directories" (466), and the plan's account of
why the operator's checkout drops its worktrees (see the limit above). The link
counts and times the plan (4390, 24.7 s, five worktrees) and the review (5890,
29.2 s, seven) measured on the operator's checkout are superseded by the row
above; each grows with the worktree count, which is the defect itself.

## Verdict

Both linters now list this repository's files the way git does — but only when this
directory is itself the repository root — and fall back to a pruning walk when it is
not, or when git lists nothing, so a nested checkout under the root is never read. The self-test drives both against a real nested checkout, a linked worktree,
a plain directory, no checkout at all, and a vendored-and-ignored kit, and CI runs
it. The 14 false failures in the operator's checkout are gone and `link-lint` there
drops from 43.5 s to 4.2 s as a side effect.

The **silent** direction — a nested copy hiding a real drift — is asserted, by case
7, and an earlier draft of this record said it could not be. That draft reasoned
that the block reads the first candidate the walk returns and that no fixture can
fix the file system's order. Round 2 measured the code instead of reasoning about
it: block 2b accepts **any** candidate with enough lines rather than the first, and
block 2c — the one that reads the first — runs only for a `*.sh` suffix. So a
citation into a `.md` past the real file's end is resolved by a longer copy inside
the nested checkout whatever the order, which is exit 0 before the fix and exit 1
after. Recording a gap honestly was better than claiming a case that passes either
way, and measuring the code was better still.
