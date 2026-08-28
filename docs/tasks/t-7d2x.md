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
path is closed. The repair path is not, for now: nothing has yet landed on `main` since
the 2026-08-27 reset — this record's own merge ends that — and both a backup reference
and the forge's record of the merge that produced the discarded tip survive — so
restoring it is a fast-forward that makes nothing unreachable, and outside the record's
own definition of destruction. That is not the same as being permitted: ADR-0004 says
only that it does not reach the act, and leaves what governs it to [#48](https://github.com/pharzam/armature/issues/48). The question
stops being a fast-forward one the moment anything lands, because the restore would then
discard that work. If that proves wrong in practice, the correction is a **superseding**
ADR, not an edit: the decision would have changed, and `adr/README.md` reserves
amendment for a decision that still holds.

## What this record deliberately does not carry

Nine rounds of independent review ran over a draft that grew to 11,895 bytes,
about twice the size of ADR-0004 today, and most of what they found was in material added beyond
what the audit asked for. That material is recorded here, where an adopter
deletes it with the file, rather than in an ADR they cannot edit.

**Undoing a destruction.** The draft carried a repair carve-out that waived the
second-operator requirement, plus a recursion bound and a fast-forward rule to
contain it. Review found, in order: it exempted the very reset it scores; it
waived all five conditions rather than one; it contradicted itself; it recursed
without bound, leaving every un-undone destruction a standing single-operator
licence; and once bounded by count it was still unbounded in time. Each fix
raised a new defect. The carve-out is deferred to
[#48](https://github.com/pharzam/armature/issues/48), which carries all five
failures so the next draft does not rediscover them.

One decision #48 inherits: the cut draft held that a fast-forward repair "is
still a repair, and conditions 1, 3, 4 and 5 still apply to it", where the
record now says it does not reach the act at all. The looser reading is the one
in force, and it was never argued for — it should be settled deliberately.

**Acts that reach the same outcome sideways.** A default-branch swap — point the
canonical role at a new branch, then delete or rewrite the old one — walked past
an enumerated definition twice. The definition is anchored to the remote's
default branch now — to *every* branch that has held that role, not only the
current one, which is what stops an operator moving the pointer and then
emptying the branch it left behind. Three earlier definitions were walked past
because they tested only the branch that is the default at the moment of the
act. It does carry two
stated exceptions — the swap where the old branch stays, and local history never
pushed — because a definition with no exceptions turned out to be a definition
that either caught the swap or exempted anyone who made a backup. The tag act
and the per-mechanism lock discipline that grew alongside it are gone.

**What the sweep cannot see.** Condition 3 reads the refs at two moments, which
stops an operator emptying the set by deleting branches *after* condition 1's
issue is opened. It does not stop deleting them **before** — that ordering is
outside what the sweep can observe, and the condition's ordering instruction concedes it rather than
implying a completeness it does not have. Local-only branches are also outside
it: the sweep reads the remote, so a branch that exists on one machine is not
preserved by this rule. `chore/t-5r2q-review-debt` was exactly that case, and
the scorecard below records that it survived by luck rather than by the rule.

**Where the evidence lives.** Every finding above, with its reproduction, is on
[#43](https://github.com/pharzam/armature/issues/43) and
[#16](https://github.com/pharzam/armature/issues/16) — over 245,000 bytes of
review record. The 11,895-byte draft is in this branch's own
history; the earlier 7,022-byte one is on `docs/t-7d2x-reset-adr`, which forked
at the reset point and is reference only, never a merge source.

## The 2026-08-27 reset, scored against the five conditions

Written by the operator who performed the reset it scores. Issue timestamps are from each issue's own timeline; the repository events feed reports some of them one or two seconds later.

| Time (UTC) | Event |
|---|---|
| 10:08:11 | `main` reset locally (`git reflog show main`) |
| 10:11:26 | a branch ruleset named `main` is created, already disabled — see below |
| 10:14:25 | `backup/pre-r12-reset-999765f` pushed — the default branch's tip preserved, before anything was destroyed (`git reflog show refs/remotes/origin/backup/pre-r12-reset-999765f`; the events feed carries a CreateEvent for this push at 10:14:26Z, but none for the second backup) |
| 10:18:03 | force-pushed to the remote (`PushEvent refs/heads/main`) |
| 10:41:02 | the record written on #16, opening **"Status: main was reset."** — past tense |
| 10:46:24–10:46:51 | **twelve further issues closed as completed** (#19, #20, #22, #33–#41) over deliverables `main` no longer held |
| 11:46:56–11:47:38 | the eighteen affected issues reopened |

| Condition | Score |
|---|---|
| 1 — *"An open issue states the goal in the operator's own words, and why no revert, fix-forward, or new branch reaches it. It records every reference on the remote, by name and object name, as they stand at that moment."* | **Not met, on all three limbs.** Nothing was written anywhere before the act. The goal was recorded 23 minutes after the push, so for that limb the condition is about *when*. The second limb — why no revert, fix-forward or new branch reaches the goal — was never recorded at all: the 10:41:02Z record names none of the three. The third limb postdates the act, but nothing was written at all, so it fails on the same evidence. |
| 2 — *"A second operator approves in writing, and that operator is a person… With no second person, the path is closed."* | **Not met.** Self-approved. |
| 3 — *"Everything about to be lost is preserved first…"* | **Partly.** `backup/pre-r12-reset-999765f` held the default branch's tip, correctly. One other remote tip that was not an ancestor of it was not, and one branch condition 3 does not reach at all: `fix/t-3k8w-runner-asserts-reason` happened to be on the remote already, and `chore/t-5r2q-review-debt` existed on one machine only and was pushed to `backup/pre-r12-reset-t-5r2q` — a name that carries a task ID where condition 3's `backup/pre-<reason>-<short-sha>` wants the tip's short SHA, though the condition postdates the act — at 11:46:30Z (local `git reflog show refs/remotes/origin/backup/pre-r12-reset-t-5r2q`; the repository events feed carries a CreateEvent for the first backup at 10:14:26Z but none for this one), 88 minutes after the push. It survived by luck. Condition 3 now sweeps the references as they stood when condition 1's issue opened *and* as they stand at the act, together; here condition 1's issue never existed, so only the act-time set applies and the score is unchanged. |
| 4 — *"Any lock on the branch is lifted deliberately and restored afterwards, with both recorded, and the restore checked against a record of the lock's full configuration made before lifting…"* | **Not met.** A documented lock existed and, on the evidence below, was lifted around the act and restored; nobody recorded either, and no check against a prior record ran — which is the failure regardless of what the lock was doing. See below. |
| 5 — *"Every issue whose deliverable is no longer on the default branch returns to open with the evidence, and condition 1's issue — or a new one if condition 1 was skipped — records what was destroyed, where the backups are, and who approved. This comes after the act and before any further work on the repository that is not part of it; a commit, a push, a merge and closing an issue all count as further work."* | **Not met.** The test is *before the acting operator does any further work*, and work resumed 28 minutes after the push in the wrong direction: twelve further issues were closed as completed over deliverables that had just been destroyed. The reopens began at 11:46:56Z, 60 minutes after those closes. Condition 1's issue never existed, so the second half has no subject; the 10:41 comment records what was destroyed and names the backup branch, and there was no approver to record. |

**Nought of five fully met, one partly.**

#### What the lock was actually doing

**The lock was documented three days earlier.** [#6](https://github.com/pharzam/armature/issues/6) closed 2026-08-24T07:22:36Z; [PR #7](https://github.com/pharzam/armature/pull/7), merged 07:22:35Z, states the configuration in prose: pull request required, `0` approvals, force-pushes and deletion blocked, enforced for administrators, conversation resolution required, no status checks. Every one of those six matches the live configuration today.

**So the force push should have been impossible.** With `allow_force_pushes: false` and `enforce_admins: true`, the forge rejects a rewind for every actor, administrators included. The push at 10:18:03Z rewound `999765f` to `2cd70ee` and succeeded. The lock was therefore not in that state at that moment, and it is in that state now — so it was lifted and restored, and neither was recorded.

This is stated as an inference, not a fact: PR #7 is a claim in a pull-request body, not an API snapshot, and the forge exposes no history for classic protection. The account security log may hold the lift; it has not been consulted.

The ruleset created at 10:11:26Z — three minutes after the local reset, seven before the push — is not evidence of the lift. It was created *already disabled*, with `bypass_actors: []`, and a ruleset born disabled removes no obstacle. That it was born disabled is not an inference: `gh api repos/pharzam/armature/rulesets/21643143/history` returns exactly one version, so it has never been modified since creation and cannot have been created enabled and switched off afterwards. Of its three rules (`deletion`, `non_fast_forward`, `pull_request`), all three would have blocked the push had it been enabled. What it does show is the operator inside the branch-protection settings, in that window.

The argument for condition 4 is not that the configuration was unrecorded — #6 and PR #7 recorded it well. It is that **the lift and the restore were not**, at the moment they mattered.

### What that score does and does not say

It does not say the reset was wrong. It answered a real problem — 45 commits, 67 files and roughly 1,659 insertions delivered in under three hours in one session, which the operator could not absorb — though whether a revert or a new branch would have served as well was never argued, then or since. The backup went to the remote before anything was destroyed, and the reason was written down.

It says the care came from the operator and not from a rule, and that unguided care covered part of one of the five things that matter and missed the rest.

Under condition 2 this reset would not have been permitted: there is no second person here, so the path is closed. The rule the incident produced forbids the incident.
