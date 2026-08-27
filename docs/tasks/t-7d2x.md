# T-7d2x — Destroying history on the default branch

Detail for the [completed](completed.md) entry, per that file's one-line rule. Holds the
design notes and the incident record that
[ADR-0004](../adr/0004-destroying-history-on-the-default-branch.md) deliberately does not
carry.

## Why this file exists rather than a longer ADR

This repository is a template. Adopters copy every file verbatim, cannot edit an accepted
ADR (they are immutable), and cannot delete one without renumbering every later record —
`adr-lint.sh` requires contiguous numbering from `0001`. So an incident record placed in
an ADR would be inherited permanently by every adopter, in a repository where none of it
is true.

This file is in-repo, is not immutable, and an adopter deletes it with one command. The
convention is the kit's own: `backlog.md` says design notes, rejected alternatives, open
questions, and reproduction detail live in `tasks/<id>.md`.

## Open question, recorded rather than decided

Condition 2 requires a second **person**. On a one-person project the path is closed, so
this repository cannot destroy history on its own default branch. If that proves wrong in
practice, the correction is a **superseding** ADR, not an edit: the decision would have
changed, and `adr/README.md` reserves amendment for a decision that still holds.

## The 2026-08-27 reset, scored against the five conditions

Written by the operator who performed the reset it scores.

| Time (UTC) | Event |
|---|---|
| 10:08:11 | `main` reset locally (`git reflog show main`) |
| 10:11:26 | a branch ruleset named `main` is created, already disabled — see below |
| 10:18:03 | force-pushed to the remote (`PushEvent refs/heads/main`) |
| 10:41:02 | the record written on #16, opening **"Status: main was reset."** — past tense |
| 10:46:25–10:46:51 | **twelve further issues closed as completed** (#19, #20, #22, #33–#41) over deliverables `main` no longer held |
| 11:46–11:47 | the eighteen affected issues reopened |

| Condition | Score |
|---|---|
| 1 — *"An open issue states the goal in the operator's own words, and why no revert, fix-forward, or new branch reaches it."* | **Not met.** Nothing was written anywhere before the act. The goal and the reason are real and were recorded 23 minutes after the push; the condition is about *when*. |
| 2 — *"A second operator approves in writing, and that operator is a person."* | **Not met.** Self-approved. |
| 3 — *"Everything about to be lost is preserved first."* | **Partly.** `backup/pre-r12-reset-999765f` held the default branch's tip, correctly. Two unmerged tips that were not ancestors of it were not: `fix/t-3k8w-runner-asserts-reason` happened to be on the remote already, and `chore/t-5r2q-review-debt` existed on one machine only and was pushed to `backup/pre-r12-reset-t-5r2q` about 100 minutes later. It survived by luck. No tags existed. |
| 4 — *"Any lock on the branch is lifted deliberately and restored afterwards, checked field by field against a record of its full configuration made before lifting."* | **Not met.** No record of the configuration was made, and no field-by-field check ran. What the lock was doing is still partly undetermined — see below. |
| 5 — *"(a) every issue whose deliverable is now gone returns to open; (b) the issue from condition 1 records what was destroyed and where the backup is; (c) it records who approved."* | **(a) Not met.** The test is *before other work resumes*, and work resumed 28 minutes after the push in the wrong direction: twelve further issues were closed as completed over deliverables that had just been destroyed. The reopens came 88 minutes after that. **(b) Not met** — condition 1's issue never existed, so it has no subject. The 10:41 comment does record what was destroyed and names the backup branch, which is the substance. **(c) Not met**, there being no approver. |

**Nought of five fully met, one partly.**

#### What the lock was actually doing

Condition 4 fails on its own terms regardless of the answer, because nothing was recorded and nothing was checked. But the question of what the lock was doing is worth stating precisely, because a first draft of this file called it "unknown and unknowable" and that was wrong — and a second draft then arranged the evidence to imply more than it shows.

What is verifiable (`gh api repos/pharzam/armature/rulesets/21643143`): a branch ruleset scoped to `refs/heads/main`, carrying three rules — `deletion`, `non_fast_forward`, `pull_request` — with `enforcement: disabled`, `bypass_actors: []`, `created_at` 10:11:26.809Z and `updated_at` 10:11:26.834Z, unchanged since.

**That evidence does not bear on condition 4.** A ruleset created *already disabled*, in a single write 25 ms wide, removes no obstacle: there was nothing there before 10:11:26 to lift, and no self-exemption was carved. Of its three rules, `non_fast_forward` and `pull_request` would each have blocked the 10:18:03Z push had it been enabled; `deletion` would not, since nothing was deleted. The plain reading is someone adding protection shortly after the reset and leaving the enforcement field at its default — not a lock stood up in order to be left off.

What remains genuinely undetermined is **classic** branch protection, which is live today (`allow_force_pushes: false`, `enforce_admins: true`) and was specified by [#6](https://github.com/pharzam/armature/issues/6), closed 2026-08-24 — three days before the reset. Its API exposes no history, so whether it was in force at 10:18:03Z cannot be shown from the repository. The account security log may hold it; it has not been consulted.

### What that score does and does not say

It does not say the reset was wrong. It answered a real problem — 45 commits, 67 files and roughly 1,659 insertions delivered in under three hours in one session, which the operator could not absorb — and no revert solves that. The backup went to the remote before anything was destroyed, and the reason was written down.

It says the care came from the operator and not from a rule, and that unguided care covered part of one of the five things that matter and missed the rest.

Under condition 2 this reset would not have been permitted: there is no second person here, so the path is closed. The rule the incident produced forbids the incident.
