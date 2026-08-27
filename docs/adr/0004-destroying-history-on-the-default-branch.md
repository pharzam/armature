# 0004. Destroying history on the default branch

Date: YYYY-MM-DD

## Status

Accepted

## In plain terms

> Removing or rewriting commits on the default branch is the one change no pull
> request can express, and the one nobody can undo. It stays allowed, under five
> conditions, and a second person must agree first. It also does not do what
> people expect: on most hosted forges anything that ever appeared in a pull
> request stays fetchable afterwards. So if a credential leaked, revoke it —
> removing the commit is not what ends the exposure.

## Context

Every change to the default branch lands through a pull request, which proposes
commits **onto** a branch. A reset, a rewrite, or a deletion takes them **away**.
No rule written for the first shape reaches the second, so the most irreversible
operation in this kit is the one with no procedure.

Three forces separate it from ordinary work:

- **No later review can undo it.** Every other mistake here is recoverable by a
  further commit; this one destroys what a fix would apply to.
- **One party cannot be both the actor and the check.** Whoever wants the history
  gone is worst placed to judge whether it should go.
- **The forge keeps copies you do not control.** Most hosted forges retain a
  per-pull-request reference the operator cannot delete; a bare remote retains
  none. Confirm what yours keeps before assuming a commit is gone.

## Decision

We will permit destruction of history on the default branch only under the five
conditions below.

**Destruction** means making commits that are — or once were — reachable from the
default branch unreachable from it: a reset, a force-pushed rewrite, deleting the
branch, or a tag left pointing into discarded commits. Deleting any *other* branch
is ordinary housekeeping and is not covered.

**Repair is not destruction.** Restoring the default branch to a tip it previously
held, losing no commit except those the incident being undone created, is a repair:
record it on an issue, and it needs no second operator. Without this carve-out the
rule would forbid fixing an accidental force-push.

1. **An open issue states the goal** in the operator's own words, and why no
   revert, fix-forward, or new branch reaches it.
2. **A second operator approves in writing, and that operator is a person.** This
   narrows [`issue-workflow.md`](../issue-workflow.md) and
   [`glossary.md`](../glossary.md), which define an operator as a human *or* an
   agent. An agent instantiated by the acting operator is not independent: it can
   be re-prompted until it approves, it holds no stake in what is lost, and it
   cannot be held to the decision afterwards. With no second person, the path is
   closed.
3. **Everything about to be lost is preserved first** — the default branch's tip
   *and* every unmerged branch tip that is not an ancestor of it
   (`git merge-base --is-ancestor`) — pushed to the remote as
   `backup/pre-<reason>-<short-sha>`, one per tip. **Exception:** when the content
   is itself the reason for the destruction, keep the backup off the remote and
   record where it is. That record is one party's word, unverifiable by anyone
   else, unavoidably.
4. **The remote lock is lifted deliberately and restored afterwards**, checked
   field by field against a record of its full configuration made *before*
   lifting. A restore from memory that gets one setting wrong passes an
   unrecorded check.
5. **Afterwards, before other work resumes:** every issue whose deliverable is now
   gone returns to open with the evidence, and the issue from condition 1 records
   what was destroyed, the backup, and the approval.

Conditions 1–4 hold before the act. Condition 5 cannot: evidence that the branch
no longer holds something does not exist until it no longer holds it.

We rejected forbidding it outright: it is sometimes correct, and forbidding what a
careful operator will do anyway teaches them the rules are ornamental. We rejected
[R4](../issue-workflow.md#r4--no-workarounds)'s workaround shape, which supplies
approval authority but nothing about preserving history. We rejected requiring a
pull request, which cannot express the operation.

## Consequences

- **On a one-person project, condition 2 closes the path.** That is the intended
  cost. For a leaked credential, **revoke and rotate** — that ends the exposure,
  which on a forge retaining pull-request references the deletion would not. For
  an oversized object or an erasure request, the forge's operator must act
  regardless, so the request goes to them.
- **Nothing checks the five conditions.** The
  [`pre-push` hook](../../.githooks/pre-push) refuses the push but is advisory and
  bypassable; branch protection blocks the act wherever an adopter configures it
  and says nothing about who approved; neither reaches a web editor or an API
  write. See [what is enforced where](../issue-workflow.md#what-is-enforced-where).
- Condition 5 is the one skipped while this rule did not exist, and the only one
  whose cost falls after the operator has what they wanted. Expect that again.
- Nothing here covers the backups condition 3 creates once condition 1's issue
  closes; say in that issue when they may go.
