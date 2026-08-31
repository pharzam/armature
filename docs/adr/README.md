# Architecture Decision Records

This directory holds the project's Architecture Decision Records (ADRs), in the
lightweight format described by Michael Nygard — see
[0001](0001-record-architecture-decisions.md) for the full rationale.

## Adding a new ADR

1. Copy [`template.md`](template.md) to `NNNN-short-title.md`, using the next
   sequential number.
2. Fill in Context, Decision, and Consequences. Set Status to `Proposed` if it
   still needs sign-off, or `Accepted` if it is already decided.
3. If this decision **replaces** an earlier one, set the old ADR's status to
   `Superseded by ADR-NNNN` and link to the new one.
4. If it **extends** an earlier one — the old decision still holds, but this adds
   to it — set the old ADR's status to `Accepted. Amended by ADR-NNNN` instead.
   Supersession would wrongly imply the old decision stopped applying.

The Status line is the one part of an accepted ADR that may be edited, and only
to record one of these two relationships. Everything else stays immutable.

## The linter enforces these rules

[`adr-lint.sh`](adr-lint.sh) checks every `NNNN-*.md` in this directory against
the conventions above — filename shape, contiguous numbering, the title line, a
`Date:` line, an allowed `## Status`, the required `## Context` / `## Decision` /
`## Consequences` sections, and a row in the index table below (a missing inbound
cross-link is a warning). It reads only Markdown, so `sh docs/adr/adr-lint.sh`
runs anywhere, and it is wired into the
[`pre-commit` hook](../engineering-discipline.md#git-hooks) and
[CI](../engineering-discipline.md#continuous-integration-optional). If you change
this template's shape, change the linter in the same change — the two must agree.

## Index

| ADR                                             | Title                         | Status   |
| ----------------------------------------------- | ----------------------------- | -------- |
| [0001](0001-record-architecture-decisions.md)   | Record architecture decisions | Accepted |
| [0002](0002-record-product-requirements.md)     | Record product requirements as PRDs | Accepted |
| [0003](0003-adopt-issue-first-workflow.md)      | Adopt an issue-first workflow | Accepted |
| [0004](0004-ship-agent-entry-points.md)         | Ship agent entry points       | Accepted |
| [0005](0005-independent-review-may-be-an-agent.md) | Independent review may be an agent | Accepted |
| [0006](0006-derive-expectations-from-prose.md) | Keep deriving expectations from the prose | Accepted |

<!-- Add one row per ADR as you write them. Keep the newest at the bottom. -->
