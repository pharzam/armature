# #34 — Remove the solo form of R4 — a workaround needs two operators, always

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T07:30:32Z.*

---

Part of #16.

## Goal

Remove the solo form of R4. A workaround needs the written approval of **two
different operators**, always. On a solo project the path is closed, not
self-approved.

State in the same change that **gate step 5 admits no solo form**: only an
independent reviewer in a fresh context — agent or human — satisfies it, and the
author's own session never counts.

## Why

#21 (landed by #25) gave R4 a solo-operator form: *"a dated self-review comment on
the issue … Writing it down is the check, because there is no second operator to
be one"* (`docs/issue-workflow.md:68`). Two things went wrong with it:

1. **It reads as a general exemption.** It was cited on #16 to argue that the
   seven self-review-only merges were permitted. R4 governs workarounds only, and
   gate step 5 is a gate, not a workaround — but a rule that invites the confusion
   is a defect in the rule.
2. **A self-approval is not a check.** The operator who wants the shortcut cannot
   also be the operator who approves it. Writing it down records a deviation; it
   never approves one.

The kit already states the harder half of this — *"an agent is never the second
operator"*. The solo form contradicts it in the next paragraph.

## Duplicate check (R2)

- [x] Searched the open **and** closed issues. #21 (closed) **added** the form
      this issue removes; that makes this the reversal, not a duplicate. Parent:
      #16.

## Solution note (R3)

- **Chosen:** delete the solo branch of R4 and say plainly that a solo project
  cannot approve a workaround — the answer is to fix the cause or open an issue,
  not to route around it. Add one sentence to gate step 5 in
  `engineering-discipline.md` ruling out a solo form there, so the two rules can
  never be read as sharing an exemption. R10 sync across `issue-workflow.md`,
  `engineering-discipline.md`, and `AGENTS.md`, and an honest row in "What is
  enforced where".
- **Rejected:** *keep the solo form and add a warning* — the confusion it caused
  came from its existence, not from missing words around it. *Remove R4's
  two-operator rule instead and rely on the removal issue alone* — that drops the
  approval check entirely, which is the opposite of the finding.
- **Decision record:** this issue. Not architecturally significant: it tightens an
  existing rule rather than changing how the kit is built or consumed.

## Acceptance criteria

- [ ] R4 in `docs/issue-workflow.md` states one approval rule: two different
      operators, in writing, on the issue. No solo branch.
- [ ] R4 states what a solo operator does instead, and that a self-review records
      a deviation without approving it.
- [ ] Gate step 5 in `docs/engineering-discipline.md` states that only an
      independent reviewer in a fresh context satisfies it.
- [ ] `AGENTS.md` carries the same R4 line and the same step-5 line (R10).
- [ ] The "What is enforced where" table stays honest about both rows.
- [ ] The task line moves from `docs/tasks/backlog.md` to
      `docs/tasks/completed.md` in the same pull request.




---

### Comment — pharzam — 2026-08-27T10:46:33Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:19Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

Half of this is already true on `main`, and for the wrong reason. The reset removed #21's solo form of R4 by **deleting the commit that added it**, not by deciding anything. R4 at `2cd70ee` reads "two different operators" because that text predates #21 — not because this issue landed.

The other half is missing outright:

- Gate step 5 in `docs/engineering-discipline.md` at `2cd70ee` carries no sentence ruling out a solo form.
- The "Reviewing until findings decay" section carries no ruling that an **agent in a fresh context satisfies step 5**, and none that **R4 governs approval authority while step 5 governs independence**.

That ruling is the load-bearing half. It was decided and reviewed three times before the rounds ran; only the landing remains.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 1** — patch the rules before any code. Only the landing remains; the decision is made and thrice-reviewed.
