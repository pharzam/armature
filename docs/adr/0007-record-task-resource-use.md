# 0007. Record each task's resource use, per part and in total

Date: 2026-09-09

## Status

Accepted

## Context

[ADR-0005](0005-route-work-by-model-tier.md) routes work by model tier, and named
its own limit in its Consequences: **nothing is mechanized** — no check reads which
model ran which step, and none can, so the rule "buys a claim precise enough to be
*wrong*, not a verified control". A rule nobody records is not even wrong: it is
unobservable. "The reasoning tier owned the plan review" is a claim a later reader
should be able to check, and today there is nothing to check it against.

This record adds the missing **evidence**. It does not mechanize the routing and must
not read as if it did — the figures are self-reported, and that honesty is the same
one [Who may review](../engineering-discipline.md#who-may-review) states about its own
independence levels.

## Decision

Every task **started after this record lands** closes with a **resource record**: a
further section of its `docs/tasks/<id>.md` file, after `## Verdict`, giving for each
part of the work the model, the effort, the tokens and the elapsed time, with the
totals at the foot. The shape is defined once, in an adopter-copyable form, in
[Completing a task](../engineering-discipline.md#completing-a-task); gate step 8 asks
for it, so it is applied and not merely written.

A **part** is classified by the routing partition [Model tiers](../engineering-discipline.md#model-tiers)
already defines — a **reasoning-tier** part (which decides or judges) or an
**execution-tier** part (which carries out a fixed plan) — with a third value **`—`**
for the gate steps that partition does not route. This record names those two classes
and cites `#model-tiers` for their authoritative definition rather than restating the
activity lists, which live there. Recording cost against the **same** partition the
tier is routed against is the whole point: an execution-tier model on a reasoning part
is a mismatch a reader can raise as a finding. The `—` rows carry no such expectation
but are still summed, so the total is a true total.

**These figures are recorded, not budgeted.** They carry no approval number, no cap,
and no route to a verdict. An overrun of tokens or time is not a finding, does not
block a merge, and does not touch the `Budget maximum` or the `Cycle cap`. The kit has
exactly one budget, and its unit is **not** tokens or time — it is "lines added plus
lines removed on the whole branch diff, plus files touched, measured against a named
base SHA" ([Reviewing until findings decay](../engineering-discipline.md#reviewing-until-findings-decay)).
The kit also has no [Ceiling](../glossary.md): an approval is one number at landing and
reaches no further, and one of the three reaches a review round once wrote and a later
round falsified was "bounding the measured outturn" — which is exactly what a token or
time figure is. This record sits on that measured-outturn side and bounds nothing.

Where the adopter's harness cannot report a figure, the rule says to write
`not reported` — never a guess; a guessed number is worthless as evidence. The record
is **vendor-neutral**: `effort` is the reasoning-effort setting where the model exposes
one, no vendor, model or effort vocabulary is named, and how the figures are obtained
stays a `‹…›` marker. The gate binds both operator classes, so a **human**-worked part
is recorded too, with its model columns written `not applicable`; `elapsed` is
wall-clock for every part, so model and human rows are comparable.

This record **amends** ADR-0005 — the routing decision still holds, and this adds the
evidence it named as missing — so ADR-0005's Status becomes `Accepted. Amended by
ADR-0007`, per [Adding a new ADR](README.md#adding-a-new-adr) step 4. It changes
nothing else in that record's immutable body.

We reject the alternatives, recorded so none is reopened: rows in `completed.md`
(breaks its one-line index rule); a new metrics document or store (needs infrastructure
the kit defers until the problem requires it, and the kit is toolchain-free); no ADR
(the budget-and-Ceiling tension goes unrecorded and gets relitigated); and extending
the review record's fields (those are review-round fields, and most parts of a task
are not review rounds).

## Consequences

- A routing claim becomes checkable: a reader lays each part's model against the tier
  its partition expects, and a mismatch is a finding. The evidence ADR-0005 lacked now
  exists.
- **The figures are self-reported.** No check verifies that the model named is the
  model that ran — the record buys a checkable claim, not a control. Overstating it
  would be the defect the review sections exist to catch.
- **It is not a second budget.** No cap, no verdict, no ceiling; an overrun is recorded
  and never blocks a merge. The one budget's unit and the no-ceiling rule are untouched.
- The record is written in the close-out commit, in the task's detail file — the same
  end-of-process, inert bookkeeping the verdict already is, produced only once the
  rounds finish. Nothing in the gate acts on a recorded figure, so an unread or even a
  wrong figure is no silent false green; a correction a round must act on still lands
  as an ordinary fix before close-out.
- An adopter whose tooling cannot report a figure writes `not reported` and stays green;
  the rule degrades, it does not fail. Adopter-specific values stay `‹…›` markers.
- The routing partition is cited, not copied, so this record adds no fourth wording of
  a partition prose that already varies across its homes; reconciling that variance is
  a separate concern, not reopened here.
