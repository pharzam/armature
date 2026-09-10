# T-cw87 — Record model, effort, tokens and elapsed time per gate part

Tracks [issue #179](https://github.com/pharzam/armature/issues/179), the follow-up to
[ADR-0005](../adr/0005-route-work-by-model-tier.md). Completed line:
[completed.md](completed.md). Plan and its independent review are on the issue (R12).

## Why

[ADR-0005](../adr/0005-route-work-by-model-tier.md) routes work by model tier but named
its own limit — "nothing is mechanized … the rule buys a claim precise enough to be
*wrong*, not a verified control." A rule nobody records is unobservable. This task adds
the **evidence**: a per-task **resource record** of the model, effort, tokens and elapsed
time, per gate part and in total, so a routing claim becomes a row a reader can check.

## What

A new constitutional **ADR-0007** decides it; the record is a section of
`docs/tasks/<id>.md` after `## Verdict`, hooked from gate **step 8**.

- **The part** is ADR-0005's routing partition — **reasoning**, **execution**, or **`—`**
  for the gate steps neither tier routes — cited from
  [Model tiers](../engineering-discipline.md#model-tiers), not re-stated (the prose already
  drifts three ways; a fourth copy is a fresh defect — that drift is a separate issue). A
  wrong-tier row is a finding; the `—` rows carry no expectation but still sum, so the
  `Total` is true.
- **Recorded, not budgeted:** no approval number, no cap, no verdict; an overrun is not a
  finding. ADR-0007 names the budget unit and the [Ceiling](../glossary.md) it must not
  disturb.
- **ADR-0007 amends ADR-0005** (its body Status and index-row status both record it), and
  its close-out reconciliation amends the archived origin record `D-0003` (Status pointer).
- **Zero-toolchain / vendor-neutral / not retroactive:** `not reported` where a harness
  cannot report (never a guess); `Effort` is the reasoning-effort setting where exposed;
  `Elapsed` is wall-clock; a human part's model columns read `not applicable`. It applies to
  tasks **started after** this lands — so **this task carries no record of its own**.

The record lands at close-out, in the task detail file. The close-out exception was
narrowed by [#115](https://github.com/pharzam/armature/issues/115) after a correction landed
*unread*; this reconciles it (already inaccurate — the `## Verdict` lands there too) to cover
**inert** end-of-process records, while a correction a round must act on still lands before
close-out. Nothing acts on a recorded figure, so an unread one is no false-green.

## Plan (R12 — ordered, test-first where a test applies)

Task card + pre-registered checks → ADR-0007 + amend ADR-0005 → define the shape once in
`## Completing a task` and reconcile the close-out exception / figure-at-landing / archived
`D-0003` → hook from gate **step 8** (no ninth step) → glossary entry → verify every check +
semantic pass → independent decay rounds on a frozen head → close out.

## Definition of Done

See the acceptance criteria on [issue #179](https://github.com/pharzam/armature/issues/179).

## Out of scope (own issue)

The pre-existing ADR-0005 ↔ `#model-tiers` ↔ glossary wording drift — off this path and
unreconcilable here (ADR-0005's body is immutable); ADR-0007 cites rather than re-quotes.

## Verdict

Delivered ADR-0007 and the resource-record section (gate step 8, recorded not budgeted);
three decay rounds converged after fixing a stale `D-0003` close-out mirror and an 8-line
budget overrun. All lints and 13 acceptance criteria pass; the tier-wording drift is its
own issue.

