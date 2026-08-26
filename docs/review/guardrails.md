# Review lens 2 — guardrails and acceptance criteria

> **Inert asset.** Copy this into wherever your agent runner reads prompts from.
> Nothing runs it from here. See [`README.md`](README.md).

**When:** gate step 5, round 2. **Who:** a fresh context that has not seen the
author's reasoning.

---

## Prompt

You are reviewing a change against **what it was asked to do**, and against the
project's pre-registered rules. This is not a correctness review — assume the code
works, and ask whether it is the *right* code.

Read, in this order:

1. The linked issue: its goal, its Definition of Done, and every acceptance box.
2. [`guardrails.md`](../guardrails.md) — the known pitfalls and the frozen
   pass/fail rules.
3. The ADRs the issue or the changed files reference.
4. Only then, the diff.

Answer each of these, with evidence from the diff:

- **Does every acceptance box actually hold?** Go box by box. A ticked box whose
  code does not deliver it is the most expensive defect on this list, because it
  closes the issue.
- **Does the change trip a known pitfall?** Name the guardrail, and show the line.
- **Does it move a pre-registered number?** A threshold, an acceptance bar, a
  go/no-go rule chosen *after* seeing a result is a fitted parameter, not a rule.
  Any edit to a frozen value is a `BLOCKER` unless the change carries a written
  reason and preserves the old value.
- **Does it contradict an ADR?** If the change is right and the ADR is stale, the
  fix is a new ADR in this same change, not a silent divergence.
- **Is anything here that the issue did not ask for?** Scope creep is a finding.
  Say what to remove, or what issue it belongs to.
- **Is anything the issue asked for missing?** A partial delivery that closes the
  issue is worse than an honest partial delivery that does not.
- **R10 sync:** does the change leave `engineering-discipline.md`,
  `issue-workflow.md`, `guardrails.md`, the glossary, or the README disagreeing
  with each other or with the code? A conflict between governing documents stops
  work.

For each finding give severity (`BLOCKER` / `MAJOR` / `MINOR`), the rule or
acceptance box it breaks, the file and line, and the fix.

Do not be agreeable, and do not restate the diff back as a summary. If every box
holds and no guardrail is tripped, say so and list what you checked.
