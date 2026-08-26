# Test section

The project's **testing conventions** — the kinds of test, the patterns to write
them, the checklists that keep them honest, and the traceability that ties each
test to the thing it proves. It is a domain-free scaffold: every document here is
a template with `‹…›` placeholders, and no language, framework, or test runner is
named. You adapt it to your stack, then grow it.

This section holds the *conventions*. The product tests themselves live in the
root [`tests/`](../../tests/) directory (or your stack's own layout). Armature
ships no product tests — only these patterns for an adopter to fill.

> **How to adapt this section.** Do three things, then delete this note.
> 1. **Fill the placeholders.** Replace every `‹…›` command in
>    [`test-levels.md`](test-levels.md) with your stack's real command
>    (`‹unit test command›`, `‹integration test command›`, and so on). That file
>    is the one place the commands are defined; the templates inherit them.
> 2. **Wire enforcement.** Fill the matching `‹…›` steps in the
>    [`pre-commit` hook](../../.githooks/pre-commit) and the [CI templates](../ci/),
>    including the `‹security scanner›` step — see
>    [Enforcement](#enforcement-hook--ci) below.
> 3. **Adopt the patterns.** Copy a `template-*.md` pattern for each new test, and
>    add a [traceability](traceability-template.md) row so every test names what it
>    proves. Delete a document you genuinely do not use.

## In plain terms

> This folder tells you how to test on this project: what the four kinds of test
> are, how to write each one, what to check before you trust a test suite, and how
> to prove that every requirement has a test behind it. It does not run any tests
> itself — it is the rulebook your real tests follow.

## What's here

| Document | What it holds |
|----------|---------------|
| [`test-levels.md`](test-levels.md) | The four test kinds — unit, integration, end-to-end (E2E), discipline — and where each runs. The reference the rest point at. |
| [`template-unit.md`](template-unit.md) | Generic unit-test pattern + checklist. |
| [`template-integration.md`](template-integration.md) | Generic integration-test pattern + checklist. |
| [`template-e2e.md`](template-e2e.md) | Generic end-to-end-test pattern + checklist. |
| [`template-uat.md`](template-uat.md) | User-acceptance-test (UAT) scenario pattern (human sign-off). |
| [`security-checklist.md`](security-checklist.md) | Security-weakness checks — secret scan, dependency scan, static analysis at minimum. |
| [`scaling-checklist.md`](scaling-checklist.md) | Rules that keep a test suite fast and stable as the project grows. |
| [`dod-checklist.md`](dod-checklist.md) | How to verify every Definition of Done (DoD) item has test coverage. |
| [`traceability-template.md`](traceability-template.md) | The format linking a test to a requirement, guardrail, or ADR. |
| [`example-fact-to-test.md`](example-fact-to-test.md) | A worked path: fact → requirement → guardrail → test, in kit conventions. |

## How the pieces fit

1. **[`test-levels.md`](test-levels.md)** defines the ladder and the command
   placeholders. Read it first.
2. The **`template-*.md`** documents give you a pattern per level to copy for each
   new test.
3. The **checklists** — [security](security-checklist.md),
   [scaling](scaling-checklist.md), [DoD](dod-checklist.md) — are the gates you run
   a suite against.
4. **[`traceability-template.md`](traceability-template.md)** ties each test back
   to the requirement, guardrail, or ADR it proves, and
   **[`example-fact-to-test.md`](example-fact-to-test.md)** walks the whole line
   once, end to end.

## Enforcement (hook + CI)

The test section is only as real as what runs it. The command placeholders are
wired, cheap-first, into two layers:

- The [`pre-commit` hook](../../.githooks/pre-commit) runs the cheap levels (unit,
  then integration) and a fast security step before a commit is recorded.
- The [CI templates](../ci/) run the whole ladder plus the long-running checks —
  E2E and the full [security scan](security-checklist.md) behind `‹security scanner›`.

Both are inert until you fill the `‹…›` steps for your stack. This mirrors how the
[ADR and PRD linters](../engineering-discipline.md#testing) are already wired.

## The rules behind this section

The written rules these documents implement live in
[`engineering-discipline.md`](../engineering-discipline.md#testing) (the Testing
section — coverage, the test-freeze and conflict rules, scaling) and
[`guardrails.md`](../guardrails.md) (the testing pitfalls). This section is the
how-to; those are the must.
