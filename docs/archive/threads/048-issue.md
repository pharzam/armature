# #48 — Decide how a destruction of history may be undone — ADR-0004 leaves it open

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-28T05:36:02Z.*

---

Part of #16. Split out of #43.

## Goal

Decide how a destruction of history on the default branch may be **undone**, and record the decision.

## In plain terms

> If someone force-pushes over the main branch by accident, putting it back can itself destroy history — so where it does, the rule we just wrote says it needs a second person, and on a one-person project that means the branch stays broken. Where the restore only fast-forwards, the rule does not reach it at all, which is not the same as allowing it: nothing says what should govern it. Neither half is obviously right, and both deserve a decision of their own instead of a clause bolted onto another one.

## Why this is separate

[ADR-0004](https://github.com/pharzam/armature/blob/710cc6f/docs/adr/0004-destroying-history-on-the-default-branch.md) states the conditions for destroying history and says explicitly that it does **not** settle this:

> This record does not say how to undo a destruction that should not have happened. Restoring it can itself destroy history under the definition above — undoing a rewrite makes the rewritten commits unreachable — and where it does, these conditions apply, including the second operator that a solo operator does not have. Where it does not, most plainly when the tip being restored is a descendant of the current one, nothing becomes unreachable and this record does not reach the act. What governs it instead is left open and decided on its own terms.

**Quoted at `b1158d1`.** The wording moved twice during #43's closure audits; this quote is the current one. The second half — the fast-forward case — did not exist when this issue was filed, and it is the half most in need of a decision, because "not reached by the record" is being read as "permitted".

A carve-out for this was drafted inside #43 and cut. It is worth reading the history before drafting another, because the same clause failed five distinct ways under review:

1. **It exempted the incident it was written beside.** `2cd70ee` is a tip `main` previously held, and every discarded commit came from the session the record calls "the incident" — so the 2026-08-27 reset qualified as a *repair* needing no second operator, while the scorecard two files away said it "would not have been permitted".
2. **It waived all five conditions, not one.** A repair discards everything landed since the act it undoes — the moment a backup matters most was the one moment nothing required one.
3. **It contradicted itself.** "Repair is not destruction, and waives only condition 2" — a repair makes commits unreachable, which is the record's own definition of destruction, and "waives only condition 2" only parses if the conditions govern it.
4. **It recursed without bound.** Undoing a repair is itself a destruction, so undoing *that* qualified as a repair of the last — leaving two histories swappable forever by one party. And a solo operator who broke the second-operator rule once thereby created the predicate making every later rewind lawful.
5. **Bounded by count, it was still unbounded in time.** Every un-undone destruction in a repository's past stayed a standing single-operator licence to discard arbitrary later work — with the supervision inverted, since a repair that destroys *nothing* needed a pull request while one discarding a year of work needed neither a pull request nor an approver.

Two more facts the next draft should not have to rediscover:

- **`refs/pull/N/head` does not name the discarded tip.** It is the contributor's branch tip; under no merge strategy is it the tip the default branch ends up holding, and `refs/pull/N/merge` is thrown away when the pull request closes. What does name it is the forge's record of the merge — `merge_commit_sha`, populated for merge, squash and rebase alike — but only where that merge produced the tip.
- **A fast-forward repair is expressible as a pull request.** Where the destruction was a rewind and nothing has landed since, the restored tip is a *descendant* of the current tip. Verified on this repository: `main` is an ancestor of `backup/pre-r12-reset-999765f`.

## Duplicate check (R2)

- [x] Searched the open **and** closed issues. #43 states the conditions and explicitly defers this; nothing else covers undoing a destruction. Parent: #16.

## Solution note (R3)

- **Chosen:** decide it on its own terms, as an amendment or a superseding record to ADR-0004 — not as a clause added to it under review pressure, which is how the five failures above were produced.
- **Rejected:** *leave it undecided indefinitely* — the rule as it stands leaves a solo operator with a broken default branch and no permitted route back, which a reviewer called "actively harmful"; *re-land the cut draft* — it failed five times and the sixth attempt would inherit its shape.
- **Decision record:** an ADR.

## Acceptance criteria

- [ ] The record says whether undoing a destruction is governed by ADR-0004's conditions, all of them or some.
- [ ] It answers the solo case: what a one-person project does about an accidental force-push.
- [ ] Whatever it permits is bounded in **time** as well as in count, or says why neither bound is needed.
- [ ] It states which of the five failures above its shape avoids, and how.
- [ ] ADR-0004's Status is amended or superseded per `docs/adr/README.md`, and the enforced-where table stays honest.
- [ ] The task line moves from `docs/tasks/backlog.md` to `docs/tasks/completed.md` in the same pull request.



