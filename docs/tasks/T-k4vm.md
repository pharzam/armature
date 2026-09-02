# T-k4vm — The gate's stopping protocol

Tracks [issue #89](https://github.com/pharzam/armature/issues/89), the successor to
[#81](https://github.com/pharzam/armature/issues/81). Index line: [completed.md](completed.md); this task never sat in the backlog. The record it lands is
[ADR-0008](../adr/0008-stop-the-gate-on-a-frozen-head.md).

Written on 2026-09-02 from the two threads and the branch history. Every number below
is copied from a record that already carries it, with its source named.

## Why

[#79](https://github.com/pharzam/armature/issues/79) measured that the gate's stopping
rule does not stop. `docs/engineering-discipline.md` said to keep review rounds running
"until one round finds nothing material", with no frozen artifact between rounds, no
cap, no definition of *material*, and no route for a defect the change merely revealed.
The rule terminated on [#64](https://github.com/pharzam/armature/issues/64) because
that branch stopped moving and stayed near a declared budget; the practice that bounded
it decayed across the next three tasks, because every rule involved was written-rule-only
and nothing noticed.

The gate is this repository's product. A stopping rule that does not stop is a defect in
the thing the kit ships, not in the prose that describes it.

## What the record decides

Six decisions, each with its rejected alternatives, in
[ADR-0008](../adr/0008-stop-the-gate-on-a-frozen-head.md):

1. **A frozen head.** A round reviews a named commit; a fix re-freezes it. Integration
   with the default branch takes the merge route, because a rebase rewrites the SHA a
   verdict names.
2. **A cycle cap and a non-merge verdict.** At most two fix-and-review cycles after the
   first freeze; on the cap **with something material still in scope** the verdict is
   `not mergeable, findings recorded`, a legitimate outcome rather than a failure, whose
   successor state is an issue split.
3. **Materiality.** A finding is material when it changes an exit code, an assertion, a
   behaviour on an adopter's tree, a claim in the tree a reader could act on, or a
   Definition-of-Done item. Wording, style and layout are not.
4. **Classification and routing.** A defect *in* the change is fixed inside the budget;
   one the change *revealed* off its path opens its own issue. No finding leaves the
   scope on the author's word alone.
5. **The budget record.** R12's bound made operational: a unit, a named base, and an
   approval that is the operator's alone. What a ceiling is, and how far an approval
   reaches, is **not** decided here — three rounds produced three rules for it and each
   was falsified by the next, so it is deferred to its own issue and the record says so.
6. **The review record.** Ten named fields under a fixed heading, with a closed verdict
   vocabulary, and a statement of what no record proves.

## What the predecessor cost, and what stopped it

#81 built this record and was stopped by the rule it was writing. The sequence, from
that issue's close-out:

| Stage | Lines | Files |
|---|---|---|
| Plan-review maximum | 300 | 8 |
| Build | 291 | 7 |
| After round 1's five findings | 307 | 9 |
| Operator approval, with a ceiling | 370 | 10 |
| After round 2's twelve findings | 436 | 9 |

Section 5 gives the operator one approval per issue. It was spent on the 370 ceiling,
the ceiling was passed, and a second ceiling set after measuring 436 would have been a
decision rule chosen once the result was known — a fitted parameter under
[guardrails, section 1](../guardrails.md#1-pre-registered-decisions--or-the-goalposts-move).
So the issue split and this one carries the work whole and untrimmed.

Four of round 2's twelve findings were structural, and each is a case where the protocol
as first written could not be run: it contradicted the repository's own landing rule;
its cap reset for free; it had no cap at all when a plan-review confirmation was missing,
which its own evidence said was the common case; and a disputed finding had no verdict to
stop on. Eleven are fixed on this branch. The twelfth, the record's exact syntax, was routed to [#82](https://github.com/pharzam/armature/issues/82) with the raising reviewer's agreement, because the issue that builds the parser is the one that can test the contract against the records already written. No round here re-litigates any of them.

## What this task added

Three things the predecessor could not fit inside its ceiling.

- **The completed log said something false.** It recorded the work as a completed task
  citing #81, an issue that closed unmerged. The entry now names this task and this
  issue. That correction produced this task's only red: the log's own header requires a
  detail link, so the link necessarily preceded this file.
- **Section 5's "once" is stated, and not dressed as a guard.** It counts per issue,
  so a successor issue starts with an approval of its own. R11 does not forbid the
  successor — it is a test of scale, not of novelty, and section 2 *prescribes* one
  when a cap is reached. An earlier draft claimed the successor's maximum being set
  from the measured carried size stopped a split buying budget; a round showed that
  it bounds only the carried half and contradicts the section's own Baseline and
  Maximum. The record now says the plain thing: nothing prevents a successor's fresh
  approval, and what the rule relies on is that its plan review sets a maximum with
  the carried size already measured and on the issue. That is a discipline, not a
  mechanism, and it is written as one. This issue is the instance: a bound of 566 set
  as 436 measured plus 130 estimated.
- **A ceiling got a rule of its own, and it did not hold.** This task wrote the third
  rule three rounds produced for that clause, and the successor's first round falsified
  it as its predecessors were falsified. The clause is deferred whole to
  [#99](https://github.com/pharzam/armature/issues/99), which carries all three
  attempts. What this task got right is the measurement underneath: an approval is one
  number, on one issue, at a named head against a named base.

## What the evidence turned out to be

The record cited #64 as its template and as the cap's whole evidence base. Both citations
were wrong, and were corrected on the predecessor branch after an operator checked the
thread: #64's outturn was **319**, not 312; its 300 bounded **the length of one file**,
`link-lint.sh`, not a branch diff; and its overrun **reached the default branch with no
operator approval at all** — reported twice, judged earned by a reviewer, and merged.
The approval step this record writes down had never once been exercised before #81.

The cap of two is fitted to a single observation, and the record says so and names what
would move it. That is stated rather than hidden, because a cap presented as measured
when it rests on one case is the defect this record exists to catch.

## Verdict

Delivered the stopping protocol as ADR-0008, with `docs/engineering-discipline.md`,
`docs/glossary.md` and `AGENTS.md` made to say the same thing, on a branch carrying
eleven of the twelve fixes the predecessor's round 2 produced — the twelfth, the
record's exact syntax, is #82's.

The honest summary of the predecessor is that the gate worked and the task did not: a
record with four structural defects would have landed as `Accepted`, and
[`docs/adr/README.md`](../adr/README.md) holds an accepted record immutable but for its
Status line. It was stopped by the rule its own diff writes, which is the strongest
evidence available that the rule is worth landing.
