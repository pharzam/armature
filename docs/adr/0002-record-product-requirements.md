# 0002. Record product requirements as PRDs

Date: YYYY-MM-DD

## Status

Accepted

## Context

The kit derives requirements from customer [facts](../facts/) (the two-layer
rule), and the [quality gate](../engineering-discipline.md#working-a-task-under-the-quality-gate)
tells a task author to read "the ticket's acceptance criteria" — but the kit
shipped nowhere to *write* a requirement, no ID scheme for one, and no link from a
fact to the test that proves it. The two ends of the chain existed (raw facts at
one end, tests at the other) with no documented middle. Without that middle, a
requirement cannot be traced back to the customer's words, and "acceptance
criteria" has no home.

## Decision

We will keep product requirements as versioned **Product Requirements Documents
(PRDs)** under [`../prd/`](../prd/), one `PRD-NNNN-slug.md` per product or feature,
built on [`../prd/template.md`](../prd/template.md). Every requirement carries a
stable `REQ-NNN`/`NFR-NNN` ID, a MoSCoW priority, a phase, and **at least one
cited fact** (`F-NNNN`) that resolves to a real [facts](../facts/) record; each
PRD ends with a traceability matrix (fact → requirement → guardrail → ADR → task →
test). The convention is enforced by a Markdown-only linter,
[`../prd/prd-lint.sh`](../prd/prd-lint.sh), wired into the `pre-commit` hook and
CI.

We rejected keeping requirements as free-form text in issue trackers or commit
messages: that leaves them unversioned, uncited, and impossible to lint, so
traceability decays the moment the project grows.

## Consequences

- Traceability becomes a checkable property rather than a hope: `prd-lint.sh`
  fails a requirement with no resolvable fact, a duplicate ID, or a matrix that
  does not match the requirement set.
- The kit carries one more small discipline test to maintain; if the template
  shape changes, the linter changes in the same change.
- A PRD's matrix `ADR` and `Test` columns start empty and fill in as ADRs and
  tests arrive — the chain is designed now and completed over time.
- A project with no external customer, or one too small to track requirements,
  can delete [`../prd/`](../prd/) and the `prd-lint` steps; nothing else depends
  on them.
