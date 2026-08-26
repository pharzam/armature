# Definition of Done (DoD) test-coverage checklist

A Definition of Done (DoD) item is a claim, and a claim is not done until a test
proves it. This file turns the [test traceability](traceability-template.md)
table into a gate: it checks that every requirement and every DoD item names a
row in that table, so "done" means "proven", not "looked right".

> **How to adapt this file.** The rule and the checklist below are the reusable
> content — keep them. Replace the `‹…›` DoD items in the table with your
> project's real Definition of Done, and add or remove rows to match it. Delete
> this note once your own items are in.

## In plain terms

> A checked box with no test behind it is a promise, not proof. This file says
> that every item on the Definition of Done, and every requirement, must point
> at a specific test that passed — if it does not, the item is not done, no
> matter how confident anyone feels about it.

## The rule

Every requirement (`REQ`/`NFR`) and every DoD item maps to at least one
[traceability](traceability-template.md) row whose status is `green` or
`frozen`. `planned` and `red` rows show intent, not proof — they do not close
the item. An item with no row at all is not covered, and the change is not
done; see [Testing](../engineering-discipline.md#testing) for the fuller rule
this checklist enforces.

A DoD item does not have to be a requirement itself — it can be a
process rule ("every commit follows the message format") as easily as a
product capability. Either way, the same test applies: name the test, or the
item is unproven.

## The DoD, mapped to tests

| DoD item | Test level | Traceability row | Done? |
|----------|-----------|-------------------|-------|
| `‹every requirement has a test›` | `‹unit \| integration›` | `‹a REQ/NFR row in the traceability table›` | `‹✓ / ✗›` |
| `‹every user-facing path has a test›` | `‹e2e›` | `‹an E2E row per scenario›` | `‹✓ / ✗›` |
| `‹a delivered feature is signed off by a person›` | `‹uat›` | `‹a UAT row, human-checked›` | `‹✓ / ✗›` |
| `‹a bug fix has a test that fails on the old code›` | `‹unit \| integration›` | `‹a row citing the bug's task ID›` | `‹✓ / ✗›` |
| `‹a known pitfall from guardrails.md is defended against›` | `‹unit \| integration \| e2e›` | `‹a row with a Guardrail cell filled in›` | `‹✓ / ✗›` |

## Checklist

Run this at task close, before the change is called done:

- [ ] Every `REQ`/`NFR` this task touches has at least one `green`/`frozen` row
  in the [traceability table](traceability-template.md).
- [ ] Every item on this task's Definition of Done has a covering test, listed
  above or added as a new row.
- [ ] No requirement change left a stale test — a test written against an old
  requirement is updated or replaced, not left passing against a rule that no
  longer holds.
- [ ] The traceability table's ID set matches the requirement set: no `REQ`/`NFR`
  is missing a row, and no row cites an ID that does not exist.
