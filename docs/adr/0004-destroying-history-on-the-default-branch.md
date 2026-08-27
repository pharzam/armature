# 0004. Destroying history on the default branch

Date: YYYY-MM-DD

## Status

Accepted

## In plain terms

> Removing or rewriting commits on the default branch is the one change no pull
> request can express, and the one nobody can undo. It stays allowed, under five
> conditions, and a second person must agree first.

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
  per-pull-request reference the operator cannot delete, so a commit that ever
  appeared in a pull request usually survives the branch it came from. A bare
  remote retains none.

## Decision

We will permit destruction of history on the default branch only under the five
conditions below. Conditions 1–4 hold **before** the act. Condition 5 cannot:
the evidence it requires does not exist until the act has happened.

**Destruction** means making commits that are — or once were — reachable from the
default branch unreachable from it: a reset, a force-pushed rewrite, deleting the
branch, or deleting or moving a tag that points into commits already discarded from
it. Deleting a branch whose commits are ancestors of the default branch is ordinary
housekeeping and is not covered; deleting an unmerged branch is covered by nothing
here, which is a gap this record does not close.

**Repair is not destruction.** Undoing a *prior destruction of history on the
default branch* — restoring a tip the branch held before that act, losing no commit
which the act did not create and the repair does not re-apply — is a repair. It
needs no second operator; its issue names the act being undone, by issue number or
backup reference, because the reflog that would otherwise prove it expires and the
actor can erase it. No other work qualifies, however it is labelled.

1. **An open issue states the goal** in the operator's own words, and why no
   revert, fix-forward, or new branch reaches it.
2. **A second operator approves in writing, and that operator is a person.** This
   narrows [`issue-workflow.md`](../issue-workflow.md), which binds every operator,
   human or agent, alike. An agent instantiated by the acting operator is not
   independent: it can be re-prompted until it approves, it holds no stake in what
   is lost, and it cannot be held to the decision afterwards. With no second
   person, the path is closed.
3. **Everything about to be lost is preserved first** — the default branch's tip,
   every unmerged branch tip that is not an ancestor of it, and every tag pointing
   into what will be discarded — pushed to the remote as
   `backup/pre-<reason>-<short-sha>`, one per tip. **Exception:** when the content
   is itself the reason for the destruction, keep the backup off the remote and
   record where it is. That record is one party's word, unverifiable by anyone else.
4. **Any lock on the branch is lifted deliberately and restored afterwards**,
   checked field by field against a record of its full configuration made *before*
   lifting; a restore from memory that gets one setting wrong passes an unrecorded
   check. Where the remote offers no configurable lock, record that instead.
5. **Afterwards, before other work resumes:** (a) every issue whose deliverable is
   now gone returns to open with the evidence; (b) the issue from condition 1
   records what was destroyed and where the backup is; and (c) it records who
   approved.

We rejected forbidding destruction outright — it is sometimes correct — though
condition 2 closes the path on a solo project regardless. We rejected
[R4](../issue-workflow.md#r4--no-workarounds)'s workaround shape, which supplies
approval authority but nothing about preserving history. We rejected requiring a
pull request, which cannot express the operation.

## Consequences

- **On a one-person project, condition 2 closes the path.** That is the intended
  cost. For a leaked credential, **revoke and rotate** — that ends the exposure,
  which deleting the commit may not. For an oversized object or an erasure request,
  whoever operates the remote must act; where that is the same solo operator, the
  path stays closed and the obligation does not, so the answer is to get a second
  person, not to proceed alone.
- **Nothing checks the five conditions.** The
  [`pre-push` hook](../../.githooks/pre-push) refuses the push but is advisory, and
  a web editor or an API write never runs it. A lock on the branch, where the
  remote offers one, blocks the act from every client and says nothing about who
  approved. See [what is enforced where](../issue-workflow.md#what-is-enforced-where).
- Condition 5 is the only one whose cost falls after the operator already has what
  they wanted, which makes it the one most likely to be skipped.
- Nothing here covers the backups condition 3 creates once condition 1's issue
  closes; say in that issue when they may go.
