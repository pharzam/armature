# T-r4t8 — Reconcile the glossary's execution-tier model gloss with ADR-0005

Tracks [issue #188](https://github.com/pharzam/armature/issues/188). Completed
line: [completed.md](completed.md). Plan and its independent review are on the
issue (R12).

## Why

The `Model tier` glossary entry glosses the execution tier's model class as
**"(lighter, cheaper models)"**, while ADR-0005's Decision and the operative
[`## Model tiers`](../engineering-discipline.md#model-tiers) table both write
**"(lighter, faster, cheaper models)"**. The glossary drops **"faster"** — a
pre-existing [R10](../issue-workflow.md#r10--sync-with-governance) drift on a
different axis from the "set/fixed" execution-tier-*clause* drift that
[#185](https://github.com/pharzam/armature/issues/185) fixed, and which #185
deliberately scoped out and raised here.

- `docs/glossary.md:62` — "an **execution tier** (lighter, cheaper models) …"
- `docs/adr/0005-route-work-by-model-tier.md:36` (immutable) — "(lighter, faster, cheaper models)"
- `docs/engineering-discipline.md:237` — "lighter, faster, cheaper models"

## What

ADR-0005's body is immutable and the operative table already agrees with it, so the
canonical gloss is **"lighter, faster, cheaper"**. The editable outlier is the
glossary entry; add the dropped **"faster"** so the three homes agree (R10). ADR-0005
is untouched.

Rejected alternative: judge the glossary's two-adjective gloss acceptable compression
and record no change. Rejected because there is no principled reason the glossary
keeps "lighter" and "cheaper" but drops only "faster"; it reads as an oversight, not a
considered shorter gloss, and the one-word alignment restores exact consistency at no
cost. The plan review picks; see the issue.

## Plan (R12 — ordered, test-first where a test applies)

Task card → pre-register the consistency grep and confirm it fails now (the glossary
gloss lacks "faster") → add "faster" to the glossary gloss → re-run the grep (the
three homes now agree) and every discipline check + `git diff --check` → one
independent, clause-by-clause semantic-agreement round on a frozen head, on a second
model (a governance document, so Model independence applies) → close out with the
resource record, the completed line, and the verdict, in the landing PR.

## Definition of Done

- The `Model tier` glossary entry glosses the execution tier as "lighter, faster,
  cheaper models", matching ADR-0005's Decision and the `## Model tiers` table (R10).
- ADR-0005's body is untouched (immutable).
- A pre-registered grep confirms all three homes use "lighter, faster, cheaper" and
  the glossary no longer carries the two-adjective "lighter, cheaper" gloss.
- `adr-lint`, `prd-lint`, `link-lint`, `run-discipline-tests` and `git diff --check`
  pass.
- An independent clause-by-clause semantic-agreement review is recorded on
  [#188](https://github.com/pharzam/armature/issues/188).
- Observed, not folded in (non-material, glossary style): the reasoning-tier gloss
  reads "frontier/reasoning" in the glossary and "frontier / reasoning" in the table
  and ADR — a whitespace-only typographic difference, not a dropped word; left as is.

## Verdict

Mergeable. The `Model tier` glossary entry now glosses the execution tier as
"(lighter, faster, cheaper models)", matching ADR-0005's Decision and the
`## Model tiers` table — so the three homes agree (R10), and ADR-0005's immutable
body is untouched. The plan was reviewed once and **approved** (Option A confirmed
independently — the glossary keeps both adjectives for the reasoning tier but dropped
one for the execution tier, signalling an oversight, not a considered compression) on
[#188](https://github.com/pharzam/armature/issues/188); one independent,
Model-independent semantic-agreement decay round on frozen head `b07c5b0` returned
`nothing material in scope`. The reasoning-tier "frontier/reasoning" vs
"frontier / reasoning" slash-spacing is a whitespace-only difference, non-material,
left as observed. The discipline checks, the pre-registered consistency grep, and
`review-record-lint` (3 comments, 1 round, cap 2) all pass.

## Resource record

Per [ADR-0007](../adr/0007-record-task-resource-use.md). This harness reports tokens
and elapsed time for the independent **agent** sessions but not per part for the main
loop, so the main-loop cells read `not reported` (the degradation ADR-0007
anticipates, never a guess). The two review sessions ran on a different frontier model
(Sonnet 5) to reach **Model** independence for this governance-document change; no part
was routed to a genuinely lighter **execution tier** — the execution part (the fix)
ran on the reasoning-tier main-loop model, the single-tier limit
[ADR-0005](../adr/0005-route-work-by-model-tier.md) says to record.

| Part | Expected tier | Model | Effort | Tokens | Elapsed |
| ---- | ------------- | ----- | ------ | ------ | ------- |
| the plan | reasoning | Opus 4.8 (main loop) | not reported | not reported | not reported |
| the plan review | reasoning | an independent agent session (Sonnet 5) | not reported | 68,000 | ~2 min |
| the fix | execution | Opus 4.8 (reasoning tier — single-tier limit) | not reported | not reported | not reported |
| the decay review round | reasoning | an independent agent session (Sonnet 5) | not reported | 54,958 | ~1 min |
| isolate + close-out | `—` | Opus 4.8 (main loop) | not reported | not reported | not reported |
| **Total** | | | | not reported (main-loop parts unmeasured) | not reported |
