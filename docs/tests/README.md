# Test section

The project's **testing conventions** — the kinds of test, the patterns to write
them, the checklists that keep them honest, and the traceability that ties each
test to the thing it proves. It is a domain-free scaffold: every document here is
a template with `‹…›` placeholders, and no language, framework, or test runner is
named. You adapt it to your stack, then grow it.

This section is mostly *conventions*, plus two executable exceptions:
[`run-discipline-tests.sh`](run-discipline-tests.sh), which runs the kit's own
discipline linters against their fixtures (see
[The discipline self-tests](#the-discipline-self-tests) below), and
[`nested-checkout-check.sh`](nested-checkout-check.sh), which proves two of those
linters read this repository's files and not a nested checkout's. The *product*
tests themselves live in the root [`tests/`](../../tests/) directory (or your
stack's own layout); Armature ships no product tests — only these patterns for an
adopter to fill. The discipline self-tests are the exceptions because their subject
— the kit's linters — ships with the kit, so their tests can too.

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
> to prove that every requirement has a test behind it. It is mostly the rulebook
> your real product tests follow; the two things here that actually run are
> `run-discipline-tests.sh` and `nested-checkout-check.sh`, which test the kit's
> own linters.

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
| [`run-discipline-tests.sh`](run-discipline-tests.sh) | One of the two executables here: runs each discipline linter against its good/bad fixtures and asserts the outcome. |
| [`nested-checkout-check.sh`](nested-checkout-check.sh) | The other: builds a throwaway repository holding a nested checkout and proves `audit-record-lint` and `link-lint` never read it. Needs `git`, so CI runs it and the hook does not. |

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

## The discipline self-tests

The kit's [discipline tests](test-levels.md#discipline-tests) — `adr-lint`,
`prd-lint`, `agents-lint`, `audit-record-lint`, `pr-link-lint`, and the
`commit-msg` hook — are themselves tested.
Each ships with a fixture suite (a `good` case and one or more `bad-*` cases), and
[`run-discipline-tests.sh`](run-discipline-tests.sh) runs every case and asserts
the exit code by a simple naming convention:

- a fixture whose name starts with `good…` must be **accepted** (exit 0);
- a fixture whose name starts with `bad…` must be **rejected** (exit 1 — the
  linters' "one or more violations" code, so a crashed linter is caught, not
  mistaken for a rejection).

The linters already self-lint the *real* repo green in the hook and CI; the runner
does the complementary job — it proves each linter correctly *rejects* bad input,
not just that it passes the kit's own clean files. It dispatches per suite
(`adr-lint`, `prd-lint`, `audit-record-lint` and `agents-lint` take a fixture
directory, `pr-link-lint`/`commit-msg` take a file), skips entries that are neither
`good*` nor `bad*` (the shared `prd/tests/facts/`
directory, a suite `README.md`), and skips a suite whose linter or fixtures are
absent — so a slimmed adopter kit still runs green.

A test that never runs proves nothing, so the runner also enforces a **coverage
floor**: every *present* suite must keep at least one `good` and one `bad` fixture,
and at least one case must run overall. That turns a silently-disabled suite —
fixtures emptied, or renamed out of the `good*`/`bad*` convention — into a red
rather than a green with no coverage. (It does not police the exact count, so keep
fixture names within the convention; each suite's `README.md` lists the cases it
expects.)

It reads only text and needs no toolchain. Run it directly with
`sh docs/tests/run-discipline-tests.sh` (add `-v` for an `ok` line per case); it
also runs in the [`pre-commit` hook](../../.githooks/pre-commit) and in [CI](../ci/).
Add a fixture when you add or tighten a linter rule.

## Enforcement (hook + CI)

The test section is only as real as what runs it. The command placeholders are
wired, cheap-first, into two layers:

- The [`pre-commit` hook](../../.githooks/pre-commit) runs the cheap levels (unit,
  then integration, and optionally an end-to-end smoke subset) and a fast security
  step before a commit is recorded.
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
