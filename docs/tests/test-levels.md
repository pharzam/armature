# Test levels

The fixed ladder of test kinds this project uses, from the cheapest and most
local to the most expensive and most whole-system. It is the reference the rest
of the [test section](README.md) points at: every template and checklist here
names one of these levels. This document is domain-free — it defines the levels
and where they run, and leaves every concrete command as a `‹…›` placeholder for
the adopter to fill.

> **How to adapt this file.** The level *definitions* are the reusable content —
> keep them. Replace each `‹…›` placeholder with your stack's real command, and
> delete a level you genuinely do not use (most projects use all four). Do not
> name a language, framework, or runner here; the command placeholders are the
> only place a tool name belongs, and only once you fill them in your own copy.
> Delete this note once your commands are in.

## In plain terms

> A test is only useful if you know what it proves and how much it costs to run.
> This project sorts its tests into four kinds and runs the cheap ones on every
> commit and the expensive ones in the shared pipeline, so a broken change is
> caught in seconds locally and confirmed thoroughly before it merges.

## The ladder — cheap first

The levels are ordered so a failure stops the expensive work early. A change runs
the cheap levels in the [commit hook](../engineering-discipline.md#git-hooks) for
fast local feedback, and the whole ladder in
[CI](../engineering-discipline.md#continuous-integration-optional) as the
authority.

| Level | Proves | Scope | Speed | Runs in |
|-------|--------|-------|-------|---------|
| 1. Unit | one component behaves | one function/class/module, dependencies stubbed | fastest | hook + CI |
| 2. Integration | components work together | two or more units across a real seam | medium | hook (subset) + CI |
| 3. End-to-end (E2E) | a whole user path works | the running system, front to back | slowest | CI (optionally a smoke subset in the hook) |
| Discipline | the process stays honest | repo files, no product toolchain | fast | hook + CI |

The three numbered rungs — unit, integration, end-to-end — are the **product-test
levels** you tag by level and run cheap-first. **Discipline** tests are a separate,
process-level track (they lint the repo's own conventions); the table lists them for
the full picture, but they are not one of the tagged product levels.

## 1. Unit tests

A unit test exercises **one component in isolation** — the smallest piece of
behaviour that stands on its own — with its dependencies replaced by stand-ins.
When it fails, the fault is in that one component, not somewhere across a chain.
Unit tests touch no file, network, or clock, so they are fast and deterministic
and run first, on every commit.

- **Command:** `‹unit test command›`
- **Where:** the commit hook and CI.
- **Rule:** every component has at least one unit test (see
  [`template-unit.md`](template-unit.md)).

## 2. Integration tests

An integration test proves that **two or more components work together across a
real interface or workflow** — the seams a unit test stubs out. It uses the real
collaborator (a real datastore, a real adapter) rather than a stand-in, so it is
slower than a unit test and runs after it.

- **Command:** `‹integration test command›`
- **Where:** CI in full; a fast subset may run in the hook.
- **Rule:** every interface or workflow has an integration test (see
  [`template-integration.md`](template-integration.md)).

## 3. End-to-end (E2E) tests

An E2E test walks a **whole user-facing path through the running system**, front
to back, the way a real user or caller would. It is the most expensive automated
level, so it usually runs in CI rather than the commit hook; a tiny smoke subset
may run locally to prove the wiring.

- **Command:** `‹end-to-end test command›`
- **Timeout:** `‹test timeout›` — an E2E test that hangs must fail, not stall the
  pipeline.
- **Where:** CI (optionally a smoke subset in the hook).
- **Rule:** every user-facing scenario has an E2E test (see
  [`template-e2e.md`](template-e2e.md)).

**User acceptance (UAT) is a human layer on top of E2E.** A
[UAT](template-uat.md) scenario checks the *same* path a person cares about, but
a human runs or signs it off against plain Given/When/Then steps. It is judged by
a person, not asserted by a command, so it is not a rung of the automated ladder
— it is the acceptance step that rides on the E2E path.

## Discipline tests

A discipline test lints the **process rather than the product**: it checks the
repo's own conventions and needs no product toolchain, so it can be the project's
first test, before any product code exists. The kit ships five:
[`adr-lint.sh`](../adr/adr-lint.sh), [`prd-lint.sh`](../prd/prd-lint.sh),
[`glossary-lint.sh`](../glossary-lint.sh), and
[`backlog-lint.sh`](../tasks/backlog-lint.sh) read repo files and run in both the
hook and CI, while
[`pr-link-lint.sh`](../ci/pr-link-lint.sh) reads the pull-request body — a forge
artifact absent at commit time — so it runs in CI only. Add one whenever a
convention is worth enforcing by machine rather than by review.

## Security tests sit alongside the ladder

Security checks are not a fourth rung but a parallel track that runs at hook and
CI time — a secret scan, a dependency scan, and static analysis at minimum. They
have their own command placeholder and their own checklist:

- **Command:** `‹security test command›` runs the scans — a fast subset in the
  [hook](../../.githooks/pre-commit), the full set in [CI](../ci/) — and
  `‹security scanner›` names the tool it drives.
- **Checklist:** [`security-checklist.md`](security-checklist.md).

## The placeholders this section uses

Fill these once, in your own copy, and every template here inherits them:

| Placeholder | Meaning |
|-------------|---------|
| `‹unit test command›` | Run the unit level. |
| `‹integration test command›` | Run the integration level. |
| `‹end-to-end test command›` | Run the E2E level. |
| `‹security test command›` | Run the security scan step. |
| `‹test timeout›` | The per-test (or per-suite) time limit before a hang is a failure. |
| `‹test directory›` | Where product tests live — the root [`tests/`](../../tests/) drop-in, or your stack's convention. |
| `‹security scanner›` | The tool that runs the security checks (secret scan, dependency scan, static analysis). |
