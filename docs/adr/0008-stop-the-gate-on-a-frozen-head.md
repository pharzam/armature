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
| Budget declared | 300 lines, by the plan reviewer | None | None |
| Overrun | 312 lines, reported and not revised | n/a | Widened three times by decision |
| Round record | A table per round | Seven comments on the PR | None |
| Termination | Round 3 at `b569583`: "nothing material" | Round 6 on a frozen tree found seven | No final round |

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
that round, and a fix produces a new frozen head that the next round names.
"What a round records" already fixed the commit within a round. The gap was
between rounds, and this closes it. Rejected: reviewing the branch as it moves.
A verdict on a moving target names no commit.

### 2. The cycle cap and the non-merge verdict

After the first freeze, at most **two** fix-and-review cycles follow. The cap is
declared in the plan-review confirmation. When the cap is reached and the round
still finds something material in scope, the verdict is
`not mergeable, findings recorded`. That is a legitimate outcome. The model for
it is #64's overrun: reported, not revised.

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
measurement, before the merge.

Classification is the cheapest way out of a round, so a classification dispute
routes to [When reviewers disagree](../engineering-discipline.md#when-reviewers-disagree)
like a materiality dispute, and the author does not move their own finding out
of scope unopposed: the reviewer that raised it agrees, or the classification is
recorded as disputed on the issue. Rejected: routing every finding into the
branch. That is what removed the stopping condition on #76.

### 5. The budget record

[R12](../issue-workflow.md#r12--slice-and-prioritize) already says the plan
states the bound out loud and that growth past it becomes a child sub-issue.
This record does not restate that. It makes it operational:

- **Unit**: lines added plus lines removed on the whole branch diff against the
  merge-base, so splitting commits changes nothing, plus files touched.
  Documents, tests and fixtures count; they were the growth on #76. Rejected:
  a count by commit, or one that leaves documents out.
- **Baseline**: the plan's estimate. **Maximum**: set in the plan-review
  confirmation.
- **Overrun**: a finding reported on the issue, never a revision of the number.
  The only approver is the operator, once, on the issue; the alternative is a
  child issue.
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
| `Cycle` | `0` on the first frozen head; `k` for the k-th fix-and-review cycle after it |
| `Raw findings` | before triage, each with its one-line basis and its classification |
| `Fixes` | what landed, and the new frozen head if one |
| `Verdict` | one of the closed values below |

The plan-review confirmation carries `Verdict`, `Budget maximum` and
`Cycle cap`. The verdict vocabulary is closed in all three positions. A plan
review is `approve`, `approve-with-conditions` or `reject`. An intermediate
round is `material` or `nothing material in scope`. The last round is
`nothing material in scope` or `not mergeable, findings recorded`. A check
counts the cap from `Cycle` and matches the verdict as a string.

`Independence claimed`, `Cycle`, `Raw findings` and `Fixes` are new fields.
#64's records carried the first five as fields and the rest as prose; they are
the shape this list grew from, and they do not satisfy it. The contract is not
retroactive: no record written before this date is read against it. Rejected:
prose records. A check cannot count a cycle or match a verdict it has to
interpret.

No record proves that a reviewer did not read a barred comment, or that the
model named is the model used. The record makes each claim falsifiable; it does
not verify it.

## Consequences

A task can stop honestly. `not mergeable, findings recorded` is a verdict a task
can reach and a reader can act on; before this record the only exits were
"nothing material" or another round. The two distinctions cut the branch: a
wording finding is not fixed inside a frozen round, and a revealed defect leaves
the branch for an issue with its measurement attached.

More writing per round. A record has ten named fields and a closed verdict, and
each finding carries a basis and a classification. A non-merge is a real
outcome: a task that reaches the cap ends with open issues and no merge, which
is more visible than a branch that kept growing.

What stays open. Every mechanism is
[#82](https://github.com/pharzam/armature/issues/82)'s, and until one lands this
is a written rule, as the
[enforcement table](../issue-workflow.md#what-is-enforced-where) says. The
cap's evidence base is one task, #64; #81, which decided this record, is the
first task that runs under it.
