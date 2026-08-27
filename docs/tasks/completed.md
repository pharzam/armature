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

- **2026-08-27** — **T-7d2x** — Added ADR-0004: history on the default branch may be destroyed only under five conditions, one of which is a second operator who is a person, with repair carved out and the forge's surviving pull-request references named — so rotation, not deletion, ends a credential exposure ([#43](https://github.com/pharzam/armature/issues/43); [detail](t-7d2x.md))
- **2026-08-26** — **T-9p4c** — Added rule R12 (slice and prioritize) to `issue-workflow.md`: decompose an issue into ordered, DoD-covering, domain-focused steps with the test slice first (TDD), each passing the gate, and the plan reviewed once and recorded on the issue; wired into the enforced-where table and the quality-gate intro ([#14](https://github.com/pharzam/armature/issues/14))
- **2026-08-26** — **T-4mk7** — Added the domain-free test-section scaffold: `docs/tests/` conventions (levels, per-level templates, security/scaling/DoD checklists, traceability, worked example), the root `tests/` drop-in, the Testing/guardrails/README rule updates, and the hook + CI placeholder wiring ([#12](https://github.com/pharzam/armature/issues/12))
