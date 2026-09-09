# 0006. Convene a panel to generate options, not to vote

Date: YYYY-MM-DD

## Status

Accepted

## Context

A proposed way of working asks a **multi-agent panel** to deliberate a complex
challenge — a novel solution, firm requirements, an implementation roadmap — and to
"iterate until it reaches a unified, robust consensus". The kit forbids the move that
last clause asks for. [When reviewers disagree](../engineering-discipline.md#when-reviewers-disagree)
says two reviewers who disagree "do not average their verdicts, and the author does
not break the tie", and an unresolvable disagreement is **recorded unresolved** rather
than manufactured into agreement. [R10](../issue-workflow.md#r10--sync-with-governance)
says a conflict between governance documents stops work until an ADR or a decision
note resolves it — which is why this is an ADR and not a prose edit.

The kit already supplies the argument the proposal is reaching for.
[Who may review](../engineering-discipline.md#who-may-review) says two agents given
the same prompt, the same context and the same model "are one reviewer run twice, and
they share every blind spot". Diverse perspective is a value the kit holds; a
consensus *verdict* is not.

## Decision

We will treat a **panel as a generator of options, not as a voter.**

For a complex challenge, a panel of *diverse* specialists may be convened to generate
and compare candidate options and their falsifiable arguments. Its output is the
**compared candidate set with the tradeoffs recorded**, which feeds
[Solution selection](../engineering-discipline.md#solution-selection) and the
[R12](../issue-workflow.md#r12--slice-and-prioritize) plan. A panel **does not vote
and does not average.** Where it does not converge, the disagreement is **recorded**,
and the escalation ladder in
[When reviewers disagree](../engineering-discipline.md#when-reviewers-disagree) runs
unchanged — that clause is left exactly as it stands. A panel of identical agents is
no panel; its members differ in domain, and which domains sit on one is the adopter's
`‹…›` marker. A panel costs model calls, so it is **required** only for the
architecturally-significant or novel decisions a project names panel-worthy — never a
step added to every task — and **optional** elsewhere, under an iteration bound set in
advance.

We reject two alternatives, recorded so neither is reopened without new information.
**A consensus verdict under a bounded protocol** — a panel that converges to one
verdict, which would amend `When reviewers disagree` to say when averaging is allowed —
reopens a clause three review rounds hardened, and trades a recorded disagreement (a
known risk) for a manufactured agreement (a false green). **Informal panels with no
rule** — rejecting the consensus requirement and writing nothing — keeps the very
diversity failure the kit already names, a panel of identical agents, with nothing in
the kit to catch it.

## Consequences

- The panel is a new **front end** to Solution selection and R12 — the generative
  steps the proposal itself points at — and it changes no verdict clause. `When
  reviewers disagree` is untouched and still stops an author from manufacturing
  agreement.
- A panel's value is **falsifiable argument**, not a tally. Nothing is mechanized: no
  check reads a panel's output, the same honesty the review sections state about their
  own claims.
- A panel is **bounded**: required only where a project says so, under an iteration
  cap, so not every task grows a panel.
- Which domains compose a panel stays the adopter's `‹…›` marker; the kit names none.
- The operative hook lives in Solution selection and R12, written first; this record
  says why.
