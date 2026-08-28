# #23 — Housekeeping: remove the stale worktree, prune merged branches, ignore the worktree dir

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:43Z.*

---

Part of #16.

## Goal

Make the kit obey the kit: remove the stale worktree, prune the merged branches, and ignore the worktree directory.

`docs/engineering-discipline.md` §"Starting a task" says to remove a worktree once its branch is merged or abandoned, and says the `‹worktree dir›` is gitignored. Neither holds here today.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16.

## Solution note (R3)

- **Chosen:** remove the stale worktree and its branch, delete the four merged branches, and add the worktree directory to `.gitignore`.
- **Rejected:** *leave them* — the kit's credibility is its only product; a kit that breaks its own rule in its own repository teaches an adopter to do the same.
- **Decision record:** this issue. Pure hygiene.

## Acceptance criteria

- [ ] The stale worktree at `.claude/worktrees/feat+test-section-scaffold` is gone, with its branch.
- [ ] The merged branches `ci/pr-link-check`, `feat/enforce-quality-gate`, `feat/prd-issue-workflow-traceability`, and `feat/test-section-scaffold` are deleted, local and remote.
- [ ] `.gitignore` ignores the worktree directory.
- [ ] The task line moves from backlog to completed in the same PR.




---

### Comment — pharzam — 2026-08-26T15:00:56Z

**Two corrections to this issue's scope, found while planning.**

**1. Six merged branches, not four.** The remote has six, and every one is already merged into `origin/main`:

```
ci/pr-link-check
docs/remove-upstream-dependency      <- missed by this issue
feat/enforce-quality-gate
feat/prd-issue-workflow-traceability
feat/r12-slice-and-prioritize        <- missed by this issue
feat/test-section-scaffold
```

`git branch -r --no-merged origin/main` returns nothing, so pruning all six is safe. The local `worktree-feat+test-section-scaffold` branch goes with the stale worktree.

**2. One real broken link, folded into this slice.** `docs/ci/tests/pr-link/README.md:3` links `../pr-link-lint.sh`, which resolves to `docs/ci/tests/pr-link-lint.sh`. That file does not exist; the linter is two levels up at `docs/ci/pr-link-lint.sh`. The link needs `../../`.

It belongs here because this slice is "make the kit obey the kit", and `engineering-discipline.md` §"Keeping documentation current" calls a stale document a defect. A separate issue for a two-character fix would be ceremony.

A link check over every tracked Markdown file found no other broken relative link. The remaining hits are deliberate template placeholders (`NNNN-short-title.md`, `<id>.md`).


---

### Comment — pharzam — 2026-08-27T11:47:10Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

This issue's own defect class is back:

- `2cd70ee:.gitignore` holds one entry, `.obsidian/`. The `.worktree/` line is gone.
- `.worktree/` exists untracked and unignored, holding two worktrees.
- Two stale local branches exist: `chore/t-5r2q-review-debt` and `fix/t-3k8w-runner-asserts-reason`.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1. Phase 0 clears the current leftovers by hand today; the `.gitignore` line that stops them returning re-lands with this slice.
