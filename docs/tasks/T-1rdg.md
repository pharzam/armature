# T-1rdg — One reading, not two

Issue [#193](https://github.com/pharzam/armature/issues/193). Add an enforceable
standard that **decision-driving text admits one honest reading, not two** — the
issue statement, the acceptance criteria and Definition of Done, a directive to an
operator, a plan step, and a review finding.

## Verdict

Delivered. The rule ships in four synced pieces: the engineering principle
**"One reading, not two"** in [`engineering-discipline.md`](../engineering-discipline.md#one-reading-not-two)
(one reading; falsifiable; no unquantified vague word carrying a decision; a
tripwire on the plan review and each decay round, with "honest reading" pinned
operationally); the citable rule **R13** in
[`issue-workflow.md`](../issue-workflow.md#r13--one-reading-not-two) with a
decay-review lens and an honest enforced-where row (reviewer judgement — no
deterministic check, ambiguity being semantic); **ADR-0008** recording the decision
and its rejected alternatives; and the R10 sync (the rule count to R1–R13 across
every living summary, and a new glossary term "Decision-driving text").

Two independent, Model-independent decay rounds found two material issues — a stale
glossary lens enumeration, and an unpinned "honest reading" (R13 failing its own
third clause) — both fixed; a third finding (ADR-0004's immutable "twelve rules")
was withdrawn by its raiser as frozen ADR history, on the ADR-0003:22 precedent.
Evidence: `adr-lint` OK, `link-lint` OK (964 links), `run-discipline-tests` 81/0,
`git diff --check` clean. Last round (`e20e27d`, cycle 1): **nothing material in
scope**.

## Resource record

Per [ADR-0007](../adr/0007-record-task-resource-use.md); recorded, not budgeted.
This session routed author-side work (plan, edits, close-out) on the reasoning-tier
model and reached a **different** model for the independent reviews — the Model
independence level required for a governance change. It has no execution-tier model,
so the "writing the docs" part ran on the reasoning tier; that limit is named here
rather than implied. Per-part tokens and wall-clock are **not reported**: this
harness exposes no per-part token or elapsed meter to the agent, and a guess would
be worthless as evidence.

| Part | Expected tier | Model | Effort | Tokens | Elapsed |
| ---- | ------------- | ----- | ------ | ------ | ------- |
| The plan and its review | reasoning | Opus 4.8 (plan); Claude Sonnet (independent review) | not reported | not reported | not reported |
| The decay review rounds | reasoning | Claude Sonnet (rounds 1–2, three independent sessions) | not reported | not reported | not reported |
| Writing the docs (the change) | execution | Opus 4.8 (no execution-tier model available — limit recorded) | not reported | not reported | not reported |
| Isolate, guardrails, docs sync, close-out | — | Opus 4.8 | not reported | not reported | not reported |
| **Total** | | | | not reported | not reported |
