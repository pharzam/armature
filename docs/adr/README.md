# Architecture Decision Records

This directory holds the project's Architecture Decision Records (ADRs), in the
lightweight format described by Michael Nygard — see ADR-0001 in the index below
for the full rationale.

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

A **link** whose destination's final path component **is** the record's
filename — inline
`[text](…/0001-….md)`, a reference definition `[label]: …/0001-….md`, or a raw
`href` — carried by a Markdown file the check reads. It reads every `.md` under
this directory's **parent** except this directory itself, plus the `README.md`
beside that parent. In this kit those are [`docs/`](..) and the repository-root
[`README.md`](../../README.md), so a file elsewhere in the tree — the root
`AGENTS.md` included — is outside its reach. Move the ADR directory and the reach
moves with it, which is the last of the limits listed in the script.

Two kinds of file inside that reach still do not count. **Fixture cases** hold
test data rather than navigation, and some of their links are deliberately broken,
so a link planted in one would otherwise satisfy this check for a real record.
Both shapes the [test runner](../tests/run-discipline-tests.sh) drives are
skipped, on the `good*` / `bad*` globs it dispatches on: a case **directory**, and
a case **file** under a `tests/` directory. Their suite READMEs
are prose a reader follows, and do count — the naming is the whole mechanism, so
fixture data called something else is read like any other document.

**A link to a real record from any suite README satisfies that record's inbound
link**, which is rarely what the author of a fixture intends. The one exception is
[this suite's own](tests/README.md): it sits inside this directory, which is
excluded before anything else, so a link there counts for nothing. Every other
one — `docs/agents/tests/`, `docs/prd/`, `docs/tasks/` — counts. Nothing enforces
this; it is a rule for whoever writes a fixture.

And a document that only **names** a record is discussing it, not linking it: the
`ADR-NNNN` shorthand in a sentence, the filename in a citation or a code span, a
link-shaped example inside a fence, a link inside an HTML comment. None of those
satisfies the check.

The distinction is the whole check. A token match — the shorthand, or the
filename, anywhere in a file — reads a document that *discusses* a record as one
that links it, and prose about records is exactly where that token turns up. The
warning then goes quietest for a newly written record, which is the one most
likely to be discussed before anyone links it.

The check matches link syntax; it does not **resolve** it. Whether a link lands
on a real file is [`link-lint.sh`](../links/link-lint.sh)'s single job, given to
it by ADR-0007, and the two compose: this one proves a link to the record exists, that one proves
it points at something. Neither, on its own, proves the link is the *right* one —
that stays a review responsibility.

One limit is worth knowing before you rely on that pair: **they compose only for
an in-tree target.** `link-lint` skips `http`, `https` and `mailto` deliberately —
resolving them needs the network, which would cost the offline property every
check here depends on — so a record whose only inbound link is an absolute forge
URL reads as cross-linked and is resolved by nothing. That URL can name a file
that does not exist and both checks stay green. Eight narrower ones — six more about what the
matching reads, two about where the ADR directory sits — are listed in
[`adr-lint.sh`](adr-lint.sh)'s header beside the code that carries them.

One rule for writing in **this** file, which follows from a different check. The
index-row check is a bare filename match against this README, so any sentence here
that carries a record's **filename** makes that check unfalsifiable — the row could
be deleted and the linter would still find the name in the prose. So refer to a
record by number here, and let the index table below do the linking.

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
| [0008](0008-stop-the-gate-on-a-frozen-head.md) | Stop the gate on a frozen head | Accepted |

<!-- Add one row per ADR as you write them. Keep the newest at the bottom. -->
