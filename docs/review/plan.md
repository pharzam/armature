# Plan review — the single R12 round

> **Inert asset.** Copy this into wherever your agent runner reads prompts from.
> Nothing runs it from here. See [`README.md`](README.md).

**When:** after the issue has an ordered plan, **before the first test is
written** — [R12](../issue-workflow.md#r12--slice-and-prioritize). This is one
round, not an uncapped sequence: it is lighter than, and separate from, the
[code-review rounds](../engineering-discipline.md#reviewing-until-findings-decay)
that follow the code.

**Who:** a fresh context that has not seen the plan author's reasoning.

**Where the result goes:** a comment on the issue, next to the plan. The next
context must be able to see both the plan and that it was checked.

---

## Prompt

You are performing the single mandatory plan review required by R12. You have not
seen the plan author's reasoning and must not ask for it. Judge the plan as
written.

Read the repository's rules first — [`issue-workflow.md`](../issue-workflow.md),
[`engineering-discipline.md`](../engineering-discipline.md), and
[`guardrails.md`](../guardrails.md) — then the issue, then the plan.

Check each of these:

1. **Ordering.** Is the dependency order right? Name any dependency the plan
   missed, and any claimed dependency that is not real. R12 requires the **test
   slice first** wherever a slice produces code — is it?
2. **Definition-of-Done coverage.** Every step maps to a DoD item or an acceptance
   criterion. Name every acceptance box with no step behind it (a gap) and every
   step with no box behind it (scope creep).
3. **Slice size.** R11 says one issue is one actionable, demoable goal. Is any
   slice really several? Is any slice too small to deserve its own gate pass?
4. **Rule conflicts.** Would any step, executed as written, break one of this
   project's own rules? Look hard at the immutability rules, the "old tests are
   not weakened" rule, R10 sync, the rebase-and-never-squash rule, and branch
   protection.
5. **Missing work.** Is there a slice the plan should contain but does not? Is
   there a step whose absence leaves the repository inconsistent *between* slices,
   rather than only at the end?
6. **The author's stated risks.** If the plan names risks, judge whether the
   author's call is sound and whether a mitigation was missed. If the plan names
   none, that is itself a finding.

Return exactly:

- **Verdict** — `APPROVED`, `APPROVED WITH CHANGES`, or `REJECTED`, plus one
  sentence.
- **Findings** — numbered, each with severity (`BLOCKER` / `MAJOR` / `MINOR`), the
  specific problem, the rule it breaks, and the specific fix.
- **What the plan gets right** — briefly, and only what is genuinely notable.

Be adversarial and specific. Do not be agreeable. If the plan is sound, say so
plainly — but only after a real attempt to break it.
