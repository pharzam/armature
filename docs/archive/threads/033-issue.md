# #33 — Clear the review debt: run the missing independent review rounds over the seven merged PRs

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T07:30:30Z.*

---

Part of #16.

## Goal

Clear the review debt. Run gate step 5 — independent blind review in a fresh
context — over the seven pull requests that reached `main` with a self-review
only (#24, #25, #26, #27, #28, #30, #32), and hold the deviation record here
instead of in the pull-request bodies.

Two late adversarial passes over that work have already found six defects (#29,
#31). Each pass looked in one place and found defects there. The rest of the
merged work has had no independent look at all.

## Why this blocks #16

[The plan on #16](https://github.com/pharzam/armature/issues/16#issuecomment-5435724373)
adds one acceptance line to the parent: **#16 does not close while any review debt
remains.** Zero debt at close, not logged debt. This issue is that debt.

## Duplicate check (R2)

- [x] Searched the open **and** closed issues. Nothing covers the missing review
      rounds. Parent: #16. Related: #29 and #31 (both closed) each fixed the
      findings of one late pass; neither is the debt itself.

## Solution note (R3)

- **Chosen:** one full round per review lens over the **accumulated diff** of the
  seven pull requests (`2cd70ee..main` — the tree the audit read, to the tree
  today),
  each round run by a fresh context that has not seen the author's reasoning,
  with the prompts in [`docs/review/`](docs/review/). Rounds continue until one
  full round finds nothing material, which is what gate step 5 asks for. Every
  material finding becomes its own issue and lands as its own pull request with
  its own round.
- **Rejected:** *a separate round for each of the seven pull requests* — they are
  merged, and the later ones edit the files the earlier ones added, so a per-PR
  review reads a state that no longer exists on `main`. The accumulated diff is
  the state an adopter gets. *Treat the self-reviews as sufficient* — all three
  defects in #29 passed a self-review first. That is the exact failure mode step 5
  exists for.
- **Decision record:** this issue.

## Acceptance criteria

- [ ] The accumulated diff of the seven pull requests gets a full round for each
      of the four lenses in `docs/review/`, each in a fresh context.
- [ ] Rounds continue until one full round finds nothing material. Each round's
      lens, reviewer context, and result are recorded here.
- [ ] Every material finding gets its own issue, and is fixed — or rejected with a
      written reason — before this issue closes.
- [ ] The deviation records in the seven pull-request bodies are collected here.
      The pull-request bodies stay as history.
- [ ] The task line moves from `docs/tasks/backlog.md` to
      `docs/tasks/completed.md` in the same pull request.




---

### Comment — pharzam — 2026-08-27T07:40:01Z

## The seven deviation records, moved here from the pull-request bodies

Acceptance criterion 4 of this issue. The pull-request bodies stay as history;
this is the single place the debt is now tracked. Quoted, not paraphrased.

| PR | Task | Merged | What the body recorded |
| -- | ---- | ------ | ---------------------- |
| [#24](https://github.com/pharzam/armature/pull/24) | `T-7h2v` | 2026-08-26 | **Nothing.** The body has no review-status section at all. Its acceptance list ticks `adr-lint` and `prd-lint` and says "the discipline linters are this repository's test suite" — the review round is not mentioned, not even as skipped. |
| [#25](https://github.com/pharzam/armature/pull/25) | `T-3q8d` | 2026-08-26 | *"Independent blind review (gate step 5) could not be run: every reviewer agent dispatched in this session reached an idle state without delivering a report, including a file-writing workaround. This PR carries a **self-review**, which is weaker exactly where it matters. Recorded rather than hidden, under §"Honesty and evidence". The self-review did find the `LC_ALL` false-pass above, before the linter was committed."* |
| [#26](https://github.com/pharzam/armature/pull/26) | `T-5w9k` | 2026-08-26 | *"Same deviation as #24 and #25 … This carries a self-review only, and says so rather than ticking the box."* And: *"there is an irony worth stating plainly: **this PR ships the review-lens prompts, and could not itself get an independent review.**"* |
| [#27](https://github.com/pharzam/armature/pull/27) | `T-2f6r` | 2026-08-26 | *"Same deviation as #24, #25, and #26 … Self-review only, recorded rather than hidden. It did catch a real defect: the first commit attempt bundled the ADR, the linter fix, and the doc sync into one commit, breaking §"Commit granularity". The branch was unwound and split into the five commits now on it."* |
| [#28](https://github.com/pharzam/armature/pull/28) | `T-8j4m` | 2026-08-26 | *"Same deviation as #24–#27; every reviewer agent dispatched reached idle without delivering a report. Self-review only, stated rather than hidden."* |
| [#30](https://github.com/pharzam/armature/pull/30) | `T-6b3n` | 2026-08-26 | *"Still self-review — the reviewer agents remain unable to deliver. But this PR is itself the product of the adversarial pass that the missing review round should have been, run against already-merged work. It found three real defects, which is the argument for doing the round properly on the rest."* |
| [#32](https://github.com/pharzam/armature/pull/32) | `T-4v7h` | 2026-08-26 | *"Self-review, like #24–#30 — the reviewer agents still cannot deliver. This PR is itself the second adversarial pass over already-merged work, after #30 was the first. Two passes, six defects. That is the case for the review round, made by its absence."* |

### Two things the collection shows that no single pull request could

1. **#24 recorded nothing.** Six of the seven state the deviation plainly. The
   first one does not mention it. So the honest-recording claim made on #16 —
   *"Each PR carries a self-review and says so"* — is true of six PRs, not seven.
   The one that says nothing is the one that changed `.gitignore` and deleted a
   worktree and six branches.
2. **The stated cause is the same every time:** reviewer agents that reached idle
   without delivering. That is a tooling failure, and the kit had no rule for it.
   The deviation repeated six times because nothing in the process forced a stop
   after the first. A gate that can be missed twice in the same way is missing a
   rule, not just a round.



---

### Comment — pharzam — 2026-08-27T07:54:51Z

## Recorded before the first round: an agent in a fresh context satisfies gate step 5

Required by the confirmation round of the tranche-2 R12 plan (#16, finding 7).
The rounds below are run by agents. Gate step 5 does **not** say today whether an
agent qualifies as an independent reviewer — so the ruling is written down here,
before the first round, rather than assumed by it.

**The ruling, from two independent plan reviewers who reached it separately:**

> An agent in a fresh context **does** satisfy gate step 5. R9 already admits one
> for the stricter decision — *"a **fresh context** (another agent or session, not
> the author) confirms the tests"* (`docs/issue-workflow.md:110`) — and nothing in
> step 5 requires a human.

**What it does not mean.** Reviewing is not approving. R4 governs approval
authority and rules an agent out as the second operator; gate step 5 governs
independence and admits one as the reviewer. The two rules answer different
questions, and #34 writes that distinction into R4 so it cannot be read as one
rule contradicting itself.

**Why it is written here and not only in a session.** The words are missing from
`docs/engineering-discipline.md` today. #34 adds them. Until then this comment is
the record that the rounds below were run under a ruling, not under an assumption
— and if the ruling is wrong, the honest consequence is that a solo project cannot
pass gate step 5 at all, which would stop this work rather than weaken it.

**One more thing this round already found, before it started.** Three reviewer
agents dispatched for the plan review reached idle without delivering a report —
the same tooling failure named in all seven deviation records above. The answer
used here is redundancy plus a written artifact: dispatch more than one reviewer,
and require each to write its report to a file **and** return it. Both survivors
delivered, and their reports are on #16. That is the method the rounds below use.
A reviewer that cannot deliver is repeated with redundancy; it is never recorded
as a deviation and merged past.



---

### Comment — pharzam — 2026-08-27T07:57:09Z

## R12 plan for this issue, and its confirmation

R12 requires the ordered plan **and its review confirmation** to sit on the issue
the work belongs to, so a fresh context sees both. This slice's plan was reviewed
as part of the tranche-2 plan on #16; it is restated here with its verdicts, so
#33 is readable on its own.

**Task ID:** `T-5r2q` · **Branch:** `chore/t-5r2q-review-debt` · **Worktree:**
`.worktree/t-5r2q`

### The ordered plan

0. **Open the backlog line** (`9e84512`) — done, so the same-pull-request move at
   close-out has something to move.
1. Four rounds over `2cd70ee..999765f` — the accumulated diff of #24, #25, #26,
   #27, #28, #30 and #32, 67 files and about 1,700 added lines — one round per
   **code** lens: `correctness.md`, `guardrails.md`, `simple.md`,
   `adversarial.md`. Each round runs in a fresh context that has not seen the
   author's reasoning, and is handed the matching prompt from `docs/review/`
   verbatim.
2. Record each round here: the lens, what it read, what it found, and what it
   attacked and could **not** break.
3. Every material finding gets its own issue and its own gate pass. A finding
   rejected on inspection gets its reason written here.
4. Rounds continue until one round finds nothing material — and that round is
   never the one that found the last defect. The clearing round reads the range
   **as it stands then**, including any fix landed since.
5. The seven deviation records (already collected above). Backlog line →
   completed, in the landing pull request.

### No code, one deliberate exception

This slice writes no linter and no rule. Its pull request carries the backlog
line and its move, and `docs/tasks/t-5r2q.md` holding the round record. R12 asks
for the test slice first *wherever a slice produces code*; this one does not, so
there is no test slice to put first. The rounds themselves are the deliverable.

### Confirmation

Reviewed three times, independently, in fresh contexts, on #16:

| Round | Verdict | Findings affecting this slice |
| ----- | ------- | ----------------------------- |
| Reviewer A | REJECTED | A3 (rounds, not one round), A10 (name the four code lenses — `docs/review/` holds five prompts), A11 (the range moves under the slice) |
| Reviewer B | REJECTED | B11 (the fix chain can deadlock the tranche — later slices depend on *the lenses having run*, not on this issue closing) |
| Confirmation | APPROVED WITH CHANGES | Finding 7 (record the gate-step-5 ruling on this issue **before** the first round — done above) |

All findings accepted; the steps above are the corrected form. Building on this
slice began after the confirmation round, not before it.



---

### Comment — pharzam — 2026-08-27T08:04:30Z

## Gate step 5, round 2 of 4 — guardrails and acceptance criteria

Reviewer: an agent in a fresh context, handed `docs/review/guardrails.md` verbatim.
It had not seen the author's reasoning. Posted unedited.

**I verified F1, F2, F4 and F5 against `main` before posting.** All four reproduce
exactly as written. F3 was an error in this issue's own sibling (#19), introduced
less than an hour before the round found it — it is already fixed.

---

# Round 2 — guardrails and acceptance criteria

Range `2cd70ee..999765f` (67 files). Fresh context, author's reasoning not seen.
Nothing tracked was modified; all experiments ran on a copy under the scratchpad.

The brief said to hunt for more of the class #29 and #31 found — *a check that
reports OK having checked less than it claims*. I found two more instances and
four documentation claims that do not hold on `main` today. No blocker.

---

## Findings

### F1 — MAJOR. `discipline-tests.sh` reports OK after skipping whole linters, whole fixture sets, and misnamed fixtures

**Breaks:** the `What is enforced where` row added by #28 —
`docs/issue-workflow.md:185`:

> `| Every discipline linter still catches what it claims to | Testing | pre-commit | discipline-tests | — | Enforced |`

and #28's acceptance box *"The 'What is enforced where' table gains two honest
rows"*, and #19's box 7 *"the table … is updated honestly"*.

**Guardrail tripped:** `docs/guardrails.md:65` — *"Tests that pass for the wrong
reason. A test that asserts nothing, asserts the wrong thing, or never actually
exercises the path reports a safety that is not there — worse than no test."*
Also `docs/guardrails.md:74` — *"a skipped gate is no gate."*

**Evidence** (copy of the repo, `docs/tests/discipline-tests.sh`):

```
baseline                                   -> discipline-tests: OK (37 cases)   exit 0

1. mv docs/glossary-lint.sh away           -> NOTE  docs/glossary-lint.sh not present — skipped
                                              discipline-tests: OK (32 cases, 1 set(s) skipped)   exit 0
2. mv docs/tasks/tests away                -> NOTE  backlog-lint.sh has no fixtures at docs/tasks/tests — skipped
                                              discipline-tests: OK (30 cases, 1 set(s) skipped)   exit 0
3. add docs/adr/tests/badfilename/ (typo)  -> discipline-tests: OK (37 cases)   exit 0   (silent: no NOTE, no count change)
4. add empty docs/tasks/tests/bad-nothing-here/
                                           -> discipline-tests: OK (38 cases)   exit 0
   but that "passing case" is only:           FAIL  missing …/bad-nothing-here/backlog.md (the task index)
```

Three separate holes, all in the tool whose stated job (`discipline-tests.sh:10`)
is *"the gate for the gate"*:

- **Deleting or renaming a linter is the largest possible linter regression, and
  the runner reports it as a pass.** `run_set` at `docs/tests/discipline-tests.sh:73`
  turns a missing script into a `NOTE` and `skipped++`; the final branch at line
  104 only checks `fail -eq 0`. Combined with `.githooks/pre-commit`, which wraps
  every check in `if [ -f … ]` (lines 20, 25, 30, 35, 41), a renamed
  `glossary-lint.sh` removes the check from the hook *and* from the runner and the
  whole gate stays green.
- **A fixture whose name is not `good*` or `bad-*` is dropped in silence.**
  `run_case:53` returns 0 with no message for anything unmatched. Experiment 3: a
  fixture directory that exists on disk was never executed and nothing said so.
- **`bad-*` asserts only "exit 1", never "caught the thing it is named for".**
  Experiment 4: an empty directory counts as a passing `bad-*` case because the
  linter cannot find its input. #30's own PR body already documents this hazard —
  *"the fence fixture also fails against `origin/main`, but for the wrong reason"* —
  so the limitation is known, and the table row still says `Enforced`.

The runner's own zero-case guard (line 99) only catches *all* sets vanishing. The
gap it leaves is one set vanishing, which is the realistic failure.

**Fix.** Two small changes and one honest word:

1. Turn the manifest into an assertion: a row whose linter or fixture root is
   missing is a `FAIL`, not a `NOTE`. If an adopter deleting a section must still
   pass, make that an explicit opt-out (`SKIP_SETS=…`), not the default.
2. Make an unmatched fixture name a `FAIL` naming the entry, not a silent return.
3. Either have `bad-*` assert on the expected message (a one-line `expect` file
   per fixture, matched against stderr), or change the table's Status cell from
   `Enforced` to something the code supports — e.g. *"Enforced: every fixture runs
   and every `bad-*` is rejected; which rule rejected it is not asserted."*

Optionally assert the case count (`37`) so a silent drop is loud — the number is
already published in `docs/tasks/completed.md:21` with nothing holding it true.

---

### F2 — MAJOR. `glossary-lint.sh` still reports OK when its scan root does not exist

**Breaks:** the same `guardrails.md:65` pitfall, in the linter #30 was written to
de-fang. #30's title is literally *"the new linters reported OK after checking
less than they claimed"*; this is the branch next door, still open.

**Evidence** (on `main`, unmodified):

```
$ sh docs/glossary-lint.sh docs/glossary.md /no/such/dir
glossary-lint: OK
exit=0
```

**Mechanism.** `docs/glossary-lint.sh:149` — `( cd "$scan_root" … && git ls-files … )`
— the `cd` fails, `$tmp/files` is empty. The guard #30 added at line 156 then runs
`find "$scan_root" …`, which also finds nothing because the directory is absent,
so control reaches line 160 and prints `glossary-lint: OK`. The guard fires only
for *"the directory exists and holds untracked Markdown"*; *"the directory is not
there at all"* falls through to the success path.

**Reachability, stated honestly.** Not reachable through the shipped wiring today:
the hook and both CI templates call the linter with no arguments, and
`discipline-tests.sh` guards its root with `[ -d … ]`. It *is* reachable through
the two-argument shape the script's own usage text documents at line 15, which is
the shape an adopter pointing the linter at their own docs tree will use — and a
typo there buys a green that scanned nothing.

**Fix.** Before line 149, `[ -d "$scan_root" ] || { printf 'FAIL glossary-lint: scan root not found: %s\n' "$scan_root" >&2; exit 1; }`. One line, same shape as the
existing glossary check at line 75.

---

### F3 — MAJOR. Issue #19's prose marks an undelivered box as satisfied

**Breaks:** #19 is the only issue in this tranche left open, so it is the sole
record of what remains. Its acceptance preamble says:

> "Boxes 1, 2, 4, 5 and 6 were satisfied by pull requests that merged in tranche 1"

The boxes that actually carry a delivering-PR reference are **1, 2, 5, 6 and 7**.
Box **4** — *"A commit-subject task-ID cross-check: an ID in a commit subject
exists in `backlog.md` or `completed.md`"* — is annotated **"Added."** and names no
PR: it is new work, undelivered. Box 7 (the enforced-where table) is delivered and
excluded from the list.

The numbering is stale by one: inserting box 4 shifted the old 4/5/6 to 5/6/7, and
the preamble was not renumbered. A reader ticking "1, 2, 4, 5 and 6" in the landing
PR — which is exactly what the preamble instructs — ticks the commit-subject
cross-check that nobody wrote, and leaves the table box unticked.

**Fix.** Edit #19's preamble to read "Boxes 1, 2, 5, 6 and 7". Better: delete the
list from the preamble entirely — every satisfied box already names its PR inline,
so the summary line is a second copy that can drift, and just did.

---

### F4 — MINOR. `README.md` still says three linters run green; five do

`README.md:95-96`:

> the [ADR linter](docs/adr/adr-lint.sh), [PRD linter](docs/prd/prd-lint.sh), and
> [glossary linter](docs/glossary-lint.sh) run green out of the box.

`backlog-lint.sh` and `discipline-tests.sh` also run green out of the box, are
wired into the hook (`.githooks/pre-commit:35,41`) and both CI templates, and are
listed everywhere else — `.githooks/README.md:24`, `docs/ci/README.md:42-43`,
`docs/tests/README.md:47`, `AGENTS.md:121-122`.

**Breaks R10 sync**, and specifically #28's own commit `90fc8e8`, whose subject is
*"docs: T-8j4m bring the docs in step with five linters and their runner"* and
which touched `README.md` without fixing this sentence. #25 had established the
invariant as an explicit acceptance box (*"README … all count four discipline
tests, not three"*); #28 inherited it and missed one line.

**Fix.** Name all five, or drop the enumeration and say "the discipline linters run
green out of the box" so the sentence cannot go stale again.

---

### F5 — MINOR. `README.md` says the issue workflow is R1–R11

`README.md:49`: *"The issue-first workflow (R1–R11): the ticket policy the gate
assumes."* R12 has existed since T-9p4c. `AGENTS.md:64` and `AGENTS.md:150` both
say R1–R12, as does `README.md:33` and `README.md:46` — the same file disagrees
with itself two rows apart.

**Pre-existing, not introduced by this diff.** I flag it because three PRs in this
range (#25, #27, #28) ticked an acceptance box asserting R10 sync *including the
README*, and R10 says a conflict between governing documents stops work
(`docs/issue-workflow.md:122`). A per-PR R10 box that a stale line survives three
times is a box being ticked by intention rather than by check.

**Fix.** `R1–R11` → `R1–R12` in `README.md:49`. The durable fix is the same one
#19 box 3 already plans — a coverage check — extended to the README's R-range.

---

### F6 — MINOR. `glossary-lint.sh` needs git, and the kit claims its linters do not

`docs/prd/README.md:59` says the linters run *"anywhere with no toolchain … green
on a fresh kit"*; `backlog-lint.sh:8` repeats *"runs green on a fresh kit"*; #19's
solution note says *"POSIX shell, no toolchain, green on a fresh kit"*.

**Evidence** — the kit copied to a directory with no `.git`:

```
adr-lint: OK          exit 0
prd-lint: OK          exit 0
backlog-lint: OK      exit 0
FAIL  …/nogit holds Markdown that git does not track — the scan would cover
      nothing. Stage the files first (git add), then re-run.        exit 1
FAIL  glossary-lint.sh on docs/tests/glossary-lint/good: exit 1, expected 0
discipline-tests: 1 of 37 cases failed                              exit 1
```

Four of five linters honour the claim; `glossary-lint` does not, and takes the
runner down with it. The message is also wrong for this case — it says *"git add"*
when there is no repository to add to.

This is the right trade (the alternative is scanning untracked files, which #30
correctly rejected), so the fix is the wording, not the behaviour: say that
`glossary-lint` requires a git checkout, and give the "not a git repository" case
its own message.

---

## What I checked and found sound

- **All five checks pass on `main`:** `adr-lint: OK`, `prd-lint: OK`,
  `glossary-lint: OK`, `backlog-lint: OK`, `discipline-tests: OK (37 cases)`.
- **#30's hardest claim holds.** Re-ran with `GIT_DIR`/`GIT_INDEX_FILE` exported to
  simulate a hook: `glossary-lint: OK` and `discipline-tests: OK (37 cases)`,
  identical to the plain run. The `GIT_DIR` fix at `glossary-lint.sh:56` works.
- **Every `bad-*` fixture fails for the reason its name states.** I ran all 30
  `bad-*` cases individually and read the message: `bad-filename` →
  *"filename must be NNNN-kebab-case.md"*; `bad-unclosed-comment` → *"an HTML
  comment is opened and never closed"*; `bad-unclosed-fence` → *"a code fence is
  opened and never closed"*; and so on for all of them. F1 is that the *runner*
  does not assert this, not that the fixtures are wrong. They are not wrong.
- **The 37 cases are real and add up:** adr 6, prd 9, tasks 7, pr-link 10,
  glossary 5. `pr-link-lint.sh` takes a `BODY_FILE` argument (line 15), so the
  runner drives its 10 cases correctly rather than hanging on stdin.
- **Every relative link in every tracked Markdown file resolves.** The only
  non-resolving targets are `NNNN-short-title.md`, `<id>.md`, `‹id›.md` and `...`,
  all documented placeholders inside `<!-- -->` blocks or a template's Status line,
  all pre-dating this range. #24, #27 and #28's link boxes hold.
- **#24:** worktree `.claude/worktrees/feat+test-section-scaffold` gone; branch
  gone; `.gitignore` covers `.worktree/` and `.claude/worktrees/`; `git branch -a`
  shows only `main` remaining. The one box it left unticked (branch pruning as
  repo administration) is honest — the work is done, the box says why it is not a
  file change.
- **#26:** all five prompt files plus the README exist under `docs/review/`;
  `engineering-discipline.md` links them from §"Reviewing until findings decay"
  (lines 165-177) *and* from "How to adapt this kit" (lines 47-48); `README.md:55`
  and `AGENTS.md:53,156` name the directory. Every box holds.
- **#32:** all three corrections are on `main` — `AGENTS.md:80` R10 now says *"Keep
  **this file**, discipline, ADRs, guardrails…"*; `AGENTS.md:74` carries *"a model
  approving a workaround it proposed is one operator, not two"*, matching
  `issue-workflow.md` R4 word for word in substance; `AGENTS.md:106-107` exempts
  `HTML`, `URL`, `JSON`, matching the `STOPLIST` at `glossary-lint.sh:81`.
  `wc -w AGENTS.md` = **1460**, under the 1,500 budget.
- **#28:** `backlog-lint` does enforce one-line-per-task (`## Now`/`## Next` in
  backlog, `## Log` in completed — which is every task-bearing section those two
  files have), bracketed IDs, uniqueness within each file, and never-in-both. All
  five linters are wired into `.githooks/pre-commit` and into both
  `docs/ci/github-actions-ci.yml` and `docs/ci/gitlab-ci.yml`.
- **No pre-registered number moved.** The 1,500-word `AGENTS.md` budget is intact
  and was respected under pressure in #32 rather than raised. `31 → 37` is a case
  count, not a threshold, and it went up.
- **No ADR contradicted.** ADR-0004 predicted coverage-vs-agreement drift; #32 is
  the agreement check ADR-0004 said a machine could not do, done by hand and
  recorded. #32 is a correction inside ADR-0004's design, not a divergence, and it
  correctly declines to change the ADR.
- **No scope creep worth a finding.** #25's absorption of `glossary-lint.sh` from
  #19 is declared under R12 with the circular-dependency reasoning stated. #24's
  folding of the broken link into the hygiene slice is declared and justified.
- **Partial delivery handled correctly.** #28 left its last box unticked and kept
  #19 open rather than closing an issue whose final criterion was unmet — exactly
  the behaviour this lens asks for, and worth saying out loud.

## Hypotheses — stated, not verified

- **`discipline-tests.sh` has no fixtures of its own.** The gate for the gate is
  itself ungated; its only self-protection is the zero-case guard at line 99, which
  F1 shows is too narrow. I did not attempt to design a fixture set for a runner
  and do not know whether it is worth the recursion. Raising it because F1's fixes
  would themselves be untested.
- **`run_case` matches `good*` with a glob, not `good` or `good-*`.** A future
  fixture named `goodbye-case` would be silently expected to pass. I did not test
  this; the current sets contain no such name.
- **The `*/tests/*` skip at `glossary-lint.sh:168` does not match a repo-root
  `tests/` directory**, because `*` cannot supply the leading `/`. Today the root
  `tests/` holds only a `.gitkeep`, so nothing is affected. If an adopter drops
  Markdown fixtures there, they would be scanned as prose. Read from the glob, not
  executed.

---

**Verdict.** No blocker; the machinery works for the fixtures it runs, and I could
not falsify a single one of the 30 `bad-*` cases. But the pattern #29 and #31
named is not exhausted: F1 and F2 are two more instances of *reports OK having
checked less than it claims*, this time in the runner built to catch that class
and in the linter last fixed for it. F1's table row is the one that matters most —
it is the kit telling an adopter that a property is `Enforced` when the shipped
code checks a weaker property, in a table whose own preamble promises honesty.



---

### Comment — pharzam — 2026-08-27T08:05:06Z

## Gate step 5, round 3 of 4 — clean and simple

Reviewer: an agent in a fresh context, handed `docs/review/simple.md` verbatim.
Posted unedited.

**M2 is verified and it is a bug, not a tidiness point.** Reproduced against a
clean `git archive` of `999765f`: the same undefined token appended to both
`docs/tests/test-levels.md` and `docs/guardrails.md` is reported for one file only.

```
$ sh docs/glossary-lint.sh
FAIL  abbreviation "ZQXW" is used but has no glossary row (in: docs/guardrails.md )
```

Ten committed prose documents under `docs/tests/` are outside a scan that
`engineering-discipline.md` and `AGENTS.md` both say covers **every** abbreviation
in committed Markdown. That is the fourth instance of the class #29 and #31 named,
and the widest one so far — a whole directory, not one file.

The reviewer flagged it as out-of-lens and reported it anyway. That was right.

---

# Round 3 — clean and simple

Lens: [`docs/review/simple.md`](../docs/review/simple.md). Range `2cd70ee..999765f`
(67 files, ~1,659 insertions). Fresh context; the author's reasoning was not
available to me and I did not ask for it.

Verdict: the **shell is not the problem** — the duplication people expect to find
there is small and each copy earns its keep. The problem is **prose**: one decision
(which discipline linters the kit ships) is written out in sixteen places, and three
of them already disagree with each other today.

---

## MAJOR

### M1 — `.githooks/pre-commit:9` describes a hook that no longer exists

The hook body was edited in this very diff: step `1.` became `1a.`, and `1c`, `1d`,
`1e` were added (lines 28–44), so the hook now runs five checks. Its own header
comment, eleven lines above the change, still says:

```
# It runs the ADR and PRD linters out of the box (docs-only, no toolchain needed). The
```

Fix — `.githooks/pre-commit:9`:

```
# It runs the ADR, PRD, glossary, and backlog linters and the linters' own fixture
# tests out of the box (docs-only, no toolchain needed). The
```

This is `AGENTS.md:32` ("Never land a change that leaves a document stale. Same pull
request, or not at all") broken inside the file the change was editing, and it is
the exact defect `docs/engineering-discipline.md:509-516` ("Code comments") warns
about. `.githooks/README.md:24` *was* updated correctly in the same PR — the hook's
own header was the one that got missed.

### M2 — `docs/glossary-lint.sh:168-171` exempts ten real prose documents

```sh
case "$f" in
	*/tests/*README.md) : ;;
	*/tests/*)           continue ;;
esac
```

The intent is "skip fixtures". The rule written is "skip anything under a directory
named `tests/`" — and `docs/tests/` is not a fixture directory, it is the kit's
test-conventions section. Ten committed prose documents are silently outside the
scan:

```
docs/tests/test-levels.md          docs/tests/template-unit.md
docs/tests/dod-checklist.md        docs/tests/template-integration.md
docs/tests/scaling-checklist.md    docs/tests/template-e2e.md
docs/tests/security-checklist.md   docs/tests/template-uat.md
docs/tests/traceability-template.md  docs/tests/example-fact-to-test.md
```

Verified on a scratch copy of `999765f`: appending the same undefined token `ZQXW`
to both `docs/tests/test-levels.md` and `docs/guardrails.md` reports only
`docs/guardrails.md`. So `docs/engineering-discipline.md:303-304` ("Every
abbreviation in a committed Markdown file has a row") and `AGENTS.md:104-105` are
not true as written.

**Out-of-lens** (correctness, not tidiness) — reported because a bug outranks
tidiness, and because it is precisely the "test that passes for the wrong reason"
that this script's own header (lines 29-31) and `guardrails.md` name.

The simpler rule is also the correct one: key the skip on the **fixture naming
convention** (`good*` / `bad-*`) that `docs/tests/discipline-tests.sh:50-54` already
reads, instead of on a directory name. Four lines become three:

```sh
	# A fixture is an input to a linter, not documentation: its contents are
	# deliberately malformed, so scanning them for vocabulary is meaningless.
	# Keyed on the good*/bad-* fixture naming that discipline-tests.sh reads —
	# a directory that merely happens to be called tests/ is prose.
	case "$f" in
		*/good/*|*/good-*|*/bad-*) continue ;;
	esac
```

Verified on the scratch copy: `glossary-lint: OK` on the clean tree,
`discipline-tests: OK (37 cases)`, and `ZQXW` in `docs/tests/test-levels.md` is now
caught. The fixture READMEs that should stay in scope
(`docs/adr/tests/README.md`, `docs/tasks/tests/README.md`,
`docs/tests/glossary-lint/README.md`) still are; the per-case index READMEs are
correctly skipped as part of the fixture.

Note the same rewrite makes `docs/tests/glossary-lint/README.md:12-15` accurate —
it currently explains the `tests/` skip and its one README exception, and that whole
paragraph shrinks to one sentence.

### M3 — one decision, sixteen places, three already in disagreement

"Which discipline linters does the kit ship, and where does each run" is currently
written out at:

| # | Where |
| - | ----- |
| 1 | `.githooks/pre-commit:18-44` (the code) |
| 2 | `.githooks/pre-commit:9` (header comment) — **wrong today**, see M1 |
| 3 | `.githooks/README.md:24` |
| 4 | `docs/ci/github-actions-ci.yml` (jobs) |
| 5 | `docs/ci/gitlab-ci.yml` (jobs) |
| 6 | `docs/ci/README.md:39-48` (table) |
| 7 | `docs/ci/README.md:50-55` (prose) — **wrong today** |
| 8 | `docs/tests/discipline-tests.sh:90-94` (the manifest) |
| 9 | `docs/tests/README.md:47` |
| 10 | `docs/tests/test-levels.md:93-98` ("The kit ships five") |
| 11 | `docs/engineering-discipline.md:83-85` (hook list) |
| 12 | `docs/engineering-discipline.md:95-100` ("Confirm the discipline linters run") |
| 13 | `docs/engineering-discipline.md:416-436` (the roster sentence) |
| 14 | `docs/engineering-discipline.md:452-455` (CI authority list) |
| 15 | `docs/engineering-discipline.md:477-482` (pre-commit description) |
| 16 | `docs/issue-workflow.md:173-185` (enforced-where table) + `AGENTS.md:116-123` + `README.md:44-61, 92-96` |

The two live disagreements besides M1:

- `README.md:95-96` — "the [ADR linter], [PRD linter], and [glossary linter] run
  green out of the box". `backlog-lint.sh` and `discipline-tests.sh` also run green
  out of the box and are also wired into the hook and both CI templates. Fix: "the
  discipline linters ([`docs/tests/discipline-tests.sh`](docs/tests/discipline-tests.sh)
  lists them) run green out of the box."
- `docs/ci/README.md:53` — "wire it into both a CI job and the `pre-commit` hook,
  the way `adr-lint`, `prd-lint`, and `glossary-lint` are." The table five lines
  above lists all five. Fix: delete the trailing clause — "…wire it into both a CI
  job and the [`pre-commit`](../../.githooks/pre-commit) hook, like the rows above."

Seven of the sixteen are genuinely different machines' inputs and must each carry
the list: the hook, the two CI templates, the runner manifest, and the three
README/table indexes (`docs/ci/README.md:39-48`, `.githooks/README.md:24`,
`docs/issue-workflow.md:173-185`). The other nine are prose restating them. Concrete
deletions that cost nothing:

1. **Delete the counts.** `docs/engineering-discipline.md:416` "the kit ships five
   tests of its own conventions" and `docs/tests/test-levels.md:93` "The kit ships
   five:" — a count is the first thing to go stale (it already said "three" before
   this diff) and buys the reader nothing the list beneath it does not. Both become
   "the kit ships:".
2. **Delete the enumeration at `docs/engineering-discipline.md:83-85`** and replace
   with "…the `pre-commit` hook runs the [discipline linters](#testing) and their own
   [fixture tests](#testing), plus the fast gate you fill in." Same for
   `:477-482`.
3. **Delete `docs/engineering-discipline.md:417-431`** — see M4 — and point at
   `docs/ci/README.md`'s table, which is already the one place that says
   linter → what it lints → ready-or-adapt.

That takes sixteen sites to nine and removes every one that is currently wrong.

`AGENTS.md:53` is the pattern to copy: it points at `docs/review/` rather than
restating the four lenses. `AGENTS.md:116-123` is the counter-example.

### M4 — `docs/engineering-discipline.md:417-431`: one sentence, fifteen lines, four "and"s

Lines 417-431 are a single sentence describing five linters, joined by a repeating
`— and —` that was clearly extended twice:

> `adr-lint.sh` lints … — `prd-lint.sh` lints … — and `glossary-lint.sh` lints … —
> and `tasks/backlog-lint.sh` lints … — and `ci/pr-link-lint.sh` checks …

No reader parses this. It is also the third copy of the roster (M3). Replace lines
417-431 with:

```markdown
| Linter | Lints | Runs in |
| ------ | ----- | ------- |
| [`adr/adr-lint.sh`](adr/adr-lint.sh) | Filenames, numbering, required sections, the index, cross-links | hook + CI |
| [`prd/prd-lint.sh`](prd/prd-lint.sh) | Requirement IDs, a resolvable cited fact, MoSCoW, phase, the matrix | hook + CI |
| [`glossary-lint.sh`](glossary-lint.sh) | Table shape, duplicate and empty rows, a row per abbreviation | hook + CI |
| [`tasks/backlog-lint.sh`](tasks/backlog-lint.sh) | One line per task, stable ids, never both "Now" and done | hook + CI |
| [`ci/pr-link-lint.sh`](ci/pr-link-lint.sh) | A PR body links its issue ([R1](issue-workflow.md#r1--issue-first)) | CI only — the PR body is a forge artifact absent at commit time |
```

Keep lines 431-436 as prose: "They read only text, so they need no toolchain…" and
"Add a discipline test whenever a convention is worth enforcing automatically" are
rules, not roster. 15 lines → 8, and the "CI only" reason moves next to the row it
explains instead of trailing the sentence.

### M5 — `README.md:49` says R1–R11

```markdown
| [`docs/issue-workflow.md`](docs/issue-workflow.md) | The issue-first workflow (R1–R11): the ticket policy the gate assumes. |
```

Every other file in the repository says R1–R12 (`AGENTS.md:64,150`,
`docs/engineering-discipline.md:58,153`, `docs/onboarding-for-engineers.md:75`,
`docs/glossary.md:54`, and `README.md:33` and `README.md:46` — the two lines
immediately above and below it, both added by this diff). Fix: `R1–R11` → `R1–R12`.

`docs/adr/0003-adopt-issue-first-workflow.md:22` also says R1–R11 and is **correct
as-is** — an ADR is a dated record of a decision, and
`docs/engineering-discipline.md:236-238` says a correction is a new record, not an
edit. Leave it; do not let a future sweep "fix" it.

---

## MINOR

### m1 — `docs/engineering-discipline.md:83-85`: a stranded conjunction

```
  [ADR linter](#testing), the [PRD linter](#testing), and the
  [glossary linter](#testing), the [backlog linter](#testing), and the
  [discipline-test runner](#testing), plus the fast gate you fill in.
```

Two `and`s; the first is left over from when the list ended at the glossary linter.
Subsumed by M3.2 if that is taken; otherwise delete the `and ` on line 83.

### m2 — `docs/review/correctness.md:3-6` is the odd one of five siblings, and names a vendor

Four of the five prompt files carry an identical two-line note. `correctness.md`
carries a four-line variant that adds `(for example \`.claude/commands/\`, a Cursor
rule, or a saved prompt)`. Two problems, one fix:

- Style drift across a set of files that exist to be read side by side.
- It is the only place in the kit that names a specific agent tool.
  `AGENTS.md:24-25` says "Never name a language, framework, or test runner outside a
  `‹…›` placeholder", and
  `docs/adr/0004-ship-a-root-agents-file.md:50-53` rejected `CLAUDE.md`-alone on
  exactly this principle ("It names one vendor").

Fix — make `correctness.md:3-6` byte-identical to the other four:

```markdown
> **Inert asset.** Copy this into wherever your agent runner reads prompts from.
> Nothing runs it from here. See [`README.md`](README.md).
```

The vendor-neutral form of those examples already exists in
`docs/review/README.md:47-49` ("a commands directory, a rules file, a saved
prompt"), which is where a reader of the set will look.

### m3 — `docs/tasks/backlog-lint.sh:134-144` runs `uniq -d` twice and drifts from the block below it

```sh
dupes() {
	uniq -d < "$1" | while IFS= read -r id; do
		[ -n "$id" ] && printf 'FAIL  duplicate task id "%s" in %s\n' "$id" "$2" >&2
	done
}
if [ -s "$tmp/backlog.ids" ]; then
	d=$(uniq -d < "$tmp/backlog.ids"); [ -n "$d" ] && { dupes "$tmp/backlog.ids" "$(basename "$backlog")"; fail=1; }
fi
if [ -s "$tmp/completed.ids" ]; then
	d=$(uniq -d < "$tmp/completed.ids"); [ -n "$d" ] && { dupes "$tmp/completed.ids" "$(basename "$completed")"; fail=1; }
fi
```

`uniq -d` runs twice per file: once into `$d`, which is then discarded, and again
inside `dupes`. The `[ -s ]` guard is dead — `uniq -d` on an empty file prints
nothing, so `[ -n "$d" ]` already covers it. And the `both=` block four lines below
(`:148-155`) does the same job in the clean shape: compute once, test, loop, set
`fail=1`. Make the two match:

```sh
dupes() {
	d=$(uniq -d < "$1")
	[ -z "$d" ] && return 0
	printf '%s\n' "$d" | while IFS= read -r id; do
		[ -n "$id" ] && printf 'FAIL  duplicate task id "%s" in %s\n' "$id" "$2" >&2
	done
	fail=1
}
dupes "$tmp/backlog.ids"   "$(basename "$backlog")"
dupes "$tmp/completed.ids" "$(basename "$completed")"
```

11 lines → 10, one idiom instead of two in the same file, and no double scan.

### m4 — `docs/glossary-lint.sh`: a documented call shape nothing uses

`:15-17` documents `sh docs/glossary-lint.sh [GLOSSARY] [SCAN_ROOT]`, and `:68-69`
implements it. Nothing in the repository ever passes a second argument, and nothing
passes a file as the first — `docs/tests/discipline-tests.sh:94` passes a
*directory*, and the hook and both CI templates pass nothing. So the `else` branch's
`${1:-…}` and `${2:-…}` are an untested code path inside a linter whose whole job is
to be trustworthy. Delete the two-argument form from the header and simplify
`:64-70`:

```sh
if [ -d "${1:-}" ]; then
	glossary=$1/glossary.md
	scan_root=$1
else
	glossary=$script_dir/glossary.md
	scan_root=$(dirname "$script_dir")
fi
```

The **directory** form stays — that one is load-bearing, see "Complex for a good
reason" below.

### m5 — `docs/tests/discipline-tests.sh:12-13, 35`: `[REPO_ROOT]` has no caller

`repo_root=${1:-$(dirname "$(dirname "$script_dir")")}` — the default is right for
every caller (hook, both CI templates, and a bare `sh docs/tests/discipline-tests.sh`),
and no caller overrides it. A parameter with zero callers. Delete the argument and
the usage line; keep the derived value. Small, but this is the one script whose
correctness the whole gate rests on, so a second untested way to invoke it is worth
losing.

### m6 — `docs/glossary-lint.sh:21-26` is the third copy of the CLI/TUI/GUI anecdote

The "SCOPE, stated honestly" block restates
`docs/engineering-discipline.md:303-314` (which is the authority) and
`AGENTS.md:104-112` (the sanctioned summary), down to repeating the anecdote:

- `engineering-discipline.md:312-314` — "…which is exactly how `CLI`, `TUI`, and
  `GUI` came to sit undefined inside the very document that states the rule…"
- `glossary-lint.sh:25-26` — "…and this one had: CLI, TUI, and GUI sat undefined
  inside the very file that states it."

Replace `:21-26` with one line:

```sh
# SCOPE. This enforces the checkable half of the rule — committed Markdown.
# docs/engineering-discipline.md#glossary states both halves and why.
```

Keep `:28-31` ("KNOWN LIMIT"): that states a limit of *this code* that the code
cannot show, which is exactly what
`docs/engineering-discipline.md:509-516` says a comment is for. Six lines saved, and
one fewer copy of a story that reads as stale the moment those three rows change.

### m7 — `README.md:46` restates a number that `README.md:33` just gave

Lines 33 and 46 both say "under 1,500 words"; `docs/adr/0004-…:35` says it a third
time as the actual decision. `AGENTS.md` is 1,460 words today — 40 words of
headroom, and it grew by ~100 in this diff (T-4v7h). Drop it from the table row at
`:46`, which is an index entry, not a sales pitch:

```markdown
| [`AGENTS.md`](AGENTS.md) | The agent entry point: the gate and R1–R12 compressed. [`CLAUDE.md`](CLAUDE.md) points to it. |
```

`docs/tasks/completed.md:23` also says "1,360 words" and is **correct as-is** — a
dated log entry records what shipped that day. Leave it.

---

## Complex for a good reason — leave these alone

I checked each of these because they are what a duplication review normally
flags. None should change.

- **Per-case `README.md` files under `docs/adr/tests/*/`** (six near-identical
  five-line files). `adr-lint.sh:34` requires an index README and `:131` checks that
  each ADR has a row in it, so every fixture case *must* ship one — and
  `docs/adr/tests/bad-no-index/README.md` differs by exactly the missing row that is
  the point of that case. Real fixtures, not copy-paste.

- **`err()`, the `mktemp -d` + `trap` pair, and the `…-lint: OK` tail, repeated
  across four linters.** One to two lines each. A shared `lib.sh` would add a
  sourcing path that has to resolve from the hook, from CI, from
  `discipline-tests.sh`, and from a bare command line — a real portability
  surface — to save six lines. The lens's own churn test rejects it. The scripts
  being standalone POSIX files with no dependency is the property
  `docs/adr/0004-…:56-58` says the kit is protecting.

- **`backlog-lint.sh`'s HTML-comment stripping vs `glossary-lint.sh`'s code-fence
  stripping.** These are not two copies of one thing. `<!-- … -->` spans lines and
  nests inside a line (`:44-70`); ` ``` ` toggles a mode and cannot nest
  (`:173-174`). Different grammars, different failure modes, different error
  messages. Only two of the five linters do any stripping, not three — `adr-lint.sh`
  and `prd-lint.sh` do none. Genuinely different.

- **`glossary-lint.sh:64-70`'s directory-argument form.** It exists so
  `discipline-tests.sh` can drive every linter with one uniform argument
  (`:44-66`). The alternative — a per-linter argument template in the runner — moves
  the special case into the file that most needs to stay simple. Right call.

- **`glossary-lint.sh:38-56`'s `LC_ALL=C` and `unset GIT_DIR` blocks and their long
  comments.** Both state constraints the code cannot show, and both describe silent
  failure modes (a multibyte abort, a hook answering differently from the command
  line). Exactly the comments `engineering-discipline.md:509-516` says to keep.

- **The `__UNCLOSED_FENCE__` sentinel** (`glossary-lint.sh:205, 211, 220`). In-band
  signalling normally deserves a flag, but the alternative is a second pass over
  every file to answer one boolean. Weighed and dropped.

- **`backlog-lint.sh:111-132`'s `ids_of()` with its `grp` parameter.** Two call
  sites passing literal `1` and `2`, so it is legitimately parameterized, and the
  awk is whitespace-tolerant in a way the two-line `sed` equivalent is not. Weighed
  and dropped.

- **The "Inert asset" note repeated in all five `docs/review/*.md` prompts.** Each
  file is meant to be copied out on its own; the note must travel with it.
  Deliberate. (The *variant* wording in `correctness.md` is m2 — the repetition
  itself is right.)

- **`AGENTS.md` restating the gate and R1–R12.** Decided, costed, and mitigated in
  `docs/adr/0004-ship-a-root-agents-file.md:60-86`, which names the drift risk
  outright. Not reopening a recorded decision in a tidiness lens.

---

## Checked and clean

- **Links and anchors.** I resolved every relative Markdown link and every
  `#anchor` across all committed `.md` files against the actual heading slugs.
  All resolve. The one hit — `docs/adr/template.md:7 → NNNN-short-title.md` — is
  the template's own placeholder and is correct.
- **`docs/ci/tests/pr-link/README.md:3`** — the `../` → `../../` fix in this diff is
  right.
- **`docs/review/simple.md` against `docs/review/README.md:22-28` and
  `docs/engineering-discipline.md:165-170`** — lens names, order, and round numbers
  agree in all three.
- **`docs/tests/discipline-tests.sh`** — 37 cases, five linters, green on a clean
  checkout of `999765f` and green under the M2 rewrite.
- **`.gitignore:4-9`** — carries the `‹worktree dir›` marker inside the comment, so
  `AGENTS.md:132`'s "Search for `‹` to find every one" finds it. Done right.

---

## What I would fix first

M1 and M5 are one-line edits that remove statements which are false today. M2 is a
three-line rewrite that restores ten documents to a scan that claims to cover them —
and it is the only finding here that is a bug rather than a preference. M3 and M4
are the structural one: the count of linters is written down enough times that this
diff already got it wrong twice, and the fix is deletion, not new machinery.

No `BLOCKER` in this lens by definition, and I found nothing that would warrant one.

Method note: all experiments ran against a `git archive` copy of `999765f` under
`/private/tmp/claude-501/-Users-farzam-projects-armature/8ac959d1-a78b-497d-8ffc-b94e4db5e205/scratchpad/work-simple/kit`.
No tracked file was modified; the working tree is clean.



---

### Comment — pharzam — 2026-08-27T08:07:52Z

## Gate step 5, round 1 of 4 — correctness and failure modes

Reviewer: an agent in a fresh context, handed `docs/review/correctness.md` verbatim.
Posted unedited. Eleven findings, six MAJOR.

**I re-verified the three sharpest against a clean `git archive` of `999765f`, with
`core.hooksPath=.githooks` enabled. All three reproduce exactly.**

### M4 is the most serious thing this whole round found

The pre-commit hook lints the **working tree**, not the index. Stage a violation,
tidy the working copy, commit — the gate prints five greens and the violation lands:

```
$ printf "This doc uses ZQXSTAGED which is undefined.
" > docs/staged-demo.md
$ git add docs/staged-demo.md
$ sh docs/glossary-lint.sh
FAIL  abbreviation "ZQXSTAGED" is used but has no glossary row (in: docs/staged-demo.md )

$ printf "This doc is clean prose now.
" > docs/staged-demo.md   # index untouched
$ git commit -m "docs: demo staged bad content"
adr-lint: OK
prd-lint: OK
glossary-lint: OK
backlog-lint: OK
discipline-tests: OK (37 cases)

$ git show HEAD:docs/staged-demo.md
This doc uses ZQXSTAGED which is undefined.      <- what landed
```

`glossary-lint.sh:53-55` claims the opposite in a comment: *"The staged index is
still what git reads, so a pre-commit run still sees what is about to land."* Only
the **file list** comes from the index; every byte of **content** comes from disk.
That comment was added by #30 — the pull request written to stop this exact class.

### M6 and M2, also re-verified

```
# M6 — a task id mentioned outside ## Now / ## Next:
FAIL  task id "T-4v7h" is in BOTH backlog.md and completed.md — move it, do not copy it
      (there is nothing to move; the message misdirects the reader into deleting a correct line)

# M2 — a committed non-ASCII path:
$ git ls-files "docs/caf*"
"docs/caf\303\251.md"
$ sh docs/glossary-lint.sh
glossary-lint: OK        <- the undefined abbreviation in it is never seen
```

---

# Round 1 — correctness and failure modes

Lens: `docs/review/correctness.md`. Range `2cd70ee..999765f` (67 files, ~1659
insertions). Fresh context; the author's reasoning was not consulted.

All five linters pass on `main` today. Everything below was **reproduced**, on a
copy of the repository, unless it appears under "Hypotheses". The repository
working tree is clean; nothing tracked was modified.

---

## BLOCKER

None. No finding below corrupts data or produces a wrong *value*. But four of the
six MAJORs are the class named as most expensive here — **a check that reports
`OK` having checked less than it claims** — and one of them is in the runner that
is supposed to catch exactly that.

---

## MAJOR

### M1 — The runner treats "linter exited 1" as "the fixture was rejected for its own reason". Delete three fixtures entirely and it still prints `OK (37 cases)`.

**File:** `docs/tests/discipline-tests.sh:56-65` (`sh "$_linter" "$_target"`;
`[ "$_got" -eq "$_want" ]`).

**Concrete failure.** On a copy of the repo:

```
rm -f docs/tests/glossary-lint/bad-undefined/doc.md \
      docs/tests/glossary-lint/bad-undefined/glossary.md \
      docs/tasks/tests/bad-dup-id/backlog.md \
      docs/tasks/tests/bad-dup-id/completed.md \
      docs/adr/tests/bad-status/0001-sample.md \
      docs/adr/tests/bad-status/README.md
sh docs/tests/discipline-tests.sh
```

Output: `discipline-tests: OK (37 cases)`, exit 0. The three cases "passed"
because the linters exited 1 for:

```
FAIL  glossary not found: docs/tests/glossary-lint/bad-undefined/glossary.md
FAIL  missing docs/tasks/tests/bad-dup-id/backlog.md (the task index)
FAIL  missing docs/adr/tests/bad-status/README.md (the ADR index)
```

— not for "undefined abbreviation", "duplicate task id", or "bad Status". This is
the false green the prompt asked to be checked for, and it is structural: exit
status 1 is the *only* rejection code every linter has, so `run_case` cannot
distinguish a real rejection from a missing file, a broken `mktemp`, or an awk
syntax error. The case count is not pinned either, so `rm -rf` on a whole fixture
set drops the count to 34 and still prints `OK`.

**Fix.** Assert on the *reason*, not the code. Give each `bad-*` fixture a
sibling `expect` file holding a fixed string (`duplicate task id`, `Status
'Maybe' is not one of`, …); in `run_case`, capture stderr and require
`grep -qF -f "$_target/expect"` for `bad-*` cases. Additionally pin the total:
`run_set` should fail, not silently continue, when a fixture root yields zero
cases, and the manifest should carry the expected case count per set.

---

### M2 — `glossary-lint` silently skips every committed Markdown file whose path is non-ASCII, and reports `OK`.

**File:** `docs/glossary-lint.sh:149` (`git ls-files '*.md'`) and `:163-164`
(`[ -f "$scan_root/$f" ] || continue`).

**Concrete failure.** `git ls-files` quotes non-ASCII paths by default
(`core.quotePath=true`):

```
$ printf 'A doc using ZQXNOTDEFINED here.\n' > 'docs/café.md'
$ git add 'docs/café.md'
$ git ls-files 'docs/caf*'
"docs/caf\303\251.md"                 <- literal quotes and octal escapes
$ sh docs/glossary-lint.sh
glossary-lint: OK                      <- exit 0
```

The loop reads the quoted string as the filename, `[ -f "$scan_root/$f" ]` is
false, and `continue` drops the file **without a word**. An undefined
abbreviation in it never reaches the gate. This matters here specifically: the
kit's own house style uses `‹…›`, em dashes and IPA, so non-ASCII filenames are
not exotic for an adopter, and the same `continue` also swallows a file listed in
the index but absent from the working tree.

Confirmed the fix works: `git -c core.quotePath=false ls-files 'docs/caf*'` prints
`docs/café.md`, and the scan then finds `ZQXNOTDEFINED`. Filenames containing
spaces are *not* affected (verified — `docs/my note.md` is scanned correctly).

**Fix.** Two changes, both needed:
1. `git -c core.quotePath=false ls-files '*.md'` at line 149.
2. Make the skip loud — `[ -f "$scan_root/$f" ] || { err "listed by git but not
   readable: $f"; continue; }`. The silent `continue` is the deeper defect; a
   linter whose job is "no green that was not earned" must never drop an input
   quietly. (A path containing a newline still defeats a line-oriented read; if
   that matters, `git ls-files -z` with a NUL-safe loop.)

---

### M3 — The `*/tests/*` fixture exclusion silently removes ten genuine documentation files from the scan, including `test-levels.md` and `security-checklist.md`.

**File:** `docs/glossary-lint.sh:168-171`.

**Concrete failure.** The pattern excludes everything under any `tests/`
directory except a `README.md`. That is not just fixtures — `docs/tests/` is a
real documentation directory:

```
docs/tests/dod-checklist.md          docs/tests/template-e2e.md
docs/tests/example-fact-to-test.md   docs/tests/template-integration.md
docs/tests/scaling-checklist.md      docs/tests/template-uat.md
docs/tests/security-checklist.md     docs/tests/template-unit.md
docs/tests/test-levels.md            docs/tests/traceability-template.md
```

All ten are committed Markdown and all ten are unscanned. Demonstrated:

```
$ printf '\nThis line uses ZQXHIDDEN.\n' >> docs/tests/test-levels.md
$ sh docs/glossary-lint.sh
glossary-lint: OK                                    <- exit 0
$ printf '\nThis line uses ZQXHIDDEN.\n' >> docs/onboarding-for-engineers.md
$ sh docs/glossary-lint.sh
FAIL  abbreviation "ZQXHIDDEN" is used but has no glossary row (in: docs/onboarding-for-engineers.md )
```

`AGENTS.md:104` states "every abbreviation that appears in committed Markdown has
a glossary row" and `docs/engineering-discipline.md:303` says "**Enforced —
committed Markdown.** Every abbreviation in a committed Markdown file …". Ten
committed Markdown files are outside the enforcement. Also note `test-levels.md`
was itself edited in this diff, so it is a live, maintained document.

I re-ran the scan with the exclusion narrowed to true fixture inputs: **no
abbreviation is hiding in those ten files today**, so this is a hole rather than
a current wrong answer. It closes the moment anyone writes `SLO`, `SLA`, or `RTO`
into `security-checklist.md`.

**Fix.** Exclude the fixture *inputs*, not the directory:

```sh
case "$f" in
    */tests/bad-*/*|*/tests/*/bad-*/*|*/tests/good/*|*/tests/*/good/*|\
    */tests/facts/*|*/tests/pr-link/bad-*|*/tests/pr-link/good-*) continue ;;
esac
```

or, more robustly, mark fixture roots with a sentinel file (`.lint-fixtures`) and
exclude any path under a directory containing one.

---

### M4 — The pre-commit hook lints the working tree, not the index. The comment in the script claims the opposite, and a commit carrying an undefined abbreviation goes through with `glossary-lint: OK`.

**File:** `docs/glossary-lint.sh:53-55` — *"The staged index is still what git
reads, so a pre-commit run still sees what is about to land."* — against
`:206` (`awk … "$scan_root/$f"`, which reads the working tree).

Only the *file list* comes from the index; every byte of *content* comes from
disk. Demonstrated end to end with `core.hooksPath=.githooks` enabled:

```
$ printf 'This doc uses ZQXSTAGED which is undefined.\n' > docs/staged-demo.md
$ git add docs/staged-demo.md
$ sh docs/glossary-lint.sh
FAIL  abbreviation "ZQXSTAGED" is used but has no glossary row (…)

$ printf 'This doc is clean prose now.\n' > docs/staged-demo.md   # index untouched
$ git commit -m "docs: demo staged bad content"
adr-lint: OK
prd-lint: OK
glossary-lint: OK              <- the hook is satisfied
…
$ git show HEAD:docs/staged-demo.md
This doc uses ZQXSTAGED which is undefined.     <- what actually landed
```

The reverse is also reproducible and equally wrong: stage the fix, leave the
working tree broken, and the hook blocks a commit whose staged content is clean.
This is the ordinary `git add -p` / stage-then-keep-editing workflow, and it is
the default workflow for an agent editing files between `git add` and `git
commit`.

**Fix.** Either (a) read staged content in the hook —
`git show ":$f" | awk …` when `$GIT_INDEX_FILE`/hook context is detected, or a
`--staged` flag the hook passes; or (b) if reading the working tree is the
deliberate choice, delete the claim at lines 53-55 and say so: "reads the working
tree; stage-then-edit is not covered." Right now the comment asserts a property
the code does not have, which is the one thing the lens says not to trust.

---

### M5 — The code-fence tracker is not Markdown-correct in three common shapes, producing false `FAIL`s that block clean commits.

**File:** `docs/glossary-lint.sh:173-174`
(`/^[ \t]*```/ { infence = !infence; next }`).

Three reproductions, each on a committed file, each exiting 1:

| Input | Result |
|---|---|
| A `~~~sql` fenced block containing `SELECT ZQXTILDE FROM t;` | `FAIL abbreviation "FROM" …` and `FAIL abbreviation "SELECT" …` |
| A four-space-indented code block `    export ZQXINDENT=1` | `FAIL abbreviation "ZQXINDENT" …` |
| A four-backtick fence wrapping a three-backtick fence | `FAIL abbreviation "ZQXNEST" …` (the inner ` ``` ` closes the outer fence) |

Tilde fences and indented code are standard CommonMark; the nested-fence shape is
exactly what a document that *documents fences* uses — which this kit does. Every
one of these blocks a correct commit, and `guardrails.md`'s own warning applies:
a linter that cries wolf gets switched off.

**Fix.** Track the opening fence's character and run length and close only on a
line of the same character with a run at least as long — the CommonMark rule:

```awk
/^[ \t]{0,3}(```+|~~~+)/ {
    m = $0; sub(/^[ \t]*/, "", m); ch = substr(m, 1, 1)
    n = 0; while (substr(m, n + 1, 1) == ch) n++
    if (!infence)      { infence = 1; fch = ch; flen = n }
    else if (ch == fch && n >= flen && m ~ /^[`~]+[ \t]*$/) infence = 0
    next
}
infence { next }
/^[ \t]{4,}/ && !inlist { next }   # indented code block
```

The `END { if (infence) … }` sentinel stays, and stays correct.

---

### M6 — `backlog-lint` collects task IDs from every section of `backlog.md`, not only `## Now` and `## Next`, so a cross-reference in any other section is falsely reported as "in BOTH files".

**File:** `docs/tasks/backlog-lint.sh:111-132` (`ids_of` matches `/^- \*\*/`
anywhere in the file), against `:78-82`, where the format check correctly
restricts itself to `Now`/`Next`.

**Concrete failure.** Append a notes section that mentions an already-completed
task — a natural thing to do, and legal under the file's own conventions, since
the linter itself treats only `Now`/`Next` as task sections:

```
## Notes

- **T-4v7h** — a reference to an already-completed task, not a task entry
```

Result on today's `main`:

```
FAIL  task id "T-4v7h" is in BOTH backlog.md and completed.md — move it, do not copy it
```

There is nothing to move. The message actively misdirects the reader toward
deleting a correct line.

**Fix.** Give `ids_of` the same section gate the format check has: track
`/^## /`, and only emit IDs while `insec` is true. Same for `completed.md` and
its `## Log` section.

---

## MINOR

### m1 — `backlog-lint.sh` does not set `LC_ALL=C`, although its sibling documents at length why it must.

`docs/glossary-lint.sh:40-47` explains that several `awk` implementations abort
with "multibyte conversion failure" on this repository's `‹…›` and em dashes, and
that the abort is silent in a pipeline. `docs/tasks/backlog-lint.sh` has no such
guard (`:25`, only `set -u`) and its `awk` programs match a **literal em dash**
(`:87`, `:102`) and a literal `—` in `strip_comments` output. Its `sort` /
`uniq -d` / `comm -12` chain (`:131-155`) is likewise locale-dependent where
`glossary-lint`'s is not.

I could **not** make this fail: `LC_ALL` in `C`, `en_US.UTF-8`, `tr_TR.UTF-8`,
and `C.UTF-8` all gave identical, correct results for `backlog.md` and all six
`bad-*` fixtures, on macOS `awk version 20200816` and under `/bin/dash`. So this
is fragility, not a demonstrated defect — but it is one line, and the identical
concern is already documented as load-bearing next door.

**Fix.** Add `LC_ALL=C; export LC_ALL` after `set -u`, with a pointer to the
comment in `glossary-lint.sh`.

### m2 — The header comment promises "no empty cell"; column 2 (`Abbr.`) is never checked.

`docs/glossary-lint.sh:9-11` says the table check enforces "four cells per row,
no duplicate term, no empty cell". The loop at `:117-122` runs `for (i = 3; i <= 4; i++)`
— Description and Example only. Verified: blanking the `Abbr.` cell of
`docs/tests/glossary-lint/good/glossary.md` produces no table-shape error (the
run only fails downstream, because the term is then undefined).

An em dash in `Abbr.` is legitimate, so leaving column 2 unchecked may well be
intentional — in which case the fix is to the comment, not the code. Either way
the two disagree today.

### m3 — A fixture whose name does not start with `good` or `bad-` is skipped in complete silence.

`docs/tests/discipline-tests.sh:50-54` returns 0 for any other name, counting
neither a pass, a fail, nor a skip. A fixture added as `bad_dup` or `broken-id`
is never run and never mentioned. Combined with M1's unpinned count, a fixture
set can quietly stop testing anything. (Verified: all 37 current fixtures *are*
reached, and the three `README.md`s plus `docs/prd/tests/facts` are correctly the
only silent skips.)

**Fix.** Print `NOTE  ignored non-fixture entry: <path>` for anything under a
fixture root that matches neither convention and is not a known non-fixture
(`README.md`, `facts`).

### m4 — `grep -Ev '^R[0-9]+$'` at `docs/glossary-lint.sh:220` drops any abbreviation of the form letter-R plus digits.

`R1`…`R12` are rule pointers, correctly excluded. But the pattern is unanchored to
that meaning: an adopter's genuine abbreviation `R2` (or `R3`, in a robotics or
avionics glossary) is silently exempted from the whole check. Low impact for this
repository, and it ships to adopters.

**Fix.** Exclude the known rule identifiers by an explicit list, or require the
token to appear adjacent to "R1"-style prose; do not exclude a shape.

### m5 — GitLab template runs the new linters on `alpine:3`, which has no `git`.

`docs/ci/gitlab-ci.yml` adds three jobs on `image: alpine:3`; two of them
(`glossary-lint`, and `discipline-tests` via `glossary-lint`) call `git ls-files`.
The existing `mr-link` job on the same image needs no git, so the image comment
("any image with POSIX sh + grep/awk/sed") was true before this change and is not
true now. I could not run this — see Hypotheses.

**Fix.** Use `alpine/git` (or add `- apk add --no-cache git`) for the two jobs
that need git, and update the comment.

---

## Hypotheses — stated, not demonstrated

No container runtime was available, so these were reasoned from the code and are
**not** verified. Each is cheap to settle.

- **H1 — BusyBox tooling.** `docs/ci/gitlab-ci.yml`'s `alpine:3` image supplies
  BusyBox `awk`, `sed`, `grep`, `comm`, `uniq`, `mktemp`. `glossary-lint`'s awk
  uses `match()` with `RSTART`/`RLENGTH` in a `while` loop and multi-byte literals
  (`‹`), and `comm` is not in every BusyBox build. If BusyBox awk mishandles any
  of it, the failure mode is the one this linter was written to prevent: an empty
  scan. The `used.tokens` self-check at `:225-227` would catch a *total* scan
  failure, which is a real mitigation; it would not catch a partial one.
  *Settle it:* `docker run --rm -v "$PWD:/w" -w /w alpine:3 sh -c 'apk add -q git; sh docs/tests/discipline-tests.sh'`.
- **H2 — GNU vs BSD `comm` collation.** `backlog-lint` sorts with the ambient
  locale (see m1) and then relies on `comm -12`. I built several ID shapes
  (`T-a`/`Ta`, punctuation-differing IDs) and could not construct a case where
  GNU and BSD disagreed; a case may exist on glibc with a locale whose collation
  reorders punctuation differently from `comm`'s equality test.
- **H3 — CRLF input.** Not tested. `backlog-lint`'s entry regexes end in `.`,
  which a trailing `\r` satisfies, so a CRLF `backlog.md` probably passes; the
  extracted ID would then carry no `\r` (it is inside `**…**`), but a CRLF
  `completed.md` ID might. Worth one fixture.
- **H4 — Path with a newline.** `while IFS= read -r f` at
  `docs/glossary-lint.sh:163` splits such a path into two, both of which fail
  `[ -f … ]` and are dropped silently — the same silent skip as M2. Not
  demonstrated because creating the file was not worth the cleanup risk.

---

## Attacked and could NOT break — do not repeat this in round 2

- **Every new fixture is load-bearing.** I mutation-tested each one: disabled the
  specific guard in the linter and confirmed the fixture flips to exit 0.
  Verified for `glossary-lint` × {`bad-dup-term` (disabled `if (term in seen)`),
  `bad-malformed-row` (disabled `ncell != 4`), `bad-undefined` (disabled the
  `missing` block), `bad-unclosed-fence` (emptied the `END { if (infence) … }`
  sentinel)} and `backlog-lint` × {`bad-unclosed-comment` (emptied `END { if
  (incomment) exit 3 }`), `bad-malformed` and `bad-multiline` (disabled the
  one-line regex), `bad-dup-id` (disabled `uniq -d`), `bad-in-both` (disabled
  `comm -12`), `bad-no-date` (disabled the dated-entry regex)}. All ten flipped.
  **No new fixture passes for the wrong reason** in the sense of "would still fail
  if its guard were deleted" — M1 is a different hole (a fixture that is *gone*).
- **Every `bad-*` fixture's first error message names its own defect.** Checked
  by hand for all 6 ADR, 8 PRD, 6 backlog and 4 glossary fixtures. The 7 `pr-link`
  `bad-*` fixtures all emit the same message, but `pr-link-lint.sh` has exactly
  one failure path, so that is correct rather than a false green.
- **The runner reaches all 37 fixtures.** Enumerated `run_set`'s five roots
  against `run_case`'s name test: 6 ADR + 9 PRD + 7 tasks + 10 pr-link + 5
  glossary = 37, matching the reported count. The only silently-ignored entries
  are the four `README.md`s and `docs/prd/tests/facts`, all correctly non-fixtures.
- **Current working directory.** `sh /abs/path/docs/tests/discipline-tests.sh`
  from `/` gives `discipline-tests: OK (37 cases)`. `script_dir` /
  `repo_root` resolution is correct.
- **`GIT_DIR` in a hook.** The `unset GIT_DIR GIT_INDEX_FILE GIT_WORK_TREE` at
  `docs/glossary-lint.sh:56` does what it claims: I enabled
  `core.hooksPath=.githooks` and committed; the hook printed the same five results
  as a command-line run. (The #29 regression is genuinely fixed — the *content*
  problem in M4 is a separate issue.)
- **Shell portability.** All five scripts give identical, correct results under
  `/bin/sh` and `/bin/dash`.
- **Locale.** `LC_ALL` in `C`, `en_US.UTF-8`, `tr_TR.UTF-8`, `C.UTF-8` gives
  identical results for `backlog-lint` on `backlog.md` and all six `bad-*`
  fixtures (macOS `awk version 20200816`). See m1 for why I still flag it.
- **Filenames with spaces.** `docs/my note.md` is listed, read, and scanned
  correctly; the undefined abbreviation in it is reported with the space intact.
  Only non-ASCII breaks (M2).
- **`set -u` safety.** `${1:-}`, `${2:-…}`, `${_name%.md}` are all guarded; no
  unbound-variable path found in any of the three new scripts.
- **Temp-directory handling.** `mktemp -d` failure is checked in both new
  linters; `trap 'rm -rf "$tmp"' EXIT INT TERM` is correctly quoted in both.
- **`comm` input ordering.** Both `comm` chains
  (`glossary-lint:229`, `backlog-lint:148`) receive input from `sort`/`sort -u` in
  the same locale as the `comm` that consumes it; no unsorted-input path found.
- **The `used.tokens` self-check.** `docs/glossary-lint.sh:225-227` does fire —
  it is what catches a *total* scan failure, and it is the reason M2 and M3 are
  MAJOR rather than BLOCKER: a hole that swallowed every file would be caught.
- **Repository state.** `git status --porcelain` is empty. All experiments ran on
  a copy under `scratchpad/work-correctness/repo`; no tracked file was modified.

---

## Summary

| ID | Severity | One line |
|---|---|---|
| M1 | MAJOR | Runner accepts any non-zero exit; three deleted fixtures still report `OK (37 cases)` |
| M2 | MAJOR | Non-ASCII committed Markdown paths are silently dropped from the glossary scan |
| M3 | MAJOR | `*/tests/*` excludes ten real documents, contradicting `AGENTS.md:104` |
| M4 | MAJOR | Hook lints the working tree, not the index; a bad commit lands with `OK` |
| M5 | MAJOR | Fence tracker mis-handles `~~~`, indented code, and nested fences — false `FAIL`s |
| M6 | MAJOR | `backlog-lint` collects IDs outside `Now`/`Next` — false "in BOTH files" |
| m1 | MINOR | `backlog-lint` lacks the `LC_ALL=C` guard its sibling documents |
| m2 | MINOR | "no empty cell" is claimed but column 2 is unchecked |
| m3 | MINOR | Mis-named fixtures are skipped in silence |
| m4 | MINOR | `^R[0-9]+$` exempts a shape, not a set of known identifiers |
| m5 | MINOR | GitLab jobs need `git`, `alpine:3` has none |

M1 is the one to fix first. It is the check on the checks, and it currently
cannot tell "the linter rejected the defect" from "the linter could not find the
file" — which means the other four linters are, today, guarded by a test suite
that would stay green if their fixtures evaporated.



---

### Comment — pharzam — 2026-08-27T08:09:42Z

## Gate step 5, round 4 of 4 — adversarial bug-hunt

Reviewer: an agent in a fresh context, handed `docs/review/adversarial.md` verbatim.
Posted unedited. **Nine reproduced defects.**

**I re-verified F4 and F5** (F1, F2 and F3 were already confirmed in rounds 1 and 3).

### F4 — the same file, the same content, only the line endings differ

```
# LF, with a deliberate violation appended:
$ sh docs/tasks/backlog-lint.sh <fixture>
FAIL  backlog.md:10: not a one-line task entry (want "- **<ID>** — <summary>"): * T-zzzz - ...
exit=1

# byte-identical content, converted to CRLF:
$ sh docs/tasks/backlog-lint.sh <fixture>
backlog-lint: OK
exit=0
```

The repository ships no `.gitattributes`, so any adopter on Windows with the default
`core.autocrlf=true` gets a backlog linter that checks nothing and says OK.

### F5 — a repository path containing a space

```
$ sh "…/atk space dir/docs/adr/adr-lint.sh"
adr-lint.sh: line 78: [: atk: integer expression expected
FAIL  duplicate ADR number: atk
FAIL  duplicate ADR number: spac
```

Nonsense on a repository that violates nothing. `prd-lint.sh` carries the identical
bug and only looks clean because the kit ships no `PRD-*.md` to reach it.

---

# Round 4 — adversarial bug-hunt

Target: `2cd70ee..999765f` (PRs #24 #25 #26 #27 #28 #30 #32) — five POSIX-shell
checks plus `docs/tests/discipline-tests.sh`. All five pass on `main`. The job was
to make one of them **lie**.

All work happened in copies under `/private/tmp/.../scratchpad/`
(`work-adversarial/`, `atk*/`). No tracked file in `/Users/farzam/projects/armature`
was touched — `rtk proxy git status --porcelain` is empty at `999765f`.

Baseline before any attack:

```
adr-lint: OK  /  prd-lint: OK  /  glossary-lint: OK  /  backlog-lint: OK
discipline-tests: OK (37 cases)
```

**Result: nine reproduced defects.** Four make a check report OK on a repository
that violates the rule it enforces. Four make a check fail on a repository that
does not. One erodes the runner's own coverage silently. Six are the class the two
previous rounds found — *a check that reports OK having scanned less than it
claims* — arriving through five new doors.

---

## F1 — `glossary-lint` never scans ten of its own prose documents. **HIGH**

`docs/glossary-lint.sh:168-171`

```sh
case "$f" in
    */tests/*README.md) : ;;
    */tests/*)           continue ;;
esac
```

The comment above it states the intent: "a test fixture is an input to a linter,
not documentation". The glob does not say that. It says *any* Markdown under *any*
path segment named `tests`, at any depth, except a `README.md`. `docs/tests/` is a
**documentation** directory, not a fixture directory. Ten committed prose files are
therefore outside the scan entirely:

```
docs/tests/dod-checklist.md          docs/tests/template-e2e.md
docs/tests/example-fact-to-test.md   docs/tests/template-integration.md
docs/tests/scaling-checklist.md      docs/tests/template-uat.md
docs/tests/security-checklist.md     docs/tests/template-unit.md
docs/tests/test-levels.md            docs/tests/traceability-template.md
```

**Reproduction**

```sh
printf '\nA ZQXFOO token in real prose.\n'      >> docs/tests/test-levels.md
printf '\nAnother WQBAR token in real prose.\n' >> docs/tests/dod-checklist.md
rtk proxy git add -A
sh docs/glossary-lint.sh ; echo "exit=$?"
```

**Observed**

```
glossary-lint: OK
exit=0
```

**Control** — the identical token in a file outside a `tests/` path is caught:

```
FAIL  abbreviation "ZQXFOO" is used but has no glossary row (in: docs/adr/README.md )
```

60 of the 106 tracked `*.md` files are excluded by this rule. Most are genuine
fixtures; ten are not. Second-order trap: `docs/tests/README.md` **is** scanned (it
matches the first arm), so anyone who probes the exclusion by editing that file
concludes the directory is in scope.

**Fix:** exclude fixture *roots*, not a directory name — the runner's manifest at
`docs/tests/discipline-tests.sh:90-94` already states exactly what they are. Derive
the exclusion from that list so the two cannot drift.

---

## F2 — `glossary-lint` silently skips any file git C-quotes. **HIGH**

`docs/glossary-lint.sh:149` and `:164`

```sh
( cd "$scan_root" 2>/dev/null && git ls-files '*.md' 2>/dev/null ) > "$tmp/files" || :
...
while IFS= read -r f; do
	[ -f "$scan_root/$f" ] || continue      # <- silent
```

Under git's default `core.quotePath=true`, `git ls-files` renders any path holding
a non-ASCII byte (or a backslash, double quote, or tab) as a C-quoted string:
`"docs/adr/caf\303\251-notes.md"`. That string is not a path, `[ -f ]` fails, and
the file is dropped **without a word**. The linter then reports OK.

**Reproduction**

```sh
printf '# Cafe notes\n\nZQXACCENT is an undefined abbreviation.\n' \
  > "$(printf 'docs/adr/caf\303\251-notes.md')"
rtk proxy git add -A
rtk proxy git ls-files '*.md' | grep -a caf
sh docs/glossary-lint.sh ; echo "exit=$?"
```

**Observed**

```
"docs/adr/caf\303\251-notes.md"
glossary-lint: OK
exit=0
```

**Control** — same file, same repository, one git setting away:

```sh
rtk proxy git config core.quotePath false
sh docs/glossary-lint.sh
# FAIL  abbreviation "ZQXACCENT" is used but has no glossary row (in: docs/adr/café-notes.md )
# exit=1
```

Two opposite answers on the same tree, decided by a git config the linter never
mentions. Same shape as the `GIT_DIR` defect (#29): the check's answer depends on
the caller's git environment. A filename holding a newline hits the same silent
`continue` through `read`.

**Fix:** `git -c core.quotePath=false ls-files '*.md'` — and, more important, make
the `continue` on line 164 **loud**. A path the scan cannot open is precisely the
"scanned nothing, said OK" failure this script exists to prevent, so it must `err`.

---

## F3 — `glossary-lint`'s fence tracker desyncs; real prose is skipped. **HIGH**

`docs/glossary-lint.sh:173-174`

```awk
/^[ \t]*```/ { infence = !infence; next }
infence { next }
```

A blind toggle on ` ``` `. It does not know about `~~~` fences (valid CommonMark,
and the *only* way to display backtick fences), and it does not know about longer
fences (` ```` `). A document that shows fence syntax — which a docs kit will do —
desyncs the toggle, and the skipped region still ends with `infence == 0`, so the
unterminated-fence guard added in #31 never fires.

**Reproduction** — `docs/adr/how-to-write-fences.md`, valid CommonMark throughout:

````markdown
# How to write a fenced block

To open a block, write:

~~~
```sh
~~~

ZQXHIDDEN is an undefined abbreviation sitting in plain prose.

To close it, write the same three characters again:

~~~
```
~~~

And a real example:

```sh
echo hi
```

Done.
````

```sh
rtk proxy git add -A
sh docs/glossary-lint.sh ; echo "exit=$?"
```

**Observed**

```
glossary-lint: OK
exit=0
```

`ZQXHIDDEN` is on line 9, outside every fence (`grep -n` confirms), in a tracked
file (`git ls-files` confirms). Lines 6–16 were skipped.

**The clinching control** — append a second undefined token to the *same tracked
file*, after the last fence:

```sh
printf '\nZQXPLAIN is undefined too.\n' >> docs/adr/how-to-write-fences.md
rtk proxy git add -A ; sh docs/glossary-lint.sh
```

```
FAIL  abbreviation "ZQXPLAIN" is used but has no glossary row (in: docs/adr/how-to-write-fences.md )
exit=1
```

Same file, same run: the late token is found, `ZQXHIDDEN` is **still** invisible.

**The mirror defect (false FAIL).** The same toggle reads genuine code as prose.
Both of these documents violate nothing, and both fail the gate:

```
~~~
ZQXTILDE token inside a tilde fence
~~~
```

`````
````
```
ZQXNEST token inside a nested fence
```
````
`````

```
FAIL  abbreviation "ZQXNEST" is used but has no glossary row (in: docs/adr/fence-b.md )
FAIL  abbreviation "ZQXTILDE" is used but has no glossary row (in: docs/adr/fence-a.md )
exit=1
```

**Fix:** track the opening fence's character and length, as CommonMark specifies —
a fence closes only on a run of the *same* character at least as long as the
opener; a shorter or different run inside it is content. Add both fixtures.

---

## F4 — `backlog-lint`'s two structural checks are dead on a CRLF file. **HIGH**

`docs/tasks/backlog-lint.sh:79-80` and `:97-98`

```awk
/^## / { sec = substr($0, 4); sub(/[ \t]+$/, "", sec)
         insec = (sec == "Now" || sec == "Next"); next }
!insec { next }
```

`sub(/[ \t]+$/, ...)` strips spaces and tabs. It does not strip `\r`. On a CRLF
file `sec` is `"Now\r"`, `insec` is never set, and **every task line in every
section is skipped**. Checks 1 and 2 — the one-line rule and the dated-entry rule —
become no-ops that still print `backlog-lint: OK`.

**Reproduction** — start from the shipped `good` fixture, add one violation, then
change nothing but the line endings:

```sh
cp -R docs/tasks/tests/good /tmp/crlf ; cd /tmp/crlf
printf -- '* T-zzzz - wrong bullet, no bold id, wrong dash\n' >> backlog.md
sh .../docs/tasks/backlog-lint.sh .
# FAIL  backlog.md:10: not a one-line task entry ... : * T-zzzz - wrong bullet, no bold id, wrong dash
# exit=1

perl -pe 's/\n/\r\n/' backlog.md   > b && mv b backlog.md
perl -pe 's/\n/\r\n/' completed.md > c && mv c completed.md
sh .../docs/tasks/backlog-lint.sh .
```

**Observed**

```
backlog-lint: OK
exit=0
```

A second, different violation stays invisible too:

```sh
printf -- '- **T-yyyy** — an entry with no completion date\r\n' >> completed.md
sh .../docs/tasks/backlog-lint.sh .
# backlog-lint: OK
# exit=0
```

This is not exotic. The repository ships **no `.gitattributes`**, so any adopter on
Windows with the default `core.autocrlf=true` gets a CRLF working tree and a
backlog linter that checks nothing while reporting OK.

Converting the whole fixture set makes the mechanism explicit — three `bad-*`
fixtures flip green:

```
FAIL  backlog-lint.sh on docs/tasks/tests/bad-malformed:  exit 0, expected 1
FAIL  backlog-lint.sh on docs/tasks/tests/bad-multiline:  exit 0, expected 1
FAIL  backlog-lint.sh on docs/tasks/tests/bad-no-date:    exit 0, expected 1
```

**What makes it silent** is a missing assertion, and that is worth fixing on its
own: `backlog-lint` never checks that the sections it lints **exist**. An empty
`backlog.md` also reports OK:

```sh
: > backlog.md ; sh .../docs/tasks/backlog-lint.sh .
# backlog-lint: OK
# exit=0
```

**Fix:** strip `\r` at the top of every awk program (`{ sub(/\r$/, "") }`) in all
five linters; ship a `.gitattributes` with `*.md text eol=lf`; and fail when
`backlog.md` has no `## Now`/`## Next` heading or `completed.md` has no `## Log`.
Add a CRLF fixture — no current fixture touches line endings at all.

---

## F5 — `adr-lint` and `prd-lint` break on a repo path containing a space. **MEDIUM**

`docs/adr/adr-lint.sh:59,71,87` and `docs/prd/prd-lint.sh:45,58`

```sh
adr_files="$adr_files $path"      # space-joined
...
for p in $adr_files; do ...       # unquoted: word-split, then globbed
for path in $adr_files; do ...
```

The `for path in "$adr_dir"/*.md` loop is quoted correctly; the accumulator is not.
Every path component after a space becomes its own "ADR file".

**Reproduction**

```sh
cp -R work-adversarial "atk space dir" ; cd "atk space dir"
sh docs/adr/adr-lint.sh ; echo "exit=$?"
```

**Observed** — 40+ lines of nonsense on a repository that violates nothing:

```
docs/adr/adr-lint.sh: line 78: [: atk: integer expression expected
FAIL  duplicate ADR number: atk
FAIL  duplicate ADR number: spac
awk: can't open file /private/tmp/.../scratchpad/atk
FAIL  atk: first non-blank line must be '# atk. <title>' (got: <empty>)
FAIL  atk: missing 'Date: YYYY-MM-DD' line
...
exit=1
```

`prd-lint.sh` carries the identical bug; it only looks clean because the kit ships
no `docs/prd/PRD-*.md` and early-exits at line 51. Add one valid PRD and it fires:

```sh
cp docs/prd/tests/good/PRD-0001-sample.md docs/prd/
mkdir -p docs/facts && cp docs/prd/tests/facts/F-0001-sample.md docs/facts/
sh docs/prd/prd-lint.sh
# awk: can't open file /private/tmp/.../scratchpad/atk
# awk: can't open file space
# awk: can't open file dir/docs/prd/PRD-0001-sample.md
# exit=1
```

Copy the same tree to a path with no space: `prd-lint: OK`, exit 0.

`backlog-lint`, `glossary-lint` and `discipline-tests` survive this — they quote
throughout. `discipline-tests` does **not** catch it, because it hands the linters
*relative* fixture paths, which never carry the spaced prefix. No fixture can cover
this; it needs a case that invokes a linter with an absolute path.

**Fix:** stop accumulating paths in a string. Process each file inside the first
loop, or use `set --` / `"$@"`.

---

## F6 — `adr-lint` false-fails on CRLF, with a self-contradicting message. **MEDIUM**

Same root cause as F4, opposite direction. `docs/adr/adr-lint.sh:103-110` and
`:117-122` compare exact strings against values that still carry `\r`:

```sh
find docs -name '*.md' -print0 | xargs -0 perl -i -pe 's/\r?\n/\r\n/'
sh docs/adr/adr-lint.sh
```

```
FAIL  0001-record-architecture-decisions.md: Date must be YYYY-MM-DD (a real date or the placeholder); got 'YYYY-MM-DD'
FAIL  0001-record-architecture-decisions.md: Status '' is not one of: Proposed | Accepted | Deprecated | ...
exit=1
```

The first message rejects the placeholder for not being the placeholder. The second
reports an empty Status for a file whose Status line reads `Accepted`. Nothing in
the repository violates the ADR rules; a Windows checkout cannot pass the gate, and
the diagnostics point nowhere.

---

## F7 — `discipline-tests` loses cases silently, and counts empty ones. **MEDIUM**

`docs/tests/discipline-tests.sh:50-54, 73-80, 99-102`

The runner's only floor is "at least one case ran anywhere".

**7a — a renamed fixture vanishes.** `run_case`'s `*) return 0` arm drops anything
matching neither `good*` nor `bad-*`, with no output:

```sh
mv docs/adr/tests/bad-status    docs/adr/tests/bad_status
mv docs/tasks/tests/bad-in-both docs/tasks/tests/in-both
sh docs/tests/discipline-tests.sh
# discipline-tests: OK (35 cases)     <- was 37; nothing says so
# exit=0
```

**7b — a whole fixture root vanishes as a NOTE.**

```sh
rm -rf docs/prd/tests
sh docs/tests/discipline-tests.sh
# NOTE  prd-lint.sh has no fixtures at docs/prd/tests — skipped
# discipline-tests: OK (26 cases, 1 set(s) skipped)
# exit=0
```

Nine cases gone and the gate for the gate stayed green.

**7c — an empty fixture directory counts as a passing test.** An empty directory
named `bad-*` makes the linter exit 1 for a reason unrelated to what the fixture is
named for, and the runner scores it as a pass:

```sh
mkdir -p docs/adr/tests/bad-empty-dir
sh docs/tests/discipline-tests.sh
# discipline-tests: OK (38 cases)
# exit=0
```

That is the general false-green in the `bad-*` convention: the runner asserts *that*
the linter exited 1, never *why*. Delete `adr-lint.sh`'s entire Status block and
`bad-empty-dir` still passes.

**Fix:** the script's own comment (lines 96-98) has the right instinct and the wrong
threshold. Assert a **per-set** floor — a manifest row that finds its fixture root
but zero cases is a failure — warn on any entry inside a fixture root that matched
neither pattern and is not a README, and have each `bad-*` fixture assert a
substring of the expected message rather than only the exit status.

---

## F8 — `glossary-lint` rejects a valid table row with an escaped pipe. **LOW-MED**

`docs/glossary-lint.sh:98` splits on `|` with no escape handling, so `\|` inside a
cell — the standard way to write a literal pipe in a GitHub-flavoured Markdown
table — inflates the cell count.

**Reproduction**

```
| Sample Term | `SMP` | A fixture term, written A \| B in prose. | The SMP value. |
```

```
FAIL  glossary.md:5: table row has 5 cells, want 4 (Term | Abbr. | Description | Example)
exit=1
```

`prd-lint.sh` in the same PR set gets this right — `split_row` at line 61 does
`gsub(/\\\|/, "\001", line)` before splitting and restores it afterwards. Two
linters shipped together disagree about the same Markdown. Port `split_row`'s
handling into `glossary-lint`.

---

## F9 — `adr-lint`'s cross-link check can never fire inside a fixture. **LOW**

`docs/adr/adr-lint.sh:39-49`. `is_cross_linked` greps `$(dirname "$adr_dir")`
recursively. For the fixture run `adr_dir=docs/adr/tests/good`, that root is
`docs/adr/tests`, which holds five *other* fixture directories, every one with a
file named `0001-sample.md`. `grep -R -Fl "0001-sample"` therefore always matches a
sibling fixture, `grep -qv "^docs/adr/tests/good/"` always succeeds, and check 3f
always reports "cross-linked".

The WARN is non-fatal, so this is not a lie — but **no fixture exercises 3f in
either direction**. Delete lines 133-136 and all 37 cases still pass.

---

## Unverified (hypothesis; could not reproduce on this machine)

- **`backlog-lint` sorts with the caller's locale but compares bytes.**
  `docs/tasks/backlog-lint.sh:131-132` pipes through plain `sort`; lines 135-148
  then use `uniq -d` and `comm -12`, which compare bytes. `glossary-lint.sh:46`
  sets `LC_ALL=C` deliberately and explains why; `backlog-lint.sh` never does.
  Under glibc `en_US.UTF-8`, `sort` collates ignoring punctuation, so IDs such as
  `AUTH-2` and `AUTH1` come out in an order `comm` rejects; `comm` then writes
  "file 1 is not in sorted order" to stderr (unchecked), returns nothing, and the
  "in BOTH backlog and completed" check passes silently. I built that case and it
  still failed correctly here: both BSD `sort` and Homebrew `gsort` fall back to
  byte order under macOS locale data. CI runs `ubuntu-latest`, where glibc
  collation applies, so I expect it fires there. Note the exposure is only via the
  **pre-commit hook** and a direct command-line run — `discipline-tests.sh:31`
  exports `LC_ALL=C`, which masks it for every fixture case.
  Cheap fix regardless: add `LC_ALL=C; export LC_ALL` to `backlog-lint.sh` and
  check `comm`'s exit status.
- **`for path in $prd_files` also glob-expands.** A repository directory named with
  `*` or `?` could resolve a PRD path to a different existing file. I could not
  construct a case where the expansion matched something real rather than falling
  back to the literal word, so the only demonstrated consequence is F5's
  word-splitting.

---

## Attacked and could not break

Listed so the next round does not repeat the work. Every line below was run.

- **Filenames.** Leading dash (`-0001-x.md`), embedded space (`0009 spaced.md`),
  glob metacharacter (`000*-glob.md`) and an empty `empty.md` in `docs/adr/` — all
  four rejected correctly by the filename filter, which is tight enough that
  nothing dangerous reaches the unquoted expansions of F5.
- **Symlinked ADR.** A symlink `0009-symlink-copy.md -> 0001-....md` is followed and
  linted as a file; it fails for the right reasons (numbering gap, wrong title,
  no index row). No crash, no skip.
- **`mktemp` and `trap`.** `mktemp -d` failure is handled in both scripts that use
  it (`backlog-lint.sh:39`, `glossary-lint.sh:87`); `trap 'rm -rf "$tmp"' EXIT INT
  TERM` is quoted and survives a `TMPDIR` containing a space. Nothing is
  predictable enough to collide: two concurrent `backlog-lint` runs and a run
  repeated twice both behave.
- **Foreign working directory.** All five resolve their own directory with
  `CDPATH= cd -- "$(dirname -- "$0")" && pwd`. Invoked from `/` by absolute path,
  all five exit 0, matching the in-repo run.
- **`GIT_DIR` / `GIT_WORK_TREE` / `GIT_INDEX_FILE`.** The `unset` at
  `glossary-lint.sh:56` holds: exporting all three and running from `docs/` gives
  `glossary-lint: OK`, same as the command line. A real commit through
  `.githooks/pre-commit` (`git config core.hooksPath .githooks`) runs all five and
  prints the same five lines. #29's fix is sound.
- **Locale for `glossary-lint`.** `LC_ALL=C` at line 46 holds under
  `LC_ALL=en_US.UTF-8`, `LC_ALL=C`, and unset — exit 0 in all three. The `‹…›`,
  em dashes and IPA do not abort awk. #31's fix is sound.
- **Exit codes in the runner.** A `bad-*` fixture exiting 2 instead of 1 is
  reported as a failure — `[ "$_got" -eq "$_want" ]` is an exact comparison, not
  "non-zero". A missing linter script is a NOTE. Both correct.
- **All 37 fixtures fail for the reason their name states.** I ran every case
  individually and read every message. No fixture is a "right exit code, wrong
  reason" false green — except the structural gaps in F7c and F9.
- **Escaped pipe in a PRD cell.** `| REQ-001 | The system accepts an order \| or a
  refund. | Must | 1 | F-0001 |` → `prd-lint: OK`. Handled correctly (contrast F8).
- **`**bold**` inside a task summary.** `- **T-zzzz** — a summary with a **bold**
  span in it` and the completed-log equivalent → `backlog-lint: OK`. The `**…**`
  group counting is not fooled.
- **Task ID with regex metacharacters.** `T-a.b*c[d` is rejected, but for a
  defensible reason (the `*` breaks `[^*]+`, so the ID is not `**…**`-bracketed as
  the document requires) and the ID is never interpolated into a regex — the check
  is `match()` against a literal pattern. The message ("not a one-line task entry")
  is misleading for this input; worth a word, not a finding.
- **Missing trailing newline.** Truncating the final newline from `backlog.md`,
  `completed.md`, `glossary.md` and an ADR changes no verdict in any of the five.
- **`awk -v` escape injection.** `fname` is a basename that already passed a strict
  filename filter in `adr-lint`/`prd-lint`; `facts` is a list of `F-NNNN` tokens.
  Neither can carry a backslash.



---

### Comment — pharzam — 2026-08-27T08:13:58Z

## Triage — four rounds, ~30 raw findings, six issues

All four lenses have run. Every round is posted above, unedited. **I re-verified
eight findings myself against a clean `git archive` of `999765f` before filing**;
all eight reproduced exactly as written. Nothing was taken on the reviewer's word.

### The rounds

| Round | Lens | Reviewer | Result |
| ----- | ---- | -------- | ------ |
| 1 | correctness and failure modes | fresh context | 11 findings, 6 MAJOR |
| 2 | guardrails and acceptance criteria | fresh context | 6 findings, 3 MAJOR |
| 3 | clean and simple | fresh context | 12 findings, 5 MAJOR |
| 4 | adversarial bug-hunt | fresh context | **9 reproduced defects** |

No round found nothing. Gate step 5 says rounds continue **until one round finds
nothing material** — so this is not the clearing round, and the rounds are not
finished. A clearing round runs after the fixes land, over the range as it stands
then.

### The issues

| Issue | What | Blocks this one? |
| ----- | ---- | ---------------- |
| #36 | **The gate lints the working tree, not what is being committed.** Stage a violation, tidy the working copy, commit — five greens, and the violation lands. | Yes |
| #37 | `discipline-tests` asserts that a linter exited 1, never **why**. Delete three fixtures' contents and it still prints `OK (37 cases)`. Delete a whole linter and the hook *and* the runner stay green. | Yes |
| #38 | `glossary-lint` scans less than it claims — five silent holes (ten prose documents excluded, C-quoted paths dropped, fence tracker desync, missing scan root) and one false rejection. | Yes |
| #39 | CRLF makes `backlog-lint` check nothing and say OK; CRLF makes `adr-lint` fail a clean repository with self-contradicting messages; a space in the repository path breaks `adr-lint` and `prd-lint`. | Yes |
| #40 | Six shipped statements are not true of `main`. Each was ticked as "R10 sync holds" in a self-reviewed pull request. | Yes |
| #41 | One decision written in sixteen places; nine are prose. Plus six small dead or duplicated pieces, and a vendor name in a file the kit's own rule forbids it in. | **No** — see below |

### Why #41 does not block

This issue's acceptance criterion says every **material** finding is fixed or
rejected with a reason. #41 is not material in that sense: none of it makes a check
lie. It is the audit's "over-engineered in breadth" finding, measured — and it
belongs beside #20, which addresses the same finding from the other direction. The
one part of it that *does* break a stated rule — a vendor name in
`docs/review/correctness.md`, which `AGENTS.md:24-25` forbids — is one line, and it
is pulled forward into #40.

### What the count means

Two earlier adversarial passes over this same work found six defects. Four proper
rounds found roughly thirty, including one that had been live in the gate since
#28. **Every one of those seven pull requests carried a self-review that passed.**
That is the argument for gate step 5, stated in numbers rather than in principle.

The sharpest single result: `docs/glossary-lint.sh:53-55` asserts *"The staged
index is still what git reads, so a pre-commit run still sees what is about to
land."* It does not. That comment was written by #30 — the pull request whose whole
purpose was to stop checks from claiming more than they do.

### Order of the fixes

`#37 → #38 → #39 → #36 → #40`. #37 first because it is the test infrastructure:
until the runner asserts **why** a fixture failed, no fixture written for the other
four proves anything. That is R12's "test slice first", applied to a repair.



---

### Comment — pharzam — 2026-08-27T10:46:31Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:17Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

The review record — four rounds, their lenses, their reviewer contexts, and their findings — survives on this thread, and that record is this issue's real output. It is intact and it is what Phase 2 uses as its test list.

The two acceptance criteria that touch the repository are unmet:

- *"Every material finding gets its own issue, and is fixed — or rejected with a written reason — before this issue closes."* Findings #36, #37, #38, #39, #40, and #41 are unfixed on `main`.
- *"The task line moves from `docs/tasks/backlog.md` to `docs/tasks/completed.md` in the same pull request."* Neither file mentions T-5r2q at `2cd70ee`. The one commit that opened that task existed only on a local branch; it is now preserved on the remote as `backup/pre-r12-reset-t-5r2q`.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — it spans the tranche. This issue closes when the debt is zero, not when it is logged.
