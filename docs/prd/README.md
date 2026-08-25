# Product Requirements Documents

This directory holds the project's Product Requirements Documents (PRDs). A PRD is
**Layer 2** of the [two-layer facts rule](../engineering-discipline.md#customer-facts):
it is written *from* the raw [`F-NNNN` facts](../facts/), and every requirement in
it cites the fact it derives from. Layer 1 (the facts) is immutable evidence;
Layer 2 (the PRD) is where interpretation is allowed — so a reader can always trace
a requirement back to the customer's exact words.

> **How to adapt this directory.** Keep [`template.md`](template.md), this README,
> and [`prd-lint.sh`](prd-lint.sh) — they are the reusable scaffold. Write your
> real PRDs beside them as `PRD-NNNN-‹slug›.md`. A project with no external
> customer, or one too small to need requirement tracking, can delete this whole
> directory (and the `prd-lint` steps in the [hooks](../../.githooks/pre-commit)
> and [CI](../ci/)); nothing else depends on it. Delete this note once your first
> PRD is in.

## Adding a new PRD

1. Copy [`template.md`](template.md) to `PRD-NNNN-short-slug.md`, using the next
   sequential number.
2. Fill in every section. **Cite a fact** (`F-NNNN` or `F-NNNN#n`) for every
   requirement — see the convention below.
3. Give each requirement a stable ID (`REQ-NNN` functional, `NFR-NNN`
   non-functional), assigned once and never reused or renumbered.
4. Add a row to the [Index](#index) table below.
5. If this PRD **replaces** an earlier one, set the old PRD's Status to
   `Superseded by PRD-NNNN` and link the new one.

## The convention

- **Requirement IDs.** `REQ-NNN` (functional) and `NFR-NNN` (non-functional),
  three digits, assigned once, never reused or renumbered. A retired requirement
  keeps its ID and is marked retired in the change log.
- **Every requirement cites a fact.** At least one cited `F-NNNN`/`F-NNNN#n` must
  resolve to a real record in [`../facts/`](../facts/). *A requirement with no
  cited fact is not a requirement — it is an assumption or a known trap, and
  belongs in [`../guardrails.md`](../guardrails.md).*
- **Statement style.** Short, active, present-tense capability statements. The
  MoSCoW column carries the obligation, so the sentence does not repeat
  "shall/must".
- **Priority and phase.** Every requirement carries a MoSCoW priority
  (`Must | Should | Could | Won't`) and a project-defined phase tag. A `Won't`
  requirement uses the em-dash `—` for its phase.
- **Traceability.** Each PRD ends with the §12 matrix — REQ ↔ facts ↔ guardrail ↔
  ADR ↔ task ↔ test — the one place a requirement is followed end to end.
- **Versioning.** A PRD is versioned like an [ADR](../adr/): a changed requirement
  is a new `## 13. Change log` entry, never a silent edit.

The decision to keep requirements this way is recorded in
[ADR-0002](../adr/0002-record-product-requirements.md).

## The linter enforces these rules

[`prd-lint.sh`](prd-lint.sh) checks every `PRD-*.md` in this directory against the
conventions above — filename shape, unique `REQ`/`NFR` IDs, a resolvable cited
fact per requirement, an allowed MoSCoW value, the `Won't ⇒ Phase —` rule, and a
§12 matrix whose ID set equals the requirement set. It reads only Markdown, so
`sh docs/prd/prd-lint.sh` runs anywhere with no toolchain, and it is green on a
fresh kit (no PRDs yet). It is wired into the
[`pre-commit` hook](../engineering-discipline.md#git-hooks) and
[CI](../engineering-discipline.md#continuous-integration-optional). **If you change
this template's shape, change the linter in the same change** — the two must
agree. Its self-tests live in [`tests/`](tests/) (sample good and bad PRDs, not
example content to fill in). A project on a specific stack may instead port these
checks to its `‹test runner›`.

## Index

| PRD                                        | Title       | Status |
| ------------------------------------------ | ----------- | ------ |
| ‹[PRD-0001](PRD-0001-slug.md)›             | ‹title›     | ‹Draft› |

<!-- Add one row per PRD as you write them. Keep the newest at the bottom. -->
