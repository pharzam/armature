# #22 — Dogfood the kit on one real product repository

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:41Z.*

---

Part of #16.

## Goal

Adopt the kit on one small, real product repository, and link that adoption from the README.

This is the audit's most important finding (#16): a documents-only repository built these rules, and a documents-only repository is the only place they have ever run. Every rule is therefore fitted to a repo with no product code, no test runner, no build, and no dependencies.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16.

## Solution note (R3)

- **Chosen:** one small real product, taken through the whole gate once — filled placeholders, a real test runner, real CI, a real PRD with a real fact. Then bring the friction back as issues here.
- **Rejected:** *a toy example inside this repository* — it would share the kit's blind spot and prove nothing. *Wait for an outside adopter* — the kit cannot learn from a user it does not have.
- **Decision record:** an ADR here once the adoption reports back.

## Acceptance criteria

- [ ] One real repository runs the kit end to end, with every `‹…›` filled.
- [ ] The friction found is filed back here as issues.
- [ ] The README links the adoption as a worked reference.

## Notes

This is the one slice that cannot land inside this repository.




---

### Comment — pharzam — 2026-08-27T10:46:28Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:08Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

The rejection itself was a written decision and it stands. Its artifact does not: the README honesty line — that the kit has only ever run on a repository with no product code, no test runner, and no build — is not in `README.md` at `2cd70ee`.

A rejection whose record never landed is indistinguishable, to a reader of `main`, from work that was never done.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 4** — the rejection is re-recorded there, in `README.md`, where a reader meets it.
