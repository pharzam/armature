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
| 10:11:26 | a branch ruleset named `main` created — `deletion`, `non_fast_forward`, `pull_request` — with enforcement **disabled** |
| 10:18:03 | force-pushed to the remote (`PushEvent refs/heads/main`) |
| 10:41:02 | the record written on #16, opening **"Status: main was reset."** — past tense |
| 11:46–11:47 | the eighteen affected issues reopened |

| Condition | Score |
|---|---|
| 1 — *"An open issue states the goal in the operator's own words, and why no revert, fix-forward, or new branch reaches it."* | **Not met.** Nothing was written anywhere before the act. The goal and the reason are real and were recorded 23 minutes after the push; the condition is about *when*. |
| 2 — *"A second operator approves in writing, and that operator is a person."* | **Not met.** Self-approved. |
| 3 — *"Everything about to be lost is preserved first."* | **Partly.** `backup/pre-r12-reset-999765f` held the default branch's tip, correctly. Two unmerged tips that were not ancestors of it were not: `fix/t-3k8w-runner-asserts-reason` happened to be on the remote already, and `chore/t-5r2q-review-debt` existed on one machine only and was pushed to `backup/pre-r12-reset-t-5r2q` about 100 minutes later. It survived by luck. Condition 3's sweep exists because of it. No tags existed. |
| 4 — *"Any lock on the branch is lifted deliberately and restored afterwards, checked field by field against a record of its full configuration made before lifting."* | **Not met**, on its own terms: no record of the configuration was made, and no field-by-field check ran. What the lock was doing is *partly* knowable and was not looked at until review: `gh api repos/pharzam/armature/rulesets` shows a ruleset scoped to `refs/heads/main`, carrying exactly the two rules that would have blocked this act, **created at 10:11:26Z — after the local reset and before the push — with enforcement `disabled`**, and unchanged since (`updated_at` is 25 ms after `created_at`). Classic branch protection is live today (`allow_force_pushes: false`, `enforce_admins: true`) and its API exposes no history, so whether it was in force at 10:18:03Z is still undetermined; the account security log may answer it and was not consulted. |
| 5 — *"(a) every issue whose deliverable is now gone returns to open; (b) the issue records what was destroyed and where the backup is; (c) it records who approved."* | **Not met at the time.** (a) came about 90 minutes later. (b) was half done at 10:41 — the commits and counts are there and all verify; no issue is named. (c) never, there being no approver. |

**Nought of five fully met, one partly.**

### What that score does and does not say

It does not say the reset was wrong. It answered a real problem — 45 commits, 67 files and
roughly 1,659 insertions delivered in under three hours in one session, which the operator
could not absorb — and no revert solves that. The backup went to the remote before anything
was destroyed, and the reason was written down.

It says the care came from the operator and not from a rule, and that unguided care covered
part of one of the five things that matter and missed the rest.

Under condition 2 this reset would not have been permitted: there is no second person here,
so the path is closed. The rule the incident produced forbids the incident.

Note also what condition 4's row shows about the value of the condition itself. The one
fact nobody recorded is the one that took a reviewer's API call to surface, and it is still
only half-answered. That is the argument for the condition, made by its own absence.
