# 0005. Route work by model tier

Date: YYYY-MM-DD

## Status

Accepted

## Context

The kit binds **every operator — each human and each LLM coding agent** — to the
[quality gate](../engineering-discipline.md#working-a-task-under-the-quality-gate).
Model choice appears in exactly one place today: the **Model** independence level in
[Who may review](../engineering-discipline.md#who-may-review), and only there — for
*review*, only for high-risk work, and only where an adopter has a second model to
reach for. The gate says nothing about which class of model should do the rest of
the work it drives.

Two forces press on that gap. [Solution selection](../engineering-discipline.md#solution-selection)'s
**Determinism** criterion prefers "plain code, rules, and algorithms to an LLM
call", and [R5](../issue-workflow.md#r5--deterministic-over-llm-based) repeats it —
so any rule about *models* must not read as licence to reach for one where a script
would settle the claim. And an operator running agents across the whole gate needs a
rule for which class of model does which class of work, without weakening either the
Determinism preference or the one independence level model choice already backs.

## Decision

We will **route model work by tier**, and only after Determinism has warranted a
model at all.

We define two tiers, and name no vendor or model — which concrete models fill each
tier is the adopter's `‹…›` marker. A **reasoning tier** (frontier / reasoning
models) owns the steps that **decide or judge**: the ordered plan and its review,
solution selection, the review rounds, the review before a costly or irreversible
action, and the verdict. An **execution tier** (lighter, faster, cheaper models)
owns **tactical execution and coding** — writing the tests and the code once the
plan is fixed, and routine mechanical edits.

The routing carries two bounds, so it strengthens the gate without weakening a rule
that already holds. First, it applies **after** the Determinism criterion, never
instead of it: a [deterministic check](../issue-workflow.md#r5--deterministic-over-llm-based)
still outranks a model of any tier. Second, it never weakens the **Model
independence level**: routing says which tier *executes* a step, independence says a
reviewer's model *differs from the author's*, and where the two meet **independence
wins** — a reviewer never drops to the author's model to satisfy routing. An adopter
with a single model cannot route; it runs the work on the tier it has and **records
the limit**, the same way Who may review handles running out of independence levels.

We rejected the alternatives, recorded so none is reopened without new information:
a discipline section with **no ADR** — a later reader reopens the closed question of
how routing relates to Determinism, and the tension goes unrecorded; the rule placed
**only inside Who may review** — that governs review, not execution, and the rule is
about both; a **new standalone document** — the kit prefers a rule beside its use
and earns a new artifact type only when an existing home fails; and **naming
concrete models** — the kit is vendor-neutral, so "frontier" and "light" stay the
adopter's markers.

## Consequences

- An operator has one rule for which class of model does which class of work, and it
  sits beside Solution selection, which already owns model choice. The rule extends
  model choice from review to the whole gate.
- **Nothing is mechanized.** No check reads which model ran which step, and none can
  — the same honesty Who may review states about its own levels. The rule buys a
  claim precise enough to be *wrong*, not a verified control; overstating it would be
  the defect the review sections exist to catch.
- The **Determinism** preference is untouched and still outranks any tier; the
  **Model independence level** is untouched and still wins where it meets routing.
  This ADR adds a rule beside them, not over them.
- A single-model adopter cannot route and records that limit. A limit recorded can
  be judged; a limit implied cannot.
- The operative rule lives in a new `## Model tiers` section of
  [`engineering-discipline.md`](../engineering-discipline.md#model-tiers), written
  first; this record says why.
