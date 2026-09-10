# T-q7w2 — Reconcile the model-tier wording drift ("set" vs "fixed")

Tracks [issue #185](https://github.com/pharzam/armature/issues/185). Completed
line: [completed.md](completed.md). Plan and its independent review are on the
issue (R12).

## Why

The routing partition [ADR-0005](../adr/0005-route-work-by-model-tier.md) decided
is stated in more than one home, and the operative
[`## Model tiers`](../engineering-discipline.md#model-tiers) table is the odd one
out — a pre-existing [R10](../issue-workflow.md#r10--sync-with-governance) drift
that [#179](https://github.com/pharzam/armature/issues/179) surfaced and recorded
here rather than compounded there (ADR-0007 cites the partition rather than
re-quoting it, so it added no further variant). The execution-tier clause reads, across
its homes, in two forms:

- ADR-0005 (Decision), the [`glossary.md`](../glossary.md) `Model tier` entry, and
  the [`AGENTS.md`](../../AGENTS.md) pointer: **"tactical execution and coding …
  once the plan is fixed"**.
- the operative `## Model tiers` table (Execution-tier row): **"carry out a fixed
  plan … once the plan is set"**.

"carry out a fixed plan" versus "tactical execution and coding", and "set" versus
"fixed", disagree across the documents that state one partition.

## What

ADR-0005's body is immutable — the `## Status` line is the only editable part, and
it already reads `Accepted. Amended by ADR-0007` — so the record that decided the
partition cannot be edited to match, and must not be. Pick the ADR's wording as
canonical: it is the record that decided the partition, and three of its homes plus
the dated `completed.md` history already use it. Align the single editable outlier —
the `## Model tiers` table's Execution-tier row — to it. No other home changes: the
glossary entry and the `AGENTS.md` pointer already carry the canonical clause.

Rejected alternative (recorded so it is not reopened): keep the operative table's
wording and reconcile the others to it. It would force marking ADR-0005's immutable
Decision prose "dated" through a Status-line pointer for a purely stylistic
difference — heavy machinery where no later decision supersedes the prose — and
would change two homes (glossary, AGENTS.md) instead of one. The plan review picks;
see the issue.

## Plan (R12 — ordered, test-first where a test applies)

Task card → pre-register the consistency grep and confirm it fails now (the table
row carries "carry out a fixed plan"/"once the plan is set") → edit the one outlier
clause in the `## Model tiers` table so it reads "perform tactical execution and
coding … once the plan is fixed" → re-run the grep (the outlier tokens gone from the
operative rule documents, the four homes carrying the canonical clause) and every
discipline check + `git diff --check` → one
independent, clause-by-clause semantic-agreement round on a frozen head, on a second
model (this is a governance change, so Model independence applies) → close out with
the resource record, the completed line, and the verdict, in the landing PR.

## Definition of Done

- The `## Model tiers` table's Execution-tier clause states the same partition as
  ADR-0005's Decision: "tactical execution and coding" and "once the plan is fixed".
- ADR-0005's body is untouched (immutable; its Status already points to ADR-0007).
- All four homes — ADR-0005 Decision, the `## Model tiers` table, the `Model tier`
  glossary entry, and the `AGENTS.md` pointer — agree on the execution-tier clause
  (R10); a pre-registered grep finds the outlier tokens ("once the plan is set",
  "carry out a fixed plan") in no operative rule document (ADR-0007's distinct
  "(which carries out a fixed plan)" paraphrase uses "fixed", does not conflict, and
  stays out of scope).
- `adr-lint`, `prd-lint`, `link-lint`, `run-discipline-tests` and `git diff --check`
  pass.
- An independent, clause-by-clause semantic-agreement review of the changed clause
  against ADR-0005 is recorded on
  [#185](https://github.com/pharzam/armature/issues/185).
- Scoped out and tracked: the glossary's "lighter, cheaper" versus the table and
  ADR's "lighter, faster, cheaper" is a different, off-#185-path phrasing difference
  (a dropped adjective, not the "set/fixed" clause drift). It is not folded into this
  change; it is tracked as follow-up
  [#188](https://github.com/pharzam/armature/issues/188).

## Verdict

Mergeable. The `## Model tiers` table's Execution-tier row now states the partition
in ADR-0005's canonical wording — "**perform tactical execution and coding**:
writing the tests and the code once the plan is fixed, and routine mechanical edits"
— so all four homes (ADR-0005 Decision, the table, the `Model tier` glossary entry,
and the `AGENTS.md` pointer) agree on the execution-tier clause (R10), and
ADR-0005's immutable body is untouched. The plan was reviewed once and approved
(approve-with-conditions; Option A confirmed independently, conditions applied) on
[#185](https://github.com/pharzam/armature/issues/185); one independent,
Model-independent semantic-agreement decay round on frozen head `396a4d7` returned
`nothing material in scope`. The off-path glossary "faster" gloss difference is
tracked as follow-up [#188](https://github.com/pharzam/armature/issues/188). The
discipline checks, the pre-registered consistency grep, and `review-record-lint`
(3 comments, 1 round, cap 2) all pass.

## Resource record

Per [ADR-0007](../adr/0007-record-task-resource-use.md). This harness reports tokens
and elapsed time for the independent **agent** sessions but not per part for the main
loop, so the main-loop cells read `not reported` (the degradation ADR-0007
anticipates, never a guess). The two review sessions ran on a different frontier
model (Sonnet 5) to reach **Model** independence for this governance change; no part
was routed to a genuinely lighter **execution tier** — the execution part (the fix)
ran on the reasoning-tier main-loop model, the single-tier limit
[ADR-0005](../adr/0005-route-work-by-model-tier.md) says to record.

| Part | Expected tier | Model | Effort | Tokens | Elapsed |
| ---- | ------------- | ----- | ------ | ------ | ------- |
| the plan | reasoning | Opus 4.8 (main loop) | not reported | not reported | not reported |
| guardrails / convention survey | reasoning | an independent agent session (Opus 4.8) | not reported | ~121,900 | ~7 min |
| the plan review | reasoning | an independent agent session (Sonnet 5) | not reported | 79,645 | ~4 min |
| the fix | execution | Opus 4.8 (reasoning tier — single-tier limit) | not reported | not reported | not reported |
| the decay review round | reasoning | an independent agent session (Sonnet 5) | not reported | 57,647 | ~2 min |
| isolate + close-out | `—` | Opus 4.8 (main loop) | not reported | not reported | not reported |
| **Total** | | | | not reported (main-loop parts unmeasured) | not reported |
