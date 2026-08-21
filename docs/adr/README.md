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

## Index

| ADR                                             | Title                         | Status   |
| ----------------------------------------------- | ----------------------------- | -------- |
| [0001](0001-record-architecture-decisions.md)   | Record architecture decisions | Accepted |

<!-- Add one row per ADR as you write them. Keep the newest at the bottom. -->
