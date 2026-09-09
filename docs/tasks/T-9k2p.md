# T-9k2p — Route work by model tier

Tracks [issue #171](https://github.com/pharzam/armature/issues/171), child of
[#170](https://github.com/pharzam/armature/issues/170). Completed line:
[completed.md](completed.md).

## Why

Model choice exists in the kit at exactly one place — the **Model** independence
level in [`Who may review`](../engineering-discipline.md#who-may-review) — and only
for review. The gate says nothing about which class of model does the rest of its
work. The kit needs one rule for which class of model does which class of work,
without weakening either the [Determinism](../engineering-discipline.md#solution-selection)
preference or that one independence level.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card: this file and the [`backlog.md`](backlog.md) line.
2. Write `docs/adr/0005-route-work-by-model-tier.md`, and add its index row to
   [`docs/adr/README.md`](../adr/README.md). Cites only sibling constitutive docs —
   no forge issue, PR or URL, no link into `docs/decisions/`.
3. Add a `## Model tiers` section to [`engineering-discipline.md`](../engineering-discipline.md),
   after `Solution selection`. It carries the tier-to-gate-step map, links ADR-0005
   (an in-tree relative link), and states both subordinations: routing after
   Determinism, and independence winning where it meets routing.
4. Add a `Model tier` entry to [`glossary.md`](../glossary.md).
5. Add a concise `Model tiers` pointer to [`AGENTS.md`](../../AGENTS.md); review it
   clause by clause for semantic agreement with the source.
6. Run the discipline checks; run independent decay review rounds on a frozen head.
7. Close out: move this task's line to [`completed.md`](completed.md), tick the DoD,
   write the verdict, in the landing PR.

## Definition of Done

- `docs/adr/0005-*.md` exists, follows the template, cites no forge issue/PR/URL,
  and states the rejected alternatives and the Determinism / R5 / Model-independence
  reconciliation.
- A `## Model tiers` section carries the operative rule and maps each tier to the
  gate steps it owns; which models fill a tier stays a `‹…›` marker.
- The section says what an adopter with one tier does.
- `docs/adr/README.md` has the index row; a file under `docs/` links the record.
- The `Model tier` term is in `glossary.md`.
- `adr-lint`, `link-lint`, `run-discipline-tests` and `git diff --check` pass.
- `engineering-discipline.md`, `AGENTS.md` and `glossary.md` agree (R10).

## Verdict

The kit now has one rule for which class of model does which class of work.
[ADR-0005](../adr/0005-route-work-by-model-tier.md) records the decision and its
rejected alternatives; a new `## Model tiers` section in
[`engineering-discipline.md`](../engineering-discipline.md#model-tiers) carries the
operative rule and maps each tier to the gate steps it owns. The rule subordinates
on both axes — it applies only after `Solution selection`'s Determinism criterion
warrants a model, a deterministic check still outranks any tier, and the Model
independence level wins where it meets routing — and a one-tier adopter records the
limit. Which models fill a tier stays a `‹…›` marker; no vendor is named.

The ADR cites only sibling constitutive documents (no forge issue, PR or URL, no
link into `docs/decisions/`); its index row is in `docs/adr/README.md`, and the
`Model tiers` section supplies the inbound link. A `Model tier` glossary entry and a
concise `AGENTS.md` pointer keep the summary layer in step (R10).

Reviewed under a frozen head: round 1 (three lenses on `4c08068`) found one material
defect — the README's "next constitutional ADR" pointer still said `0005` after this
change consumed it — fixed to `0006` in `c077d55`; round 2 (`c077d55`, completeness
lens) returned `nothing material in scope`. Evidence: `adr-lint`, `prd-lint`,
`link-lint` (784 links), `run-discipline-tests` (81 passed) and `git diff --check`
all pass. Budget: 175 changed lines across 7 files, against base `12a1358` (max 260 /
≤10).
