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

### What counts as an inbound cross-link

A **link**, from a Markdown file outside this directory, whose destination names
the record's file — inline `[text](…/0001-….md)`, a reference definition
`[label]: …/0001-….md`, or a raw `href`. A document that only **names** a record
is discussing it, not linking it: the `ADR-NNNN` shorthand in a sentence, the
filename in a citation or a code span, a link-shaped example inside a fence.
None of those satisfies the check.

That distinction was learned the hard way. The check used to match the shorthand
or the stem as a plain string anywhere under `docs/`, so
[0007](0007-link-coverage-belongs-to-link-lint.md) read as cross-linked on the day
it was written — by an audit record that used `ADR-0007` as a hypothetical
counter-example when no such record existed
([#73](https://github.com/pharzam/armature/issues/73)). A warning that cannot
fire for a record everyone is talking about is worst where it is needed most.

The check matches link syntax; it does not **resolve** it. Whether a link lands on
a real file is [`link-lint.sh`](../links/link-lint.sh)'s single job
([0007](0007-link-coverage-belongs-to-link-lint.md)), and the two compose: this
one proves a link to the record exists, that one proves it points at something.
Neither, on its own, proves the link is the *right* one — that stays a review
responsibility.

## Index

| ADR                                             | Title                         | Status   |
| ----------------------------------------------- | ----------------------------- | -------- |
| [0001](0001-record-architecture-decisions.md)   | Record architecture decisions | Accepted |
| [0002](0002-record-product-requirements.md)     | Record product requirements as PRDs | Accepted |
| [0003](0003-adopt-issue-first-workflow.md)      | Adopt an issue-first workflow | Accepted |
| [0004](0004-ship-agent-entry-points.md)         | Ship agent entry points       | Accepted |
| [0005](0005-independent-review-may-be-an-agent.md) | Independent review may be an agent | Accepted |
| [0006](0006-derive-expectations-from-prose.md) | Keep deriving expectations from the prose | Accepted |
| [0007](0007-link-coverage-belongs-to-link-lint.md) | Link coverage belongs to link-lint | Accepted |

<!-- Add one row per ADR as you write them. Keep the newest at the bottom. -->
