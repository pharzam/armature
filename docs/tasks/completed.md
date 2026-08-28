# Completed

Append-only log of finished backlog tasks, most recent first.

## How to keep this file readable

**One line per task — keep it that way.** When a task in [backlog.md](backlog.md)
is done, move its line here unchanged except for a leading completion date:
`**YYYY-MM-DD** — **<ID>** — <summary> (<links>)`. Any detail worth keeping — the
design, the bugs caught, the verification story — lives in `tasks/<id>.md`, linked
as `[detail](<id>.md)`; it does **not** go inline here. This is a dated index, not
a changelog narrative. The git history and commit messages hold the blow-by-blow.

## Log

<!-- Most recent first. Example shape:
- **YYYY-MM-DD** — **‹ID›** — ‹one-sentence summary of what the task found or delivered› ([‹link›](...); [detail](‹id›.md))
-->

- **2026-08-28** — **T-6r2d** — Added a domain-free discipline-test runner (`docs/tests/run-discipline-tests.sh`) that runs the four discipline linters against `good`/`bad` fixtures and asserts exit codes, plus new `adr-lint` and `commit-msg` fixture suites; wired into the `pre-commit` hook and both CI templates. Hardened over two blind-review rounds (bad→exit-1, per-suite + global coverage floor) ([#49](https://github.com/pharzam/armature/issues/49); [detail](T-6r2d.md))
- **2026-08-26** — **T-9p4c** — Added rule R12 (slice and prioritize) to `issue-workflow.md`: decompose an issue into ordered, DoD-covering, domain-focused steps with the test slice first (TDD), each passing the gate, and the plan reviewed once and recorded on the issue; wired into the enforced-where table and the quality-gate intro ([#14](https://github.com/pharzam/armature/issues/14))
- **2026-08-26** — **T-4mk7** — Added the domain-free test-section scaffold: `docs/tests/` conventions (levels, per-level templates, security/scaling/DoD checklists, traceability, worked example), the root `tests/` drop-in, the Testing/guardrails/README rule updates, and the hook + CI placeholder wiring ([#12](https://github.com/pharzam/armature/issues/12))
