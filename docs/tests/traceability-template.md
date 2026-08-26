# Test traceability template

The format that ties one **test** back to the thing it proves — a requirement, a
guardrail, or an Architecture Decision Record (ADR). It is the last link in the
kit's traceability line, the point where "the customer asked for it" becomes "a
test proves it":

    fact (F-NNNN#n) → requirement (REQ/NFR) → guardrail → ADR → task (‹task-ID›) → test

The [PRD traceability matrix](../prd/README.md) already writes this whole line for
one requirement. This template is the test-side view of the same link: fill one
row per test so a reader can go from any test to the reason it exists, and from
any requirement to the test that covers it.

> **How to adapt this file.** Copy the table below into your test suite's docs (or
> keep it here and grow it), one row per test. Replace every `‹…›` cell. Keep a
> row's IDs (`REQ`/`NFR`, `F-NNNN`, `‹task-ID›`) identical to the ones in the
> [PRD matrix](../prd/README.md) and [`facts/`](../facts/), so the two never
> drift. Delete this note once your first real rows are in.

## In plain terms

> Every test in this project exists to prove one specific thing that was asked
> for. This table is the map: pick any requirement and it names the test that
> covers it; pick any test and it names the requirement, the known pitfall, and
> the decision behind it. A requirement with no row here has no proof it works.

## The format

One row per test. The `Test ID` is your own stable handle for the test (a name, a
path, or a tag); the other columns cite records that already exist elsewhere in
the repo.

| Test ID | Level | Covers (REQ/NFR) | Fact (F-NNNN#n) | Guardrail | ADR | Task (‹task-ID›) | Status |
|---------|-------|------------------|-----------------|-----------|-----|------------------|--------|
| `‹test id or path›` | `‹unit \| integration \| e2e \| uat›` | `‹REQ-001›` | `‹F-0001#1›` | `‹guardrails.md §n, or —›` | `‹ADR-000n, or —›` | `‹T-…›` | `‹planned \| red \| green \| frozen›` |

**Column rules:**

- **Level** — one of the [test levels](test-levels.md): `unit`, `integration`,
  `e2e`, or `uat`.
- **Covers** — the `REQ-NNN`/`NFR-NNN` this test proves, or a
  [Definition of Done](dod-checklist.md) item. A test that covers nothing
  traceable is a test looking for a purpose.
- **Fact** — the raw `F-NNNN#n` the requirement derives from, so the line reaches
  all the way back to the customer's words. Use `—` for a test that covers a
  guardrail or DoD item rather than a customer requirement.
- **Guardrail / ADR** — the pitfall this test defends against, or the decision it
  enforces, if any. Use `—` when none applies.
- **Status** — where the test is in the [strict TDD](../engineering-discipline.md#requirements-traceability)
  cycle: `planned` (listed, not written), `red` (written, failing for the right
  reason), `green` (passing), `frozen` (confirmed by a fresh context under
  [R9](../issue-workflow.md#r9--test-freeze-after-confirmation), not to be
  weakened).

## How the row is kept honest

- **One requirement, at least one row.** The
  [DoD checklist](dod-checklist.md) turns this into a rule: a requirement or DoD
  item with no `green`/`frozen` row is not covered, and the change is not done.
- **A frozen row is not weakened.** If a `frozen` test later fails, that opens a
  bug sub-issue — the failure is the signal, not the test's fault
  ([R9](../issue-workflow.md#r9--test-freeze-after-confirmation)).
- **The IDs match their source.** A `REQ`/`NFR` here is the same ID as in the
  [PRD](../prd/); an `F-NNNN` resolves to a real [facts](../facts/) record; a
  `‹task-ID›` matches the [backlog](../tasks/backlog.md) line. `prd-lint.sh`
  already checks the PRD side of this; keep this side in step by hand until a
  linter covers it.
