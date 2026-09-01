# T-3v9q — Record two external audits of the kit

Tracks [issue #55](https://github.com/pharzam/armature/issues/55). Completed line:
[completed.md](completed.md).

## In plain terms

> Two audits were run against this kit on 2026-08-28. Forty-three of their
> forty-four claims are true. Little of it is new. Sixteen of the forty-four were
> already written up across ten of the thirty-three issues this repository closed,
> twenty-three of them as `NOT_PLANNED`,
> and two of the fixes both audits now recommend — a root agent entry file and a
> glossary linter — were shipped once and then removed. An `Accepted` decision
> record went with them, and nothing says why. The audits are accurate about the
> kit and wrong about how bad it is: after an adversarial second pass, no single
> finding survives at critical or high severity. They are wrong in the other
> direction too. One report's headline defect is that six of the kit's checks can
> be deleted with the test suite still green. The real number is eleven.

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

**Verification result.** 43 of 44 claims stand — 26 as written, 17 with a
correction to the detail. One is refuted. Severity after the adversarial pass:
7 medium, 30 low, 7 describe no defect.

## Plan (R12 — ordered, test-first)

This is the second version of the plan. The first version is on
[issue #55](https://github.com/pharzam/armature/issues/55) and an independent
review rejected it. Its step 1 was a "test slice" that wrote nothing and asserted
only that the existing gate stayed green. That assertion cannot fail: delete this
record and the glossary from a scratch copy and `run-discipline-tests.sh` still
printed `34 passed, 0 failed` at `ccc4e91`. A first step that cannot fail is not the
red half of
[R8](../issue-workflow.md#r8--test-driven-strict-red-then-green), and it left
Definition of Done items 1 to 6 with no covering step at all. The revised plan is
below, and the review that rejected the first one is recorded on the issue.

1. **Test slice.** Write [`audit-record-lint.sh`](audit-record-lint.sh), which
   asserts Definition of Done items 1 to 6, 8 and 9 against this record, the
   backlog, the glossary and `completed.md`. Run it red first: against the record as first
   written it fails on 30 of the 43 standing claim rows. Ship its own fixtures
   under [`tests/`](tests/), one good case and one bad case per block, and wire
   them into `run-discipline-tests.sh` — findings M1 to M7 below fault every other
   linter in this kit for exactly the fixture gap, so this one does not get to
   ship without them. Mutation-test every block, and read every kill for its
   reason, before trusting the green.
2. **Glossary slice.** The abbreviation rule
   ([engineering-discipline.md:308-320](../engineering-discipline.md#glossary))
   binds this file the moment it names an abbreviation. Add the missing rows, and
   let block 6 of the linter decide which rows are missing rather than a reading.
3. **Record slice.** This file, including a `file:line` citation on every standing
   claim. Block 2 of the linter is the gate on this step.
4. **Schedule slice.** One line per follow-up under **Next** in
   [backlog.md](backlog.md), each naming the closed issue it revives. Block 5 of
   the linter is the gate on this step.
5. **Close-out slice.** Move the task line to [completed.md](completed.md), and
   wire the new linter into a gate that runs on every commit: step 1d of
   [`.githooks/pre-commit`](../../.githooks/pre-commit), plus its own fixture
   suite under [`tests/`](tests/), which
   [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh) drives. A `green`
   traceability row for a test no gate runs is what
   [`dod-checklist.md:22-27`](../tests/dod-checklist.md) forbids, so this step is
   what makes those rows honest.

   **The continuous-integration job is not part of this slice, and that is a
   defeat, not a design.** The intended step was to wire the linter into both
   gates. The `ci.yml` job is written and committed, but the credential available
   to the agent that wrote it had no GitHub `workflow` scope, so every push
   touching `.github/workflows/` was refused. Rather than leave the plan claiming a
   step it did not finish, the job was scheduled as `T-1k9r`. A maintainer pushed
   it and it merged in `0f2a7b9`, so
   [`ci.yml`](../../.github/workflows/ci.yml) now carries the `audit-record-lint`
   job and this slice is complete.

## Definition of Done

Every item names the **test** that proves it, not the document that asserts it.
[`dod-checklist.md:22-27`](../tests/dod-checklist.md) is explicit: an item with no
`green` or `frozen` traceability row is not covered, and the change is not done.
This task has **nine** Definition of Done items. Items 1 to 6, 8 and 9 are
machine-checked by [`audit-record-lint.sh`](audit-record-lint.sh), which this task
ships for that purpose. Item 8 is checked in part only, and the table says which
part. The count in that first sentence is not decoration: block 7 reads it and
fails if the table stops matching, so the highest item cannot be dropped from both
tables at once and still look consistent.

| # | Item | Covered by |
| - | ---- | ---------- |
| 1 | All 44 claims recorded with a verdict | `audit-record-lint.sh` block 1 |
| 2 | Every standing claim cites a file and a line | `audit-record-lint.sh` block 2 |
| 3 | The prose arithmetic matches the tables | `audit-record-lint.sh` block 3 |
| 4 | Every finding an already-closed issue covers names that issue | `audit-record-lint.sh` block 4 |
| 5 | Each follow-up is exactly one line across its lifecycle — `## Now`, `## Next`, or a dated `## Log` entry | `audit-record-lint.sh` block 5 |
| 6 | Every abbreviation used has a glossary row | `audit-record-lint.sh` block 6 |
| 7 | The gate stays green | `run-discipline-tests.sh`, `adr-lint`, `prd-lint` |
| 8 | Every claim the reports got wrong carries the correction | `audit-record-lint.sh` block 8, and the review rounds — see below |
| 9 | Docs updated and the task line moved to `completed.md` | `audit-record-lint.sh` block 9 |

**Item 8 is covered in two halves, and only one of them is a machine.** Whether a
correction is the *right* correction is a judgement. No regular expression decides
it, and inventing a text pattern that the current 17 `Corrected` rows happen to
satisfy would be a decision rule chosen after seeing the result — the fitted
parameter [`guardrails.md`](../guardrails.md) names in its first section, and the
same trap this record faults both reports for.

So the halves are split honestly. **Block 8** asserts the machine-checkable half:
every row whose verdict is `Corrected` carries a citation, and the Corrections
section exists and is not empty. **The review rounds** cover the judgement half.
That is a `uat` row under
[`test-levels.md`](../tests/test-levels.md) — a scenario a reviewer runs and signs
off — and [`dod-checklist.md:40`](../tests/dod-checklist.md) provides for exactly
that shape. Five independent rounds have now run against this record. Round three
re-derived every corrected figure and found five still wrong; round four found five
more defects, four of them in the linter rather than the record. That is what a
working check looks like. The evidence is
[linked from the row](#test-traceability).

The limit is stated rather than hidden: the review row does **not** re-run on every
commit. A future edit to a `Corrected` row is guarded by block 8's citation
requirement and by nothing else until a reviewer looks again.

Block 7 of the linter guards this table and the one below it. Reverting any
`Covered by` cell to a document name fails the gate; so does deleting a row from
either table, or dropping an item from both at once. It took three versions to get
there, and the first two were fail-open in the way this block exists to prevent.
Version one checked nothing here at all: reverting all six cells left the gate
green. Version two checked only items 1 to 6 and 9, and built its item set **from
the cells it was validating** — so a cell reverted to "this file" simply dropped
out of the set and was never looked at, and items 7 and 8 were unguarded. The set
now comes from both tables at once, each checking the other, with the item count
anchored in the sentence above so a truncation at the top cannot pass either.

The general lesson is worth more than the fix: **a check that derives its own scope
from the data it is checking cannot fail.** That is the same shape as the "test
slice" that opened this whole review, and as the mutation sweeps whose scratch
trees were missing the files the mutants needed.

## Test traceability

One row per assertion, in the format of
[`traceability-template.md`](../tests/traceability-template.md). `Level` is
`discipline` — a test of the process rather than the product, run with no product
toolchain.

| Test ID | Level | Covers | Guardrail | Task | Status |
| ------- | ----- | ------ | --------- | ---- | ------ |
| `audit-record-lint.sh` block 1 | discipline | DoD 1 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 2 | discipline | DoD 2, issue #55 criterion 1 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 3 | discipline | DoD 3 | fitted parameters, [`guardrails.md`](../guardrails.md) | `T-3v9q` | green |
| `audit-record-lint.sh` block 4 | discipline | DoD 4 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 5 | discipline | DoD 5 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 6 | discipline | DoD 6 | — | `T-3v9q` | green |
| `run-discipline-tests.sh` | discipline | DoD 7 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 7 | discipline | this table and the DoD table | fitted parameters, [`guardrails.md`](../guardrails.md) | `T-3v9q` | green |
| `audit-record-lint.sh` block 9 | discipline | DoD 9 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 8 | discipline | DoD 8, machine-checkable half | — | `T-3v9q` | green |
| [Review rounds 1-3](https://github.com/pharzam/armature/issues/55#issuecomment-5463371193) | uat | DoD 8, judgement half | fitted parameters, [`guardrails.md`](../guardrails.md) | `T-3v9q` | green |
| `docs/tasks/tests/` fixtures | discipline | the linter itself, via `run-discipline-tests.sh` | — | `T-3v9q` | green |

The `uat` row is a reviewer sign-off, not an automated test, and it does not re-run
per commit. It is recorded at that level on purpose: `dod-checklist.md:40` provides
for a human-checked row, and pretending a script decides the judgement would be
worse than naming who did.

Every row is `green` and every row was driven red first. Block 2 was red against
the record as first written: 30 of the 43 standing rows carried no citation. The
other blocks were driven red by mutation. The **Verdict** section records the
sweep, the mutants that survived it, and what a second, independent sweep found
that the first one missed.

## Findings

Verdicts are after an adversarial second pass. `Stands` means the substance held
under attack. `Corrected` means it held but a detail was wrong. `Refuted` means it
did not hold.

A `file:line` citation is a **pointer into the tree as it stands**, not a
transcript, so it moves when the code it names moves. `T-8q3f` refreshed every
`adr-lint.sh:NN` below when it rewrote the cross-link check
([#73](https://github.com/pharzam/armature/issues/73)). Block 2b proves only that
the cited line **exists**, so it would stay green while pointing at the wrong code
— keeping these true is a review duty, and the same duty falls on the next change
to a linter this record cites. A number that is a **measurement at a named
commit** rather than a pointer keeps that anchor — it is true of that commit
whatever the file does later — but where its line number would now send a reader
to unrelated code, the sentence names the check instead of the line. M1 reads
"gut that check" for this reason.

A finding is heavier than a pointer. No verdict here has been reopened, but a
change to the code a finding describes can make its **reasoning** stop holding
even while its headline stands, and that is worth more than a moved number: an
independent review of `T-8q3f` caught one, in A1. Where it happened, the row
says so in place and names the change — the audited claim is kept, so the record
still reads as what was found on the day, with what stopped being true beside it.

### The linters — the kit's only executable surface

| ID | Finding | Verdict | Severity |
| -- | ------- | ------- | -------- |
| M1 | The duplicate-ADR-number check is `adr-lint.sh:402`. No case under `docs/adr/tests/` holds two records with the same number — every case directory has one file per number. Gut that check and the suite still passed at `b684a96`, where it printed `34 passed, 0 failed`. | Stands | medium |
| M2 | The ADR title-line check is `adr-lint.sh:432-434`, not one line. It has no fixture: every record under `docs/adr/tests/` starts with a correct `# NNNN. <title>` line. | Corrected | low |
| M3 | The `Date:` line check has no fixture. Its two `err` sites are `adr-lint.sh:465` (the line is missing) and `:473` (the format is wrong). All eight records under `docs/adr/tests/` carry the placeholder `Date: YYYY-MM-DD`, so neither site can fire. **Amended by `T-2p6k`:** the count and the reason both moved. There were nine records on the audit day, not eight, and there are twelve now; `docs/adr/tests/good-crlf/0002-crlf-real-date.md` carries a real `Date: 2026-09-01`, so "all of them carry the placeholder" no longer holds. The verdict is untouched — that record is *valid*, so it exercises the check's passing arm and still fires neither `err` site. What the row said about coverage stands; the sentence it rested on does not. | Stands | low |
| M4 | The missing `## Status` check is `adr-lint.sh:478-479`. It has no fixture: every record under `docs/adr/tests/` has the section. `bad-status` tests the status value at `adr-lint.sh:492`, not the missing section. | Stands | medium |
| M5 | The `requirement missing from the matrix` check is `prd-lint.sh:134`. It has no fixture: `docs/prd/tests/bad-matrix-mismatch/` fails on the opposite arm at `prd-lint.sh:135`. Neutralise line 134 and the suite still passed at `b684a96`, where it printed `34 passed, 0 failed`. | Stands | medium |
| M6 | No fixture pipes a body into `pr-link-lint.sh:43`. The runner always passes a file: `run-discipline-tests.sh:297`, wired at `:304`. The one live run pipes: `.github/workflows/pr-link.yml:26`. The shipped CI templates pipe too. | Stands | medium |
| M7 | Deleting a fixture root makes the runner exit 0. `run-discipline-tests.sh:280` turns an absent root into `return 0`, so the coverage floor at `:287` never runs. It prints `skip` at `:103`, so it is not silent, but the gate accepts it. | Corrected | low |
| A1 | A trailing slash on the `adr-lint.sh` directory argument silences the cross-link check. The exclusion — `grep -v "^$adr_dir/"` as audited, a literal prefix comparison at `adr-lint.sh:315` today — became a double slash that matched no path, so the ADR's own index README counted as an inbound link. The failure is a false negative: in any run that passes the index check at `:502`, the warning cannot fire. **Audit-day evidence, preserved:** `sh docs/adr/adr-lint.sh docs/adr/tests/good/` printed no `WARN`; the same run without the slash printed two. **First amendment, `T-8q3f`:** that last clause stopped holding when the same change separated the two checks — `:502` still matches a bare filename but the cross-link check needs a link, so a run can pass the index check and still warn. **Second amendment, `T-8q3f`: closed.** The trailing slash was one of five spellings of the same mistake — a bare relative name, `.`, a path holding `..`, and a symlinked directory each made the exclusion match nothing too, all of them silently — and the comparison now uses a canonical form of the argument, resolved with `-P` so the symlink resolves with the rest, so all five agree. Re-measured on this row's own repro, a copy at `docs/adr/tests/zzz-notafixture/`: two warnings with the slash and two without, where the audit measured none and two. The verdict stands as audited; the defect does not. | Stands | low |
| A2 | `run-discipline-tests.sh:282` globs `"$2"/*/` and `:285` passes each `$case_dir` to the linter, so the harness always supplies that slash. | Corrected | low |
| A3 | The README row status is never compared to the record. `adr-lint.sh:502` is a bare filename match and `$readme` is read nowhere else, so the `Status` cells at `docs/adr/README.md:98-104` can say anything. `adr-lint.sh:491` also accepts `Superseded by ADR-0007` when ADR-0007 does not exist. **Amended by `T-8q3f`:** ADR-0007 exists in this tree now, so that illustration no longer illustrates — and the sentence carrying it is the one whose `ADR-0007` token made that record read as cross-linked, which is the defect [#73](https://github.com/pharzam/armature/issues/73) was opened for. The finding is untouched: the check still accepts a supersession naming a record that does not exist. Read the example as `Superseded by ADR-9999`. | Stands | low |
| A4 | `docs/facts/` has filename, header, status and index conventions — `docs/facts/README.md:53`, `:55` and `:65`, and `docs/facts/template.md:10` — and no linter checks any of them. `prd-lint.sh:65-66` reads the directory only to collect `F-NNNN` stems, and `run-discipline-tests.sh:302-308` wires four suites with none for facts. | Stands | low |
| F1 | `prd-lint.sh:90` accepts the `#n` anchor, then `prd-lint.sh:91` truncates the citation with `substr(...,1,6)`. A copy of `docs/prd/tests/good/PRD-0001-sample.md` that cites `F-0001#99` gives `prd-lint: OK`, exit 0. | Stands | low |
| F2 | The kit does promise the anchor resolves to a numbered fact. `docs/facts/README.md:39` defines `F-0007#3` as the third numbered fact in that document. So the gap is against a stated promise. | Corrected | low |
| F3 | `#99` is genuinely out of range in the sample. `docs/prd/tests/facts/F-0001-sample.md:6-8` holds only three numbered facts. | Stands | none |
| F4 | Nothing else validates the anchor. Only `prd-lint.sh:86-96` parses a cited fact token. A `grep -rn 'F-'` over `adr-lint.sh`, `pr-link-lint.sh`, `run-discipline-tests.sh` and `.githooks/` returns nothing. | Stands | none |
| P1 | The workflow pipes on standard input at `.github/workflows/pr-link.yml:26`. Every fixture passes a file: `run-discipline-tests.sh:297` gives each fixture to the linter as an argument, for the suite at `:304`. | Corrected | low |
| P2 | The two paths do **not** diverge. The branches join at the `fi` at `pr-link-lint.sh:44`, and the first shared statement is `pr-link-lint.sh:48`. | Refuted | none |
| P3 | `pre-push` is 38 lines of untested branching. `.githooks/pre-push:20` sets the protected ref to `refs/heads/main` and `:23` compares it exactly, so an edit that drops the `refs/heads/` prefix makes the loop body unreachable and the hook exits 0 at `:38`. No test runs the hook: `grep -rn pre-push docs/tests/` finds nothing, and `.githooks/tests/` holds only `commit-msg/`. | Stands | low |
| P4 | Nine `commit-msg` fixtures exist under `.githooks/tests/commit-msg/`. `.githooks/commit-msg:25` lists 10 types and the fixtures use 3 of them (`feat`, `docs`, `refactor`). `.githooks/commit-msg:21` lists 5 exempt prefixes and only `good-merge.txt` covers one. | Stands | none |

**The survivor count is wrong, and it is wrong downwards — see X7.** Report B
names six. An independent sweep finds **eleven**: ten in the two Markdown linters
— every `err "` site in `adr-lint.sh`, every `ec=1` site in `prd-lint.sh`, and the
required-section loop — plus the fail-open mutant of the standard-input branch at
`pr-link-lint.sh:43`, which lies outside that sweep and is M6 below.

**M6 and P1, stated honestly.** Report B calls the standard-input path its
sharpest finding and says the branch that runs in continuous integration has zero
coverage. That overstates it. The exclusive code is one statement, `body=$(cat)`
at `pr-link-lint.sh:43`; the file path has two exclusive lines of its own, equally
untested; everything below line 45 is shared and fully exercised. The gap is real
but small. What makes it worth fixing is not size: a fail-open mutant —
`cat >/dev/null; body="Closes #1"` — survives the suite with
`34 passed, 0 failed` at `b684a96` and silently disables R1 enforcement for every
pull request.
One piped fixture kills it.

### The kit against its own rules

| ID | Finding | Verdict | Severity |
| -- | ------- | ------- | -------- |
| S1a | "Two hooks ship with the kit" at `engineering-discipline.md:454`. Three ship: `.githooks/` holds `commit-msg`, `pre-commit` and `pre-push`. `README.md:54` names only two of them. `.githooks/README.md:22-26` gets it right. | Corrected | low |
| S1b | The gate document never names `pre-push` or the discipline runner: `engineering-discipline.md` has zero hits for either. Its hooks section is `:443-465`, and the `pre-commit` bullet at `:458-462` names the ADR and the PRD linter but not the runner. `.githooks/README.md:24` omits the runner too, but `.githooks/pre-commit:30-32` runs it. | Stands | low |
| S1c | `engineering-discipline.md:515` calls the `‹worktree dir›` directory gitignored. `.gitignore` is two lines and covers only `.obsidian/` at `.gitignore:2`. | Corrected | medium |
| S1d | `docs/ci/tests/pr-link/README.md:3` links `../pr-link-lint.sh`. The script is at `docs/ci/pr-link-lint.sh`, so the link is broken. It is the only broken relative link in the tree; the seven other unresolved targets are documented placeholders — `‹id›.md` and `...` at `backlog.md:31` and `completed.md:17`, `<id>.md` at `backlog.md:12` and `completed.md:11`, and `NNNN-short-title.md` at `adr/template.md:7`. | Stands | low |
| S1e | `LICENSE:3` reads `Copyright (c) 2026 Farzam`, and the file holds no `‹` marker at all. No shipped document links to it. Only the follow-up line at `backlog.md:44` names it, and this task wrote that line. | Corrected | low |
| S2a | The abbreviation rule binds **all LLMs and all human operators** and is "not optional" at `engineering-discipline.md:311-312`. `CLI`, `TUI` and `GUI` sit in rule text at `engineering-discipline.md:116-117` and had no glossary row. This task added the three rows at `glossary.md:74-76`. | Stands | low |
| S2b | "Fresh context" has no row in `glossary.md` — no Term column matches it. It is used six times outside `docs/tasks/`: `adr/0003-adopt-issue-first-workflow.md:44`, `engineering-discipline.md:291`, `glossary.md:63`, `issue-workflow.md:98`, `tests/example-fact-to-test.md:75` and `tests/traceability-template.md:52`. The use at `glossary.md:63` sits inside the "Test freeze" entry. | Stands | low |
| S2c | `completed.md:7` states one line per task. The four bullets the report measured, at `completed.md:22-25`, run 536, 476, 389 and 359 characters. The file now holds six, and `completed.md:21` (`T-7k3m`, 410) sits between them and this entry. | Corrected | low |
| S2d | The "what is enforced where" table at `issue-workflow.md:164-172` names R1, R5, R8 and R12 only. It omits the abbreviation rule of `engineering-discipline.md:308`. R2, R3, R4, R6, R7, R9, R10 and R11 are absent from it too. | Stands | low |
| S2e | The rule binds "any conversation, context, prompt, reply, or response" at `engineering-discipline.md:308-309`, which reaches a read-only turn that changes nothing. `glossary.md:7-8` repeats the same scope. | Corrected | low |
| S2f | `README.md:32-37` sets the reading path before a first commit: `onboarding-for-engineers.md` (88 lines) plus `engineering-discipline.md` (557) is 645 lines, not 608. The broken "short sections" promise is `engineering-discipline.md:7`, not the README. | Corrected | low |

### Dependencies and hygiene

| ID | Finding | Verdict | Severity |
| -- | ------- | ------- | -------- |
| D1 | The security checklist names dependency scanning as a minimum check. The row is `security-checklist.md:29`, under the heading `## The minimum checks` at `:24`. | Stands | none |
| D2 | Actions float on mutable tags. The real scope at `b684a96` is **13** unpinned `uses:` references, not 2, across `.github/workflows/` and `docs/ci/`, and none carries a commit SHA. Every job this kit adds later adds one more, so `T-7m6s` pins them by rule and not by count. `docs/ci/gitlab-ci.yml:25` floats on `alpine:3`, and so do `:31`, `:37` and `:43`. No Dependabot configuration: `.github/` holds only `workflows/`. | Corrected | low |
| D3 | Pinning is already recorded — but only at `T-2w8k.md:73-75`, a card already moved to `completed.md:22`. It was not a backlog line at `b684a96`. This task added one: `backlog.md:44`, `T-7m6s`. | Stands | none |
| D4 | The repository description says "Fork it as a template", against `README.md:67` ("not a fork") and `:81` ("no fork relationship"). Fork and template are different operations on this forge, and the repository is set as a template. | Stands | low |
| D5 | **Eight** stale remote branches, not six. Two are merged and undeleted — `origin/ci/T-2w8k-activate-live-ci` and `origin/docs/T-53-solution-selection`; six are abandoned. The kit has no written rule about remote branches: `engineering-discipline.md:517-519` tells you only to remove the local worktree once it is merged or abandoned. | Corrected | low |

### The agent operator

| ID | Finding | Verdict | Severity |
| -- | ------- | ------- | -------- |
| K1 | The rules bind "each LLM coding agent" at `issue-workflow.md:22`. Only R5 (`:63`) and R6 (`:72`) are model-specific. No rule says when to start a fresh session — the word `session` occurs once in the file, at `:98`. But R6 (`:77`), R7 (`:85`), R9 (`:98`) and ADR-0003 (`0003-adopt-issue-first-workflow.md:44`) are all built on context not surviving a session, so the premise is present without the vocabulary. | Corrected | low |
| K2 | The solution-selection standard asks for licenses (`engineering-discipline.md:150`), project health (`:154`), advisories (`:159`) and deprecation signals (`:166-167`). It never asks where a claim was checked, or when. The record step at `:170-172` asks only for the selected option, the rejected alternatives and the tradeoffs. | Stands | low |
| K3 | Layer 1 is called evidence at `facts/README.md:15` and immutable at `:18`. The provenance header is `facts/template.md:5-10` — six rows, not four — with no capture-method row and no verified-against-original row. An optional capture-notes section exists at `template.md:24`, but `:28-29` tells the operator to delete it. The `Origin` row at `template.md:9` links the original only if one exists, so meetings and calls leave nothing to check against. | Corrected | medium |
| K4 | Review rounds require a fresh reviewer, not a different model. `engineering-discipline.md:188-189` asks only that the reviewer does not see your reasoning. R9 at `issue-workflow.md:98` names "another agent or session" as sufficient. A repository-wide search for the phrase "different model" finds it only in this record. | Stands | medium |
| K5 | `guardrails.md:51` ships a filled testing-pitfalls block at `:56-77`. It has no equivalent for model pitfalls — a search of the file for `model`, `LLM`, `hallucination` and `prompt` returns nothing. No rule requires one, so this is an enhancement. | Stands | low |
| K6 | No agent entry file — `git ls-files` matches no `AGENTS.md`, `CLAUDE.md`, `.cursorrules` or Copilot file. The kit's own pattern is to ship tool-specific files inert under `docs/templates/` (`docs/templates/README.md:7`), so that is where one belongs. | Stands | low |
| K7 | No numeric quality bar — no threshold is written down anywhere. At `b684a96` a repository search for `complexity`, `cyclomatic`, `mutation`, `mutant` and `CRAP` found nothing at all; the only hits today are this record, `backlog.md`, and the `CRAP` glossary row at `glossary.md:80` that this task added, none of which sets a bar. **But the coverage placeholder does exist** — `issue-workflow.md:171` reserves `‹add a coverage gate›` in the enforcement table. Report B's premise for its coverage recommendation is wrong. | Corrected | low |
| K8 | "Substantive task" is undefined at 3 sites — `README.md:36`, `engineering-discipline.md:11` and `:93` — and `glossary.md` has no row for it. Adoption markers number **350** outside this record, not 297, and the one unclosed `‹` is at `README.md:92`. | Corrected | low |
| K9 | The reports disagree on scale. Both are right at `b684a96`: 76 markdown files before `T-7k3m.md` landed at `70611c0`, 77 after; `git ls-files "*-lint.sh"` returned 3 files, while `run-discipline-tests.sh:302-308` dispatched 4 discipline linters, counting the `.githooks/commit-msg` hook. Neither stated its counting rule, and neither named a commit. | Stands | none |

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
same kit. The mapping is in the next section, and it is worth stating at its true
size: it covers **16 of the 44 findings across 10 closed issues**, not most of
them. An earlier draft of this record said "most", which the mapping table does not
support. The point survives the correction — 16 findings that were already found,
written up, and then abandoned is the defect this record is about — but the
sentence has to match the table under it. Report B quotes "the rules you throw
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

> **Update, 2026-08-31 (T-4b7p).** `main` now carries a *third*, different decision
> at this number — the one that ships the root agent entry points. The finding
> above is dated evidence and stands as written for the tree it measured; what
> changed is that restoring either branch record under its own number is now
> foreclosed. The branch-level duplication it describes is unchanged, so the
> follow-up stays open.

**X4 — two of the things the reports recommend building already existed.** The
pre-reset branch holds 124 files against the 105 on `main`. Gone from `main`:
`AGENTS.md`, `CLAUDE.md`, `docs/glossary-lint.sh` with **five** fixture
directories under `origin/backup/pre-r12-reset-999765f:docs/tests/glossary-lint/`,
`docs/tasks/backlog-lint.sh` with seven under
`origin/backup/pre-r12-reset-999765f:docs/tasks/tests/`, and the six files of
`docs/review/`. Both counts exclude each suite's own `README.md`.
Report A's headline recommendation is a glossary linter. Report B's R5 is an agent
entry file. Both were shipped, then removed.

**X5 — the main checkout sits on a merged branch.** The worktree list shows
`~/projects/armature` on `docs/T-53-solution-selection`, whose pull request #54 is
merged. `engineering-discipline.md:511-512` says never work on the operator's main
worktree.

**X6 — the production linter run is vacuous.** `docs/facts/` holds no `F-*.md` and
`docs/prd/` holds no `PRD-*.md`, so `sh docs/prd/prd-lint.sh` exits early at
`prd-lint.sh:61-63` and prints `OK` without checking anything. Every piece of
evidence that the linters work comes from fixtures. That is acceptable, and it is
worth knowing when reading a green gate.

**X7 — report B undercounts its own headline defect.** B says six checks can be
gutted with the suite still green. The real number is **eleven**, and the
arithmetic is `10 + 1`. A sweep that neutralises every `err "` site in
`adr-lint.sh`, flips every `ec=1` in `prd-lint.sh`, and narrows the
required-section loop leaves **ten** survivors. The eleventh is the fail-open
mutant of `pr-link-lint.sh:43`, recorded under M6 above; it is outside that sweep,
because the sweep covers only the two Markdown linters. State the third arm or the
method does not produce the number. The five B missed:

| Survivor | What stops being checked |
| -------- | ------------------------ |
| `adr-lint.sh:66` | the ADR index README need not exist |
| `adr-lint.sh:473` | the `Date:` **format** — separate from `:465`, which B counts as one check with it |
| `adr-lint.sh:497` | the `## Context` and `## Consequences` arms of the required-section loop; only `## Decision` has a fixture |
| `prd-lint.sh:115` | a requirement with no phase value |
| `prd-lint.sh:120` | a requirement-like row with the wrong number of cells |

The sweep is the method B recommends, applied to every site rather than to a
chosen list. B's own R1 is therefore scoped too small: it budgets fixtures for six
survivors and would leave five alive. `T-8b4r` carries the corrected set.

Two mutations in the first sweep run — `prd-lint.sh:110` and `:113` — failed to
apply, because the replacement text broke the `sed` expression. They are recorded
as killed on the strength of the run that applied them cleanly, not on that failed
run. A sweep that cannot tell "mutation applied and was caught" from "mutation
never applied" reports a false green, which is the same defect the sweep exists to
find. Any standing harness built for `T-8b4r` must assert that the mutant actually
changed the file.

**X8 — report B readmits the figures it says it excluded.** B states that two of
its lenses cited "182 obligations, 21 enforced, 149 prose-only" from a rules map
that does not exist, and that those numbers are excluded. Its headline sentence
then says the kit "states about 180 rules while shipping checks for roughly two
dozen". That is the same unsourced magnitude, re-entering through the most quoted
line in the report. Neither `180` nor `two dozen` has a file behind it. Both are
barred from this record. A defensible ratio would count committed sites — 11 `err`
sites in `adr-lint.sh`, 1 `err` site plus 10 `ec=1` sites in `prd-lint.sh:57`
onward, 1 failure path in `pr-link-lint.sh`, 1 regular expression in
`.githooks/commit-msg:25`. Counting the `ec=1` sites as `err` sites, as an earlier
draft of this bullet did, is the same loose counting the bullet objects to.

**X9 — report A's cost estimate for its linters is false.** A ranks "ship the two
linters" as its first action, "most value for the least work", on the premise that
fixtures are "picked up by `run-discipline-tests.sh` with no change to the runner".
The runner has no discovery loop: `run-discipline-tests.sh:302-308` hardcodes four
dispatch lines. Every new suite needs a new line, and neither proposed linter fits
either existing shape — a glossary or link check is repo-wide, not
one-fixture-per-directory or one-fixture-per-file, so it needs a third helper too.
Report B's R1 gets this right and budgets for a new dispatch. A's ranking rests on
a cost it did not check.

**X10 — the reports contradict each other, and the record settles it.** On the
same measured drifts, A adds two linters and ranks them first; B fixes them with
nine one-line edits at "prose delta ≈ 0" and would have dropped the linters at its
own bar. X9 breaks the tie: A's cheapest-first ranking is built on a wrong cost, so
take B's one-line edits now (`T-4x2k`) and hold both linters as unproven. On review
discipline the two invert: A calls the fresh-reviewer rule a verification gap, B
lists the same mechanism among the kit's strengths without a caveat. Both are
right about different things. The stopping rule — rounds until a round finds
nothing — is a verified strength. Reviewer independence is a real gap at
`engineering-discipline.md:188`, because a fresh session is not a different model.

**X11 — three of report B's ten recommendations are outside this record.** B's R6
(restate test-driven development as the falsification event rather than the write
order), R8 (ship a `docs/architecture.md` for module structure), and R9 (give a
plan a revision path, as every other artifact has) are policy proposals, not
findings about the tree. They are not verified here, and they are not scheduled.
Each changes a rule, so each needs its own issue and an ADR under R10.

## Already recorded — finding to abandoned issue

Triage these before writing anything new. R2 requires it.

The table names **16 of the 44 findings, across 10 closed issues**. The other 28
are new to this record. Read the table as evidence that the tracker held real work
that was thrown away, not as a claim that the audits found nothing.

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
- The `completed.md` bullets the report measured are 536, 476, 389 and 359
  characters at `completed.md:22-25`. The reported 540/482/393/363 are byte counts,
  and "the two most recent" was already stale when it was written.
- 13 unpinned action references at `b684a96`, not 2. The token is
  `pull-requests: read`, not a broad grant.
- 8 stale remote branches, not 6.
- 350 adoption markers at `b684a96`, not 297. Counting rule: every occurrence of
  the open marker, not every closed pair. The one unclosed marker **outside this
  record** is `README.md:92`. No figure for the tree after this change is given
  here on purpose — it moves with every commit, and an unanchored count is the
  defect this bullet exists to correct.
- A coverage placeholder **does** exist at `issue-workflow.md:171`.
- 77 markdown files at `b684a96`. 3 files named `*-lint.sh` there, 4 after this
  change. The runner dispatched 4 fixture suites there and dispatches 5 after this
  change — that is the counting rule K9 faults both reports for leaving unstated.
- The standard-input gap is one statement, not a whole branch.
- The R8 template difference is intentional. See X1.
- **Eleven** linter checks survive gutting, not six. See X7.
- "About 180 rules … roughly two dozen checks" is the figure report B declares
  excluded, re-entering through its headline. Neither number has a file behind it.
  Barred from this record. See X8.
- "No change to the runner" is false: every new suite needs a hardcoded dispatch
  line, and a repo-wide linter needs a third helper as well. See X9.

## Out of scope (follow-ups)

Nine follow-ups came out of this task: `T-5h8n`, `T-2q7d`, `T-8b4r`, `T-6f3w`,
`T-9c5t`, `T-4x2k`, `T-7m6s`, `T-3d9v`, `T-1k9r`. Each names the closed issue it
revives. None was started by this task.

This list is dated evidence of what the audits produced, so it keeps every ID
even after an item finishes. It is **not** the live state. For that, read
[backlog.md](backlog.md) — `## Now` and `## Next` — and the `## Log` in
[completed.md](completed.md). `audit-record-lint.sh` block 5 holds the two in
step: every ID here must be named by exactly one line across those three
sections.

`T-1k9r` was different from the other eight: it was not a finding from the audits,
it was **the half of this task's own close-out slice that could not land**. The
`audit-record-lint` job for `.github/workflows/ci.yml` was written and committed,
but the credential available to the agent that wrote it had no GitHub `workflow`
scope, so the push was refused. A maintainer pushed it, and it merged with this
record in `0f2a7b9`. `T-1k9r` is **done** and its line is in
[completed.md](completed.md).

Closing it found a second defect, which [#57](https://github.com/pharzam/armature/issues/57)
records: block 5 of the linter knew only `## Next`, so it failed the gate on both
the documented `Next` to `Now` promotion and on completion itself. It required a
task to stay deferred for ever. The first follow-up to finish was the one that
exposed it.

Two fixes do land here, because the kit's own rules force them. The abbreviation
rule requires a glossary row in the same change that names an abbreviation, so
this file's use of `CLI`, `TUI`, `GUI`, `AI`, `ID`, `SHA`, `CRAP` and `HTML` adds
eight rows to [`glossary.md`](../glossary.md). Finding S2a is therefore closed by
this task, not deferred. And `docs/tests/dod-checklist.md:22-27` requires a test
behind every Definition of Done item, so this task ships
[`audit-record-lint.sh`](audit-record-lint.sh) as well.

## Verdict

The record is complete and the gate is green. Evidence, run on this branch:

```
$ sh docs/adr/adr-lint.sh               -> adr-lint: OK             exit 0
$ sh docs/prd/prd-lint.sh               -> prd-lint: OK             exit 0
$ sh docs/tests/run-discipline-tests.sh -> 42 passed, 0 failed      exit 0
$ sh docs/tasks/audit-record-lint.sh    -> audit-record-lint: OK    exit 0
$ git diff --check                      -> (no output)              exit 0
```

All nine Definition of Done items map to a `green` traceability row — see **Test
traceability** above. Eight of the nine are covered by a machine. **Item 8 is
covered in two halves, and the second half is a reviewer, not a script.** Block 8
asserts that every `Corrected` row cites a file and a line and that the Corrections
section is not empty; the judgement — is this the *right* correction? — is a `uat`
row carrying three recorded review rounds. That split is stated in the Definition
of Done table and repeated here, because "nine of nine" would otherwise read as
"nine of nine automated", which is not true.

An earlier version of this section said item 8 was uncovered and the change
therefore not done. That was the honest reading at the time and a reviewer was
right to call the contradiction with the ticked box on issue #55. The resolution
was to cover the half a machine can cover and name the reviewer for the rest —
not to invent a text pattern that the 17 `Corrected` rows happen to satisfy, which
would have been a decision rule chosen after seeing the result. Every relative link and
heading anchor in the changed files resolves. Seven unresolved targets remain in
the tree and all seven are documented placeholders: `‹id›.md` and `...` inside the
HTML comments at `backlog.md:31` and `completed.md:17`, `<id>.md` at
`backlog.md:12` and `completed.md:11`, and `NNNN-short-title.md` at
`adr/template.md:7`. All were there before this change. The one genuinely broken
link in the tree is `docs/ci/tests/pr-link/README.md:3`, which is finding S1d and
is scheduled as `T-4x2k`.

Three things are worth carrying forward.

**The reports were right about the kit and wrong about the danger.** 43 of 44
claims stand, and not one survives at high severity. An audit that grades its own
findings has no pre-registered pass bar, which is the trap
[`guardrails.md`](../guardrails.md) names in its first section: a decision rule
chosen after seeing the result is a fitted parameter. Both reports set severity
after the fact. Read their facts; re-derive their severities.

**The kit's real defect is not in the kit.** It is that this repository already
found 16 of these 44 findings, wrote them up across 10 issues, and closed them —
23 of its 33 closed issues carry `NOT_PLANNED`. Report B quotes "the rules you
throw away are the ones you will pick up off the floor in a year" and then
measures the loss in prose drift. The
measurement was in the issue tracker. `T-5h8n` is therefore ordered first: triage
the abandoned issues before writing one new line of rule.

**One test of the rule ran during this task, and reading it was not enough.** The
abbreviation rule forced glossary rows the moment the record named an
abbreviation. Reading the record by hand found three — `CLI`, `TUI`, `GUI`. A
machine reading the same file found five more: `AI`, `ID`, `SHA`, `CRAP` and
`HTML`. The rule was the same both times; only the reader changed. In the same
change a heading anchor was written that looked right and did not exist
(`#long-running-operations`, against the real
`#progress-indicators-for-long-running-operations`). It was caught by checking,
not by reading. That is the single broken link in `docs/ci/tests/pr-link/README.md`
happening again, live, and it is the argument for `T-8b4r` and the proposed link
check: the rules that fire are the ones a machine checks.

This entry is 249 characters at `completed.md:20`, against the 410 of `T-7k3m` at
`:21` and the 536 of `T-2w8k` at `:22` — the two entries directly before it. An
earlier draft of this sentence compared it to "536 and 476", which are `T-2w8k` and
`T-6r2d`, and so skipped `T-7k3m`, the shortest of the three and the one that most
weakens the point. Finding S2c says that file's own one-line rule is decaying. This
task does not add to the decay, and it does not get to pick which neighbours it is
measured against.

**A completeness pass ran after the first version of this record, and changed
it.** It re-read both reports against the covered claims and found what the sweep
had not asked: X7 through X11. The largest is X7 — the survivor count is eleven,
not six, so report B understates the one defect it calls its headline, and its own
remedy is scoped to leave five checks unfixtured. The severities in this record
stand; the coverage gap behind them is larger than either report says. Both facts
belong in the same sentence, and only one of them is comfortable.

**A second review round ran on the pull request, and it was the one that bit.**
[Pull request #56](https://github.com/pharzam/armature/pull/56) was reviewed and
blocked with three findings, all three correct.

1. **Issue #55 acceptance criterion 1 was not met.** 30 of the 43 standing claims
   carried no file and no line. The issue box was ticked and the pull-request
   description repeated the tick. Every standing claim now carries a citation,
   re-derived against the tree rather than copied from the reports, and block 2 of
   `audit-record-lint.sh` fails if one goes missing again.
2. **Definition of Done items 1 to 6 were not test-covered.** The table mapped them
   to documents. `dod-checklist.md:22-27` requires a `green` or `frozen`
   traceability row. `audit-record-lint.sh` and the **Test traceability** table are
   the answer. Item 9 became a block. Item 8 took two more rounds to settle, and is
   now covered in halves: a block for the machine-checkable part, a named reviewer
   for the judgement.
3. **R12 had no recorded reviewer confirmation.** `issue-workflow.md:146-151`
   requires one round of independent plan review and a reviewer's confirmation,
   commented on the issue before building. Issue #55 held two comments and both
   were the author's.

An independent review of the plan then ran and **rejected it**. It is recorded on
issue #55. Its central finding is one this record should have made about itself:
the plan's first step was a test slice that wrote nothing, and its assertion could
not fail. The reviewer proved it rather than argued it — delete this record and
`glossary.md` from a scratch copy of `ccc4e91` and the gate still printed
`34 passed, 0 failed`.
Five of the seven Definition of Done items had no step that could fail.

That review found five defects in this record that neither audit and neither
earlier pass had caught, all of them the S1a class — a shipped statement that is
not true of the thing it describes:

| Where | Was | Is |
| ----- | --- | -- |
| X4 | `glossary-lint.sh` with six fixture directories | **five** |
| X7 | the stated sweep "finds eleven" | the stated sweep finds **ten**; the eleventh is `pr-link-lint.sh:43`, outside it |
| X8 | "10 `err` sites in `prd-lint`" | 1 `err` site and 10 `ec=1` sites |
| Verdict | "the three placeholders" | **seven** unresolved targets, of two forms |
| Verdict | "249 against the 536 and 476 of the two before it" | 410 and 536; the draft skipped `T-7k3m` |
| X2 | "most were already written up" | **16 of 44**, across 10 closed issues |
| Corrections | "350 adoption markers", "77 markdown files" | true at `b684a96` only; the post-landing figures drifted and are now dropped |

The linter was then attacked three times, and it failed the first two.

The first sweep chose eleven mutants and killed ten. The survivor was block 6:
blanking the `CLI` glossary row changed nothing, because the check skipped every
table row and excused `ID` and `HTML` on an exempt list the abbreviation rule does
not grant.

A second, independent review then built mutants the author had not thought of, and
they exposed the real hole. Blocks 1 to 6 checked the record's **claims**; nothing
checked the two tables that say those claims are covered. Reverting every
`Covered by` cell to "this file" — the literal defect the pull-request review
blocked on — left the linter green. So did deleting the whole traceability table,
flipping a row from `green` to `red`, citing a file that does not exist, citing a
line past the end of a file, renaming the `## Already recorded` heading, and one
stray code fence. Block 7, block 2b and three guards against a silently vacuous
block were written in answer to those seven mutants.

**A fourth round found one more, and it was the same shape again.** The review
confirmed the five earlier findings resolved, and then found that block 7 — the
block written to stop a fail-open — was itself fail-open. It validated the
`Covered by` cell for items 1 to 6 and 9 only, and it built its item set from the
cells that already looked right. So items 7 and 8 could revert to a document name
and pass, and deleting a whole row passed too. Three of the four mutants I wrote to
check the claim survived.

The set now comes from the Definition of Done table and the traceability table at
once, each checking the other, with the item count anchored in prose so dropping
the highest item from both at the same time cannot pass. A `Covered by` cell that
claims a review round must also show the `uat` row, so the judgement half of item 8
cannot quietly disappear behind the machine half.

That is four rounds and the same defect four times, at four levels: a plan step
that could not fail, a linter that did not check the table saying it had checked,
a sweep whose mutants all died on the harness rather than the assertion, and a
guard that took its scope from the thing it was guarding. The record's own thesis
is that the rules which fire are the ones a machine checks. The corollary, learned
the hard way here, is that a machine check only fires if something outside it
decides what it must look at.

**A third review round found five more defects, and four of them were mine.** The
first two rounds attacked the record. This one attacked the linter, and it was
right to.

| # | Finding | Where |
| - | ------- | ----- |
| 1 | The record declared itself not done while issue #55 kept the matching box ticked | DoD item 8 |
| 2 | Block 2b resolved only citations with a file extension, so `LICENSE:99999` passed the check that exists to catch it | `audit-record-lint.sh` block 2b |
| 3 | An invalid traceability status printed `FAIL` and still exited 0 — the loop ran in a pipeline subshell, so the parent's flag was never set | block 7 |
| 4 | The traceability row count was a lower bound, which cannot tell **which** item lost its proof | block 7 |
| 5 | The close-out slice promised a CI job the branch does not carry | the plan |

Fixing them turned up two defects the reviewer had not seen, both found by running
rather than by reading. A regex literal passed as an awk function argument is
matched against `$0` and arrives as `0` or `1`, so the rewritten extractor silently
harvested nothing — and the sweep that was meant to prove the fix reported every
mutant killed, because every mutant died on the same broken extractor. Then the
suffix test `index($0, "/" p) == length($0) - length(p)` matched a **not-found**
result of `0` whenever the two paths happened to be the same length, so a citation
to a missing file resolved to an unrelated one. Both were false greens inside the
fix for a false green.

The lesson is now three levels deep and the same every time: a green nobody
attacked is not evidence, and a kill whose reason nobody read is not a kill.

The third sweep runs nineteen mutants and kills nineteen. Its first two runs were
themselves false greens: the scratch tree omitted `.github/` and then the root
`README.md`, so every mutant died on a missing file rather than on the assertion
under test. That is the X7 defect a third time, and it is why every mutation here
is checked for having changed the file, and every kill is read for its reason.
A sweep that reports the right number for the wrong reason is not evidence.

**One correction to this record's own history.** The first commit, `f55d19a`, and
its pull-request description both split the standing claims as "29 as written, 14
with a correction". Counting the table itself gives 26 and 17. The total, 43 of 44
standing with 1 refuted, was right throughout; only the split was wrong. It came
from the verifiers' pass rather than from the table that was finally written, and
it was caught by counting the rows, not by reading them. The commit message is
immutable and still carries the wrong split. This is the same defect class the
record documents in S1a and S1b — a shipped statement that is not true of the
thing it describes — produced while writing the record about it. It is the
argument for `T-4x2k`.
