# #20 — Define core / standard / full adoption profiles

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:38Z.*

---

Part of #16.

## Goal

Define **core**, **standard**, and **full** adoption profiles, and state which documents and which rules each profile keeps.

The audit in #16 found the kit over-engineered in breadth: one task needs an issue, a reviewed plan, a worktree, red-green TDD, uncapped review rounds, a fresh-context confirmation, an evidence commit, a glossary update, and a backlog move. Each piece is well built; the sum turns away the small adopter the kit is aimed at.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16.

## Solution note (R3)

- **Chosen:** profiles as a table in the README plus a short section in `engineering-discipline.md`. Nothing is deleted; a profile states what an adopter may defer, and what they give up by deferring it.
- **Rejected:** *delete rules* — the rules are individually sound, and the kit's value is that they are written down. *Separate branches per profile* — three copies of the kit to keep in sync, which R10 would immediately punish.
- **Decision record:** an ADR. It changes how the kit is consumed.

## Acceptance criteria

- [ ] Three profiles are defined, with the document set and rule set of each.
- [ ] Each profile says what an adopter gives up.
- [ ] An ADR records the decision.
- [ ] R10 sync holds across README, discipline, and onboarding.
- [ ] The task line moves from backlog to completed in the same PR.




---

### Comment — pharzam — 2026-08-27T10:46:26Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:03Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

- No profiles table in `README.md`.
- No profiles section in `docs/engineering-discipline.md`.
- No ADR; the index at `2cd70ee` ends at 0003.

None of the three acceptance criteria is met.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 4** — after the tranche-1 redo, so a profile can name a rule set that actually exists.
