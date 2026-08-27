# 0004. Destroying history on the default branch

Date: YYYY-MM-DD

## Status

Accepted

## In plain terms

> Removing or rewriting commits on the published default branch is the one
> change no pull request can express, and no later review can undo. It stays
> allowed, under five conditions, and a second person must agree first —
> except when undoing a prior destruction that took only away and still
> stands. It also does not do what people expect: on most hosted git services
> anything that ever appeared in a pull request stays fetchable afterwards, so
> if a credential leaked, revoke it — removing the commit is not what ends the
> exposure.

## Context

Every change to the default branch lands through a pull request, which
proposes commits **onto** a branch. A reset, a rewrite, or a deletion takes
them **away**. No rule written for the first shape reaches the second, so the
most irreversible operation in this kit is the one with no procedure.

Three forces separate it from ordinary work:

- **No later review can undo it.** Every other mistake here is recoverable by
  a further commit; this one destroys what a fix would apply to.
- **One party cannot be both the actor and the check.** Whoever wants the
  history gone is worst placed to judge whether it should go.
- **The forge keeps copies you do not control.** Most hosted forges retain a
  per-pull-request reference the operator cannot delete, so a commit that ever
  appeared in a pull request usually survives the branch it came from. A bare
  remote retains none.

## Decision

We will permit destruction of history on the default branch only under the
five conditions below.

**Destruction** means making commits unreachable from the branch the project
treats as canonical, where they were reachable from whichever branch held that
role at any point since. A reset, a force-pushed rewrite, and deleting the
branch are its usual forms; the list is not exhaustive, and an act that
reaches the same outcome in steps is covered by the outcome, not excused by
the steps. Moving the canonical role to another branch and then deleting **or
rewriting** the old one is the worked example. Rewriting local history you
have never pushed is not covered. Deleting or moving a tag that points into
commits already discarded counts too — it is the one act that removes the last
handle on history already gone, rather than making history unreachable itself.
Deleting or rewriting a branch that never held the canonical role is ordinary
housekeeping, whether or not its commits are ancestors of it, and this record
does not govern it.

1. **An open issue states the goal** in the operator's own words, and why no
   revert, fix-forward, or new branch reaches it. It records the remote's
   references as they stand at that moment — one `git ls-remote` pasted in —
   because condition 3 compares against them and nothing else captures them.
   That paste is one party's word; the operator approving under condition 2
   should run it themselves.
2. **A second operator approves in writing, and that operator is a person.**
   This narrows [`issue-workflow.md`](../issue-workflow.md), which binds every
   operator, human or agent, alike. An agent instantiated by the acting
   operator is not independent: it can be re-prompted until it approves, it
   holds no stake in what is lost, and it cannot be held to the decision
   afterwards. With no second person, the path is closed.
3. **Everything about to be lost is preserved first** — the default branch's
   tip, every unmerged branch tip that is not an ancestor of it, and every tag
   pointing into what will be discarded, **as those references stood when
   condition 1's issue was opened and as they stand at the act — both sets,
   together**. Taking both stops the sweep being emptied by deleting the
   branches first. It reaches back only to that issue: references deleted
   before it was opened are outside what this can see, so open it before
   tidying. All of it goes to the remote: branch tips as
   `backup/pre-<reason>-<short-sha>`, one per tip, and each tag **as a tag**
   under `backup/pre-<reason>/<tag>-<short-sha>`, because a branch reference
   cannot carry an annotated tag's name, message, or signature — and because a
   tag that moved between the two moments has two targets to preserve, not
   one. **Exception:** when the content is itself the reason for the
   destruction, keep the backup off the remote and record where it is. That
   record is one party's word, unverifiable by anyone else.
4. **Any lock on the branch is lifted deliberately and restored afterwards**,
   checked field by field against a record of its full configuration made
   *before* lifting; a restore from memory that gets one setting wrong passes
   an unrecorded check. Where the remote offers no such lock — a bare remote
   usually does not — record that there was nothing to lift. Where the
   operator cannot read the remote's configuration in full, record which part
   they could not read, and not that there was nothing: being unable to see a
   lock is not seeing that there is none. Where a lock exists and the operator
   holds a bypass instead, record that the bypass was used and that the lock
   was never lifted. Where the act needed neither, because it never touched
   the lock, record that the lock was untouched **and what made the act not
   need it** — that is the cheapest case to claim and the one leaving least
   behind, so it is the one that has to show its reasoning. Where the branch
   carries more than one mechanism — say a classic protection and a ruleset —
   answer for each separately; they can be in different states at once, and
   record how the set of mechanisms was established and from what, because a
   record answering for one while silently missing another reads exactly like
   a complete one. No single command enumerates them, so name the queries you
   ran; where there is a second operator, they run them too. All of this goes
   on condition 1's issue.
5. **Afterwards, before other work resumes:** (a) every issue whose
   deliverable is now gone returns to open with the evidence; (b) the issue
   from condition 1 records what was destroyed and where the backup is; and
   (c) it records who approved.

Conditions 1–3 hold **before** the act. Condition 4 straddles it where a lock
is lifted; in its other cases it records after the act what the lock's state
was and why nothing was lifted. Condition 5 can only follow it: for (a) and
(b) the evidence does not exist until the act has happened, and (c) is grouped
with them so the post-act record is complete in one place.

**A repair waives condition 2, and only while the branch still stands exactly
where that act left it and that act took only away.** Undoing a *prior
destruction of history on the default branch* — restoring the tip the branch
held immediately before that act — is a repair, and needs no second operator.
Once anything has landed on top, or the destroying act itself introduced
content, undoing it discards work someone else may be relying on, and that is
what condition 2 exists to gate: it is a destruction like any other and needs
a second operator. Conditions 1, 3, 4 and 5 still apply; 5(c) is satisfied by
recording that the act was a repair; and the issue names the act being undone
— by issue number, backup reference, or the discarded tip's own identifier
from a source the actor cannot rewrite, such as the forge's record of the
merge that produced it. The first two are the weaker of the three, being an
issue the actor wrote and a reference the actor can delete — on the one path
with no second party to check them, that matters — so prefer the third where
it exists.

**Undoing a repair is not itself a repair.** Only the *first* undo of a given
destruction is a repair; undoing that is a destruction like any other, and
needs a second operator.

**A repair that is a fast-forward is an ordinary change.** Where the
destruction was a rewind and nothing has landed since, the tip being restored
is a descendant of the current tip, so the repair lands like any other work —
through a pull request where the remote has them, as an ordinary push where it
does not — and this record does not except it from that; it is still a repair,
and conditions 1, 3, 4 and 5 still apply to it. An undo that cannot be
expressed as a pull request sits outside the pull-request rule: after a
rewrite, which leaves no descendant relationship at all, or after a branch
deletion, which no pull request is shaped to restore. Where work has landed on
top the undo is a destruction, not a repair, and the bound above governs it —
the word *repair* is reserved for the waived case throughout.

We rejected forbidding destruction outright — it is sometimes correct — though
condition 2 closes the path on a solo project regardless. We rejected
[R4](../issue-workflow.md#r4--no-workarounds)'s workaround shape, which
supplies approval authority but nothing about preserving history.

## Consequences

- **On a one-person project, condition 2 closes the path.** That is the
  intended cost. Whether the repair carve-out reopens anything for them
  depends on what evidence survives. A repair's issue must name the act being
  undone, and a solo operator who pushed a backup before an ad-hoc destruction
  already has a citation, so the repair path is open to them. Where nothing
  was preserved, a hosted forge may still hold the record of the merge that
  produced it — though only where that merge produced the tip itself, since a
  commit pushed directly after it leaves the record naming an ancestor; and a
  different artifact from the per-pull-request reference above, which holds
  the contributor's branch and not the default branch's tip — while a bare
  remote holds nothing, and then the repair path is shut too. For a leaked
  credential, **revoke and rotate** — that ends the exposure, which deleting
  the commit may not. For an oversized object or an erasure request, whoever
  operates the remote must act; where that is the same solo operator, the path
  stays closed and the obligation remains, so the answer is to get a second
  person, not to proceed alone.
- **Nothing checks the five conditions.** The [`pre-push`
  hook](../../.githooks/pre-push) refuses a push to the default branch but is
  advisory, is inert on a fresh clone until `core.hooksPath` is set, never
  runs for a web editor or an API write, does not look at tags at all, and
  names the default branch literally, so it does nothing on a project whose
  branch is named otherwise until it is edited. Even where it is installed,
  edited and the push comes from a git client, the tag act passes it in
  silence. A lock on the branch, where the remote offers one, reaches every
  client — but it covers the reset, the rewrite and the branch deletion only;
  the tag act needs a separate tag rule, and a holder of a bypass passes it
  either way. It says nothing about who approved. So the tag act is the one
  act neither mechanism reaches. See [what is enforced
  where](../issue-workflow.md#what-is-enforced-where).
- Condition 4's restore and condition 5 both fall after the operator already
  has what they wanted, which makes them the two most likely to be skipped.
  The lift without the restore is the quieter failure: it leaves the branch
  unprotected and nothing announces it.
- Deleting an **unmerged** branch is ordinary housekeeping and is not covered
  here — unless it was the default branch when its commits were reachable from
  it — except that condition 3's sweep reaches back to condition 1's issue, so
  deleting them in between does not shrink what must be preserved.
- Nothing here covers the backups condition 3 creates once condition 1's issue
  closes; say in that issue when they may go.
