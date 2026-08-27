# 0003. Adopt an issue-first workflow

Date: YYYY-MM-DD

## Status

Accepted. Amended by [ADR-0004](0004-destroying-history-on-the-default-branch.md)

## Context

The [quality gate](../engineering-discipline.md#working-a-task-under-the-quality-gate)
assumes "tickets" — it tells a task author to read "the ticket's acceptance
criteria" and to move a ticket from backlog to completed — but the kit never
defined how a ticket is opened, scoped, or linked to the change that closes it.
The kit also runs work in parallel across many worktrees and, increasingly, across
LLM agents; parallel operators need one place to coordinate and one rule for what
must exist before code is written. Without that, decisions live only in a head or a
commit message, and two operators can duplicate or contradict each other.

## Decision

We will require an **open issue before any change**, with the rules R1–R11 in
[`../issue-workflow.md`](../issue-workflow.md). One issue is one actionable,
demoable goal (large work becomes a parent plus child issues); the change lands
through a pull request whose body links the issue (`Closes`/`Refs #N`); the task ID
stays in the commit subject, so the task-ID and issue-number namespaces coexist.
The policy is written **forge-neutrally** — an "issue" is a tracked ticket in
whatever forge the project uses — and any forge-specific issue/PR templates ship
inert under [`../templates/`](../templates/), so the kit stays forge-free.

We rejected tracking work by commit message or task card alone: that leaves no
outward, linkable record of the goal and the decisions, and no single coordination
point for parallel operators.

## Consequences

- Every change is traceable to an issue, and every issue to the PR that closed it.
- The kit stays forge-free: the workflow is prose, and forge templates are opt-in
  copies, like the [CI templates](../ci/).
- Some rules (a PR-links-an-issue check, a coverage gate) are written-rule-only
  until a project wires the gate; [`../issue-workflow.md`](../issue-workflow.md)
  states honestly which are mechanized today.
- Operators — human and agent — carry a small, fixed protocol (issue first, one
  goal, decisions on the thread) that a fresh context can pick up without the
  author present.
