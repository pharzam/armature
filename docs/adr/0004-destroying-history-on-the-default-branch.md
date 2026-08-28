# 0004. Destroying history on the default branch

Date: YYYY-MM-DD

## Status

Accepted

## In plain terms

> Removing or rewriting commits on the default branch is the one change no pull
> request can express, and no later review can undo. It is permitted, under
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
  history gone is worst placed to judge whether it should go — and an agent
  instantiated by the acting operator is not a second party, since it can be
  re-prompted until it approves and holds no stake in what is lost.
- **The forge keeps copies you do not control.** Most hosted forges retain a
  per-pull-request reference the operator cannot delete, so a commit that ever
  appeared in a pull request usually survives the branch it came from. A bare
  remote retains none.

## Decision

We will permit destroying history on the default branch only under the five
conditions below. **Destruction** means making commits unreachable from every
branch that has been the default at any point in the project's history, where
they were reachable from one of them. A reset, a force-pushed rewrite and
deleting the branch are its usual forms; the list is not exhaustive. The test is
what the remote holds, not which act reached it: pointing the default at another
branch destroys nothing while the old one stands, and deleting that old branch
later is the destruction, whenever it happens and whoever does it. Rewriting
local history you have never pushed is not covered.

1. **An open issue states the goal** in the operator's own words, and why no
   revert, fix-forward, or new branch reaches it. It records every reference on
   the remote, by name and object name, as they stand at that moment.
2. **A second operator approves in writing, and that operator is a person.**
   This narrows [`issue-workflow.md`](../issue-workflow.md), which binds every
   operator, human or agent, alike. With no second person, the path is closed.
3. **Everything about to be lost is preserved first** — the default branch's
   tip and every other branch tip on the remote that is not an ancestor of it —
   pushed to the remote as `backup/pre-<reason>-<short-sha>`, one per tip. Take
   both the set as it stood when condition 1's issue was opened and the set as
   it stands at the act; earlier `backup/` references are not swept again. Open
   condition 1's issue before tidying references. None of these references is
   deleted while any commit it preserves is unreachable from the default
   branch.
4. **Any lock on the branch is lifted deliberately and restored afterwards**,
   with both recorded, and the restore checked against a record of the lock's
   full configuration made *before* lifting. Where the remote offers no such
   lock, record that; where the act never needed it moved, record that and what
   made it unnecessary.
5. **Every issue whose deliverable is no longer on the default branch returns
   to open with the evidence, and condition 1's issue — or a new one if
   condition 1 was skipped — records what was destroyed, where the backups are,
   and who approved.** This comes after the act and before any further work on
   the repository that is not part of it; a commit, a push, a merge and closing
   an issue all count as further work.

Conditions 1–3 hold before the act, 4 spans it, and 5 can only follow it: the
evidence it requires does not exist until the act has happened.

We rejected forbidding destruction outright — it is sometimes correct. We
rejected [R4](../issue-workflow.md#r4--no-workarounds)'s workaround shape, which
supplies approval authority but nothing about preserving history.

## Consequences

- **On a one-person project, condition 2 closes the path.** That is the
  intended cost. For a leaked credential, **revoke and rotate** — that ends the
  exposure, which deleting the commit may not. For an oversized object or an
  erasure request on a hosted forge, its operator must act. Where the operator
  runs the remote themselves, that route is the one condition 2 closed, and
  this record leaves them without one.
- **Nothing checks the five conditions.** The
  [`pre-push` hook](../../.githooks/pre-push) refuses a push to the branch it is
  configured to protect but is advisory, is inert on a fresh clone, and never
  runs for a web editor or an API write. A lock on the branch, where the remote
  offers one, reaches every client but says nothing about who approved, and a
  holder of a bypass passes it. See
  [what is enforced where](../issue-workflow.md#what-is-enforced-where).
- **This record does not say how to undo a destruction that should not have
  happened.** Restoring it can itself destroy history under the definition
  above — undoing a rewrite makes the rewritten commits unreachable — and where
  it does, these conditions apply, including the second operator, which a solo
  operator does not have. Where it does not, most plainly when the tip being
  restored is a descendant of the current one, nothing becomes unreachable and
  this record does not reach the act. What governs it instead is left open, to
  be decided on its own terms.
- Condition 5's cost falls after the operator already has what they wanted,
  which makes it the one most likely to be skipped.
