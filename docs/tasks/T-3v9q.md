# T-3v9q — Record two external audits of the kit

Tracks [issue #55](https://github.com/pharzam/armature/issues/55). Backlog line:
[backlog.md](backlog.md).

## In plain terms

> Two audits were run against this kit on 2026-08-28. Forty-three of their
> forty-four claims are true. Almost none of them is new. Most were already
> written up in the twenty-three issues this repository closed as `NOT_PLANNED`,
> and two of the fixes both audits now recommend — a root agent entry file and a
> glossary linter — were shipped once and then removed. An `Accepted` decision
> record went with them, and nothing says why. The audits are accurate about the
> kit and wrong about how bad it is: after an adversarial second pass, nothing
> survives at critical or high severity.

## Why

Two reports were produced against commit `b684a96`:

| Report | Measured against | Shape |
| ------ | ---------------- | ----- |
| A | Karpathy, *How I Use LLMs* | 7 findings, 2 proposed linters |
| B | Robert C. Martin on fundamentals with AI | 10 recommendations, ranked by value against prose added |

Both are machine-generated. Neither is a customer record, so neither belongs in
[`facts/`](../facts/), which is defined for the customer's own words. This file is
the record instead.

Every claim was re-run against a scratch copy before it entered this file. The six
checks report B calls untested were re-broken one at a time, and the discipline
suite was re-run after each. Nothing here is taken on a report's word.

**Verification result.** 43 of 44 claims stand — 29 as written, 14 with a
correction to the detail. One is refuted. Severity after the adversarial pass:
7 medium, 30 low, 7 describe no defect.

## Plan (R12 — ordered, test-first where a test applies)

1. **Test slice.** The covering tests are the discipline linters themselves:
   `adr-lint`, `prd-lint`, and `run-discipline-tests.sh`. They must stay green
   across this change. This record adds no executable code, so it adds no new
   fixture.
2. **Glossary slice.** The abbreviation rule
   ([engineering-discipline.md](../engineering-discipline.md#glossary)) binds this
   file the moment it names an abbreviation. Add the missing rows first.
3. **Record slice.** This file.
4. **Schedule slice.** One line per follow-up under **Next** in
   [backlog.md](backlog.md), each naming the closed issue it revives.

## Definition of Done

| # | Item | Covered by |
| - | ---- | ---------- |
| 1 | All 44 claims recorded with a verdict | this file, Findings |
| 2 | Every standing claim cites a file and a line | this file, Findings |
| 3 | Every claim the reports got wrong carries the correction | this file, Corrections |
| 4 | Every finding an already-closed issue covers names that issue | this file, Already recorded |
| 5 | Each follow-up is one line under **Next** with a stable ID | [backlog.md](backlog.md) |
| 6 | Every abbreviation used has a glossary row | [glossary.md](../glossary.md) |
| 7 | The gate stays green | `run-discipline-tests.sh`, `adr-lint`, `prd-lint` |

## Findings

Verdicts are after an adversarial second pass. `Stands` means the substance held
under attack. `Corrected` means it held but a detail was wrong. `Refuted` means it
did not hold.

### The linters — the kit's only executable surface

| ID | Finding | Verdict | Sev |
| -- | ------- | ------- | --- |
| M1 | The duplicate-ADR-number check has no fixture. Gut it and the suite still prints `34 passed, 0 failed`. | Stands | medium |
| M2 | The ADR title-line check has no fixture. The check is `adr-lint.sh:93-95`, not one line. | Corrected | low |
| M3 | The `Date:` line check has no fixture. | Stands | low |
| M4 | The missing `## Status` check has no fixture. | Stands | medium |
| M5 | The PRD "requirement missing from the matrix" check has no fixture. | Stands | medium |
| M6 | No fixture pipes a body into `pr-link-lint.sh`, and production runs it only that way. | Stands | medium |
| M7 | Deleting a fixture root makes the runner exit 0. It prints `skip`, so it is not silent, but the gate accepts it. | Corrected | low |
| A1 | A trailing slash on the `adr-lint.sh` directory argument silences the cross-link check. The failure is a false negative: the warning can never fire. | Stands | low |
| A2 | `run-discipline-tests.sh:108` globs `"$2"/*/`, so the harness always supplies that slash. | Corrected | low |
| A3 | The README row status is never compared to the record. `adr-lint.sh:131` is a bare filename match. It also accepts `Superseded by ADR-0007` when ADR-0007 does not exist. | Stands | low |
| A4 | `docs/facts/` has filename, header, status and index conventions, and no linter checks any of them. | Stands | low |
| F1 | `prd-lint.sh:81` truncates a citation with `substr(...,1,6)`. `F-0001#99` passes. | Stands | low |
| F2 | The kit does promise the anchor resolves to a numbered fact, so the gap is against a stated promise. | Corrected | low |
| F3 | `#99` is genuinely out of range in the sample. | Stands | none |
| F4 | Nothing else validates the anchor. | Stands | none |
| P1 | The workflow pipes on standard input; every fixture passes a file. | Corrected | low |
| P2 | The two paths do **not** diverge. They converge at `pr-link-lint.sh:45`. | Refuted | none |
| P3 | `pre-push` is 38 lines of untested branching that fails open if the protected-branch string is edited. | Stands | low |
| P4 | Nine `commit-msg` fixtures exist. They cover 3 of 10 types and 1 of 5 exempt prefixes. | Stands | none |

**M6 and P1, stated honestly.** Report B calls the standard-input path its
sharpest finding and says the branch that runs in continuous integration has zero
coverage. That overstates it. The exclusive code is one statement, `body=$(cat)`
at `pr-link-lint.sh:43`; the file path has two exclusive lines of its own, equally
untested; everything below line 45 is shared and fully exercised. The gap is real
but small. What makes it worth fixing is not size: a fail-open mutant —
`cat >/dev/null; body="Closes #1"` — survives the suite with
`34 passed, 0 failed` and silently disables R1 enforcement for every pull request.
One piped fixture kills it.

### The kit against its own rules

| ID | Finding | Verdict | Sev |
| -- | ------- | ------- | --- |
| S1a | "Two hooks ship with the kit" at `engineering-discipline.md:454`; three ship. `README.md:54` repeats it. `.githooks/README.md:22-26` gets it right. | Corrected | low |
| S1b | The gate document never names `pre-push` or the discipline runner. `.githooks/README.md:24` omits the runner too. | Stands | low |
| S1c | `engineering-discipline.md:515` calls the worktree directory gitignored. `.gitignore` is two lines and covers only `.obsidian/`. | Corrected | medium |
| S1d | `docs/ci/tests/pr-link/README.md:3` is the one broken relative link in 77 files. | Stands | low |
| S1e | `LICENSE` reads `Copyright (c) 2026 Farzam`, carries no `‹` marker, and no document references it at all. | Corrected | low |
| S2a | The abbreviation rule binds all operators and is "not optional". `CLI`, `TUI` and `GUI` sit in rule text at `engineering-discipline.md:116-117` with no glossary row. | Stands | low |
| S2b | "Fresh context" is undefined, used six times, once inside another glossary entry. | Stands | low |
| S2c | `completed.md` states one line per task. Its bullets run 536, 476, 389 and 359 characters. | Corrected | low |
| S2d | The "what is enforced where" table omits the abbreviation rule. R2, R3, R4, R6, R7, R9 and R11 are absent from it too. | Stands | low |
| S2e | The rule binds "any conversation, context, prompt, reply, or response", which reaches a read-only turn that changes nothing. | Corrected | low |
| S2f | The reading path before a first commit is 645 lines, not 608. The broken "short sections" promise is `engineering-discipline.md:7`, not the README. | Corrected | low |

### Dependencies and hygiene

| ID | Finding | Verdict | Sev |
| -- | ------- | ------- | --- |
| D1 | The security checklist names dependency scanning as a minimum check. | Stands | none |
| D2 | Actions float on mutable tags. The real scope is **13** unpinned references, not 2, and `docs/ci/gitlab-ci.yml` floats on `alpine:3` in four jobs. No Dependabot configuration. | Corrected | low |
| D3 | Pinning is already recorded — but only inside `T-2w8k.md:74`, a card already moved to `completed.md`. It never became a backlog line. | Stands | none |
| D4 | The repository description says "Fork it as a template", against `README.md:67` and `:80`. Fork and template are different operations on this forge. | Stands | low |
| D5 | **Eight** stale remote branches, not six. Two are merged and undeleted; six are abandoned. The kit has no written rule about remote branches — its rule covers local worktrees. | Corrected | low |

### The agent operator

| ID | Finding | Verdict | Sev |
| -- | ------- | ------- | --- |
| K1 | The rules bind "each LLM coding agent", and only R5 and R6 are model-specific. No rule says when to start a fresh session. But R6, R7, R9 and ADR-0003 are all built on context not surviving a session, so the premise is present without the vocabulary. | Corrected | low |
| K2 | The solution-selection standard asks for licenses, project health, advisories and deprecation signals, and never asks where a claim was checked, or when. | Stands | low |
| K3 | Layer 1 is called evidence and is immutable, and the provenance header has no capture-method row and no verified-against-original row. The header has six rows, not four, and an optional capture-notes section exists but can be deleted. Meetings and calls leave nothing to check against. | Corrected | medium |
| K4 | Review rounds require a fresh reviewer, not a different model. R9 names "another agent or session" as sufficient. The kit says "different model" nowhere. | Stands | medium |
| K5 | `guardrails.md` ships a filled testing-pitfalls block and no equivalent for model pitfalls. No rule requires one, so this is an enhancement. | Stands | low |
| K6 | No agent entry file. The kit's own pattern is to ship tool-specific files inert under `docs/templates/`, so that is where one belongs. | Stands | low |
| K7 | No numeric quality bar: zero hits for complexity, cyclomatic, mutation, mutant, CRAP. **But the coverage placeholder does exist** — `issue-workflow.md:171` reserves `‹add a coverage gate›`. Report B's premise for its coverage recommendation is wrong. | Corrected | low |
| K8 | "Substantive task" is undefined at 3 sites. Adoption markers number **350**, not 297, and one `‹` is unclosed. | Corrected | low |
| K9 | The reports disagree on scale. Both are right: 76 files before `T-7k3m.md` landed, 77 after; 3 files named `*-lint.sh`, 4 discipline linters counting the `commit-msg` hook. Neither stated its counting rule. | Stands | none |

## What neither report found

These came out of the verification, not the reports. They are the reason this
record matters more than the list above.

**X1 — the R8 template difference is not a defect.** Report B lists it as a
self-violation: the issue template says tests "pass (R8)", the pull-request
template says they "fail against the old code (R8)". That is R8's two halves. An
issue is written before any test exists, so it can only assert the green half; a
pull request is read afterwards, so it asserts the red half. The pull-request
template also pulls in the issue boxes at line 15, so nothing is lost. Making the
two lines match would delete the red-half check. **Do not fix this.**

**X2 — 23 issues were closed `NOT_PLANNED`, and they already hold most of this.**
Of 33 closed issues, 23 carry that reason.
[#16](https://github.com/pharzam/armature/issues/16) is an earlier audit of this
same kit. The mapping is in the next section. Report B quotes "the rules you throw
away are the ones you will pick up off the floor in a year" and then measures it in
prose drift. The measurement was in the issue tracker the whole time.

**X3 — an `Accepted` decision record was removed from the default branch.**
`origin/backup/pre-r12-reset-999765f` carries
`docs/adr/0004-ship-a-root-agents-file.md`, status `Accepted`, dated 2026-08-26.
`origin/main` has no ADR-0004 at all. Separately, `origin/archive/issue-16`
carries a *different* `0004-destroying-history-on-the-default-branch.md`. So the
number records two decisions on two branches and none on `main`.
[`adr/README.md:20`](../adr/README.md) says everything but a status change "stays
immutable", and IDs are assigned once and never renumbered. `adr-lint` cannot see
this, because it only ever reads one branch.

**X4 — two of the things the reports recommend building already existed.** The
pre-reset branch holds 124 files against the 105 on `main`. Gone from `main`:
`AGENTS.md`, `CLAUDE.md`, `docs/glossary-lint.sh` with six fixture directories,
`docs/tasks/backlog-lint.sh` with seven, and the six files of `docs/review/`.
Report A's headline recommendation is a glossary linter. Report B's R5 is an agent
entry file. Both were shipped, then removed.

**X5 — the main checkout sits on a merged branch.** The worktree list shows
`~/projects/armature` on `docs/T-53-solution-selection`, whose pull request #54 is
merged. `engineering-discipline.md:511-512` says never work on the operator's main
worktree.

**X6 — the production linter run is vacuous.** `docs/facts/` holds no `F-*.md` and
`docs/prd/` holds no `PRD-*.md`, so `sh docs/prd/prd-lint.sh` exits early at
`prd-lint.sh:51-53` and prints `OK` without checking anything. Every piece of
evidence that the linters work comes from fixtures. That is acceptable, and it is
worth knowing when reading a green gate.

## Already recorded — finding to abandoned issue

Triage these before writing anything new. R2 requires it.

| Findings here | Already written up in |
| ------------- | --------------------- |
| M1–M5, A3 | [#45](https://github.com/pharzam/armature/issues/45) — ten record shapes `adr-lint` approves |
| M7, A2 | [#37](https://github.com/pharzam/armature/issues/37) — the runner asserts the exit code, never the reason |
| A2 | [#41](https://github.com/pharzam/armature/issues/41) item 8 — the cross-link check cannot fire in a fixture |
| S1a, S1b | [#40](https://github.com/pharzam/armature/issues/40) — six shipped statements are not true of `main` |
| S1c, D5 | [#23](https://github.com/pharzam/armature/issues/23) — remove the stale worktree, prune branches, ignore the worktree dir |
| S2e, K4 | [#21](https://github.com/pharzam/armature/issues/21) — rescope the two rules the kit cannot enforce |
| K6, X3, X4 | [#17](https://github.com/pharzam/armature/issues/17) — ship a root agent file; [#19](https://github.com/pharzam/armature/issues/19) — its drift check |
| S2d | [#46](https://github.com/pharzam/armature/issues/46) — statements still saying R1–R11 |
| The whole shape | [#16](https://github.com/pharzam/armature/issues/16) — the earlier audit |

## Corrections to the reports

Recorded so nobody derives them a second time.

- `engineering-discipline.md:454`, not `:417`, holds the two-hooks sentence.
- The reading path is 645 lines, not 608. It grew when `T-7k3m` landed.
- `completed.md` bullets are 536, 476, 389 and 359 characters. The reported
  540/482/393/363 are byte counts, and "the two most recent" is now stale.
- 13 unpinned action references, not 2. The token is `pull-requests: read`, not a
  broad grant.
- 8 stale remote branches, not 6.
- 350 adoption markers, not 297.
- A coverage placeholder **does** exist at `issue-workflow.md:171`.
- 77 markdown files; 3 files named `*-lint.sh`; 4 discipline linters.
- The standard-input gap is one statement, not a whole branch.
- The R8 template difference is intentional. See X1.

## Out of scope (follow-ups)

Scheduled under **Next** in [backlog.md](backlog.md): `T-5h8n`, `T-2q7d`,
`T-8b4r`, `T-6f3w`, `T-9c5t`, `T-4x2k`, `T-7m6s`, `T-3d9v`. Each names the closed
issue it revives. None is started by this task.

One fix does land here, because the kit's own rule forces it: this file names
`CLI`, `TUI` and `GUI`, so the abbreviation rule requires their glossary rows in
the same change. Finding S2a is therefore closed by this task, not deferred.

## Verdict

Written at close-out.
