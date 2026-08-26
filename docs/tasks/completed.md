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

- **2026-08-26** — **T-4v7h** — Corrected three places where `AGENTS.md` contradicted the documents it summarises: R10 omitted `AGENTS.md` itself (so the file dropped the instruction that keeps it correct), R4 dropped the clause ruling an agent out as the second operator, and the glossary exemption listed only half the exempt forms — the agreement check [ADR-0004](../adr/0004-ship-a-root-agents-file.md) said a coverage-only drift check could never do ([#31](https://github.com/pharzam/armature/issues/31))
- **2026-08-26** — **T-6b3n** — Fixed three ways the new linters reported OK having checked less than they claimed — an unterminated HTML comment, an unterminated code fence, and a scan root whose Markdown git does not track — and the worst of them, `glossary-lint` answering differently inside a git hook than outside it because a hook exports `GIT_DIR`; added fixtures for each and a full fixture set for `glossary-lint`, taking the runner to 37 cases across five linters ([#29](https://github.com/pharzam/armature/issues/29))
- **2026-08-26** — **T-8j4m** — Added `backlog-lint.sh`, fixtures for it and for `adr-lint.sh`, and `docs/tests/discipline-tests.sh` — the runner that finally executes all 31 fixtures against all four repo-file linters, closing the gap where the kit had fixtures but nothing that ran them ([#19](https://github.com/pharzam/armature/issues/19))
- **2026-08-26** — **T-2f6r** — Shipped a root `AGENTS.md` (1,360 words) as the agent entry point — the gate's eight steps, R1–R12, the commit and landing rules, and the values an adopter fills — with a `CLAUDE.md` pointer, [ADR-0004](../adr/0004-ship-a-root-agents-file.md) recording the decision and its drift cost, and `AGENTS.md` added to R10's governing documents ([#17](https://github.com/pharzam/armature/issues/17))
- **2026-08-26** — **T-5w9k** — Shipped the mandated review procedures as runnable, inert assets under `docs/review/`: one prompt per review lens (correctness, guardrails, clean-and-simple, adversarial), the single R12 plan review, and a README that says how to wire them; linked from the quality gate and the README ([#18](https://github.com/pharzam/armature/issues/18))
- **2026-08-26** — **T-3q8d** — Made the "no undefined abbreviation" rule real: added `glossary-lint.sh` (table shape, duplicate and empty rows, and a row for every abbreviation in committed Markdown), defined `CLI`, `TUI`, `GUI`, and `MR` — four the kit had used undefined inside the document stating the rule — split the rule into an enforced half and a labelled aspiration, gave R4 a solo-operator form, and wired the linter into the hook and both CI templates ([#21](https://github.com/pharzam/armature/issues/21))
- **2026-08-26** — **T-7h2v** — Made the kit obey its own rules: removed the stale worktree and pruned the six merged branches, gitignored the agent-tooling and worktree directory (required by "Starting a task" but never done), and fixed the one broken relative link in the repository, in `docs/ci/tests/pr-link/README.md` ([#23](https://github.com/pharzam/armature/issues/23))
- **2026-08-26** — **T-9p4c** — Added rule R12 (slice and prioritize) to `issue-workflow.md`: decompose an issue into ordered, DoD-covering, domain-focused steps with the test slice first (TDD), each passing the gate, and the plan reviewed once and recorded on the issue; wired into the enforced-where table and the quality-gate intro ([#14](https://github.com/pharzam/armature/issues/14))
- **2026-08-26** — **T-4mk7** — Added the domain-free test-section scaffold: `docs/tests/` conventions (levels, per-level templates, security/scaling/DoD checklists, traceability, worked example), the root `tests/` drop-in, the Testing/guardrails/README rule updates, and the hook + CI placeholder wiring ([#12](https://github.com/pharzam/armature/issues/12))
