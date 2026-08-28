# 0004. Destroying history on the default branch

Date: YYYY-MM-DD

## Status

Accepted

## In plain terms

> Removing or rewriting commits on the default branch is the one change no pull
> request can express, and no later review can undo. It stays allowed, under
> five conditions, and a second person must agree first. It also does not do
> what people expect: on most hosted git services anything that ever appeared
> in a pull request stays fetchable afterwards, so if a credential leaked,
> revoke it — removing the commit is not what ends the exposure.

## Context

Every change to the default branch lands through a pull request, which proposes
commits **onto** a branch. A reset, a rewrite, or a deletion takes them
**away**. No rule written for the first shape reaches the second, so the most
irreversible operation in this kit is the one with no procedure.

Three forces separate it from ordinary work:

- **No later review can undo it.** Every other mistake here is recoverable by a
  further commit; this one destroys what a fix would apply to.
- **One party cannot be both the actor and the check.** Whoever wants the
  history gone is worst placed to judge whether it should go.
- **The forge keeps copies you do not control.** Most hosted forges retain a
  per-pull-request reference the operator cannot delete, so a commit that ever
  appeared in a pull request usually survives the branch it came from. A bare
  remote retains none.

## Decision

We will permit destroying history on the published default branch only under
the five conditions below. **Destruction** means making commits unreachable
from the branch the project treats as canonical, where they were reachable from
whichever branch held that role at any point since — a reset, a force-pushed
rewrite, or deleting the branch. Rewriting local history you have never pushed
is not covered.

1. **An open issue states the goal** in the operator's own words, and why no
   revert, fix-forward, or new branch reaches it.
2. **A second operator approves in writing, and that operator is a person.**
   This narrows [`issue-workflow.md`](../issue-workflow.md), which binds every
   operator, human or agent, alike: an agent instantiated by the acting
   operator is not independent, since it can be re-prompted until it approves
   and holds no stake in what is lost. With no second person, the path is
   closed.
3. **Everything about to be lost is preserved first** — the default branch's
   tip and every unmerged branch tip that is not an ancestor of it — pushed to
   the remote as `backup/pre-<reason>-<short-sha>`, one per tip.
4. **Any lock on the branch is lifted deliberately and restored afterwards**,
   checked against a record of its full configuration made *before* lifting; a
   restore from memory that gets one setting wrong passes an unrecorded check.
   Where the remote offers no such lock, record that instead.
5. **Afterwards, before other work resumes:** every issue whose deliverable is
   now gone returns to open with the evidence, and the issue from condition 1
   records what was destroyed, where the backup is, and who approved.

Conditions 1–3 hold before the act, 4 spans it, and 5 can only follow it: the
evidence it requires does not exist until the act has happened.

We rejected forbidding destruction outright — it is sometimes correct — though
condition 2 closes the path on a solo project regardless. We rejected
[R4](../issue-workflow.md#r4--no-workarounds)'s workaround shape, which supplies
approval authority but nothing about preserving history.

## Consequences

- **On a one-person project, condition 2 closes the path.** That is the
  intended cost. For a leaked credential, **revoke and rotate** — that ends the
  exposure, which deleting the commit may not. For an oversized object or an
  erasure request, whoever operates the remote must act.
- **Nothing checks the five conditions.** The
  [`pre-push` hook](../../.githooks/pre-push) refuses a push to the default
  branch but is advisory, is inert on a fresh clone, and never runs for a web
  editor or an API write. A lock on the branch, where the remote offers one,
  reaches every client but says nothing about who approved, and a holder of a
  bypass passes it. See
  [what is enforced where](../issue-workflow.md#what-is-enforced-where).
- **This record does not say how to undo a destruction that should not have
  happened.** Restoring the branch is itself destroying history under the
  definition above, so these conditions apply to it — including the second
  operator, which a solo operator does not have. Whether that is the right
  answer is deliberately left open rather than settled here in passing.
- Condition 5's cost falls after the operator already has what they wanted,
  which makes it the one most likely to be skipped.
