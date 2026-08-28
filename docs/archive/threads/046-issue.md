# #46 — Two shipped statements still say R1–R11, and one is inside an immutable ADR the kit cannot correct

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T12:15:24Z.*

---

Part of #16.

## Goal

Correct the two shipped statements that still say the issue-first workflow is **R1–R11**, and decide how the kit corrects a factual error inside an **immutable** Architecture Decision Record — because one of the two is in one.

## In plain terms

> Two files still tell the reader there are eleven rules. There are twelve. One of those files is a decision record, and this project's own rules say a decision record can never be edited except for one line. So there is currently no legal way to fix it, and nobody has noticed.

## Why

Found by the independent review round on #43 while checking R10 sync. Both predate that change and are not caused by it.

```
$ grep -rn "R1–R11" --include='*.md' .
./docs/adr/0003-adopt-issue-first-workflow.md:22:We will require an **open issue before any change**, with the rules R1–R11 in
./README.md:45:| ... | The issue-first workflow (R1–R11): the ticket policy the gate assumes. |
```

`docs/onboarding-for-engineers.md:74` says R1–R12 correctly, so the two above are the stale copies. R12 landed in [#14](https://github.com/pharzam/armature/issues/14) (T-9p4c) and its R10 sync missed them.

This is [#40](https://github.com/pharzam/armature/issues/40)'s class — *"shipped statements that are not true of `main`"* — but #40's six statements all live in files `main` no longer holds. These two are live on `main` today.

## The structural half, which is the reason this is not a one-line fix

`README.md` is trivially editable. `docs/adr/0003-*.md` is not. `docs/adr/README.md` states:

> The Status line is the one part of an accepted ADR that may be edited, and only to record one of these two relationships. **Everything else stays immutable.**

So the kit forbids editing the stale sentence, and offers only two Status transitions — `Superseded by` and `Accepted. Amended by` — both of which describe **a decision changing**. Neither fits here: ADR-0003's *decision* is entirely correct and unchanged. Only a **count in its prose** is stale.

The kit therefore has no route to correct a factual error in an accepted record. Today's options are all bad:

1. Edit it anyway and break the immutability rule the linter cannot see.
2. Write an amending ADR for a typo, which cheapens amendment and adds a record no reader needs.
3. Leave it wrong, which is what has happened.

`adr-lint` cannot catch any of this: it accepts `Accepted` and `Accepted. Amended by …` equally and has no notion of which is correct, and it never reads prose for stale cross-references.

## Duplicate check (R2)

- [x] Searched the open **and** closed issues. [#40](https://github.com/pharzam/armature/issues/40) is the same class but names six *different* statements, all in files discarded by the reset. [#45](https://github.com/pharzam/armature/issues/45) covers `adr-lint`'s blindness generally but not the immutability question. Nothing covers correcting an accepted ADR. Parent: #16.

## Solution note (R3)

- **Chosen:** fix `README.md` directly; for ADR-0003, add a third sanctioned Status form or an explicit **errata** convention in `docs/adr/README.md` — a dated correction block appended to the record, which changes no decision and leaves the original text intact and readable. Then apply it to ADR-0003.
- **Rejected:** *edit the ADR silently* — it breaks the one rule that makes the log trustworthy, and it is unenforceable, so the next operator will do it too. *An amending ADR per typo* — amendment should mean the decision moved. *Stop writing counts in prose* — correct in general (it is [#41](https://github.com/pharzam/armature/issues/41)'s principle) but it does not fix the record already shipped.
- **Decision record:** an ADR — it changes what "immutable" means for the whole log.

## Acceptance criteria

- [ ] `README.md:45` says R1–R12.
- [ ] `docs/adr/README.md` states how a factual error in an accepted record is corrected without changing its decision.
- [ ] ADR-0003's stale `R1–R11` is corrected by that route, and the route is the one the document just described.
- [ ] `adr-lint` is updated in the same change if the Status vocabulary grows — the linter and the template must agree, as `docs/adr/README.md` requires.
- [ ] R10 sync holds; no remaining `R1–R11` anywhere.
- [ ] The task line moves from `docs/tasks/backlog.md` to `docs/tasks/completed.md` in the same pull request.

## Notes

Whoever takes this should check the count problem generally rather than only these two instances — `docs/adr/0004-*` (proposed on #43) was caught in review carrying *"gates code quality at eight points"* and *"four bookkeeping problems"* above a list of three. A count in prose above a list that already says it is [#41](https://github.com/pharzam/armature/issues/41)'s exact shape.

