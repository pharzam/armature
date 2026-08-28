# #19 — Add the AGENTS.md drift check

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:35Z.*

---

Part of #16.

## Goal

Turn three written-rule-only conventions into discipline tests, and test the linters themselves.

The audit in #16 found that the kit ships ~20,000 words of prose and three small scripts, while R5 tells it to prefer a machine check. It also found that `adr-lint.sh` and `prd-lint.sh` have **no tests of their own** — which is the kit's own "a test that passes for the wrong reason" pitfall, in the kit's own gate.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16. Depends on #5-scope work and the `AGENTS.md` slice landing first.

## Solution note (R3)

- **Chosen:** extend the existing pattern — POSIX shell, no toolchain, green on a fresh kit, wired into the hook and CI. Add a self-test harness with fixtures that covers the **existing** linters as well as the new ones.
- **Rejected:** *a test framework* — needs a toolchain the kit refuses to assume, and would stop the linters being the project's first tests. *New linters with no self-tests* — repeats the defect this slice exists to fix.
- **Decision record:** this issue.

## Acceptance criteria

Some of these boxes were satisfied by pull requests that merged in tranche 1 while
this issue stayed open. **Each such box names the pull request that delivered it,
inline.** A summary list of box numbers used to stand here; it was wrong within the
hour — inserting the commit-ID box renumbered the ones after it — so it is deleted
rather than corrected. A second copy of a fact is a second copy to keep in step. Their evidence is recorded in the "What tranche 1
already satisfied" comment below, and each box names the pull request that
delivered it. **The boxes are ticked in this issue's landing pull request, not
before** — gate step 8 puts the ticking in the closing pull request, and an
acceptance box ticked outside one claims a close-out that has not happened.

- [ ] `backlog-lint` enforces the one-line-per-task rule, and that a task ID is
      present, bracketed, unique, and never in both files. **Reworded:** the
      original box said "the stable-ID *shape*". The linter deliberately does not
      check the shape, because the `‹task-ID scheme›` is the adopter's choice — the
      reason is written in the script itself. The box now says what is enforced.
      ([#28](https://github.com/pharzam/armature/pull/28))
- [ ] `glossary-lint` enforces the table shape, and finds duplicate or empty rows.
      ([#25](https://github.com/pharzam/armature/pull/25))
- [ ] A drift check confirms `AGENTS.md` covers every gate step and every R-number.
- [ ] A commit-subject task-ID cross-check: an ID in a commit subject exists in
      `backlog.md` or `completed.md`. **Added.** It is the third item of #16 §3
      ("New discipline tests") and it reached no child issue when this one was
      written — found by the R12 plan review of tranche 2.
- [ ] A self-test harness runs every discipline linter against known-bad fixtures and asserts a non-zero exit, and against the clean repo and asserts zero.
      ([#28](https://github.com/pharzam/armature/pull/28), extended to 37 cases by
      [#30](https://github.com/pharzam/armature/pull/30))
- [ ] All of it is wired into `.githooks/pre-commit` and the CI templates.
      ([#25](https://github.com/pharzam/armature/pull/25),
      [#28](https://github.com/pharzam/armature/pull/28)) — the two new checks join
      the same wiring.
- [ ] The "What is enforced where" table in `issue-workflow.md` is updated honestly.
      ([#25](https://github.com/pharzam/armature/pull/25),
      [#28](https://github.com/pharzam/armature/pull/28)) — the two new checks add
      their own rows.
- [ ] The task line moves from backlog to completed in the same PR.







---

### Comment — pharzam — 2026-08-26T15:00:55Z

**Correction to this issue's premise, found while planning.**

I wrote that the linters have no tests. That is wrong for one of the three, and the detail changes what this slice should build.

The real state:

| Linter | Fixtures | Automated runner |
| ------ | -------- | ---------------- |
| `pr-link-lint.sh` | **Yes** — 10 fixtures under `docs/ci/tests/pr-link/`, with an expected-result table in its README | **No** — the README tells a human to run them one at a time |
| `adr-lint.sh` | No | No |
| `prd-lint.sh` | No | No |

So the kit already **has** a fixture convention: `docs/<area>/tests/<linter>/`, one file per case, named `good-*` / `bad-*`, documented in a per-directory README with an expected-exit table. T-4mk7 established it and it is a good convention.

**What changes in this slice:**

1. Follow the existing convention rather than invent a location. New fixtures go in `docs/adr/tests/adr-lint/` and `docs/prd/tests/prd-lint/`.
2. The gap is not "no fixtures", it is **no runner**. Ten good fixtures that a human must run one at a time are not a gate — nothing fails a commit when one regresses. Build one runner that walks every fixture directory, asserts the expected exit status, and reports.
3. The runner covers `pr-link-lint` too, so its ten existing fixtures finally run automatically.

This makes the slice smaller and better founded than the issue first described.


---

### Comment — pharzam — 2026-08-26T16:02:12Z

**Scope reduced.** `glossary-lint.sh` moves to #21, which must ship it: that issue rescopes the abbreviation rule to say one half is *enforced*, and the word is only true once the linter exists. The two are one change. See the reasoning on #21.

This issue keeps: `backlog-lint.sh`, the `AGENTS.md` drift check, and the fixture runner that self-tests every discipline linter (including the two that ship today and the one #21 adds).


---

### Comment — pharzam — 2026-08-26T16:18:43Z

**Most of this landed in #28.** Remaining scope, and why each piece was left:

**1. `glossary-lint` fixtures.** Its interface takes two arguments — the glossary and the scan root — while `discipline-tests.sh` passes one. Making it fit would have meant changing the linter to suit its test, which is the wrong direction. Options for whoever picks this up:
   - give the runner a per-linter invocation form (a second manifest column), or
   - give `glossary-lint` a single-directory mode that infers both paths from one root.

The second is cleaner and matches every other linter's shape.

**2. The `AGENTS.md` drift check.** Assert that `AGENTS.md` names every gate step and every `R<N>`. [ADR-0004](docs/adr/0004-ship-a-root-agents-file.md) already states its limit in writing: **it tests coverage, not agreement.** It can prove `AGENTS.md` mentions R9; it cannot prove that what it says about R9 is still true. Do not let the check's existence imply more than it delivers.

**What shipped:** `backlog-lint.sh` + 6 fixtures, 6 `adr-lint` fixtures, and `discipline-tests.sh` running **31 fixtures across 4 linters**, wired into the hook and both CI templates. The runner was proved in both directions by breaking a linter on purpose, and it fails loudly if zero cases run.


---

### Comment — pharzam — 2026-08-26T16:28:57Z

**`glossary-lint` fixtures landed in #30**, along with the single-directory mode that lets the runner drive it — the option this issue recommended. The runner now covers **37 cases across five linters**.

Remaining scope is one item: the `AGENTS.md` drift check. [ADR-0004](docs/adr/0004-ship-a-root-agents-file.md) already states its limit in writing — it tests **coverage, not agreement**. It can prove `AGENTS.md` mentions R9; it cannot prove that what it says about R9 is still true.


---

### Comment — pharzam — 2026-08-26T16:35:17Z

**Scope note from #32.** The drift check remaining here must not be oversold. An agreement check run by hand over `AGENTS.md` found **three** places where it contradicted its sources — R10 omitting `AGENTS.md` itself, R4 dropping the clause that rules an agent out as the second operator, and an incomplete glossary exemption. **All three would have passed a coverage check**, because every rule was mentioned.

Build the check — catching a whole rule going missing is worth having — but keep [ADR-0004](docs/adr/0004-ship-a-root-agents-file.md)'s wording honest: it tests coverage, not agreement, and agreement stays a review question.


---

### Comment — pharzam — 2026-08-27T07:51:36Z

## What tranche 1 already satisfied — with evidence, box by box

Raised by both R12 plan reviewers of tranche 2 (#16): five of this issue's seven
acceptance boxes were satisfied by pull requests that merged while the issue
stayed open, and the tranche-2 plan covered only the drift check. R12 says every
Definition-of-Done item maps to a step; silence would have closed this issue with
six boxes unticked. Verified against `main` at `999765f`.

| Box | State | Evidence |
| --- | ----- | -------- |
| `backlog-lint` — one line per task, ID present / bracketed / unique / never in both | **Done, box reworded** | `docs/tasks/backlog-lint.sh` §1 (backlog shape), §2 (dated completed shape), §3 (IDs). Fixtures: `bad-dup-id`, `bad-in-both`, `bad-malformed`, `bad-multiline`, `bad-no-date`, `bad-unclosed-comment`, `good`. Landed by #28. |
| `glossary-lint` — table shape, duplicate and empty rows | **Done** | `docs/glossary-lint.sh` §1. Fixtures: `bad-dup-term`, `bad-malformed-row`, `bad-undefined`, `bad-unclosed-fence`, `good`. Landed by #25; fixture set completed by #30. |
| `AGENTS.md` drift check | **Open** | This slice. |
| Commit-subject task-ID cross-check | **Open, newly added** | See below. |
| Self-test harness | **Done** | `docs/tests/discipline-tests.sh` — `discipline-tests: OK (37 cases)`. Landed by #28 at 31 cases; #30 took it to 37 across five linters. |
| Wired into the hook and the CI templates | **Done** | `.githooks/pre-commit` steps 1c, 1d, 1e; `docs/ci/github-actions-ci.yml` jobs `glossary-lint`, `backlog-lint`, `discipline-tests`; `docs/ci/gitlab-ci.yml` the same three. |
| "What is enforced where" updated honestly | **Done** | `docs/issue-workflow.md` — rows for the committed-Markdown glossary rule, its conversational half as an Aspiration, one line per task, and "every discipline linter still catches what it claims to". |

### One box was overstated, and is reworded rather than ticked as-is

The original wording was *"`backlog-lint` enforces the one-line-per-task rule and
the stable-ID **shape**"*. The linter does not check the shape, and says so in its
own header:

> What it deliberately does NOT check: the shape of the ID itself. The
> `‹task-ID scheme›` is the adopter's choice, so requiring one shape here would
> fail every project that picks another. It checks that an ID exists, is bracketed
> by `**…**`, and is unique — the parts that are true under every scheme.

That reasoning is sound for a domain-free kit, so the linter is right and the
acceptance box was wrong. Ticking it as written would have claimed an enforcement
that does not exist — the exact defect class #29 and #31 already found here. The
box now states what is enforced, and this comment is the record of why (R7).

### One box was missing entirely

#16 §3 "New discipline tests" lists three items:

1. `backlog-lint` — delivered.
2. `glossary-lint` — delivered.
3. **A commit-subject task-ID cross-check against `tasks/backlog.md`** — never
   reached any child issue.

It was dropped silently when this issue was written, and no comment anywhere
records the drop. It is now an acceptance box here, and it lands in this slice
with the drift check: a task ID in a commit subject must exist in `backlog.md` or
`completed.md`; a subject with no ID stays valid, because the ID is optional by
design (`AGENTS.md` §"Commits, branches, and landing").



---

### Comment — pharzam — 2026-08-27T08:02:53Z

## R12 plan for this issue, and its confirmation

**Task ID:** `T-2c9x` · **Branch:** `feat/t-2c9x-drift-check` · this is slice 2 of
the [tranche-2 plan](https://github.com/pharzam/armature/issues/16) — moved up
from last place because a plan reviewer showed the dependency on #34 and #35 was
fictional: a coverage check counts gate steps and R-numbers, and those slices add
neither. R12 puts the test slice first, and this is the tranche's only slice with
code.

### The two checks, and what each may honestly claim

**1. The `AGENTS.md` drift check.** Sources of truth, both machine-readable today:

| What | Source | Shape |
| ---- | ------ | ----- |
| Gate steps | `docs/engineering-discipline.md` §"Working a task under the quality gate" | `N. **Title.**` |
| Rules | `docs/issue-workflow.md` | `## RN — Title` |
| The summary | `AGENTS.md` | `N. **Title.**` under §"The quality gate"; `\| **RN** Label \|` rows |

It checks **coverage in both directions** — every gate step and every R-number in
the sources appears in `AGENTS.md`, and `AGENTS.md` carries no step or rule the
sources do not have (a stale extra is drift too, and revision 1 of this plan did
not ask for it). Plus shape: the numbers are contiguous from 1, and no R-number
has two rows.

It does **not** check agreement, and the script will say so in its own header.
[ADR-0004](docs/adr/0004-ship-a-root-agents-file.md) already records that limit,
and #31 is the proof: three real contradictions between `AGENTS.md` and its
sources, every one of which this check would pass. Titles are deliberately not
compared, because the two files legitimately word them differently today —
"Keep the documentation current" against "Keep documentation current", "Close out
in the same PR" against "Close out in the same pull request". A title check would
fail on correct files, and a check that cries wolf gets switched off — which
`guardrails.md` already warns about.

**2. The commit-subject task-ID cross-check.** A task ID in a commit subject must
exist in `backlog.md` or `completed.md`.

The design problem is that the kit is domain-free: `‹task-ID scheme›` is the
adopter's choice, so nothing in a subject line tells a check whether `T-2c9x` is
an ID or the first word of a description. Deriving the pattern from the IDs
already present would guess, and would guess wrong on the first task of a fresh
kit.

- **Chosen:** the adopter supplies the pattern, exactly as they supply every other
  `‹…›` value. `docs/tasks/id-pattern` holds one POSIX extended regular
  expression. If the file is absent, or still holds a `‹…›` placeholder, the check
  **skips with a NOTE** — the same shape `discipline-tests.sh` already uses for a
  missing linter, so a fresh kit stays green. This repository fills it with its own
  scheme, so the check is live here.
- **Rejected:** *hard-code `T-`* — it names this repository's scheme inside a
  domain-free kit, and every adopter inherits it. *Infer the pattern from existing
  IDs* — it is a guess, and it cannot work on the first commit of a fresh kit.
  *Check nothing when no pattern is set, silently* — a silent skip is the defect
  class this whole issue exists to close; it prints a NOTE.

### Ordered steps — strict TDD, this slice has code

0. Open the backlog line for `T-2c9x`; confirm `docs/tasks/t-2c9x.md` is free.
1. **Red.** Fixtures first, wired into `docs/tests/discipline-tests.sh`:
   `agents-lint` — `bad-missing-step`, `bad-missing-rule`, `bad-extra-rule`,
   `bad-dup-rule`, `good`; commit-ID — a subject whose ID is in no task file, one
   whose ID is present, one with no ID at all (must pass), and a repository with
   the pattern unset (must pass, with a NOTE). Run the runner: every new case
   fails, because neither check exists.
2. **Green.** Write `docs/agents-lint.sh` and the commit-msg cross-check until the
   cases pass, and no earlier case regresses.
3. Wire both into `.githooks/pre-commit` / `.githooks/commit-msg` and both CI
   templates.
4. `docs/issue-workflow.md` "What is enforced where" gains one honest row for each
   — the drift row says **coverage, not agreement**, in the row itself.
5. R10 sync, and tick the five already-satisfied acceptance boxes in the landing
   pull request (gate step 8), with the evidence comment above as their record.
6. Backlog line → completed, same pull request.

### Confirmation

This slice's plan was reviewed three times, independently, in fresh contexts, on
#16 — two REJECTED verdicts and one APPROVED WITH CHANGES, 29 findings, all
accepted. Five of them bear directly on this issue: **B2** moved it to slice 2,
**B1** and **A5** required its already-green boxes to be recorded and ticked in
the landing pull request, **A8** added the commit-ID cross-check that had reached
no child issue, and the confirmation round's finding 4 corrected where the ticking
happens. The design decisions above (both-direction coverage, the pattern file)
are new in this issue-level plan and carry no separate verdict; they are recorded
here under R3 and R7 so the next context can weigh them.



---

### Comment — pharzam — 2026-08-27T10:46:23Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:00Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

The two checks this issue is now scoped to were never written on any branch:

- the `AGENTS.md` drift check — no such script exists, on `main` or on the backup;
- the commit-subject task-ID cross-check — likewise absent.

The boxes this issue credits to #25 and #28 name work `main` no longer holds: `docs/glossary-lint.sh`, `docs/tasks/backlog-lint.sh`, and `docs/tests/discipline-tests.sh` are all absent at `2cd70ee`. Those inline credits stay as history, but they no longer describe `main` — re-check each against the redone base before ticking it.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 4** — with #20 and #22, after the tranche-1 redo gives these checks something true to check.
