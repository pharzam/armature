# #17 — Ship a root AGENTS.md template (and a CLAUDE.md pointer)

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:31Z.*

---

Part of #16.

## Goal

Ship a root `AGENTS.md` that condenses the [quality gate](../blob/main/docs/engineering-discipline.md) and R1–R12 into under 1,500 words of agent context, plus a one-line `CLAUDE.md` that points to it.

This closes the largest gap the audit in #16 found: the kit binds "every LLM operator" but ships no file an LLM operator loads by default.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16.

## Solution note (R3)

- **Chosen:** a root `AGENTS.md` — the de-facto cross-vendor standard — shipped **filled**, not placeholder-only, because the kit's own rules are already concrete. A one-line `CLAUDE.md` points to it, because Claude Code reads `CLAUDE.md` while other agents read `AGENTS.md`.
- **Rejected:** *`CLAUDE.md` alone* — vendor lock-in, against the kit's forge-free and vendor-free stance. *A symlink `CLAUDE.md` → `AGENTS.md`* — breaks on Windows checkouts and in some tooling. *Generate `AGENTS.md` from the docs at build time* — needs a toolchain the kit refuses to assume.
- **Decision record:** an ADR. This is architecturally significant: it adds a second entry point to the kit and creates a drift risk against `engineering-discipline.md`.

## Acceptance criteria

- [ ] `AGENTS.md` exists at the repository root and is under 1,500 words.
- [ ] It states the gate steps and R1–R12 in compressed form, and names the `‹…›` values an adopter must fill.
- [ ] `CLAUDE.md` exists and points to it, without duplicating its content.
- [ ] An ADR records the decision and names the drift risk plus its mitigation.
- [ ] R10 sync: README, `onboarding-for-engineers.md`, `engineering-discipline.md`, and the glossary stay in step.
- [ ] The task line moves from `tasks/backlog.md` to `tasks/completed.md` in the same PR.




---

### Comment — pharzam — 2026-08-27T11:46:55Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

- `AGENTS.md` — absent.
- `CLAUDE.md` — absent.
- `docs/adr/0004-ship-a-root-agents-file.md` — absent; the ADR index at `2cd70ee` ends at 0003.

Every acceptance box that named a file is unmet. The gap the #16 audit called "the single largest" is open again.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1. This is the audit's largest single gap, so it re-lands early in the tranche.


---

### Comment — pharzam — 2026-08-27T12:08:25Z

## Renumber to ADR-0005 when this re-lands — read this before porting anything

**This note exists because a claim about it was false.** The plan on #43 asserted that this collision was "recorded in that issue's reopen comment". It was not — it was recorded on #43 and on #16, neither of which is where someone re-landing #17 looks. An independent reviewer caught the false claim. This comment makes it true.

### The collision

The pre-reset history gave `0004` to the `AGENTS.md` decision, as `docs/adr/0004-ship-a-root-agents-file.md`. That number is now **taken by a different record**: [ADR-0004 "Reset the default branch only under a recorded procedure"](https://github.com/pharzam/armature/pull/44) (#43).

`adr-lint.sh` requires contiguous numbering from `0001` and rejects duplicates, so the number belongs to whichever record lands first. That is no longer this one.

### What the re-land must do

1. **Rename** `docs/adr/0004-ship-a-root-agents-file.md` → `docs/adr/0005-ship-a-root-agents-file.md`, and change its title line to `# 0005. …`.
2. **Update every reference.** On `backup/pre-r12-reset-999765f` the number appears in five places: the ADR file itself, its row in `docs/adr/README.md`, `docs/engineering-discipline.md`, and two entries in `docs/tasks/completed.md`.
3. **Add the index row** in newest-at-the-bottom order, below the `0004` reset row.

If you port the `0004` filename unchanged, `adr-lint`'s duplicate-number check fires and the re-land is blocked mid-flight.

### Two related traps in the same area

**#41 points at the wrong record now.** That issue cites "ADR-0004" twice, meaning the `AGENTS.md` decision — *"ADR-0004 rejected a `CLAUDE.md`-only entry point on exactly that principle"*. A reader following it today lands on the reset procedure. Both citations need updating to `ADR-0005` when this re-lands.

**The orphan check will lie to you.** `adr-lint`'s no-orphan check greps for the bare string `ADR-0004` anywhere in `docs/` outside `adr/`. A reviewer demonstrated that restoring this issue's old `completed.md` line — which reads `[ADR-0004](../adr/0004-ship-a-root-agents-file.md)` — silences the orphan warning for the **reset** ADR, because the two share a number. So after this re-land, a clean `adr-lint` run does **not** prove either record is properly cross-linked. Check the links by reading them, not by trusting the exit code.

That is the [#37](https://github.com/pharzam/armature/issues/37) defect class again, in the linter this slice depends on. Worth a fixture when #37 re-lands.
