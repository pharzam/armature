# T-cw87 — Record model, effort, tokens and elapsed time per gate part, in the task file

Tracks [issue #179](https://github.com/pharzam/armature/issues/179), the follow-up to
[ADR-0005](../adr/0005-route-work-by-model-tier.md). Completed line:
[completed.md](completed.md). Plan and its independent review are recorded on the
issue thread (R12).

## Why

[ADR-0005](../adr/0005-route-work-by-model-tier.md) routes work by model tier but
named its own limit in its Consequences: "Nothing is mechanized … the rule buys a
claim precise enough to be *wrong*, not a verified control." A rule nobody records is
unobservable. This task supplies the **evidence** — a per-task **resource record** of
the model, effort, tokens and elapsed time, per gate part and in total — so
"the reasoning tier owned the plan review" becomes a row a later reader can check,
not a claim taken on trust. The figures are **recorded, not budgeted**.

## What

A new constitutional **ADR-0007** decides it; the record is a section of
`docs/tasks/<id>.md` after `## Verdict`, hooked from gate **step 8** (close-out).

- **The part** is ADR-0005's routing partition — **reasoning**-tier parts, **execution**-tier
  parts, and **`—`** for the gate steps neither tier routes — cited from
  [Model tiers](../engineering-discipline.md#model-tiers), not re-stated (the partition
  prose already drifts three ways; a fourth copy is a fresh R10 defect — that drift is a
  separate issue). Recording cost against the same partition the tier is routed against is
  what makes a mismatch (an execution-tier model on a reasoning part) a finding a reader
  raises; the `—` rows carry no expectation but are still summed, so the `Total` is a true
  total.
- **Recorded, not budgeted:** no approval number, no cap, no route to a verdict; an overrun
  is not a finding. ADR-0007 names the two settled rules it must not disturb — the budget
  unit and the [Ceiling](../glossary.md).
- **ADR-0007 amends ADR-0005** (it closes the gap ADR-0005 named): ADR-0005's body Status
  and its `adr/README.md` index-row status both record the amendment.
- **Zero-toolchain / vendor-neutral / not retroactive:** `not reported` where a harness
  cannot report a figure (never a guess); `Effort` is the reasoning-effort setting where the
  model exposes one; `Elapsed` is wall-clock; a human part writes the model columns
  `not applicable`. The rule applies to tasks **started after** this lands — so **this task
  carries no resource record of its own**; the worked example lives in the definition.

## The close-out edit, handled with care

The record lands in the close-out commit, in the task **detail** file. The close-out
exception ([`engineering-discipline.md`](../engineering-discipline.md#reviewing-until-findings-decay))
was deliberately narrowed by [#115](https://github.com/pharzam/armature/issues/115) after a
corrected link count once landed *unread* through the wider hole. This change does not
reverse that: it reconciles the exception (already inaccurate — the `## Verdict` is written
to the detail file at close-out too) so it covers **inert** end-of-process records produced
only once the rounds finish — the verdict and the resource record — while a **correction a
round must act on** still lands as an ordinary fix *before* close-out. Nothing acts on a
recorded figure, so an unread or wrong one is no silent false-green, unlike the #115 case.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card (this file) + `backlog.md` line; pre-register the checks (adr-lint fails 3e once
   `0007` exists without an index row; `eight` unchanged at `AGENTS.md:43` / `glossary.md:87`).
2. Write **ADR-0007**; amend ADR-0005 (body Status + index-row status); add the index row.
3. Define the record shape once in `## Completing a task`; reconcile the close-out exception,
   the "figure at landing", and the glossary `Ceiling` / `Frozen head` entries.
4. Hook from gate **step 8** (three-touch, no ninth step); confirm the count stays eight.
5. Glossary: a `Resource record | — | …` entry (parallel to `Review record`).
6. Verify every discipline check + the semantic pass; run independent decay rounds on a frozen head.
7. Close out: move this line to [`completed.md`](completed.md), write back any lesson to
   [`guardrails.md`](../guardrails.md) §2, tick the DoD, write the verdict.

## Definition of Done

See the acceptance criteria on [issue #179](https://github.com/pharzam/armature/issues/179):
`0007` exists and is template-shaped, citing no forge issue; it states what a part is and why,
that the figures are recorded not budgeted (naming the budget unit and the Ceiling), and the
self-reported limit; the record section is defined once, adopter-copyable, with a true total;
`not reported` covers the unavailable; a named gate step asks for it (count stays eight); no
row is added to `backlog.md` / `completed.md`; markers stay `‹…›`; the new form earns a glossary
entry; an index row and inbound `docs/` link exist for `0007`; all lints and `git diff --check`
pass; docs current in the same PR.

## Out of scope (own issue)

The pre-existing ADR-0005 ↔ `#model-tiers` ↔ glossary wording drift ("carry out a fixed plan"/
"once the plan is **set**" vs "tactical execution and coding"/"once the plan is **fixed**") —
pre-existing, off this path, and unreconcilable here (ADR-0005's body is immutable). ADR-0007
avoids compounding it (cites, does not re-quote); the drift opens its own issue.
