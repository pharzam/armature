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

This file is in-repository, is not immutable, and an adopter deletes it with one command. The
convention is the kit's own: `backlog.md` says design notes, rejected alternatives, open
questions, and reproduction detail live in `tasks/<id>.md`.

## Open question, recorded rather than decided

Condition 2 requires a second **person**, so on a one-person project the *destruction*
path is closed. The repair path is not: nothing has landed on `main` since the 2026-08-27
reset, and both a backup reference and the forge's record of the merge that produced the
discarded tip survive — so a repair of that reset is available to a single operator today,
and would stop being available the moment anything lands. If that proves wrong in
practice, the correction is a **superseding** ADR, not an edit: the decision would have
changed, and `adr/README.md` reserves amendment for a decision that still holds.

## The 2026-08-27 reset, scored against the five conditions

Written by the operator who performed the reset it scores. Issue timestamps are from each issue's own timeline; the repository events feed reports some of them one or two seconds later.

| Time (UTC) | Event |
|---|---|
| 10:08:11 | `main` reset locally (`git reflog show main`) |
| 10:11:26 | a branch ruleset named `main` is created, already disabled — see below |
| 10:14:25 | `backup/pre-r12-reset-999765f` pushed — the default branch's tip preserved, before anything was destroyed (`git reflog show refs/remotes/origin/backup/pre-r12-reset-999765f`; the events feed carries no event for either backup push) |
| 10:18:03 | force-pushed to the remote (`PushEvent refs/heads/main`) |
| 10:41:02 | the record written on #16, opening **"Status: main was reset."** — past tense |
| 10:46:24–10:46:51 | **twelve further issues closed as completed** (#19, #20, #22, #33–#41) over deliverables `main` no longer held |
| 11:46:56–11:47:38 | the eighteen affected issues reopened |

| Condition | Score |
|---|---|
| 1 — *"An open issue states the goal in the operator's own words, and why no revert, fix-forward, or new branch reaches it. It records the remote's references as they stand at that moment…"* | **Not met.** Nothing was written anywhere before the act. The goal and the reason are real and were recorded 23 minutes after the push; the condition is about *when*. |
| 2 — *"A second operator approves in writing, and that operator is a person."* | **Not met.** Self-approved. |
| 3 — *"Everything about to be lost is preserved first."* | **Partly.** `backup/pre-r12-reset-999765f` held the default branch's tip, correctly. Two unmerged tips that were not ancestors of it were not: `fix/t-3k8w-runner-asserts-reason` happened to be on the remote already, and `chore/t-5r2q-review-debt` existed on one machine only and was pushed to `backup/pre-r12-reset-t-5r2q` — a name that carries a task ID where condition 3's `backup/pre-<reason>-<short-sha>` wants the tip's short SHA, though the condition postdates the act — at 11:46:30Z (local `git reflog show refs/remotes/origin/backup/pre-r12-reset-t-5r2q`; the repository events feed carries no event for it), 88 minutes after the push. It survived by luck. No tags existed. Condition 3 now sweeps the references as they stood when condition 1's issue opened *and* as they stand at the act, together; here condition 1's issue never existed, so only the act-time set applies and the score is unchanged. |
| 4 — *"Any lock on the branch is lifted deliberately and restored afterwards, checked field by field against a record of its full configuration made before lifting."* | **Not met.** A documented lock existed and, on the evidence below, was lifted around the act and restored; nobody recorded either, and no field-by-field check ran — which is the failure regardless of what the lock was doing. See below. |
| 5 — *"(a) every issue whose deliverable is now gone returns to open with the evidence; (b) the issue from condition 1 records what was destroyed and where the backup is; and (c) it records who approved."* | **(a) Not met.** The test is *before other work resumes*, and work resumed 28 minutes after the push in the wrong direction: twelve further issues were closed as completed over deliverables that had just been destroyed. The reopens began at 11:46:56Z, 60 minutes after those closes. **(b) Not met** — condition 1's issue never existed, so it has no subject. The 10:41 comment does record what was destroyed and names the backup branch, which is the substance. **(c) Not met**, there being no approver. |

**Nought of five fully met, one partly.**

#### What the lock was actually doing

**The lock was documented three days earlier.** [#6](https://github.com/pharzam/armature/issues/6) closed 2026-08-24T07:22:36Z; [PR #7](https://github.com/pharzam/armature/pull/7), merged 07:22:35Z, states the configuration in prose: pull request required, `0` approvals, force-pushes and deletion blocked, enforced for administrators, conversation resolution required, no status checks. Every one of those six matches the live configuration today.

**So the force push should have been impossible.** With `allow_force_pushes: false` and `enforce_admins: true`, the forge rejects a rewind for every actor, administrators included. The push at 10:18:03Z rewound `999765f` to `2cd70ee` and succeeded. The lock was therefore not in that state at that moment, and it is in that state now — so it was lifted and restored, and neither was recorded.

This is stated as an inference, not a fact: PR #7 is a claim in a pull-request body, not an API snapshot, and the forge exposes no history for classic protection. The account security log may hold the lift; it has not been consulted.

The ruleset created at 10:11:26Z — three minutes after the local reset, seven before the push — is not evidence of the lift. It was created *already disabled*, with `bypass_actors: []`, and a ruleset born disabled removes no obstacle. That it was born disabled is not an inference: `gh api repos/pharzam/armature/rulesets/21643143/history` returns exactly one version, so it has never been modified since creation and cannot have been created enabled and switched off afterwards. Of its three rules (`deletion`, `non_fast_forward`, `pull_request`), two would have blocked the push had it been enabled. What it does show is the operator inside the branch-protection settings, in that window.

The argument for condition 4 is not that the configuration was unrecorded — #6 and PR #7 recorded it well. It is that **the lift and the restore were not**, at the moment they mattered.

### What that score does and does not say

It does not say the reset was wrong. It answered a real problem — 45 commits, 67 files and roughly 1,659 insertions delivered in under three hours in one session, which the operator could not absorb — and no revert solves that. The backup went to the remote before anything was destroyed, and the reason was written down.

It says the care came from the operator and not from a rule, and that unguided care covered part of one of the five things that matter and missed the rest.

Under condition 2 this reset would not have been permitted: there is no second person here, so the path is closed. The rule the incident produced forbids the incident.
