# 0004. Reset the default branch only under a recorded procedure

Date: 2026-08-27

## Status

Accepted

## Context

Every change to the default branch lands through a pull request. The
[`pre-push` hook](../../.githooks/pre-push) refuses a direct push to `main`, and
[R1](../issue-workflow.md#r1--issue-first) refuses a pull request that links no
issue. Between them they cover every way a commit is *added* to `main`.

They cover nothing about the one operation that *removes* commits from it. A pull
request proposes commits onto a branch; a reset rebuilds the branch at an earlier
commit and discards what came after. The mechanism this kit uses for every other
change cannot express a reset, so no rule here reached it.

On 2026-08-27 `main` was reset to `2cd70ee`, discarding 45 commits — 67 files and
about 1,659 insertions — that had reached it through seven merged pull requests.
The reason was not a defect in that work. It was delivered in under three hours in
one session, and the operator could not absorb it. This kit gates code quality at
eight points and operator understanding at none, so nothing slowed the pace, and
the reset was the operator's own remedy: relearn the tranche by re-landing it one
slice at a time.

The reset was carried out carefully. A backup branch preserved the discarded tip
before anything was destroyed, and the reason was recorded on the parent issue.
But no document required either step. The care came from the operator, not from a
rule — and the same unguided instinct left four bookkeeping problems behind:
eighteen issues still closed as completed over deliverables `main` no longer held,
a pull request stranded on a base that had ceased to exist, and the branch and
worktree leftovers that an earlier issue had already cleaned once.

The evidence is the independent review of the whole round, recorded on issue #16;
its finding R-5 is the direct source of this record.

## Decision

We will permit a reset of the default branch, and only under the procedure below.
This is the one sanctioned exception to "every change to `main` lands through a
pull request".

**All four preconditions must hold, and the record is written *before* the reset,
not after.** A record written afterwards describes what happened. A record written
first is a decision. Only the second is a check.

1. **An open issue states the goal** — in the operator's own words, not an
   agent's — and states why no smaller action reaches it. A revert, a fix-forward
   pull request, and a fresh branch are each cheaper and each reversible; a reset
   is chosen only when the goal is something none of them serves.
2. **A backup branch is pushed to the remote** before anything is discarded,
   holding the exact tip about to be discarded, named
   `backup/pre-<reason>-<short-sha>`. A backup that exists only on the operator's
   machine is not a backup. The branch is reference only, never a merge source:
   discarded work returns to `main` by being re-landed, not by being merged back.
3. **Every issue whose deliverable the reset removes returns to open**, with the
   evidence that `main` no longer holds it. The tracker never claims more than
   `main` holds. An issue closed as completed over a discarded deliverable is the
   same defect as a linter that reports OK having checked less than it claims —
   the review found that shape at every other layer of this project, and the
   tracker is not exempt from it.
4. **The reset is recorded on the parent issue**: the tip reset to, the backup
   branch, the goal, and what was discarded — in commits and in issues.

We reject three alternatives.

*Forbid a reset outright.* The one reset that has happened was the right call. It
answered a learning problem that no revert answers, and the alternative — carry 45
unabsorbed commits forward, with every later branch inheriting them — was worse. A
rule that forbids what a careful operator will correctly do anyway teaches that
operator the rules are ornamental.

*Treat a reset as a workaround under [R4](../issue-workflow.md#r4--no-workarounds)
and stop there.* R4 supplies approval authority and a removal issue. It supplies
nothing about preserving history or reconciling the tracker, which are the two
things that actually went wrong. It is also the wrong shape: a reset routes around
no defect and leaves no debt to remove.

*Require the reset to land through a pull request.* A pull request cannot express
a reset. That is why this record is necessary rather than derivable from the rules
already written.

### What the 2026-08-27 reset met, and what it did not

This record is written by the same operator who performed that reset, so it states
the score plainly rather than reading as permission granted in hindsight.

| Precondition | Met? |
| ------------ | ---- |
| 1 — an open issue stating the goal, and why nothing smaller reaches it | **Partly.** The goal and the reason were recorded on #16. The cheaper alternatives were never weighed in writing. |
| 2 — a backup branch on the remote | **Yes**, `backup/pre-r12-reset-999765f`. Two branches were missed and are now preserved as `backup/pre-r12-reset-t-5r2q` and `fix/t-3k8w-runner-asserts-reason`. |
| 3 — every affected issue reopened | **No.** Eighteen issues stayed closed as completed for about a day. Corrected after the fact. |
| 4 — recorded on the parent issue | **Yes.** |

Two of four met, one partly, one not at all. This procedure exists because
"carefully done" and "correctly done" turned out to be different things.

## Consequences

- The next reset has a procedure, and one that can be checked afterwards from the
  remote and the tracker: a `backup/` reference either holds the discarded tip or
  it does not, and the affected issues are either open or they are not.
- **Nothing enforces this.** There is no hook, no continuous-integration check and
  no branch protection behind it — a reset happens on an operator's machine and
  reaches the remote as a force push. The
  ["What is enforced where" table](../issue-workflow.md#what-is-enforced-where)
  carries a row that says so. Precondition 2 is the one a machine could check, and
  that check is not written; it is a candidate discipline test, not a claim this
  record is entitled to make.
- Preconditions 1 and 3 are the expensive ones, and 3 is the one that was skipped.
  Expect it to be skipped again: it is the only precondition whose cost falls
  *after* the reset, once the pressure that motivated the reset has gone.
- The kit gains a position it did not hold before: history on `main` is not
  sacred, but discarding it is a decision with a shape, not a reflex.
- This record does **not** add the gate whose absence caused the reset. The reset
  was a remedy for unabsorbed velocity, and no rule here asks an operator to
  absorb anything before the next slice starts. That gate is a separate change,
  deliberately out of scope: this record covers the escape hatch, not the pressure
  that sends an operator through it.
