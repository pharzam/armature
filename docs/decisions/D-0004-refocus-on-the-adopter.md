# D-0004. Refocus on the adopter; stop the unattended-run milestone

Date: 2026-09-07

## Status

Accepted

## Context

Armature's stated goal is a lean, domain-free scaffold an adopter composes onto a
new project — a template, not a product, holding no product code and no product test
suite. An independent assessment measured the repository against that one yardstick
and is kept as the deep-dive behind this record:
[the independent assessment](../audit/you-are-an-independent-swirling-whistle.md).

Its findings converge on one drift. Recent forward motion is almost entirely
self-facing (F7): the open roadmap had become a milestone whose goal is to make the
kit operate its own process with no human, its acceptance test being to land a task
with no human message on its thread (F10). The self-measured payoff of that
direction is thin — a 45-hour baseline changed behaviour in roughly one finding in
eleven — and the one run to date "was ended by the repository owner's instruction…
not by any rule" (F12). Meanwhile the kit had diagnosed its own over-fitting and
then closed the single task that would test it on a real adopter (`#22`), and the
adoption-profiles task (`#20`), both `NOT_PLANNED` (F13).

The assessment is an evaluation, not a work order, and it left one question expressly
to the owner: whether the unattended-run milestone is intended as a product in its
own right — an autonomous-agent harness — rather than as the Armature template. That
choice is the owner's to make, and it is what this record settles.

## Decision

We will keep the goal exactly as the README states it: the adopter-facing
engineering-discipline kit. Every task from now on must serve the adopter — the
engineer who copies this kit onto a new project. A task that would only make the kit
govern itself more precisely is recorded as an issue and then stopped, not worked.

We will stop the unattended-run direction. "The unattended milestone" is closed and
its open issues are superseded by the pivot decision (issue `#143`); no further
unattended-run mechanism is built in this repository.

We reject the alternative of continuing that milestone — or carrying it forward as a
separate autonomous-agent product inside this repository. The assessment left that
door to the owner, and the owner closes it: no further unattended-run mechanism is
built here, and any of the milestone's work still in flight — the pre-flight (`#126`),
whose pull request has not landed, among it — is not carried further.

This record states the decision; it does not itself delete any mechanism. The
deletions the assessment names (the `audit-record` stack, the `agents-lint`
meta-chain, and the ADRs that only justify the latter) are carried out under their
own issues in the phases that follow, each sliced and reviewed on its own.

## Consequences

The project's forward motion turns back toward the adopter. The valuable scaffold —
the core docs, the ADR and PRD conventions, `adr-lint`, `prd-lint`, the `commit-msg`
hook, the enforcement-honesty table, and the dogfooding practice that caught real
defects early (F8) — is kept and is unaffected by this record.

What becomes harder: work that sharpens the kit's self-governance no longer counts as
progress, so a genuinely useful self-check must now justify itself as adopter value or
wait.

What this creates: three follow-on efforts, each its own attended phase — CUT the
self-facing mechanism (superseding D-0001 and D-0002), SIMPLIFY what stays, and
re-slice the backlog toward the adopter by re-recording `#22` (dogfood on one real
product repository) and `#20` (adoption profiles).

What stays open: `#22` and `#20` are re-recorded as the next work but not reopened by
this record; the audit evidence under `docs/audit/` is repo-specific history that an
adopter deletes, kept here only as the basis for this decision.
