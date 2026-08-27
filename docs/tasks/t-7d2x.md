# T-7d2x — Destroying history on the default branch

Detail for the [backlog](backlog.md) entry, per that file's one-line rule. Holds the
design notes, the rejected alternatives, and the incident record that
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

Condition 2 requires a second **person**. On a one-person project the path is closed.
That is deliberate, and it is the single most consequential line in the record — it means
this repository cannot destroy history on its own default branch. If that proves wrong in
practice, the correction is a superseding ADR, not an edit: ADR-0004's decision would have
changed, and `adr/README.md` reserves amendment for a decision that still holds.

## The 2026-08-27 reset, scored against the five conditions

The record this task produced was written by the operator who performed the reset it
governs. So the score is stated plainly here rather than implied in the record, and it is
harsher than the summary that first accompanied it. Times are UTC.

| | Event |
|---|---|
| 10:08:11 | `main` reset locally (`git reflog show main`) |
| 10:18:03 | force-pushed to the remote (`PushEvent refs/heads/main`) |
| 10:41:02 | the record written on #16, opening **"Status: main was reset."** — past tense |
| 11:46–11:47 | the eighteen affected issues reopened, during Phase 0 |

| Condition | Score |
|---|---|
| 1 — an open issue states the goal, and why nothing smaller reaches it | **Not met.** Nothing was written anywhere before the act. The goal and the reason are real and were recorded 23 minutes after the push; the condition is about *when*. |
| 2 — a second operator, and that operator is a person | **Not met.** Self-approved. |
| 3 — everything about to be lost preserved first | **Partly.** `backup/pre-r12-reset-999765f` held the default branch's tip, correctly. Two unmerged tips that were not ancestors of it were not preserved: `fix/t-3k8w-runner-asserts-reason` happened to be on the remote already, and `chore/t-5r2q-review-debt` existed on one machine only and was pushed to `backup/pre-r12-reset-t-5r2q` about 100 minutes later. It survived by luck. Condition 3's `merge-base --is-ancestor` sweep exists because of it. |
| 4 — the remote lock lifted deliberately and restored, against a record made first | **Not met.** No record of the configuration was made, and no field-by-field check ran. What happened to the lock itself is **unknown and unknowable**: [#6](https://github.com/pharzam/armature/issues/6) closed on 2026-08-24 specifying force-push protection enforced for administrators, and that protection is live today, so either it was lifted and restored around the push or it was not in force despite #6 being closed. A personal repository keeps no audit log, so neither can be shown. That absence is the argument for the condition. |
| 5 — afterwards, the issues reopened and the act recorded | **Not met at the time; completed later.** Eighteen issues stayed closed as completed over deliverables `main` no longer held for about 90 minutes. The 10:41 record names commits and counts, all of which verify, but names no issue — and the issue half is what condition 5 is for. |

**Nought of five fully met, one partly.**

### What that score does and does not say

It does **not** say the reset was wrong. It answered a real problem — 45 commits, 67 files
and roughly 1,659 insertions delivered in under three hours in one session, which the
operator could not absorb — and no revert solves that. The care taken was real: the backup
went to the remote before anything was destroyed, and the reason was written down.

It says the care came from the operator and not from a rule, and that unguided care
covered two of the five things that matter and missed three. That is the whole reason this
record exists.

One consequence should be stated rather than left for a reader to notice: **under condition
2, this reset would not have been permitted.** This is a one-person project, so there is no
second operator, so the path is closed. The rule the incident produced forbids the incident.
That is intended, and it is the honest reading — not a rule bent to make its own author pass.
