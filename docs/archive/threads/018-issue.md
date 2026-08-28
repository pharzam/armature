# #18 — Package the mandated review procedures as runnable, inert assets

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:33Z.*

---

Part of #16.

## Goal

Ship the procedures the kit **mandates** as runnable, inert assets: one prompt file for each of the four blind-review lenses, and one for the R12 plan review.

Today these ship as prose only. An agent must rebuild the procedure from `engineering-discipline.md` on every task. R5 tells the kit to prefer a deterministic mechanism over an LLM judgement; the kit does not apply that rule to itself.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16.

## Solution note (R3)

- **Chosen:** plain Markdown prompt files under `docs/review/`, vendor-neutral and **inert** — exactly the pattern `docs/ci/` and `docs/templates/` already use. An adopter copies them where their agent runner expects them.
- **Rejected:** *`.claude/commands/` only* — vendor lock-in, against the kit's vendor-free stance. *Prompts embedded in `engineering-discipline.md`* — that document is already long, and a prompt is an asset to copy, not prose to read.
- **Decision record:** this issue. Not architecturally significant on its own; it follows the established inert-asset pattern.

## Acceptance criteria

- [ ] One prompt file per review lens: correctness and failure modes, guardrails and acceptance criteria, clean and simple, adversarial bug-hunt.
- [ ] One prompt file for the R12 plan review.
- [ ] A `docs/review/README.md` states that the files are inert and how to wire them.
- [ ] `engineering-discipline.md` §"Reviewing until findings decay" links them; R10 sync holds.
- [ ] The task line moves from backlog to completed in the same PR.




---

### Comment — pharzam — 2026-08-27T11:46:58Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

`docs/review/` does not exist at `2cd70ee` — none of `README.md`, `plan.md`, `correctness.md`, `guardrails.md`, `simple.md`, or `adversarial.md`.

The mandated review procedures are prose again, with nothing runnable behind them.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1. It should land early: gate step 5 is easier to skip while the prompts it names do not exist.
