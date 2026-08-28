# T-7k3m — Generalize the solution-selection standard

Tracks [issue #53](https://github.com/pharzam/armature/issues/53). Backlog line:
[backlog.md](backlog.md).

## Why

The workflow says to prefer a proven standard, but it does not give one reusable
comparison method. It also makes solution selection look like a library decision.
The same method must guide the approach used to resolve a problem, the work plan,
the test approach, and other technical selections.

## Plan (R12 — ordered, test-first where a test applies)

1. Add one canonical solution-selection standard to
   [`engineering-discipline.md`](../engineering-discipline.md).
2. Make R3 and R12 in [`issue-workflow.md`](../issue-workflow.md) apply that standard
   to problem resolution, planning, testing, and all other technical selections.
3. Add the shared term to [`glossary.md`](../glossary.md) and expose the standard in
   the root [`README.md`](../../README.md), without repeating its criteria.
4. Run the documentation linters and search for stale or duplicated selection rules.
5. Move this card from backlog to completed and record the verdict in the landing PR.

## Definition of Done

- The selection criteria are written once in one canonical section.
- Resolving, planning, testing, and other technical selections name that standard as
  a required consideration.
- `engineering-discipline.md`, `issue-workflow.md`, `glossary.md`, and `README.md`
  agree.
- The repository discipline checks pass.

## Verdict

The discipline now has one canonical solution-selection standard. It starts with a
search for an existing public solution, gives license preference, and defines the
health, security, dependency, determinism, infrastructure, and cultural-fit
considerations. R3 applies it to problem resolution, planning, testing, and all
other technical selections. R5 and R12 link to the same standard instead of
creating separate criteria.

The glossary defines the shared term, and the root README exposes the standard.
The criteria occur only in `engineering-discipline.md`. Evidence: `adr-lint`,
`prd-lint`, all 34 discipline fixture tests, and `git diff --check` pass.
