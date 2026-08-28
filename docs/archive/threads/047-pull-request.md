# PR #47 — docs: T-7d2x record when history on the default branch may be destroyed (ADR-0004)

*Archived from GitHub. State at archive time: OPEN. `docs/t-7d2x-reset-adr-v2` into `main`. Opened 2026-08-27T12:54:38Z.*

---

<!-- See docs/issue-workflow.md. A PR with no linked issue does not merge (R1). -->

## ⛔ Does not merge yet — findings have not decayed

Three plan rounds, ten gate-step-5 rounds, and four closure audits of round 10's own repair, then round 11 — a fresh four-lens round at `385a8d6`. All returned findings, and two lenses independently reopened the default-branch swap. Every round has returned findings on every lens. See [Gate status](#gate-status).

## Linked issue (R1)

`Closes #43` — `Part of #16` (Phase 0).

## What & why (R7)

- **Action:** adds `docs/adr/0004-destroying-history-on-the-default-branch.md` — five conditions under which history on the default branch may be destroyed — plus the task detail file that carries the incident record, and R10 sync across four documents.
- **Why:** [finding R-5 on #16](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512). A pull request proposes commits **onto** a branch; a reset, rewrite or deletion takes them **away**, so no rule written for the first shape reached the second.
- **Tradeoffs:** the operator chose a second **human** approver, which on this one-person repository **closes the path entirely**. That is recorded as the intended cost, and the record says so rather than letting a reader discover it.

## This replaces PR #44, which was rejected

Two review rounds (eight reviewers) rejected the first draft. What changed:

| Round 1/2 finding | Fixed here |
|---|---|
| *"There is no hook, no CI check and no branch protection"* — false on all three | The enforcement paragraph names the hook (advisory, bypassable), branch protection (blocks the act, silent on who approved), and the paths neither reaches |
| The self-scorecard scored its author "two of four met" | Rescored honestly at **nought of five, one partly** — and moved out of the ADR |
| The record shipped this repo's shas, branches and counts to every adopter (`isTemplate: true`) | ADR-0004 is fully generic: `Date: YYYY-MM-DD`, "the default branch" never `main`, no live configuration asserted |
| A precondition was logically impossible | Conditions 1–3 hold before; condition 4 straddles the act; condition 5 can only follow it, and the record says why |
| The backup covered only the default tip | `git merge-base --is-ancestor` sweep, one backup per discarded tip |
| The rule forbade repairing its own failure mode | **Not fixed here — deferred to [#48](https://github.com/pharzam/armature/issues/48).** A carve-out was written, then cut: it drew a HIGH finding in each of rounds 7 and 9 and never converged. What the record does say is narrower and checkable — restoring a tip that is a *descendant* of the current one makes nothing unreachable, so the record does not reach it at all |
| Scope carve-out was broken (backup branches are never ancestors) | Re-scoped by *what is destroyed*, not which branch is touched |
| `required_approving_review_count` claim | **Deleted** — required reviews gate a PR merge, not a force-push, and no forge distinguishes a human approver from an agent |

**And the finding that changed the rule's substance:**

```
$ git ls-remote origin 'refs/pull/*'          → bfa6bfa  refs/pull/24/head
$ git merge-base --is-ancestor bfa6bfa main   → NO (discarded by the 2026-08-27 reset)
$ git push origin --delete refs/pull/24/head
 ! [remote rejected] refs/pull/24/head (deny updating a hidden ref)
```

A commit the reset discarded is still publicly fetchable from a ref the operator cannot delete. So **the deletion does not delete**, and the record states that rotation — not deletion — is what ends a credential exposure.

## The five slices

| # | Commit | What |
|---|---|---|
| 1 | `21222ef` | Backlog line + `docs/tasks/t-7d2x.md` (shipped together — the backlog entry links `[detail](t-7d2x.md)`) |
| 2 | `1aef067` | ADR-0004, its index row, and ADR-0003's `Accepted. Amended by ADR-0004` |
| 3 | `06d432e` | R10 sync: the gate paragraph, the enforced-where row, four absolute statements, two glossary rows |
| 4 | `02191f7` | The incident scorecard |
| 5 | `54c237a` | Close out: backlog → completed |

A **slice 0** ran before any edit: the abandoned spike worktree was sitting untracked **and unignored**, holding a competing `docs/adr/0004-*.md`. Its contents were removed.

Two corrections to how that was first reported here. `git add -A` would have staged **one gitlink** for the linked worktree, not the files inside it — so a second ADR-0004 could not have entered the index by that path, though `adr-lint` would indeed not have caught what did. And the hazard is **cleaned, not prevented**: `.gitignore` still carries only `.obsidian/`, so `.worktree/` remains unignored and `engineering-discipline.md`'s description of the worktree directory as gitignored is an instruction to adopters rather than a fact about this repository. The one-line fix belongs to [#23](https://github.com/pharzam/armature/issues/23), which owns it; this branch has staged with explicit paths (`git add -- docs/ .githooks/`) throughout rather than rely on remembering.

## Test evidence, and what it is not worth

```
$ sh docs/adr/adr-lint.sh && sh docs/prd/prd-lint.sh
adr-lint: OK
prd-lint: OK
```

**Both green at every commit, and that proves less than it looks.** `adr-lint` checks *shape*, not content — an ADR with three empty sections in reverse order, a placeholder date and a prose "index row" returns `adr-lint: OK`. Of this issue's **fourteen** criteria it reaches three — one of those only as a substring, one only as a non-fatal warning. **Eleven have no machine check at all** and rest on human review. (An earlier version of this line said six, counting only the criteria about the ADR's own content; the arithmetic did not close, and it made the gap look 40 percent smaller than it is.) The ten holes in `adr-lint` itself — a different count — are [#45](https://github.com/pharzam/armature/issues/45).

No new test is added here, and this change does not claim a red/green cycle it did not perform.

## On size — the record was cut back

ADR-0004 is **6,089 bytes**, about **2.68x** its largest sibling (0003, 2,270). It was **11,895** — 5.2x — before this pass. The cut took it to 4,859. Round 10 and the closure audits that followed took it to 6,494 — **+34% in a day**, on a record whose whole justification was that it had outgrown its need. The `clean-and-simple` lens measured where it went: **76% into `## Decision`, and `## Context` absorbed none of it.** Every reason two review passes produced had been written into the numbered checklist an operator reads under pressure, instead of the section that exists to hold reasons. [Eight cuts](https://github.com/pharzam/armature/issues/43#issuecomment-5449319958) brought it to **5,776**, removing no rule — the reasons moved to Context and to `docs/tasks/t-7d2x.md`. The rule carried forward: *a repair that adds a reason puts it in Context or the task file, never inside a numbered condition.*

Nine gate-step-5 rounds ran over the larger draft, and almost every finding was in material added beyond what [Phase 0](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512) asked for. Phase 0 wanted three conditions in a short record. What grew instead carried five conditions **plus** a repair carve-out, a recursion bound, a fast-forward rule, a role-swap definition, a tag act and an off-remote bundle exception — and the carve-out alone produced the round-2 blocker, three regressions in round 3, and a HIGH finding in each of rounds 7 and 9.

The record now carries the five conditions the incident itself earned, one per observed failure: nothing written before the act, self-approval, an incomplete backup, a lock lifted without record, and issues left claiming deliverables `main` no longer held.

**What was cut is not lost.** The design notes and the five ways the carve-out failed are in `docs/tasks/t-7d2x.md` (12,434 bytes), which an adopter deletes with one command; the deferral has its own issue, [#48](https://github.com/pharzam/armature/issues/48); over 190,000 bytes of review findings stay on #43 and #16; the 11,895-byte draft is in this branch's own history; and the earlier 7,022-byte one stays on `docs/t-7d2x-reset-adr` (`b2d2764`) as reference, never a merge source.

**Why smaller is the right call here:** an ADR cannot be edited once accepted. Every byte of it is a permanent liability shipped to every adopter of the template, and the review demonstrated that the added material was where the defects lived.

## Acceptance criteria

- [x] `docs/adr/0004-*.md` exists, records the decision, passes `adr-lint`.
- [x] Generic — no shas, branch names, issue numbers, dates or counts from this repository.
- [x] States every condition and separates before from after, with the reason.
- [x] States that a hosted forge retains pull-request references outside the operator's reach, and that rotation ends a credential exposure.
- [x] Names honestly what enforces the rule and what does not.
- [x] States the human-only requirement as its own rule, names the narrowing, gives the reason.
- [x] Answers the hard cases — credential, oversized object, erasure request — naming each route, or stating plainly there is none. The self-hosted solo operator has none, and the record says so; [#43's criterion was amended](https://github.com/pharzam/armature/issues/43) because as first written it could only be met by inventing a route.
- [x] The reset scored condition by condition in `docs/tasks/t-7d2x.md`; mirrored to #16 on merge.
- [x] Index row added; ADR-0003 amended.
- [x] Linked from outside `docs/adr/`; no-orphan warning quiet.
- [x] Enforced-where row does not contradict the row above it.
- [x] R10 sync across four documents, including all four absolute statements.
- [x] Says plainly what it does **not** decide — how a destruction may be undone — with that deferral carried by [#48](https://github.com/pharzam/armature/issues/48) rather than a clause bolted on here.
- [x] Task line moved backlog → completed.
- [ ] **Independent review ran until findings decayed** — twelve rounds done, none clean. Round 8 was the first with no HIGH finding; round 10 covered the cut record; round 11 found the swap evasion reopened by a cut made during round 10's own repair; round 12 found it reopened again in two acts, and closed it by widening the test rather than adding another exemption — the first repair in twelve rounds that made the record smaller.

## Gate step 5, round 1 — four lenses, all FINDINGS, fixed in `cdb4904`

Four of the findings were errors running **in my favour**. Full record on [#43](https://github.com/pharzam/armature/issues/43#issuecomment-5439650149). The load-bearing ones:

- **The repair carve-out exempted the incident it sits beside.** `2cd70ee` is a tip `main` previously held and every discarded commit came from the session called "the incident" — so the 2026-08-27 reset qualified as a *repair* needing no second operator, while `docs/tasks/t-7d2x.md` concluded it "would not have been permitted". Now scoped to undoing a **prior destruction of history**, with the issue required to name the act being undone.
- **"Unknown and unknowable" was one API call away.** A ruleset scoped to `refs/heads/main` carrying `deletion` and `non_fast_forward` was created at **10:11:26Z** — after the local reset, before the force push — with enforcement **disabled**, unchanged since. The scorecard now records it and states what is still undetermined.
- **The scorecard contradicted its own table**, claiming the reset "covered two of the five things that matter" against a table scoring nought met and one partly.
- **The enforcement fix over-swung into a new falsehood.** A branch lock is server-side and reaches a web editor and an API write; only the hook is bypassed. #43's criterion 5 caused it, so the criterion was corrected too.
- **The scope fix opened a two-step evasion** — delete unmerged branches as "housekeeping", then reset, and condition 3 sweeps nothing. Ancestor qualifier restored; the remaining gap is now stated, not hidden.

Also: the tag clause was backwards, condition 2 cited a glossary definition that did not exist (`Operator` and `UTC` rows added), condition 5 split into (a)/(b)/(c), and four self-regarding sentences cut.

## Gate status

| Gate | Status |
|---|---|
| R12 — plan reviewed before building | **RUN.** Three rounds, six reviewers (two per round). Revision 1 was built 2m25s after its plan was posted — [the recorded deviation](https://github.com/pharzam/armature/issues/43#issuecomment-5438871326). This build began only after two BUILD WITH CHANGES verdicts. |
| Gate step 5 — review rounds over the built change | **Twelve rounds complete**, all four lenses each time, plus four closure audits of round 10's repair. Rounds 1–9 ran over the draft that grew to 11,895 bytes. Rounds 10–12 each found a defect introduced by the repair before it: a circular definition, then an exemption attached to a branch rather than an act, then a present-tense test that let the pointer be moved out from under it. Round 12's fix removed two mechanisms and added none. |

Rounds continue until one finds nothing material, and the clearing round is never the one that found the last defect. **This does not merge until then.**









