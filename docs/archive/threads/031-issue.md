# #31 — AGENTS.md contradicts the rules it summarises — R10 omits itself, R4 omits the agent loophole clause

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T16:33:37Z.*

---

## Goal

Fix three places where `AGENTS.md` **disagrees with** — not merely omits — the documents it summarises.

[ADR-0004](docs/adr/0004-ship-a-root-agents-file.md) predicted exactly this and said the planned drift check tests **coverage, not agreement**. Nobody had checked agreement. This is that check, run by hand, and it found three.

## The three disagreements

**1. R10 omits `AGENTS.md` itself. (MAJOR — self-perpetuating drift.)**

Source `issue-workflow.md` R10:
> Keep them synchronized with **`AGENTS.md`** — which summarises them, so a rule change edits it in the same change — `engineering-discipline.md`, the ADRs, `guardrails.md`, `glossary.md`, and the PRD convention.

`AGENTS.md` R10:
> Keep discipline, ADRs, guardrails, glossary, and the requirements convention in step.

`AGENTS.md` is the file an agent actually loads. Its own R10 line never tells that agent that `AGENTS.md` must be updated when a rule changes. **The file omits the one instruction that would keep it correct**, which makes every future rule change drift by default. A coverage-only drift check passes this happily: R10 is "mentioned".

**2. R4 omits "an agent is never the second operator". (MAJOR — a live loophole.)**

Source R4 ends:
> The solo form is deliberately weaker, and it is not a loophole. The removal issue is mandatory either way, and **an agent is never the second operator** — a model approving a workaround it proposed is one operator, not two.

`AGENTS.md` R4 stops at "two operators' written approval, or … one dated self-review comment".

The dropped sentence is **the only clause in R4 that is about agents**, dropped from **the agent-facing file**. An agent reading only `AGENTS.md` can conclude that a second agent's approval satisfies R4. That is precisely the loophole the source closes.

**3. The glossary exemption list is incomplete. (MINOR — over-strict.)**

Source exempts general-English forms **and** "the formats and protocols any software reader knows, such as `HTML`, `URL`, and `JSON`". `AGENTS.md` lists only the general-English half, so an agent would believe `HTML` needs a glossary row when `glossary-lint.sh` exempts it. Wrong in the harmless direction, but still wrong.

## What agreed, and was checked

The eight gate steps, R1–R3, R5–R9, R11, R12, the commit-subject format, the task-ID scheme, commit granularity, and the landing rule (rebase, plain merge, never squash) all match their sources.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Related: #17, #19, #16.

## Solution note (R3)

- **Chosen:** correct all three lines in `AGENTS.md`. Keep the compression — these are one-line summaries — but never at the cost of dropping a constraint, and never at the cost of dropping the clause that binds agents.
- **Rejected:** *wait for the #19 drift check to catch it* — it cannot, by design; ADR-0004 says so in writing. *Delete `AGENTS.md`'s R-table and link out instead* — that removes the file's whole value, which is that an agent gets the rules without following links.
- **Decision record:** this issue. A correction within ADR-0004's accepted design, not a change to it.

## Acceptance criteria

- [ ] `AGENTS.md` R10 names `AGENTS.md` among the documents a rule change must update.
- [ ] `AGENTS.md` R4 carries the "an agent is never the second operator" clause.
- [ ] The glossary exemption in `AGENTS.md` matches the linter's actual behaviour.
- [ ] `AGENTS.md` stays under its 1,500-word budget.
- [ ] Full gate green.
- [ ] The task line moves from `tasks/backlog.md` to `tasks/completed.md` in the same PR.



---

### Comment — pharzam — 2026-08-27T11:47:15Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

`AGENTS.md` does not exist at `2cd70ee`, so the three contradictions this issue corrected are absent along with the file that held them.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1, immediately after #17. It cannot land before the file it corrects.
