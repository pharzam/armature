# 0008. Stop the gate on a frozen head

Date: 2026-09-02

## Status

Accepted

## Context

[Gate step 5](../engineering-discipline.md#working-a-task-under-the-quality-gate)
runs review rounds until one round finds nothing material, and
[ADR-0005](0005-independent-review-may-be-an-agent.md) says what a round is: an
independent reviewer reading a fixed commit. Neither says what happens between
rounds. Each round's fixes change the branch, the next round reads a larger
diff, and "nothing material" is measured against a surface that moves.

Three consecutive tasks measured the result
([#79](https://github.com/pharzam/armature/issues/79),
[#81](https://github.com/pharzam/armature/issues/81)):

| | #64 | #73 / #75 | #76 / #77 |
|---|---|---|---|
| Plan review on the issue ([R12](../issue-workflow.md#r12--slice-and-prioritize)) | Yes, with conditions | None recorded | None recorded |
| Budget declared | 300 lines in one file, `link-lint.sh`, by the plan reviewer | None | None |
| Overrun | 319 lines, reported twice, never revised, never approved | n/a | Widened three times by decision |
| Round record | A table per round | Seven comments on the PR | None |
| Termination | Round 3 at `b569583`: "nothing material" | Round 6 on a frozen tree found seven | No final round |

Two things about #64's budget do not carry over, and this record says so rather
than leaving the table to imply otherwise. Its 300 bounded the **length of one
file**, `link-lint.sh`, not lines added plus lines removed on a branch diff;
[section 5](#5-the-budget-record) changes the unit deliberately, so #64's number
measures a different thing and does not transfer. And the overrun reached `main`
with **no operator approval at all**: it was reported twice, judged earned by a
reviewer, and merged. What carries over from #64 is one practice — report the
overrun, never revise the number — and one gap, which
[section 5](#5-the-budget-record) closes.

The rule terminates on a change that stops moving and stays near its budget.
It has no bounded protocol when the branch keeps changing. The practice that
bounds it existed on #64 and was gone two tasks later; every rule involved is
written-rule-only. R12 already says the plan states a bound and growth past it
becomes a child sub-issue; on #76 that clause was neither applied nor enforced.

Two distinctions were missing. The rule did not say what "material" means, so
every finding was fixed and every fix grew the branch. And it did not separate
a defect *in* the change from a defect the change *revealed* in code that was
already there; on #76 both entered the same branch.

## Decision

We will stop the gate on a **frozen head**, under six rules. The mechanisms
that would enforce them are not decided here; see [Consequences](#consequences).

### 1. The frozen head

Every round reviews one named commit. The last round reviews a commit that is
**frozen**: nothing lands on the branch after it except a fix to a finding of
that round, the integration merge below, or the **close-out bookkeeping** — and
each produces a new frozen head that the next round names.

Close-out bookkeeping is the task line **arriving in the completed log** — moved
from the backlog where the task had a line there, and simply added where it did
not, which is every task opened and finished between two landings. What
[gate step 8](../engineering-discipline.md#completing-a-task) requires of the
landing pull request is the arrival, not the move. It cannot be written before
the rounds finish, because it is what finishing means, so a rule permitting only
fixes after a frozen head forbids every landing.

The exception covers the bookkeeping and nothing else. Where the same commit also
corrects a claim — the close-out entry is prose, and a round can find it wrong —
that correction is a fix to a finding, permitted on its own footing and named as
one. What the close-out says plainly is which of the two the commit carried, and
that no round read it.
"What a round records" already fixed the commit within a round. The gap was
between rounds, and this closes it. Rejected: reviewing the branch as it moves.
A verdict on a moving target names no commit.

**Integrating the default branch.** A rebase rewrites every commit on the branch,
the frozen head among them, and so destroys the SHA the last round's verdict
names. A branch under a frozen-head verdict therefore takes the other route: it
merges `origin/main` into itself with a plain merge, and
[Integrating branches](../engineering-discipline.md#integrating-branches) names
that exception to its rebase-then-merge rule. The merge is permitted after the
last round and re-freezes the head. It consumes no cycle and needs no new round
while it is clean and changes no file the branch touched; the author carries the
verdict forward in a comment naming the old head and the new one. Where the merge
does touch a file the branch changed, a round runs on the new frozen head, scoped
to those files. That round consumes no cycle either, because no fix of the
author's bought it — but a fix to anything it finds is a fix like any other, and
that fix does consume one.

### 2. The cycle cap and the non-merge verdict

After the first freeze, at most **two** fix-and-review cycles follow. Two is
both the maximum and the default: the plan-review confirmation declares the cap
in its `Cycle cap` field and may declare a lower one, and where that confirmation
is missing or omits the field, the cap is two. Nothing raises it.

When the cap is reached and the round still finds something material in scope,
the verdict is `not mergeable, findings recorded`. That is a legitimate outcome.
The model for it is #64's overrun: reported, not revised.

The successor state is an **issue split**: one successor issue carrying the
branch's work as it stands — on a branch of its own, cut from that commit and
with a first freeze of its own — plus a child issue for each finding still open
that the successor is not taking. Where the successor takes every open finding,
it alone is the split and no child issue is owed. An unapproved overrun is always
among the findings it takes, since the successor carries the very work whose size
overran. All of them are opened before the branch is landed in part or abandoned.

`Cycle` counts the frozen heads of **this branch for this issue**: `0` is its
first frozen head, and a branch has exactly one. A branch that has reached its
cap has no new first freeze available, so continuing the work means a new issue
and a new branch. **That successor starts its own count at `0`, and this is not a
reset**: the cap binds a branch on an issue, and the successor is a different
issue with a bound of its own. An earlier form of this clause said a split is
"not a reset of the count" while section 2 prescribed exactly the move that
starts a new one — the successor issue is where the ambiguity showed, having run
`Cycle` 0, 1 and 2 on work its predecessor had already spent two cycles on.

The number two is fitted to one observation: #64, the only task with round
records in this shape, needed exactly two cycles, rounds 1 and 2 material and
round 3 nothing material. What moves it is a recorded task on which the cap
produced a non-merge verdict and a later cycle then found nothing material in
scope. A change to the number is a new record that amends this one.

Rejected: a fixed round count. Counts across lenses are not comparable; #64
needed three rounds and #75 six. Rejected: a cap of one. It would have failed
the only task that met the condition.

### 3. Materiality

A finding is **material** when it changes an exit code, an assertion, a
behaviour on an adopter's tree, a claim in the tree, or a Definition-of-Done
item. Wording, style and layout are not material. A claim in the tree is
material only when a reader could act on the claim and the change makes it
false or leaves it false; a sentence that changed and still holds is wording.
Each finding records its basis in one line: which of the five it changes, or
that it is wording.

A dispute over materiality routes to
[When reviewers disagree](../engineering-discipline.md#when-reviewers-disagree):
escalate by independence level, never average, and the author never breaks the
tie. Rejected: a severity word. "High, medium, low" is a judgement; the list
above is a test a second reader can apply.

### 4. Classification and routing

A finding is classified before it is routed:

- **In the change**: introduced by this branch, including its fixes, tests,
  guards and prose, or pre-existing on the path the Definition of Done names.
  Fixed here, inside the budget; past the budget, a child issue.
- **Revealed**: pre-existing and off that path. A new issue, with priority by
  direction: a silent false green is a blocker, a loud failure is normal.

A severe finding that is out of scope blocks the merge only if this branch made
it reachable, the test [#78](https://github.com/pharzam/armature/issues/78)
posed: a branch shipped spaced directory names into a tree whose link checker
could not read one. The final clean round lists every accepted out-of-scope
finding with its issue number; those do not count against
`nothing material in scope`. The author opens each new issue, with its
measurement, before the merge — one for every finding whose classification is
agreed.

Classification is the cheapest way out of a round, so a classification dispute
routes to [When reviewers disagree](../engineering-discipline.md#when-reviewers-disagree)
like a materiality dispute, and **no finding leaves the scope on the author's
word alone**: where a reviewer raised it, that reviewer agrees; where the author
raised it, an independent reviewer agrees. Without that assent the classification
is **recorded as disputed** on the issue. A disputed or unresolved classification
is a finding still open, so it owes no issue until it resolves, and it takes the
verdict [section 6](#6-the-review-record) gives it: the branch does not merge on
the author's own reading of it. Rejected: routing every finding into the branch.
That is what removed the stopping condition on #76.

### 5. The budget record

[R12](../issue-workflow.md#r12--slice-and-prioritize) already says the plan
states the bound out loud and that growth past it becomes a child sub-issue.
This record does not restate that. It makes it operational — and it **changes the
unit**: #64 bounded the length of one file, and this bounds a branch diff,
because #76's growth was spread over documents and fixtures that no single
file's length would have caught.

- **Unit**: lines added plus lines removed on the whole branch diff, plus files
  touched, so splitting commits changes nothing. Documents, tests and fixtures
  count; they were the growth on #76. Rejected: a count by commit, or one that
  leaves documents out.
- **Base**: the tip of the default branch at the moment of measurement, named by
  SHA wherever the number is written — the plan-review comment for the maximum,
  the round's `Raw findings` for an overrun — so a later reader reproduces the
  same figure. Merging that branch in never lowers the number: what the merge
  brought in is not this branch's work, and where a fresh measurement comes out
  below the last one recorded, the last one stands. Rejected: "the merge-base",
  which moves every time the branch takes the default branch and gives one branch
  several lawful numbers. That is not a hypothetical: on the branch that carries
  this record, measuring the head before it merged the default branch and the
  head after it, against the *same* commit, gives two different figures, and only
  the named base says which one the budget is read against.
- **Baseline**: the plan's estimate. **Maximum**: set in the plan-review
  confirmation.
- **Overrun**: a finding reported on the issue, never a revision of the number.
  The only approver is the operator, once, on the issue; the alternative is a
  child issue. **Once counts per issue, not per branch**, so a successor issue
  starts with an approval of its own. Nothing here prevents that, and this record
  does not pretend otherwise: R11 does not bound it, because R11 is a test of
  scale and not of novelty, and
  [section 2](#2-the-cycle-cap-and-the-non-merge-verdict) *prescribes* a successor
  when a cap is reached. What the record relies on instead is that a successor's
  plan review sets its maximum with the carried size already measured and on the
  issue, so a bound set in ignorance of it is not available. That is a discipline
  and not a mechanism, and it is written here as one rather than left to look like
  a guard.
  **Whether an approval may name a ceiling is not decided here.** Three rounds
  across [#81](https://github.com/pharzam/armature/issues/81) and
  [#89](https://github.com/pharzam/armature/issues/89) produced three different
  rules for it — optional, bounding the measured outturn, covering
  findings-driven growth — and each was falsified by the next round. What is
  undecided is exactly that: whether a ceiling may be named, and how far an
  approval reaches past the figure it was given. It is
  [#99](https://github.com/pharzam/armature/issues/99)'s, and until that lands
  the rule is the one above and nothing more: one approval per issue, an
  unapproved overrun blocking the merge, and the last round carrying it.
  An overrun the operator has not approved **blocks the merge**: the last round
  carries it as a finding and returns `not mergeable, findings recorded`. That
  route into the verdict does not run through the cap.
  [Section 2](#2-the-cycle-cap-and-the-non-merge-verdict) reaches the verdict when
  a cap is reached with something material still in scope; this reaches it whether
  or not a cap is near and whether or not anything else is open, because an
  unapproved overrun blocks a merge on its own. #64 is the case
  this is fitted to: its
  overrun was reported twice, judged earned by a reviewer, and merged with no
  operator approval at all — the approval step going unenforced on the one task
  that had a budget. That does not make the overrun material —
  [section 3](#3-materiality) decides whether a finding buys a fix, and this
  decides whether the branch lands. The approval is a recorded event: a comment
  on the issue naming the number, the frozen head it was measured at, and the
  base it was measured against.
- **Where it lives**: the budget line is in the plan-review comment. Any later
  change is a new comment, not an edit.

### 6. The review record

Each round is one comment on the issue under the heading
`## Review record — round N`, with these fields, by these names:

| Field | Value |
|---|---|
| `Commit reviewed` | the frozen head, by SHA |
| `Reviewer` | the model and version, or the person |
| `Lens` | the one question the round asked |
| `Briefed on` | what the reviewer was handed |
| `Barred from` | what the brief excluded |
| `Independence claimed` | the ADR-0005 levels held, and those not reached |
| `Cycle` | `0` on this branch's first frozen head for this issue; `k` for the k-th fix-and-review cycle after it |
| `Raw findings` | before triage, each with its one-line basis and its classification |
| `Fixes` | what landed, and the new frozen head if one |
| `Verdict` | one of the closed values below |

The reviewer writes nine of the ten. `Fixes` is the **author's**: the fixes land
after the round ends and are not the reviewer's work, so the author writes that
field as a **reply comment under the round it answers**, naming what landed and
the new frozen head. A record with no `Fixes` is complete until fixes land, and
the reply is a new comment rather than an edit of the record, for the reason
[section 5](#5-the-budget-record) gives for the budget line.

The plan-review confirmation carries `Verdict`, `Budget maximum` and
`Cycle cap`. The verdict vocabulary is closed in all three positions. A plan
review is `approve`, `approve-with-conditions` or `reject`. An **intermediate
round** — one a fix follows — is `material`. The **last round** — the one no fix
follows — is `nothing material in scope` or `not mergeable, findings recorded`.
The three round values are disjoint across the two positions, so the verdict
itself says which position a record holds and no field has to mark it.
`not mergeable, findings recorded` is also the last round's verdict where a
finding's materiality or classification stands disputed or unresolved: a dispute
is a finding still open, and it is recorded as one. And it is the verdict where
[section 5](#5-the-budget-record)'s unapproved overrun stands, which is a finding
open by the same reading. So three routes reach the verdict — a cap with material
in scope, a dispute, an unapproved overrun — and only the first needs the cap. A check counts the cap from
`Cycle` and matches the verdict as a string.

That check's **input contract** — how it matches the heading, how it reads the
fields as they are rendered, and what value it accepts for `Cycle` — is fixed by
the check itself, in
[#82](https://github.com/pharzam/armature/issues/82), and not here: the issue
that builds a parser is the one that can test it against the records already
written. Until a check lands, a record is read by a person, and the names above
are what a person reads it for.

`Independence claimed`, `Cycle`, `Raw findings` and `Fixes` are new fields.
#64's records are the shape this list grew from and do not satisfy it: its
round-1 record carried five of these in its table, its round-2 and round-3
records four each — `Briefed on` is in neither — and each gave its verdict as
prose. The contract is not retroactive: no record written before this date is
read against it. Rejected: prose records. A check cannot count a cycle or match a
verdict it has to interpret.

Three things no record proves. That a reviewer did not read a barred comment.
That the model named is the model used. And that every round which ran was
recorded: a round that ran and was not posted leaves no trace, nothing
distinguishes a session that died from a round the author chose not to post, and
so "until one round finds nothing material" is only as sound as the author's
posting. The record makes each claim falsifiable; it does not verify it.

## Consequences

A task can stop honestly. `not mergeable, findings recorded` is a verdict a task
can reach and a reader can act on; before this record the only exits were
"nothing material" or another round. The two distinctions cut the branch: a
wording finding does not buy a fix-and-review cycle on its own, and a revealed
defect leaves the branch for an issue with its measurement attached.

More writing per round. A record has ten named fields and a closed verdict, and
each finding carries a basis and a classification. A non-merge is a real
outcome: a task that reaches the cap ends with open issues and no merge, which
is more visible than a branch that kept growing.

What stays open. Every mechanism is
[#82](https://github.com/pharzam/armature/issues/82)'s, and until one lands this
is a written rule. The
[enforcement table](../issue-workflow.md#what-is-enforced-where) gains its row in
this change and records it as one. The
cap's evidence base is one task, #64; #81, which decided this record, is the
first task that runs under it.
