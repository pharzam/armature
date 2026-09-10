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

_Filled at close-out._

## Resource record

_Filled at close-out._
