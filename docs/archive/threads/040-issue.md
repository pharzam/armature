# #40 — Six shipped statements are not true of main

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T08:13:23Z.*

---

Found by the gate-step-5 rounds on #33 — round 2 (F4, F5, F6), round 3 (M1, M3, M5), round 1 (m2). Part of #16.

## The defect

Six statements in shipped documents are not true of `main` at `999765f`. Each one
was ticked as "R10 sync holds" in a pull request that merged with a self-review
only.

| # | Where | Says | Truth |
| - | ----- | ---- | ----- |
| 1 | `README.md:95-96` | "the ADR linter, PRD linter, and glossary linter run green out of the box" | Five run green out of the box, all wired into the hook and both CI templates. |
| 2 | `README.md:49` | "The issue-first workflow (**R1–R11**)" | R1–R12 since `T-9p4c`. `README.md:33` and `:46` — the lines immediately above and below — both say R1–R12. The file disagrees with itself three lines apart. |
| 3 | `.githooks/pre-commit:9` | "It runs the ADR and PRD linters out of the box" | It runs five checks. The hook body was edited in the same pull request, eleven lines below this comment. |
| 4 | `docs/ci/README.md:53` | "the way `adr-lint`, `prd-lint`, and `glossary-lint` are" | The table five lines above lists all five. |
| 5 | `docs/prd/README.md:59`, `backlog-lint.sh:8` | the linters run "anywhere with no toolchain … green on a fresh kit" | `glossary-lint` needs a git checkout, and fails — taking the runner with it — in a directory with no `.git`. Its message then says "git add" when there is no repository to add to. |
| 6 | `docs/glossary-lint.sh:9-11` | the table check enforces "no empty cell" | Columns 3 and 4 only; column 2 (`Abbr.`) is never checked. |

Item 5 is the interesting one: the behaviour is **right** (#29 correctly rejected
scanning untracked files), so the fix is the claim, not the code — plus a distinct
message for "not a git repository".

## Why this is its own issue and not a footnote

`AGENTS.md:32`: *"Never land a change that leaves a document stale. Same pull
request, or not at all."* Items 1, 3 and 4 were made stale **by the pull request
that edited the file next to them**. #25 had made "all four counts agree" an
explicit acceptance box; #28 inherited it, ticked it, and missed three lines. A box
ticked by intention rather than by check is the failure mode this whole audit is
about, and R10 says a conflict between governing documents *stops work*.

## Duplicate check (R2)

- [x] Searched open **and** closed issues. #31 fixed three `AGENTS.md` contradictions;
      none of these six is among them. Not a duplicate.

## Solution note (R3)

- **Chosen:** correct all six, and where a count or an enumeration caused the drift,
  **delete it** rather than update it. A count is the first thing to go stale — this
  one already said "three" before it said "five". Point at the one place that
  lists the linters instead of restating the list.
- **Rejected:** *update the numbers and keep the enumerations* — that is what the
  last three pull requests did, and it drifted again within one tranche.
- **Deliberately not changed:** `docs/adr/0003-adopt-issue-first-workflow.md:22`
  also says R1–R11 and is **correct as it stands** — an ADR is a dated record, and
  `engineering-discipline.md:236-238` says a correction is a new record, not an
  edit. Same for `docs/tasks/completed.md:23`'s "1,360 words". A future sweep must
  not "fix" either.

## Acceptance criteria

- [ ] All six statements are true, or the enumeration that made them fragile is gone.
- [ ] `glossary-lint` gives "not a git repository" its own message.
- [ ] The two records that are correct as dated history are left alone, with the
      reason written where a future sweep will see it.
- [ ] Five checks green.
- [ ] The task line moves from backlog to completed in the same pull request.




---

### Comment — pharzam — 2026-08-27T10:46:47Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:34Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

All six corrections are absent, because the statements they corrected lived in files `main` no longer holds.

**One instruction for the re-land.** Do not port these six as written. Each was verified against a tree that no longer exists, and #19 already shows what happens when a list of corrections outlives its base — the numbering was wrong within the hour. **Re-verify each of the six against the redone base**, then fold it into the slice that creates the statement it corrects.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — folded into the slices each correction touches, not landed on its own.
