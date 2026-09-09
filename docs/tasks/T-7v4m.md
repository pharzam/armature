# T-7v4m — Convene a panel to generate options, not to vote

Tracks [issue #172](https://github.com/pharzam/armature/issues/172), child of
[#170](https://github.com/pharzam/armature/issues/170). Completed line:
[completed.md](completed.md).

## Why

A proposed way of working asks a multi-agent panel to "iterate until a unified,
robust consensus". The kit forbids that:
[`When reviewers disagree`](../engineering-discipline.md#when-reviewers-disagree)
says reviewers do not average their verdicts and the author does not break the tie,
and an unresolved disagreement is recorded, not manufactured.
[R10](../issue-workflow.md#r10--sync-with-governance) makes a governance conflict an
ADR, not a prose edit.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card: this file and the [`backlog.md`](backlog.md) line.
2. Write `docs/adr/0006-convene-a-panel-to-generate-options.md`; add its index row to
   [`docs/adr/README.md`](../adr/README.md) and bump the Numbering pointer `0006`→`0007`
   (R10). Cites only sibling constitutive docs — no forge issue/PR/URL, no link into
   `docs/decisions/`.
3. Hook the panel into [`Solution selection`](../engineering-discipline.md#solution-selection)
   (supplies the inbound relative link to ADR-0006) and into R12's *Select the plan* in
   [`issue-workflow.md`](../issue-workflow.md). `When reviewers disagree` is left intact.
4. Add a `Panel` entry to [`glossary.md`](../glossary.md).
5. Run the discipline checks; run independent decay review rounds on a frozen head.
6. Close out: move this task's line to [`completed.md`](completed.md), tick the DoD,
   write the verdict.

## Definition of Done

- `docs/adr/0006-*.md` exists, follows the template, cites no forge issue/PR/URL, names
  the chosen option and why Options 2 and 3 were rejected.
- The ADR states the panel's output type — options, not a verdict — and when a panel is
  required, when optional, and what bounds its iteration.
- `When reviewers disagree` is left intact (Option 1); it never contradicts the ADR.
- The panel's composition stays a `‹…›` marker.
- `docs/adr/README.md` has the index row; the Solution-selection hook links the record.
- The `Panel` term is in `glossary.md`.
- `adr-lint`, `link-lint`, `run-discipline-tests` and `git diff --check` pass.
- `engineering-discipline.md`, `issue-workflow.md` and `glossary.md` agree (R10).

## Verdict

_(Filled at close-out, after the decay rounds settle.)_
