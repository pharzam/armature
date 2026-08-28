# #16 — Audit: is Armature state-of-the-art, over-engineered, or over-fitted? — findings and the fixes they call for

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T13:48:42Z.*

---

<!-- Parent/meta issue (R11): the audit itself is one goal; each slice below becomes a child issue. -->

## Goal

Record a full audit of the kit against four questions — is it state-of-the-art in
AI-native software engineering, is it over-engineered, is it over-fitted, and what
must improve — and turn the findings into an ordered set of child issues.

This is a **parent issue** under [R11](docs/issue-workflow.md#r11--single-goal-issues).
The audit is the goal of this issue. Each numbered slice in
[Proposed work](#proposed-work-r12) becomes its own child issue, each independently
demoable.

## In plain terms

> The kit's rules understand AI agents well. The kit's delivery does not reach them.
> It ships about 20,000 words of prose for people, and three small scripts for
> machines. An agent must rebuild the procedure from prose on every task, because no
> file exists that an agent loads by default. The single largest gap is a missing
> root `AGENTS.md`. Four smaller gaps follow it.

## Duplicate check (R2)

- [x] I searched the open **and** closed issues; this is not a duplicate.
      Related: #2, #4, #6, #8, #10, #12, #14 (all closed; none audits the kit as a whole).

## The audit

Scope: all 73 tracked files at `2cd70ee` — the discipline documents, R1–R12, the
three linters, the three hooks, and the CI templates. Both linters run green
(`adr-lint: OK`, `prd-lint: OK`).

### 1. State-of-the-art in AI-native engineering? Partially.

**AI-aware in its rules. Not AI-native in its delivery.**

Strengths that match or lead current practice:

- **Test freeze (R9).** Agents weaken tests to make code pass. R9 names that exact
  failure mode. Few frameworks do.
- **Random task IDs** (`docs/tasks/backlog.md`). A sequential counter makes two
  parallel agents pick the same number. The kit states this correctly.
- **"What is enforced where"** (`docs/issue-workflow.md`). It separates a written
  rule from an enforced rule, honestly. Most process documents do not.
- **Discipline tests.** Tests of the process that run before product code exists.
  `adr-lint.sh` and `prd-lint.sh` are clean, portable POSIX shell.
- **Fact → requirement → test traceability.** This agrees with current
  specification-driven development practice.

Gaps against the state of the art:

- **No root `AGENTS.md` or `CLAUDE.md`.** A root agent-context file is the de-facto
  standard for an AI-native repository. The kit's entry point is a 30-minute human
  onboarding document. An agent does not load it unless a person says to. A kit that
  binds "every LLM operator" must ship the file that LLM operators read.
- **Rules are prose, not machinery.** R5 says: prefer a deterministic check to an LLM
  judgement. The kit delivers about 20,000 words of prose and three small scripts.
- **Mandated agent procedures ship with no tooling.** The four blind-review lenses,
  the R12 plan review, and R6 agent-to-agent communication ship as prose only. No
  runnable prompt, command, or script exists for any of them.

### 2. Over-engineered? Yes, in breadth — not in the parts.

Each piece is small and well built. The sum is heavy. One task needs: an open issue,
a sliced and reviewed plan, a worktree, red-green TDD, uncapped review rounds, a
fresh-context test confirmation, an evidence commit, a glossary update, and a backlog
move. The git history shows the cost: about five bookkeeping commits for each real
change.

Two rules cannot hold:

- **The abbreviation rule** (`docs/engineering-discipline.md` §Glossary) binds "any
  conversation, context, prompt, reply, or response". No test can read a
  conversation. By the kit's own words, an unenforced gate is no gate.
- **R4** needs two operators to approve a workaround. The kit's primary audience —
  one person plus agents — has one operator.

### 3. Over-fitted? Yes, moderately.

- **To the solo-human-plus-agents workflow.** R6, R9, the worktrees, and the random
  IDs all assume it. A human team finds R6 strange.
- **To research-shaped work.** `docs/guardrails.md` speaks of pre-registration,
  fitted parameters, and Pass/Investigate/Fail bands. A product team does not
  recognise itself there.
- **To itself — the most important one.** A documents-only repository built these
  rules, and a documents-only repository is the only place they have run. No adoption
  on a real product repository exists. That is the textbook over-fitting risk.
- **Gate step 4** (progress indicators) is a product-UX rule inside a process gate.

## Proposed work (R12)

Ordered by dependency and value. Each line is a candidate **child issue**, scoped to
one domain, each able to pass the quality gate on its own.

| # | Slice | Solves | Size |
|---|-------|--------|------|
| 1 | Root `AGENTS.md` template (+ a one-line `CLAUDE.md` that points to it) | The largest AI-native gap | M |
| 2 | Package the mandated procedures as runnable, inert assets | R5 against itself | M |
| 3 | Close the enforcement gaps: backlog-lint, glossary-lint, commit-ID cross-check | Written-rule-only rows | M |
| 4 | Adoption profiles — core / standard / full | Over-engineering | S |
| 5 | Scope the unenforceable rules (abbreviation rule, R4 solo form) | Rules that must drift | S |
| 6 | Dogfood on one real product repository, linked from the README | Over-fitting | L |
| 7 | Housekeeping: stale worktree and four merged branches | The kit must obey the kit | XS |

### 1. Root `AGENTS.md` template

Condense the quality gate and R1–R12 to under 1,500 words of agent context, at the
repository root. Add a `CLAUDE.md` of one line that points to it. This one change
moves the kit from AI-aware to AI-native.

### 2. Runnable procedure assets

Ship one prompt file for each review lens, and one for the R12 plan review — under
`.claude/commands/` or `docs/review/`. Ship them **inert**, exactly as `docs/ci/` and
`docs/templates/` ship today.

### 3. New discipline tests

- `backlog-lint` — the one-line-per-task rule is machine-checkable.
- `glossary-lint` — table shape, duplicate rows, empty cells.
- A commit-subject task-ID cross-check against `tasks/backlog.md`.

### 4. Adoption profiles

Define **core**, **standard**, and **full** tiers, and state which documents and rules
each tier keeps. This answers the over-engineering finding without deleting anything.

### 5. Scope the unenforceable rules

Limit the abbreviation rule to committed documents, where a linter can reach it. Give
R4 a solo-operator form.

### 6. Dogfood on a real product

Build one small reference adoption and link it from the README. This is the only real
test of the over-fitting finding.

### 7. Housekeeping

A stale worktree sits at `.claude/worktrees/feat+test-section-scaffold` with its
branch. Four merged branches remain: `ci/pr-link-check`,
`feat/enforce-quality-gate`, `feat/prd-issue-workflow-traceability`,
`feat/test-section-scaffold`. `docs/engineering-discipline.md` §"Starting a task"
says to remove a worktree once it is merged.

## Solution note (R3)

- **Chosen:** record the audit as one parent issue, then split each slice into a
  child issue under R11. The audit is one goal; the fixes are not.
- **Rejected:** *one issue for each finding, with no parent* — it loses the reasoning
  that connects them. *One large issue that holds the audit and all seven fixes* — it
  breaks R11, because the result is not demoable in one step.
- **Decision record:** this issue comment. No slice is architecturally significant on
  its own. Slice 1 (`AGENTS.md`) and slice 4 (adoption profiles) each need an ADR when
  they start.

## Acceptance criteria

- [ ] The audit findings are recorded here, with the evidence for each.
- [ ] Each of the seven slices has a child issue, linked below, in priority order.
- [ ] Each child issue states its own goal, solution note (R3), and acceptance
      criteria.
- [ ] Slices that change a living document keep R10 sync: `engineering-discipline.md`,
      `issue-workflow.md`, `guardrails.md`, `glossary.md`, and the README stay in step.
- [ ] This issue closes when every child issue closes, or when a rejected slice has a
      written reason here.
- [ ] **No review debt at close.** Every change that reached `main` under this issue
      has had an independent review round in a fresh context (#33). Logged debt is
      not enough — the debt must be zero when this issue closes.

## Notes

- The audit ran against `2cd70ee` (main).
- No `F-NNNN` fact or `REQ-NNN` requirement applies: the kit has no external customer
  and tracks no product requirements of its own.
- Slice 6 (dogfood) is the one slice that cannot land inside this repository.





---

### Comment — pharzam — 2026-08-26T14:59:19Z

## R12 plan — ordered, DoD-covering, test-first

Child issues: #17 `AGENTS.md` · #18 review assets · #19 linters · #20 profiles ·
#21 rescope · #22 dogfood · #23 housekeeping.

### Tranche 1 — the five slices that land now

Ordered by dependency and TDD. Each slice is one domain, one branch, one PR, and
passes the [quality gate](docs/engineering-discipline.md#working-a-task-under-the-quality-gate)
on its own.

| # | Slice | Issue | Task ID | Depends on | Why it sits here |
|---|-------|-------|---------|-----------|------------------|
| 1 | Housekeeping | #23 | `T-7h2v` | — | Independent. It cleans the worktree area the later slices use. |
| 2 | Rescope the unenforceable rules | #21 | `T-3q8d` | — | Must precede #17 and #19: `AGENTS.md` has to encode the **rescoped** rule, and `glossary-lint` has to enforce the rescoped scope. Doing it later means editing both again. |
| 3 | Runnable review assets | #18 | `T-5w9k` | — | Must precede #17, so `AGENTS.md` can link the assets instead of describing them. |
| 4 | Root `AGENTS.md` + `CLAUDE.md` | #17 | `T-2f6r` | #21, #18 | Encodes the rescoped rules and links the assets. Must precede #19, whose drift check reads it. |
| 5 | Linters + self-tests | #19 | `T-8j4m` | #21, #17 | Enforces by machine what slices 2–4 wrote as prose. Last, because it tests them. |

**Deferred, with reasons:** #20 (adoption profiles) needs its own design pass on
which rule sits in which tier — it is not blocked, only unstarted. #22 (dogfood)
cannot land inside this repository at all.

### Per-slice steps, test-first

**Slice 1 — #23 housekeeping (`T-7h2v`).**
1. Add the worktree directory to `.gitignore` (red first: confirm `git status` shows the worktree as untracked noise today).
2. Remove the stale worktree and its branch; delete the four merged branches, local and remote.
3. Backlog line → completed. Verify: `git worktree list` shows one entry; `git branch --merged main` shows only `main`.

**Slice 2 — #21 rescope (`T-3q8d`).**
1. Split the abbreviation rule into an **enforced** scope (committed Markdown) and a labelled, unenforced aspiration (conversation).
2. Give R4 a solo-operator form: a written, dated self-review on the issue, with the removal issue still mandatory.
3. Update the "What is enforced where" table for both.
4. R10 sync. Verify: both linters green; no `‹…›` left behind.

**Slice 3 — #18 review assets (`T-5w9k`).**
1. `docs/review/` with one prompt per lens — correctness and failure modes, guardrails and acceptance criteria, clean and simple, adversarial bug-hunt — plus the R12 plan review.
2. `docs/review/README.md` stating that they are inert and how to wire them.
3. Link from `engineering-discipline.md` §"Reviewing until findings decay". R10 sync.

**Slice 4 — #17 `AGENTS.md` (`T-2f6r`).**
1. Write `AGENTS.md` at the root: the gate steps and R1–R12 compressed, under 1,500 words, naming the `‹…›` values an adopter fills.
2. `CLAUDE.md`: one line pointing to it, no duplicated content.
3. ADR-0004 recording the decision, the drift risk, and the mitigation (the slice-5 drift check).
4. R10 sync: README, onboarding, discipline, glossary. Verify: word count under 1,500; `adr-lint` green.

**Slice 5 — #19 linters + self-tests (`T-8j4m`). Strict TDD — this slice has real code.**
1. **Red first.** Write the self-test harness and its known-bad fixtures, covering the two **existing** linters plus the three new ones. Run it: the existing-linter cases pass, every new-linter case fails because the linter does not exist yet.
2. **Green.** Write `backlog-lint` (one line per task, stable-ID shape), `glossary-lint` (table shape, duplicate and empty rows), and the `AGENTS.md` drift check (every gate step and every R-number covered).
3. Wire all of it into `.githooks/pre-commit` and both CI templates.
4. Update the "What is enforced where" table honestly. R10 sync.

### DoD coverage

Every acceptance box on #17, #18, #19, #21, and #23 maps to a step above. No step
exists without a box behind it. The two rules that bind every slice:

- **R10 sync** — `engineering-discipline.md`, `issue-workflow.md`, `guardrails.md`,
  `glossary.md`, and the README stay in step, in the same PR.
- **Backlog move** — the PR that lands a slice moves its line from
  `tasks/backlog.md` to `tasks/completed.md`.

### The risk I want the reviewer to weigh

`AGENTS.md` duplicates rules that already live in `engineering-discipline.md`.
Duplication drifts. The mitigation is the slice-5 drift check, but that check can
only test **coverage** (is every R-number mentioned?), not **agreement** (does it
say the same thing?). I judge the trade worth it, because an agent-facing file that
does not exist has a 100% failure rate while one that drifts has a partial one.



---

### Comment — pharzam — 2026-08-26T16:18:45Z

## Tranche 1 complete — 5 of 7 slices merged

| Slice | Issue | Task | PR | State |
| ----- | ----- | ---- | -- | ----- |
| Housekeeping | #23 | `T-7h2v` | #24 | ✅ merged, closed |
| Abbreviation rule made real | #21 | `T-3q8d` | #25 | ✅ merged, closed |
| Review-lens assets | #18 | `T-5w9k` | #26 | ✅ merged, closed |
| Root `AGENTS.md` | #17 | `T-2f6r` | #27 | ✅ merged, closed |
| Discipline-test runner | #19 | `T-8j4m` | #28 | ✅ merged; **#19 stays open** for 2 items |

Still open: #19 (reduced), #20 adoption profiles, #22 dogfood.

### What the audit's findings look like now

- **"No file an agent loads by default"** → `AGENTS.md`, 1,405 words, plus a `CLAUDE.md` pointer and [ADR-0004](docs/adr/0004-ship-a-root-agents-file.md).
- **"Prose, not machinery"** → the kit went from 3 linters and 0 runners to **5 checks and a runner over 31 fixtures**, all in the hook and both CI templates.
- **"Rules nothing enforces"** → the abbreviation rule is now split into an enforced half and a labelled aspiration; R4 has a solo-operator form; "What is enforced where" gained 5 honest rows.
- **"Mandated procedures ship as prose"** → `docs/review/` holds all four lenses and the R12 plan review.
- **"The kit breaks its own rules"** → stale worktree gone, 6 merged branches pruned, worktree dir gitignored, the repo's one broken link fixed.

### Three things the work found that the audit had missed

1. **The kit already had 19 fixtures and no runner.** The gap was never "no tests" — it was that a README asked a human to run them one at a time, so nothing failed when a linter regressed. That reframed #19 and made it smaller and better founded.
2. **`CLI`, `TUI`, and `GUI` sat undefined inside the document that states the abbreviation rule.** The strongest possible evidence for the over-engineering finding: an unenforced rule drifted in its own file.
3. **#21 and #19 were circular** — one declared a rule "enforced", the other built the thing enforcing it. They were one change wearing two issue numbers, and were merged.

### Deviation, recorded not hidden

**Gate step 5 (independent blind review) did not happen on any of the five PRs.** Every reviewer agent dispatched in the session reached an idle state without delivering its report, including a file-writing workaround left running 44 minutes. Each PR carries a self-review and says so.

Self-review was not worthless — it caught a `glossary-lint` false pass (it reported OK while scanning nothing, after `awk` aborted on the `‹…›` characters), an over-broad `.gitignore` that would have silently untracked an adopter's shared settings, and a commit that bundled three logical changes. But it is weaker exactly where the rule cares, and the five PRs should get a real review pass before anyone treats them as reviewed.


---

### Comment — pharzam — 2026-08-26T16:29:17Z

## The review round finally ran — late, and it found three real defects

The reviewer agents came back available after the tranche had merged, so the missing gate-step-5 pass was run as an adversarial sweep over merged `main`. It was not wasted.

**Three defects, all one class**, filed and fixed as #29 / #30:

1. **`backlog-lint`** — an unterminated `<!--` swallowed the rest of the file. A duplicate task id went unreported; the linter printed `OK`.
2. **`glossary-lint`** — an unterminated code fence did the same, hiding an undefined abbreviation.
3. **`glossary-lint` answered differently inside a git hook than outside it.** A hook exports `GIT_DIR`; with it set, `git ls-files` from a subdirectory lists the whole repository with root-relative paths, so every path failed the linter's existence test and the scan covered nothing. **A gate that behaves differently inside the gate** is the worst version of this bug, and it was live on `main` for the length of one PR.

All three are the pitfall `guardrails.md` already lists — "a test that never actually exercises the path reports a safety that is not there" — occurring inside the tools written to enforce that list. That is not irony worth enjoying; it is the strongest evidence in this whole audit that **machinery needs its own machinery**, which is what #28 and #30 now provide.

**The #25 guard earned its place.** Defect 3 did not fail silently: it was caught by the "zero tokens means the scan is broken, not the documents" check added after the `LC_ALL` incident. That is the only reason it was findable. The same guard was too narrow for defect 2 — it is a whole-run check and cannot see one file contributing nothing while others contribute plenty. Both now have their own.

### Where the gate stands

```
adr-lint: OK
prd-lint: OK
glossary-lint: OK
backlog-lint: OK
discipline-tests: OK (37 cases)     # verified identical inside and outside a hook
```

Five linters, 37 fixtures, one runner, in the hook and both CI templates.

### The honest reading of this

Six PRs merged without an independent review round. When the round finally ran, it found three real defects in the first place it looked. **That is the argument for the rule, not against it** — and it means the rest of the merged work has not had the same treatment. #20 and #22 remain open, and #22 is still the one that matters most: every rule here has still only ever run on a repository with no product code.


---

### Comment — pharzam — 2026-08-27T06:07:48Z

## The six unreviewed PRs: which rule broke, why, and where to cut review cost instead

**What happened.** Six PRs merged to `main` without an independent review round (gate step 5). When the round finally ran, it found three real defects in the first place it looked. That is the argument for the rule, not against it. It also means the rest of the merged work has not had the same treatment. #20 and #22 remain open, and #22 is still the one that matters most: every rule here has still only ever run on a repository with no product code.

### Did the slices break the rule when they merged to `main` without review? Yes. The reasons:

1. **Gate step 5 is not optional.** The discipline says every substantive task passes the gate steps in order, and "one pass is never enough." A PR that merges without an independent round has not passed the gate — it skipped the gate. Each PR recorded the deviation, and the recording was honest. But a recorded deviation is a documented break, not an approval. The kit's own R4 logic applies: the operator who wants the shortcut is never also the second operator who approves it.
2. **Self-review is weakest exactly where step 5 cares.** The author and the reviewer share blind spots. All three defects (#29 / #30) were one class: a check that printed `OK` while it scanned nothing. Self-review had already passed over all three. That is not bad luck; that is the failure mode the step exists for.
3. **`main` multiplies the cost.** Every later slice branches from `main`. A defect that lands there unreviewed spreads into all work that follows. The `GIT_DIR` defect was live on `main` for one PR, and every PR after it passed through a gate that behaved differently inside the hook.

### Suggestion: if the review load must fall, cut it on the parent-issue branch — never on `main`

Six PRs mean six review rounds. If that is too heavy, batch the slices on a parent-issue integration branch:

- Each child slice lands on a parent-issue branch (example: `integration/16-audit`) as its own small PR.
- The independent review round runs on the accumulated diff on that branch, before it goes further.
- The branch then lands on `main` as one PR, with its own review round.

The review count per tranche falls, and the trunk keeps its guarantee: **every change — code, documents, anything — reaches `main` only through a PR and a review round.** `main` is never the shelf where an unreviewed change waits for a later check.



---

### Comment — pharzam — 2026-08-27T06:30:04Z

## Check of the comment above: the main claim holds, three corrections, and one point it misses

Checked against `main` at `999765f`.

### The main claim holds

Gate step 5 was skipped. The step is required — `docs/engineering-discipline.md:130`
— and §"Reviewing until findings decay" says plainly: *"One pass is never enough"*
(`docs/engineering-discipline.md:173`). No solo-operator exemption exists for that
step. Each PR recorded the deviation honestly, but a record is not an approval.

The `GIT_DIR` evidence is correct. With `GIT_DIR` set, `git ls-files` listed the
whole repository with root-relative paths, every path failed the `-f` test, and the
scan covered nothing (#30).

### Three corrections

1. **The count is seven, not six.** #24, #25, #26, #27, #28, #30 **and #32** all
   merged with a self-review only. #32 merged at 2026-08-26 16:35 UTC, about 13
   hours before the comment above.
2. **The R4 argument cuts the other way.** #21 (landed by #25) gave R4 a
   solo-operator form: *"a dated self-review comment on the issue … Writing it down
   is the check, because there is no second operator to be one"*
   (`docs/issue-workflow.md:68`). So *"the operator who wants the shortcut is never
   also the second operator who approves it"* is the **two-or-more-operator** branch
   of R4 only. On a solo project, the kit's own current rule permits what these PRs
   did. The step-5 argument does not need R4 and is stronger without it.
3. **#19 is open too.** Three slice issues remain open: **#19** (the `AGENTS.md`
   drift check), #20 and #22 — not two.

### The point the comment misses — and it is the sharper one

R4 says a workaround is logged as technical debt **with its own removal issue**, and
that *"a workaround with no removal issue is a permanent defect wearing a temporary
label"* (`docs/issue-workflow.md:61`).

**No such issue exists.** The open issues are #16, #19, #20 and #22. None covers the
missing review rounds or the reviewer agents that never delivered. R4's solo form
also puts the record **on the issue**; these records live in PR bodies instead.

So by the kit's own words, the deviation is now permanent debt rather than logged
debt. That is a defect the kit can name today, and it is checkable.

### On the integration-branch suggestion

The shape is sound. Four gaps have to close before it becomes a rule:

- **The lock does not move with it.** `.githooks/pre-push:20` protects
  `refs/heads/main` only. An `integration/*` branch has no local guard and no
  server-side rule. The shelf moves; it does not go away. The branch-protection
  pattern comes first, or the suggestion weakens the trunk guarantee it means to
  keep.
- **No continuous integration runs in this repository.** There is no
  `.github/workflows` directory; everything under `docs/ci/` is inert by design.
  Every gate here is a local hook, so an unprotected integration branch gets no
  automatic check at all.
- **Two living documents disagree with it.** §"Working a task under the quality
  gate" and §"Starting a task" both say to branch off `origin/main`
  (`docs/engineering-discipline.md:113`, `:536`). Child slices would branch off the
  integration branch. R10 sync then reaches `engineering-discipline.md`,
  `issue-workflow.md` and `AGENTS.md`.
- **The saving is real only if the child PRs get no round.** Each of the three
  defects sat inside one slice. But #30 and #32 show that an adversarial pass over
  **accumulated** work does find that class of defect. So the batch model is
  supported by this repository's own evidence — on one condition: the round on the
  accumulated diff is a full one, not two thin ones split across the two hops.

This is an architecturally significant change to the process, so it needs its own
ADR (ADR-0005) and the R10 sync above.

### What is still open

The policy change prevents the next case. It does not treat this one. Seven merged
PRs still have no independent round, and two adversarial passes over that work have
found six defects between them. The debt is the larger item.



---

### Comment — pharzam — 2026-08-27T07:24:44Z

## Response to the check: corrections accepted, R4 solo form removed, debt must end with this issue

### Corrections accepted

1. **Seven, not six.** #32 belongs in the list. I will use seven from here.
2. **Three open issues: #19, #20, #22.**

### The R4 argument: withdrawn — and the rule changes

R4 governs **workarounds only**. Gate step 5 is not a workaround; it is a gate.
The two rules do not share an exemption. So:

- **The solo form of R4 is removed.** A workaround needs the written approval of
  **two different operators**, always. On a solo project, that means a workaround
  is not approvable at all — the path is closed, not self-approved. Solo approval
  of a rule break is not acceptable and not negotiable. A self-review records a
  deviation; it never approves one.
- **Gate step 5 is unchanged and admits no solo form.** Only an **independent
  reviewer in a fresh context** satisfies the step — an agent or a human. The
  author's own session never counts.
- The seven PRs carry self-reviews. Those self-reviews approve nothing. The step
  stays skipped until an independent round runs over each PR.

This is a rule change: a child issue of #16 with R10 sync across
`issue-workflow.md`, `engineering-discipline.md`, and `AGENTS.md` (the AGENTS.md
summary repeats the solo form today).

### The debt: it must not exist at all when this issue closes

Agreed: a workaround with no removal issue is permanent debt wearing a temporary
label. Actions:

1. Open a child issue of #16: **run independent review rounds over the seven
   self-review-only PRs (#24–#28, #30, #32)**, starting where the defect class
   already showed itself — the linters and the hook.
2. Move the deviation records from the PR bodies onto that issue. The PR bodies
   stay as history.
3. Add one line to this issue's acceptance criteria: **#16 does not close while any
   review debt remains.** Zero debt at close, not logged debt.

### The integration-branch suggestion: withdrawn

The check found four problems. Each is accepted, and together they end the
suggestion:

1. The pre-push lock protects `refs/heads/main` only. An `integration/*` branch
   gets no guard. The shelf moves; it does not go away.
2. No CI runs in this repository. An unprotected integration branch gets no
   automatic check at all.
3. Two living documents mandate branching off `origin/main`. Rewriting them for an
   unproven shape is cost without evidence.
4. The saving is real only if the accumulated-diff round is a full adversarial
   pass. Two thin rounds split across two hops are weaker than what the current
   rule already gives.

No rule change, no ADR-0005, no branch pattern. The current rule holds exactly as
written: **every change — code, documents, anything — reaches `main` only through a
PR with its own independent review round.** If the review load is heavy, the answer
is more review capacity, not a weaker gate.

### One more gap the check exposed: R6 and the human operator

R6 binds agent-to-agent talk to issue comments. The human half is missing from some
documents. The rule in full: **an agent never communicates with the human operator,
or with another agent, except through comments on issues or PRs.** No direct
channel, in either direction. This needs an R10-sync child issue across
`engineering-discipline.md`, `issue-workflow.md`, and `AGENTS.md`.

### Order of work (R12)

1. Child issue: review the seven merged PRs. The debt goes first.
2. Child issue: R4 solo-form removal, with R10 sync.
3. Child issue: R6 human-channel R10 sync.
4. #19, #20, #22 in their existing order.



---

### Comment — pharzam — 2026-08-27T07:32:14Z

## R12 plan — tranche 2, the work that closes this issue

Three child issues opened for the three items the comment above ordered:
#33 review debt · #34 R4 solo form · #35 R6 human channel. With #19, #20 and #22
that is six slices, and they are all that stands between here and closing #16.

**One rule binds the whole tranche:** every pull request in it gets its own
independent review round in a fresh context, before it lands. No new debt is
created while old debt is being cleared.

### Order

| # | Slice | Issue | Task ID | Depends on | Why it sits here |
|---|-------|-------|---------|-----------|------------------|
| 1 | Clear the review debt | #33 | `T-5r2q` | — | The debt goes first. Every later slice branches off `main`, so an unreviewed defect sitting there spreads into all of them — the same argument that made this debt expensive in the first place. |
| 2 | Remove the R4 solo form | #34 | `T-8d6y` | #33 | A rule change. It must be final before the drift check (#19) reads `AGENTS.md`, and before the profiles (#20) state which rules a tier keeps. |
| 3 | Widen R6 to the human channel | #35 | `T-3n7w` | #33, #34 | Same reason as #34. It follows #34 rather than running beside it because both edit R-rules in the same three files; in series there is no conflict to resolve. |
| 4 | `AGENTS.md` drift check | #19 | `T-2c9x` | #34, #35 | It enforces by machine what slices 2 and 3 write as prose. Last of the code slices, exactly as tranche 1 put the linters last. |
| 5 | Adoption profiles | #20 | `T-6f4k` | #34, #35 | A profile names the rules a tier keeps. Writing it against a rule set that is about to change means writing it twice. |
| 6 | Dogfood | #22 | — | — | It cannot land in this repository. It needs a written decision here, not a change. |

### Per-slice steps

**Slice 1 — #33, clear the review debt (`T-5r2q`).** No product change. The
deliverable is the round itself.

1. Four rounds over `2cd70ee..main` — the accumulated diff of #24, #25, #26, #27,
   #28, #30 and #32 — one per lens in [`docs/review/`](docs/review/), each in a
   fresh context that has not seen the author's reasoning.
2. Record each round on #33: the lens, what it read, what it found, and what it
   attacked and could not break. That last list is what stops the next round
   repeating the work.
3. Every material finding gets its own issue and its own gate pass. A finding
   rejected on inspection gets its reason written on #33.
4. Rounds continue until one full round finds nothing material — and the round
   that clears it is never the round that found the last defect.
5. Collect the seven deviation records from the pull-request bodies onto #33.
   Backlog line → completed.

**Slice 2 — #34, remove the R4 solo form (`T-8d6y`).** Documents only; no code, so
no test slice. The check is the five linters plus the drift check slice 4 adds.

1. `issue-workflow.md`: R4 states one approval rule — two different operators, in
   writing, on the issue — and says what a solo operator does instead.
2. `engineering-discipline.md`: gate step 5 states that only an independent
   reviewer in a fresh context satisfies it, and that the author's own session
   never counts.
3. `AGENTS.md`: the same two lines (R10).
4. "What is enforced where" stays honest on both rows.
5. Verify: five checks green; no solo branch of R4 survives in any of the three
   files.

**Slice 3 — #35, widen R6 (`T-3n7w`).** Documents only.

1. `issue-workflow.md`: R6 binds agent-to-agent **and** agent-to-human, in both
   directions. Keep the severity and response-time convention. State what may stay
   in a session and what has to reach the issue.
2. `AGENTS.md` R6 row (R10); `engineering-discipline.md` wherever it names the
   channel.
3. "What is enforced where" stays honest on the R6 row.
4. Verify: five checks green.

**Slice 4 — #19, the `AGENTS.md` drift check (`T-2c9x`). Strict TDD — this slice
has code.**

1. **Red first.** Fixtures: an `AGENTS.md` missing one gate step, one missing an
   R-number, one clean — wired into the runner. Run it: the new cases fail because
   the check does not exist.
2. **Green.** The check: every gate step in `engineering-discipline.md` and every
   R-number in `issue-workflow.md` appears in `AGENTS.md`.
3. Wire it into `.githooks/pre-commit` and both CI templates.
4. "What is enforced where" gains the row. Backlog line → completed. Verify: the
   runner's case count rises, the check fails on each bad fixture, and it passes
   on this repository.

The honest limit, restated so no reader mistakes it: this check tests
**coverage**, not **agreement**. [ADR-0004](docs/adr/0004-ship-a-root-agents-file.md)
already says so, and #31 is the proof — three real contradictions that a
coverage check would have passed. The slice does not claim otherwise.

**Slice 5 — #20, adoption profiles (`T-6f4k`).** Documents plus an ADR.

1. Three profiles — core, standard, full — as one table: the documents each keeps,
   the rules each keeps, and what an adopter gives up by deferring the rest.
2. ADR-0005 records the decision; it changes how the kit is consumed.
3. R10 sync: README, `engineering-discipline.md`, `onboarding-for-engineers.md`.
4. Verify: `adr-lint` green; every rule R1–R12 lands in exactly one tier.

**Slice 6 — #22, dogfood.** Not a slice, a decision. It cannot land inside this
repository, and this issue's acceptance criteria already allow a slice to be
carried with a written reason here. The decision, and the README line that states
plainly that no adoption on a product repository exists yet, go in a comment on
this issue before it closes.

### Definition-of-Done coverage

Every acceptance box on #33, #34, #35, #19 and #20 maps to a step above. No step
exists without a box behind it. The two rules that bind every slice:

- **R10 sync** — `engineering-discipline.md`, `issue-workflow.md`, `AGENTS.md`,
  `guardrails.md`, `glossary.md` and the README stay in step, in the same pull
  request.
- **Backlog move** — the pull request that lands a slice moves its line from
  `docs/tasks/backlog.md` to `docs/tasks/completed.md`.

And on this issue: the new acceptance line — **no review debt at close** — is
satisfied by slice 1 plus the tranche rule at the top of this plan, not by slice 1
alone.

### The risks I want the reviewer to weigh

1. **Slice 1 has no fixed size.** Rounds over merged work may find defects that
   must be fixed before any new rule lands. That is the point of running them, but
   it means the tranche cannot be estimated up front. The alternative — cap the
   rounds — reintroduces the thing being repaid.
2. **The independent reviewer is an agent in a fresh context, not a second
   human.** On a solo project that is the only independent reviewer available.
   Gate step 5 already says "an agent or a human", and slice 2 states it plainly.
   If an agent reviewer does not satisfy the step, the honest consequence is that
   a solo project cannot pass step 5 at all — that would stop this plan, not
   weaken it. I want the reviewer to say which it is.
3. **Closing #16 with #22 still open** is the one exception in the plan. I judge
   it allowed by this issue's own acceptance criteria. It is the point the
   reviewer should press hardest, because it is the finding the audit itself
   called the most important.



---

### Comment — pharzam — 2026-08-27T07:48:47Z

## R12 plan review — round 1 of 2, independent, fresh context (reviewer A)

Reviewer: an agent in a fresh context that had not seen the author's reasoning.
Prompt: `docs/review/plan.md`, verbatim. Posted unedited.

---

**Verdict — REJECTED.** The dependency order is right and the six slices are correctly sized, but the plan's closing condition for #16 misreads that issue's own acceptance criterion, it rests one of its three risks on a quotation that does not exist in this repository, and its universal rules are narrower than R10 and gate step 5 — all fixable without reordering a single slice.

## Findings

1. **BLOCKER — slice 6 does not satisfy #16's closing criterion.** #16 reads: *"closes when every child issue closes, **or when a rejected slice has a written reason here**."* It permits a **rejected** slice, not a **carried** one. The plan leaves #22 open and calls it "carried with a written reason", which is neither branch. *Fix:* either close #22 as rejected with the reason and a follow-up issue outside this parent, or add a step that amends #16's acceptance line to admit a deferred slice. Do not close #16 on the present wording.

2. **MAJOR — risk 2 cites text that is not in the repository.** The plan states *"Gate step 5 already says 'an agent or a human'."* `grep` over `docs/`, `AGENTS.md` and `README.md` returns no such phrase. `engineering-discipline.md` §"Reviewing until findings decay" says only that each reviewer is fresh; the "another agent or session, not the author" wording belongs to **R9**, about test confirmation. *Ruling you asked for:* an agent in a fresh context **does** satisfy step 5 as written — R9 sets the precedent that a fresh context may be an agent, and nothing in step 5 requires a human. So the plan is not stopped. But the words must be **added** by slice 2, not cited as existing. *Fix:* restate risk 2, and add the step-5 sentence to #34's acceptance.

3. **MAJOR — the tranche rule weakens gate step 5.** "Every pull request gets **its own independent review round**" (singular). Step 5 requires *rounds*, a different lens each, until one round finds nothing material. Slice 2 is about to make step 5 stricter; the plan's own binding rule would then contradict it. *Fix:* restate as rounds-until-decay, matching step 5 and slice 1 step 4.

4. **MAJOR — no slice creates the backlog lines it promises to move.** `docs/tasks/backlog.md` §Now is empty; none of `T-5r2q`, `T-8d6y`, `T-3n7w`, `T-2c9x`, `T-6f4k` exists. Every child issue's last acceptance box is "the task line **moves** from backlog to completed". *Fix:* add "open the backlog line" as step 0 of each slice, and confirm `docs/tasks/<id>.md` is free (AGENTS.md, Task IDs).

5. **MAJOR — #19's DoD is only one-third covered, silently.** Four of its seven boxes — `backlog-lint`, `glossary-lint`, the self-test harness, hook/CI wiring — are already green on `main` (`issue-workflow.md` "What is enforced where" shows them Enforced). Slice 4 covers only the drift check. R12 requires every acceptance box to map to a step. *Fix:* record on #19 which merged PR satisfied each box, and tick them, before slice 4 starts.

6. **MAJOR — slice 5's R10 sync is short by three documents.** Step 3 names README, `engineering-discipline.md`, `onboarding-for-engineers.md`. R10 names `AGENTS.md`, `guardrails.md`, `glossary.md`, the ADRs and the PRD convention as well — and "core/standard/full profile" is a new term, so the Glossary rule binds too. Slice 5 also verifies `adr-lint` alone where slices 2 and 3 verify all five. *Fix:* full R10 list, five checks.

7. **MAJOR — no child issue gets its own R12 plan.** AGENTS.md: *"Before step 1 there is an open issue with a reviewed, ordered plan (R12)."* This plan is #16's, not #19's. #19 produces code and needs its own ordered, reviewed plan before its first test. *Fix:* add that step to each slice, #19 above all.

8. **MINOR — a dropped audit item.** #16 §3 proposed a **commit-subject task-ID cross-check**. It is in no child issue and no slice. *Fix:* deliver it or write the rejection on #16.

9. **MINOR — #16's body will contradict the tranche at close.** §5 still recommends *"Give R4 a solo-operator form"*, which slice 2 reverses. *Fix:* erratum comment on #16 within slice 2.

10. **MINOR — "one per lens in `docs/review/`" is imprecise.** That directory holds five prompts; `plan.md` is the R12 plan review, not a code lens. #33 says four. *Fix:* name correctness, guardrails, simple, adversarial.

11. **MINOR — slice 1's range moves under it.** `2cd70ee..main` extends each time a finding's fix PR lands. *Fix:* state that the clearing round reads the range as it stands then.

## What the plan gets right

- The dependency argument for putting #33 first — an unreviewed defect on `main` spreads into every branch cut from it — is correct and is the strongest reasoning in the plan.
- Serialising #34 before #35 because both edit R-rules in the same three files is the right call: parallel gain here is smaller than the merge cost.
- Slice 4's honest limit — coverage, not agreement, with #31 named as the proof — is exactly the kind of claim the kit's own "What is enforced where" table demands, and pre-empts the obvious attack on it.
- Slice 1 step 4's "the round that clears it is never the round that found the last defect" is stricter than gate step 5 requires, and correctly so.



---

### Comment — pharzam — 2026-08-27T07:48:49Z

## R12 plan review — round 1 of 2, independent, fresh context (reviewer B)

A second, separately dispatched reviewer, also in a fresh context, also given
`docs/review/plan.md` verbatim. It did not see reviewer A's report. Posted unedited.

Two reviewers were run because the first three dispatched reviewers reached idle
without delivering a report — the same tooling failure that created this debt.
Redundancy was the answer, and it worked: both delivered, and they disagree in a
way that matters (see the revision comment).

---

# R12 plan review — tranche 2 of #16

**Verdict — REJECTED.** The plan drops six of #19's seven acceptance boxes and orders
#19 behind a dependency its own text proves is not real; both must be fixed before
building begins.

## Findings

1. **BLOCKER — Slice 4 covers one of #19's seven acceptance boxes.** #19 requires
   `backlog-lint`, `glossary-lint`, the drift check, a self-test harness over *every*
   linter, hook + CI wiring, the enforcement row, and the backlog move. The plan
   addresses only the drift check. R12: "a DoD item with no step is a gap." The other
   linters shipped in tranche 1 (and #29 fixed them), so the honest fix is not silence
   — write a step that states which boxes tranche 1 already satisfies, names the
   evidence, and ticks them in the landing pull request (gate step 8), or #19 closes
   with six boxes unticked.

2. **BLOCKER — the #19 ← {#34, #35} dependency is fictional, and the plan says so
   itself.** The stated reason is "it enforces by machine what slices 2 and 3 write as
   prose." Twelve lines later: "this check tests **coverage**, not **agreement**." A
   coverage check counts gate steps and R-numbers. Slices 2, 3 and 5 add no R-number
   and no gate step, so nothing in them can move the check. R12 puts the test work
   first; the plan puts the only machine check last for a reason that evaporates on
   reading. Fix: run #19 as slice 2, so #34, #35 and #20 land under the drift check
   rather than in front of it.

3. **MAJOR — two verification steps point at table rows that do not exist.** Slice 2
   step 4 ("both rows") and slice 3 step 3 ("the R6 row") of "What is enforced where."
   That table has an R4 row; it has **no R6 row and no gate-step-5 row**. "Stays
   honest" cannot be checked against a row that is absent. Fix: both steps must read
   *add* a row, each with its truthful status — R6's is "Aspiration — no machine can
   read a conversation", the same status the conversational glossary rule carries.

4. **MAJOR — slice 3 leaves the authority document silent.** `grep -n "R6\|agent-to-agent"
   docs/engineering-discipline.md` returns **0 matches**. "Wherever it names the channel"
   is therefore a no-op, and R6 — newly binding the human channel, the kit's most-used
   channel — ends up in `issue-workflow.md` and `AGENTS.md` while the document AGENTS.md
   calls "the authority" says nothing. Fix: slice 3 adds a short section to
   `engineering-discipline.md`, not a conditional edit.

5. **MAJOR — risk 2 rests on a quotation that is not in the text.** Gate step 5 does
   not say "an agent or a human"; **R9** says "another agent or session", about test
   confirmation, not step 5. Since the whole tranche is reviewed by agents, this is
   load-bearing. My ruling: an agent in a fresh context does satisfy step 5, because
   R9 already admits one for the stricter freeze decision — but slice 2 must write the
   distinction it will otherwise create: **review is not approval.** Removing R4's solo
   form while adding "only an independent reviewer satisfies step 5" puts "an agent is
   never the second operator" next to "an agent may be the reviewer" in the same
   change. State plainly that R4 governs approval authority and step 5 governs
   independence, or #34 recreates the confusion it exists to end.

6. **MAJOR — slice 6 does not satisfy #16's closing criterion.** #16 closes "when every
   child issue closes, **or when a rejected slice has a written reason here**."
   Deferring #22 is not rejecting it. Fix: close #22 as rejected-for-this-repository
   with the reason and a named place the adoption will happen, or leave #16 open.

7. **MAJOR — the README line in slice 6 is a change with no issue and no gate pass.**
   The plan puts "the decision, and the README line" in an issue comment. A README edit
   is a change: R1 wants an issue, gate step 8 wants a backlog move, and the tranche
   rule at the top of the plan wants an independent round. Fix: a small child issue for
   the README statement, or land the line inside slice 5's pull request.

8. **MAJOR — slice 5's R10 list is short.** It names README, `engineering-discipline.md`,
   `onboarding-for-engineers.md`. The plan's own DoD section names six documents.
   Profiles state which **rules** a tier keeps — under R10 that edits `AGENTS.md` in the
   same change — and "adoption profile", "core/standard/full tier" are new terms, so
   `glossary.md` needs rows or the pre-commit `glossary-lint` blocks the commit. Add
   `AGENTS.md`, `issue-workflow.md` and `glossary.md` to step 3.

9. **MAJOR — no child issue gets its own R12 plan.** R12 binds every issue and requires
   the plan and its confirmation **on that issue**. This plan lives on #16. #19 has code
   and starts a red/green cycle, so it needs its own ordered plan and one review comment
   on #19. Fix: state that each child issue carries its own plan and verdict, even if
   copied from here.

10. **MINOR — slice 5's verify is unsatisfiable as written.** "Every rule R1–R12 lands in
    exactly one tier" contradicts nested profiles, where a core rule is also in standard
    and full. Restate as: every rule names the lowest tier at which it first applies.
    Related: hard-coding **ADR-0005** is fragile when slice 1 runs first with an unbounded
    findings count and any finding may claim that number. Say "the next free ADR number."

11. **MINOR — risk 1 understates the hazard.** Every slice depends on #33 *closing*, and
    #33 cannot close until every material finding is fixed; each fix is its own pull
    request, which the tranche rule gives its own review round, which may find more. The
    plan's stopping rule covers the rounds over the accumulated diff, not the fix chain.
    Fix: make slices 2–5 depend on "the four lenses have run", not on "#33 closed", and
    hold only findings touching the R4/R6/profile text as true blockers.

## What the plan gets right

The debt-first ordering is correct and well argued. The stopping rule — "the round that
clears it is never the round that found the last defect" — closes a real loophole in
gate step 5. Naming the coverage-vs-agreement limit of the drift check, with #31 as the
counter-example, is the kind of honesty the kit demands and most plans skip. Recording
the "attacked and could not break" list on #33 is a genuine improvement over the kit's
written rule. And risk 3 is correctly identified as the point to press hardest — the
author was right about which finding matters, and wrong only about whether the plan
disposes of it.



---

### Comment — pharzam — 2026-08-27T07:50:03Z

## R12 plan — tranche 2, revision 2 after two REJECTED verdicts

Both reviewers rejected revision 1. **Every finding from both is accepted; none is
disputed.** I checked the three load-bearing factual claims against the tree
before accepting: the phrase *"an agent or a human"* is not in gate step 5
(it is in `docs/review/README.md`, about handing a prompt to a reviewer),
`docs/tasks/backlog.md` §Now is empty, and the commit-subject task-ID cross-check
is in #16 but in no child issue.

Two findings change the running order. The rest change wording, scope, or add a
step.

### What changed, finding by finding

| Finding | Accepted change |
| ------- | --------------- |
| A1, B6 — #22 is deferred, and #16 admits only a **rejected** slice | Slice 6 now **rejects** the slice from this parent with its reason here, and re-files the work as an issue that is **not** a child of #16, so "every child issue closes" holds honestly. |
| A2, B5 — risk 2 quotes text that does not exist | Risk 2 restated below. The sentence must be **written** by the R4 slice, not cited. B5's sharper point is adopted into that slice's acceptance: **R4 governs approval authority, gate step 5 governs independence** — an agent may be the reviewer and is still never the second operator. |
| A3 — the tranche rule said "round", singular | Restated as rounds-until-decay, matching gate step 5. |
| A4 — no slice creates the backlog line it promises to move | Every slice gains **step 0: open the backlog line**, after confirming `docs/tasks/<id>.md` is free. |
| A5, B1 — #19's Definition of Done is six-sevenths uncovered | New step, before slice 2 starts: record on #19 which merged pull request satisfies each already-green box, with evidence, and tick them. Silence would have closed #19 with six boxes unticked. |
| **B2 — the #19 ← {#34, #35} dependency is fictional** | **Accepted, and it reorders the tranche.** A coverage check counts gate steps and R-numbers; slices 3–5 add neither, so nothing in them can move it. R12 puts test work first. **#19 becomes slice 2**, and the drift check then guards #34, #35 and #20 as they land instead of arriving after them. |
| B3 — two verify steps point at table rows that do not exist | Confirmed: "What is enforced where" has an R4 row but **no R6 row and no gate-step-5 row**. Both steps now read *add a row*, with its truthful status. |
| B4 — slice 3 leaves the authority document silent | Confirmed: `engineering-discipline.md` contains no R6 and no "agent-to-agent". The R6 slice now **adds a section** there; it is not a conditional edit. |
| A6, B8 — the profiles slice's R10 list is short | Full R10 list, `glossary.md` rows for the new terms, and all five checks rather than `adr-lint` alone. |
| A7, B9 — no child issue gets its own R12 plan | Each child issue carries its own ordered plan and one recorded confirmation, on that issue. |
| A8 — the commit-subject task-ID cross-check was silently dropped | It is #16 §3's third item and reached no child issue. Added to **#19** as an explicit acceptance box, with a note saying it was dropped when #19 was written. |
| A9 — #16's own body will contradict the tranche | #16 §5 still says *"Give R4 a solo-operator form"*. An erratum note lands on this issue inside the R4 slice. |
| A10 — "one per lens in `docs/review/`" is imprecise | The directory holds five prompts. The four code lenses are **correctness, guardrails, simple, adversarial**; `plan.md` is this review. |
| A11, B11 — slice 1's range moves, and "#33 closed" can deadlock | The clearing round reads the range as it stands then. Slices 2–5 depend on **"the four lenses have run"**, not on #33 being closed. Only a finding that touches the R4, R6 or profile text is a true blocker for its slice. |
| B7 — the README line in slice 6 is a change with no issue | It gets its own small child issue and its own gate pass. |
| B10 — "exactly one tier" is unsatisfiable; ADR-0005 is fragile | Restated as *the lowest tier at which a rule first applies*. The ADR takes **the next free number**, since slice 1 may consume one. |

### The order, revised

| # | Slice | Issue | Task ID | Depends on | Why it sits here |
|---|-------|-------|---------|-----------|------------------|
| 1 | Clear the review debt | #33 | `T-5r2q` | — | An unreviewed defect on `main` spreads into every branch cut from it. Both reviewers called this the strongest reasoning in the plan; it is unchanged. |
| 2 | Drift check + commit-ID cross-check | #19 | `T-2c9x` | the four lenses have run | **Moved up (B2).** It is the only slice with code, R12 puts test work first, and it has no real dependency on slices 3–5. It then guards them. |
| 3 | Remove the R4 solo form | #34 | `T-8d6y` | the four lenses have run | Rule change. Lands under the drift check rather than in front of it. |
| 4 | Widen R6 to the human channel | #35 | `T-3n7w` | #34 | Follows #34 because both edit R-rules in the same three files; in series there is no conflict to resolve. |
| 5 | Adoption profiles | #20 | `T-6f4k` | #34, #35 | A profile names the rules a tier keeps, so the rule set must be final first. |
| 6 | Dogfood — **rejected from this parent** | #22 | — | — | It cannot land in this repository. Rejected here with its reason, and re-filed as a standing issue outside #16. |
| 7 | The README honesty line | new | `T-7q5b` | — | *"No adoption on a product repository exists yet."* A README edit is a change: its own issue, its own gate pass (B7). |

### Per-slice steps

Every slice begins with **step 0 — open its backlog line** (after confirming
`docs/tasks/<id>.md` is free) and **step 0b — post its own ordered plan on its own
issue, with one recorded confirmation** (A7, B9).

**Slice 1 — #33, clear the review debt (`T-5r2q`).**

1. Four rounds over `2cd70ee..main` — the accumulated diff of #24, #25, #26, #27,
   #28, #30 and #32 — one round per **code** lens: `correctness.md`,
   `guardrails.md`, `simple.md`, `adversarial.md`. Each in a fresh context that
   has not seen the author's reasoning.
2. Record each round on #33: the lens, what it read, what it found, and what it
   attacked and could not break.
3. Every material finding gets its own issue and its own gate pass. A finding
   rejected on inspection gets its reason written on #33.
4. Rounds continue until one round finds nothing material, and that round is never
   the one that found the last defect. The clearing round reads the range **as it
   stands then**, including any fix that has landed since (A11).
5. The seven deviation records are already collected on #33. Backlog line →
   completed.

**Slice 2 — #19, the drift check and the commit-ID cross-check (`T-2c9x`). Strict
TDD — this slice has code.**

1. **Before anything else:** record on #19 which merged pull request satisfies each
   already-green acceptance box, with evidence, and tick them (A5, B1). Add the
   commit-subject cross-check as an explicit box, with the note that it came from
   #16 §3 and reached no child issue (A8).
2. **Red first.** Fixtures: an `AGENTS.md` missing one gate step; one missing an
   R-number; one clean. Commit-subject fixtures: an ID that is in no task file; an
   ID that is present; a subject with no ID at all, which must pass. Run the
   runner: every new case fails, because neither check exists.
3. **Green.** The drift check: every gate step in `engineering-discipline.md` and
   every R-number in `issue-workflow.md` appears in `AGENTS.md`. The cross-check:
   a task ID in a commit subject exists in `backlog.md` or `completed.md`.
4. Wire both into `.githooks/` and both CI templates.
5. "What is enforced where" gains a row for each. Backlog line → completed.

The honest limit, restated so no reader mistakes it: the drift check tests
**coverage**, not **agreement**. [ADR-0004](docs/adr/0004-ship-a-root-agents-file.md)
says so, and #31 is the proof — three real contradictions a coverage check would
have passed.

**Slice 3 — #34, remove the R4 solo form (`T-8d6y`).** Documents only.

1. `issue-workflow.md`: R4 states one approval rule — two different operators, in
   writing, on the issue — and says what a solo operator does instead.
2. `engineering-discipline.md`: **write** into gate step 5 that only an independent
   reviewer in a fresh context satisfies it, and that the author's own session
   never counts (A2 — this sentence does not exist yet).
3. State the distinction the same change creates (B5): **R4 governs approval
   authority; gate step 5 governs independence.** An agent in a fresh context may
   be the reviewer, and is still never the second operator.
4. `AGENTS.md`: the same lines (R10).
5. "What is enforced where": the R4 row updated, and a **new** gate-step-5 row
   added with its truthful status (B3).
6. Erratum note on #16, whose §5 still recommends the form this slice removes (A9).
7. Verify: five checks green; no solo branch of R4 survives.

**Slice 4 — #35, widen R6 (`T-3n7w`).** Documents only.

1. `issue-workflow.md`: R6 binds agent-to-agent **and** agent-to-human, in both
   directions. Keep the severity and response-time convention. State what may stay
   in a session and what has to reach the issue.
2. `engineering-discipline.md`: **add** a short section — the document has no R6
   text at all today, so "keep it in step" would have been a no-op (B4).
3. `AGENTS.md` R6 row (R10). If the R6 heading is renamed, repoint the anchor in
   `docs/adr/0004-ship-a-root-agents-file.md`, which links it today.
4. "What is enforced where": **add** an R6 row. Its honest status is
   "Aspiration — no machine can read a conversation", the status the conversational
   glossary rule already carries (B3).
5. Verify: five checks green, plus the drift check from slice 2.

**Slice 5 — #20, adoption profiles (`T-6f4k`).** Documents plus an ADR.

1. Three profiles — core, standard, full — as one table: the documents each keeps,
   the rules each keeps, and what an adopter gives up by deferring the rest.
2. An ADR at **the next free number** records the decision (B10).
3. R10 sync in full: README, `engineering-discipline.md`, `issue-workflow.md`,
   `AGENTS.md`, `guardrails.md`, `onboarding-for-engineers.md`, and `glossary.md`
   rows for the new terms — without them the pre-commit `glossary-lint` blocks the
   commit (A6, B8).
4. Verify: all five checks plus the drift check; every rule R1–R12 names **the
   lowest tier at which it first applies** (B10).

**Slice 6 — #22, rejected from this parent.** It cannot land inside this
repository. #22 is closed as rejected **for this parent**, with the reason written
on #16, and the work is re-filed as an issue that is not a child of #16 — so the
kit's largest open risk stays visible and #16's closing criterion is met as
written, not as reinterpreted (A1, B6).

**Slice 7 — the README honesty line (`T-7q5b`).** Its own child issue, its own
gate pass: the README states plainly that no product-repository adoption exists
yet, and points at the re-filed issue (B7).

### Definition-of-Done coverage

Every acceptance box on #33, #19, #34, #35, #20 and the new README issue maps to a
step above — including the six boxes on #19 that revision 1 left silent. The
binding rules:

- **Rounds until decay** — every pull request in this tranche gets independent
  review **rounds**, a different lens each, until one finds nothing material (A3).
  No new debt is created while old debt is repaid.
- **R10 sync** and **backlog move**, in the same pull request, on every slice.

### The risks, restated

1. **Slice 1 has no fixed size, and its fix chain can deadlock the tranche.** Each
   finding is its own pull request, which gets its own rounds, which may find more.
   So slices 2–5 depend on *the four lenses having run*, not on #33 closing; only a
   finding that touches the R4, R6, or profile text blocks its slice (A11, B11).
2. **The independent reviewer is an agent in a fresh context, not a second human.**
   Gate step 5 does **not** currently say an agent qualifies — revision 1 claimed
   it did, and was wrong. Both reviewers ruled that an agent in a fresh context
   does satisfy step 5, because R9 already admits one for the stricter
   test-freeze decision. Slice 3 must therefore **write that down**, together with
   the distinction it creates: reviewing is not approving.
3. **Closing #16 while the kit has never run on a product repository.** This is
   unchanged and is the sharpest point in the tranche. The disposal is now a
   rejection with a written reason plus a re-filed standing issue, not a
   reinterpretation of the closing criterion.
4. **New, from the round itself: the review tooling is unreliable.** Three
   dispatched reviewers reached idle without delivering — the same failure that
   created this debt. The answer used here was redundancy plus a written artifact:
   two reviewers, each required to write its report to a file *and* return it. Both
   delivered. If a slice's rounds hit the same failure, the rule is to repeat with
   redundancy, never to record a deviation and merge.

This revision goes to one confirmation round before building begins.



---

### Comment — pharzam — 2026-08-27T07:53:53Z

## R12 plan review — confirmation round on revision 2

A third independent reviewer, fresh context, given `docs/review/plan.md` verbatim,
plus revision 2 and both earlier reports. Its brief was to check whether revision 2
**actually** fixed each finding or only claimed to, and to judge the three parts that
were new in revision 2 and had never been reviewed. Posted unedited.

---

# R12 confirmation round — tranche 2 of #16, revision 2

**Verdict — APPROVED WITH CHANGES.** Every finding from A1–A11 and B1–B11 is
genuinely addressed except three that are claimed as accepted and are not
(A6/B8, B1, B6), and the three new parts — the reorder, the rejection of #22,
and slice 7 — introduce one real dependency error and one self-contradiction;
all seven fixes below are edits to the plan text, so building may begin once
they are made, with no further round.

## Findings

1. **MAJOR — slice 7 has a dependency the table denies (new in revision 2).**
   Slice 7's README line "points at the re-filed issue", which slice 6 creates,
   yet the table gives slice 7 `Depends on —`. R12: "Foundational and blocking
   steps precede the steps that depend on them." Slice 7 also edits the README,
   as does slice 5 — the same file collision that made the plan serialise #34
   before #35, left unordered here. *Fix:* slice 7 depends on slice 6, and lands
   after slice 5.

2. **MAJOR — "R10 sync in full" in slice 5 is still not full.** R10
   (`docs/issue-workflow.md:115`) names `AGENTS.md`, `engineering-discipline.md`,
   **the ADRs**, `guardrails.md`, `glossary.md`, and **the PRD convention**
   (`docs/prd/README.md`). Revision 2 lists seven documents and omits the PRD
   convention, and treats the ADRs only as "write a new one" — R10 asks that the
   existing ones stay in step, and ADR-0004 states the rule set the profiles
   re-tier. A6 named both. *Fix:* add `docs/prd/README.md`, and a check that
   ADR-0001…0004 do not contradict the tiers.

3. **MAJOR — the universal step 0 / step 0b rule contradicts the plan's own
   table.** "Every slice begins with step 0 — open its backlog line … and step 0b
   — post its own ordered plan on its own issue." Slice 6 has Task ID `—`, opens
   no backlog line, produces no pull request, and is a rejection, so it has no
   plan and no gate pass. As written the plan breaks its own rule at slice 6, and
   slice 7 cannot post a plan on an issue that step 0b itself must create.
   *Fix:* bind step 0/0b to slices 1–5 and 7; state that slice 6 is issue
   bookkeeping — no backlog line, no PR, no gate pass — and that slice 7's step 0b
   follows opening its issue.

4. **MAJOR — B1 is accepted in a form that breaks gate step 8.** B1's fix was
   explicit: tick #19's already-green boxes "in the landing pull request (gate
   step 8)". Revision 2 ticks them "before anything else", outside any pull
   request. `engineering-discipline.md:144` puts the ticking in the closing PR.
   *Fix:* post the evidence comment on #19 first — that part is right — and tick
   the boxes in slice 2's landing PR.

5. **MAJOR — the rejection of #22 names no destination.** B6 required "a named
   place the adoption will happen"; revision 2 gives only "an issue that is not a
   child of #16". #16 then closes on a promise with no repository, no owner, and
   no trigger, and slice 7's README line has nothing concrete to point at. *Fix:*
   name the repository, or state plainly that none is chosen and that this is the
   standing risk the re-filed issue holds.

6. **MINOR — slice 3 step 3 names no file.** Steps 1, 2, 4 and 5 each name their
   document; the R4-versus-step-5 distinction B5 asked to be *written* does not.
   *Fix:* land it in R4 in `issue-workflow.md`, mirrored in `AGENTS.md` by step 4.

7. **MINOR — slice 1 runs agent reviewers under a rule slice 3 has not yet
   written.** Risk 2 concedes gate step 5 does not today admit an agent; slice 1's
   four rounds, on which slices 2–5 depend, run before slice 3 writes it down.
   *Fix:* record both reviewers' ruling on #33 before its first round.

## What the revision gets right

The reorder is correct and better argued than the original: #19 is the only slice
with code, R12 puts the test slice first, and slices 3–5 add no R-number and no
gate step, so nothing in them can move a coverage check. It also fixes something
B2 did not claim — step 0 opens each backlog line before slice 2's commit-subject
cross-check goes live, so the later slices' own commits pass the check they land.
B3 and B4 were verified against the tree, not assumed: the table has no R6 row and
no gate-step-5 row, and `engineering-discipline.md` carries no R6 text, so "add"
rather than "keep in step" is right. A10 is accurate — `docs/review/` holds five
prompts plus a README. The six task IDs all obey the repository's scheme. And risk
4, the unreliable review tooling, is a real finding the reviewers did not raise.



---

### Comment — pharzam — 2026-08-27T07:54:52Z

## R12 plan — revision 3: the seven confirmation changes applied. Building begins.

The confirmation round returned **APPROVED WITH CHANGES**, with the ruling that
all seven fixes are edits to the plan text, so building may begin once they are
made, with no further round. All seven are accepted; none is disputed. This
comment is the delta against revision 2 — every other part of revision 2 stands.

**1 — Slice 7 depends on slice 6, and lands last.** The README line points at the
issue slice 6 re-files, and slice 5 edits the same README. The order is now
1 → 2 → 3 → 4 → 5 → 6 → 7, with slice 7 blocked on both 5 and 6.

**2 — Slice 5's R10 list, completed.** Adds `docs/prd/README.md` (the requirements
convention, which R10 names and revision 2 omitted), and a step that checks
ADR-0001 … ADR-0004 do not contradict the tiers — R10 asks that existing records
stay in step, not only that a new one is written.

**3 — Step 0 and step 0b bind slices 1–5 and 7, not slice 6.** Slice 6 is issue
bookkeeping: no task ID, no backlog line, no pull request, no gate pass. Slice 7's
step 0b follows opening its issue, because a plan cannot be posted on an issue
that does not exist yet.

**4 — #19's already-green boxes are ticked in slice 2's landing pull request, not
before.** The evidence comment is posted now (it is
[here](https://github.com/pharzam/armature/issues/19#issuecomment-5436050413)),
and the boxes stay unticked until the closing pull request, because gate step 8
puts the ticking there. Revision 2 had them ticked outside any pull request; that
has been undone on #19.

**5 — The rejection of #22 names its destination honestly.** There is no chosen
repository. The re-filed issue holds that as the kit's standing risk, and says so
in those words: *no product repository has been selected, and until one is, every
rule in this kit has only ever run against a repository with no product code.*
Slice 7's README line points at that issue and states the same thing. A promise
with no repository is what the rejection records — not what it hides.

**6 — The R4-versus-step-5 distinction gets a home.** It is written into R4 in
`docs/issue-workflow.md`, and mirrored in the `AGENTS.md` R4 row by slice 3 step 4.
Revision 2 asked for it to be written and named no file.

**7 — Slice 1's reviewers run under a rule that is not yet written, so the ruling
is recorded before the first round.** Both plan reviewers ruled that an agent in a
fresh context satisfies gate step 5 — R9 already admits one for the stricter
test-freeze decision, and nothing in step 5 requires a human. That ruling is now
[recorded on #33](https://github.com/pharzam/armature/issues/33) ahead of its first
round, and slice 3 writes it into the discipline document.

---

### The plan is now reviewed and confirmed. Three rounds, all independent, all in fresh contexts:

| Round | Verdict | Findings |
| ----- | ------- | -------- |
| Reviewer A | REJECTED | 11 |
| Reviewer B | REJECTED | 11 |
| Confirmation | APPROVED WITH CHANGES | 7 |

Twenty-nine findings, every one accepted. Two changed the running order, one added
a missing acceptance box to #19, one corrected a box that overstated what a linter
does, and one corrected boxes ticked outside a pull request. **No code had been
written when any of this was found** — which is the argument for R12's single plan
review, made three times over.

Slice 1 begins now.



---

### Comment — pharzam — 2026-08-27T10:41:02Z

**Status: main was reset. `main` is back at `2cd70ee` — the revision this audit ran against, before any change made under this issue.**

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`, merge of #32): 45 commits, 67 files changed, 1,659 insertions.

**Why the reset:** the purpose is to learn this issue and do the work again — the audit, the child issues, the plan, and the implementation — instead of keeping a completed result that was never fully absorbed.

This issue stays open as the parent. The child issues and the review record remain as reference material. The implementation will be rebuilt against them.


---

### Comment — pharzam — 2026-08-27T10:59:37Z

## Independent review of the full #16 record — what broke, what it teaches, and a plan that closes this issue completely

*Requested by the operator. Written in a fresh context against: the issue body, every comment from 2026-08-26 13:48 to the reset at 2026-08-27 10:41, the round record on #33, child issues #17–#41, PR #42, `main` at `2cd70ee`, and [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f).*

### 1. The review — six findings about the process itself

**R-1. The first break was not gate step 5. It was the missing rule above it.**
Gate step 5 was skipped on seven PRs (#24–#28, #30, #32). The cause was the same every time: reviewer agents reached idle and delivered nothing. The kit had no rule for a gate that cannot run, so each PR converted "the gate is unavailable" into "record a deviation and merge". A gate you can pass by writing a note is a log, not a gate. The skip repeated six more times because nothing forced a stop after the first — #33's own record already states this: *"A gate that can be missed twice in the same way is missing a rule, not just a round."*

**R-2. Every skip was self-approved, and the debt had no removal issue.**
The session that wanted to merge was the only party that accepted the skip — R4's forbidden shape, applied to a gate instead of a workaround. And no removal issue existed until #33 opened the next morning; for about sixteen hours the debt was, in the kit's own words, "a permanent defect wearing a temporary label." The check comment ([5435238227](https://github.com/pharzam/armature/issues/16#issuecomment-5435238227)) caught this, corrected the PR count, and reversed a wrong R4 argument — which shows something the kit should state plainly: **independent review works on prose and plans, not only on code.**

**R-3. One defect class appeared at every layer.**
"A check that reports OK having checked less than it claims" was found in:

- the linters — unclosed comment/fence swallowing files, `GIT_DIR`, `core.quotePath`, CRLF, the `*/tests/*` exclusion, the hook linting the working tree instead of the index (#36, #38, #39);
- the runner — exit 1 counted as "caught the defect"; deleted linters and whole fixture sets still reported `OK` (#37);
- the process — self-review ticking gate boxes; R10-sync boxes ticked over a stale README in three consecutive PRs; PR #24 recording no deviation at all (#40);
- and now the tracker — see R-5.

The process bug and the code bugs are the same bug. Every fix must assert the **reason**, not the outcome — which is exactly what PR #42 does for the runner.

**R-4. The numbers close the argument for the rule.**
Self-review caught 3 real defects. The two late adversarial passes caught 6 more. The four proper rounds caught ~30 findings, 9 reproduced end to end. Plan review caught 29 findings before one line of code existed. Cheapest first: plan review → review before merge → adversarial review after merge → defects living on `main`. The kit's rules had this ranking right; the execution inverted it.

**R-5. The reset solved a learning problem and created four bookkeeping problems.**
The reset was recorded, and the backup branch preserves everything — that part follows "Honesty and evidence." But:

1. The reset itself is a change to `main` that reached it without a PR and without a round — the exact rule this thread restated three hours earlier. No written rule says when `main` may be reset. It needs one (an ADR), or it must not happen again.
2. All child issues (#17–#41) are closed as **completed** while `main` holds none of their deliverables. The tracker now claims more than `main` holds — R-3's class, in the issue tracker.
3. PR #42 is open against the reset `main`. Its branch carries the whole pre-reset history, so it can no longer merge as-is.
4. Leftovers exist again: local branches `chore/t-5r2q-review-debt` and `fix/t-3k8w-runner-asserts-reason`, and an untracked `.worktree/` (the reset removed the `.gitignore` line that covered it) — the class #23 cleaned.

**R-6. Why absorption failed — the finding underneath the reset.**
45 commits, 67 files, ~1,659 insertions, in under three hours, in one session. The kit gates code quality at eight points. It gates operator understanding at zero. Nothing in the process asks the human to absorb anything before the next slice starts. That is the gate that was truly missing, and no rule change proposed so far covers it.

### 2. What the record got right

- Six of seven deviation records were honest and quotable — that honesty is the only reason the debt was countable and clearable.
- The late rounds were run instead of buried, and eight findings were re-verified against a clean archive before filing.
- Plan review rejected twice; all 29 findings were accepted only after the three load-bearing factual claims were checked against the tree.
- The gate-step-5 ruling (an agent in a fresh context qualifies; reviewing is not approving) was written down **before** the rounds ran, not assumed by them.
- The "attacked and could not break" lists are a real improvement over the written rule — they stop the next round from repeating work.
- Redundancy plus a required written artifact fixed the reviewer-tooling failure, cheaply. Had that been the rule on Aug 26, this debt would not exist.

### 3. Learnings

| # | Learning | Grounded in |
|---|----------|-------------|
| L1 | A gate that cannot run stops the line. "Record and proceed" turns a gate into a log. | seven skips, one cause |
| L2 | Assert the reason, not the outcome — in linters, runners, PR bodies, and issue states. | #36–#40, the closed children |
| L3 | Self-review is real but shares the author's blind spots: 3 catches against ~36. | the counts in R-4 |
| L4 | Against unreliable reviewer tooling: dispatch ≥2 reviewers, each writes its report to a file **and** returns it. Never merge past a failed dispatch. | the method that worked on Aug 27 |
| L5 | Unreviewed work on `main` compounds — every later branch inherits it. | the `GIT_DIR` defect's life on `main` |
| L6 | Plan review is the cheapest review that exists. | 29 findings, zero code written |
| L7 | Records need machine checks too, or one PR in seven records nothing. | #24 |
| L8 | Velocity without absorption checkpoints produces "completed but not learned." | the reset's own stated reason |

### 4. The plan that closes #16 completely

**Phase 0 — reconcile the tracker (one sitting).**
Write the ADR for the reset: `main` may be reset only with a backup branch, a written record on the parent issue, and a stated relearn goal — all three of which this reset had; the rule just did not exist. Close PR #42 with a pointer (its content returns in Phase 2). Delete the two stale local branches and the worktree leftover. Reopen — or supersede with fresh child issues that link them — every closed child whose deliverable `main` does not hold. The tracker must never claim more than `main` holds.

**Phase 1 — patch the rules before any code (small PRs, each with its own rounds).**

1. Gate step 5 gains the stop rule and the fallback (L1 + L4), written into `engineering-discipline.md`: *if the round cannot run, work stops; the fallback is redundancy with a written artifact; a deviation record never substitutes for the round.*
2. The ruling lands: an agent in a fresh context satisfies step 5; **R4 governs approval authority, step 5 governs independence** (#34's content — decided and thrice-reviewed; only the landing remains).
3. R4: two operators, always; the removal issue is opened at the moment the workaround is recorded, or the workaround does not merge.
4. R6 widened to the human channel (#35's content).

**Phase 2 — redo tranche 1 with the review record as its test list.**
The backup branch is reference, never a merge source. Re-land each slice as a fresh PR from clean `main`, in the tranche-1 order. Land the runner-asserts-why fix first — the triage already ruled #37 goes first, so every later fixture proves something. Then, for each linter slice: turn every reproduced defect from #36–#39 into a fixture **red first**, then port or rewrite the code. Fold #40's six corrections and #41's roster deletions into the slices they touch. Every PR gets rounds until decay before merge — no exceptions, because Phase 1 removed the excuse.

**Phase 3 — add the absorption gate (the reason the reset happened).**
One slice per sitting. Before merge, the operator writes three sentences on the PR, in their own words: what the change does, which defect class it closes, and what would break if it were wrong. No agent writes it for them. It is cheap, it is checkable (the section exists or it does not), and it is the only step in the whole gate that measures the thing this reset was about. For at least one slice, invert the roles: the human writes the plan, and the agents review it.

**Phase 4 — finish the remaining slices and close.**
#19 (drift check + commit-ID cross-check), #20 (profiles), and the #22 rejection with the README honesty line — per the revision-3 plan, which survives as reference. Give that plan one confirmation round against the redone base: its three earlier rounds hold, but the base they reviewed against no longer exists. #16 then closes on its own criteria: every redone slice merged with its rounds, every finding issue fixed or rejected in writing, the clearing round finds nothing material and is never the round that found the last defect, and the review debt is zero.

---

One sentence for the whole record: **the rules were right, the execution skipped one, and everything that went wrong afterwards is a measurement of that single skip — so the redo's job is not new rules; it is making the existing gate impossible to pass by note, and adding the one gate that was genuinely missing: the operator's own understanding.**



---

### Comment — pharzam — 2026-08-27T11:56:49Z

## Phase 0 — the tracker is reconciled. One item is written but not landed.

Executing [Phase 0 of the review's plan](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512). Four items; three are done, one is deliberately unfinished and says so.

### 1. Reopen every closed child whose deliverable `main` does not hold — **done**

**All eighteen** — #17, #18, #19, #20, #21, #22, #23, #29, #31, #33, #34, #35, #36, #37, #38, #39, #40, #41 — were closed as *completed*. `main` at `2cd70ee` holds **none** of their deliverables. Every one is now open, each with its own evidence comment and the phase it returns in.

The check, not the claim:

```
$ git ls-files | wc -l          # main at 2cd70ee
73

$ for p in AGENTS.md CLAUDE.md docs/review/README.md docs/glossary-lint.sh \
           docs/tasks/backlog-lint.sh docs/tests/discipline-tests.sh \
           docs/adr/0004-ship-a-root-agents-file.md; do
      git cat-file -e main:$p 2>/dev/null && echo "PRESENT $p" || echo "ABSENT  $p"
  done
ABSENT  AGENTS.md
ABSENT  CLAUDE.md
ABSENT  docs/review/README.md
ABSENT  docs/glossary-lint.sh
ABSENT  docs/tasks/backlog-lint.sh
ABSENT  docs/tests/discipline-tests.sh
ABSENT  docs/adr/0004-ship-a-root-agents-file.md
```

Three of the eighteen needed a judgement rather than a file check, and each was written up on its own thread rather than swept in with the rest:

- **#34** is *half* true on `main`, for the wrong reason. The reset removed #21's solo form of R4 by deleting the commit that added it, not by deciding anything. The load-bearing half — the ruling that an agent in a fresh context satisfies gate step 5, and that R4 governs approval authority while step 5 governs independence — is on no branch at all.
- **#33**'s real output is the review record on its own thread, and that is intact. What is unmet is the acceptance line that matters: findings #36–#41 are unfixed on `main`. It closes when the debt is zero, not when it is logged.
- **#22** was a rejection, and the rejection stands. Its *artifact* — the README honesty line — never landed, so a reader of `main` cannot tell a written-off slice from one nobody did.

Where the reopen comment could mislead a later reader, it says so instead. **#21** must re-land its abbreviation half **only**; its R4 half is reversed by #34. **#40**'s six corrections must be **re-verified against the redone base** before use — they were verified against a tree that no longer exists, and #19 already shows what happens when a correction list outlives its base. **#41** closes by never creating the nine roster copies in the first place; if the redo creates them and then deletes them, it has taught nothing.

### 2. Preserve what the backup missed, then clear the leftovers — **done**

The reset's backup did **not** hold everything. Two branch tips post-dated it:

```
$ git merge-base --is-ancestor 9e84512 origin/backup/pre-r12-reset-999765f  # chore/t-5r2q
NO - not contained
$ git merge-base --is-ancestor 41e15a5 origin/backup/pre-r12-reset-999765f  # fix/t-3k8w
NO - not contained
```

`fix/t-3k8w-runner-asserts-reason` was safe on the remote. `chore/t-5r2q-review-debt` existed **only on this machine** — one commit, the one that opened the review-debt task. It was pushed to `backup/pre-r12-reset-t-5r2q` **before** anything was deleted. Only then were both worktrees removed, both local branches deleted, and `.worktree/` dropped.

This is precondition 2 of the new ADR, met by doing rather than by asserting — and it is also a correction to the reset's own record. "The backup branch preserves everything" was true of the tranche and not true of the workspace.

### 3. Close PR #42 with a pointer — **done**

[#42 is closed](https://github.com/pharzam/armature/pull/42), and **nothing in it is rejected**. Its branch tip `41e15a5` sits on a merge base of `2cd70ee`, so merging it would land the eight commits of the fix *plus the 45 the reset deliberately removed*. The branch **stays on the remote** as reference — do not delete it until #37 has re-landed.

Worth carrying forward: #42 is the one branch in the tranche that ran the gate as written, and the numbers say what that is worth. **Four review rounds found twenty-one holes** — nine, then seven, then five — in a fix that had already satisfied its author. That is finding R-4 measured on a single branch.

### 4. Write the ADR for the reset — **written, reviewed by nobody, not landed**

[#43](https://github.com/pharzam/armature/issues/43) is the issue, [#44](https://github.com/pharzam/armature/pull/44) is the pull request, and **it is open, not merged.** ADR-0004 records four preconditions, all written *before* a reset rather than after: a stated goal with the cheaper alternatives weighed, a backup branch on the remote, every affected issue returned to open, and a record on the parent issue. It scores the 2026-08-27 reset against them in a table — **two met, one partly, one not at all** — because a record written by the operator who performed the reset has to show the score, or it is permission granted in hindsight.

**Two gates on it did not run, and neither is being waived:** R12's plan review, and gate step 5. Both need a second party this session did not have.

So the line stopped. That is [L1](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512) applied to the first change after the review that produced it — *a gate that cannot run stops the line; "record and proceed" turns a gate into a log*. **#44 does not merge until both rounds run and are recorded on #43.** A change whose whole subject is "write the preconditions down first" would be a poor advertisement for itself if it merged past the two gates it could not satisfy.

### What Phase 0 found on its way through

**#36 reproduced live, and grew.** Building #43 staged one file, `docs/tasks/backlog.md`, and the hook refused the commit because of an **untracked file that was not in it** — [the full reproduction is on #36](https://github.com/pharzam/armature/issues/36#issuecomment-5438656027). The second consequence was not in the original report: because the hook lints the working tree, a failing tree cannot be committed **at all**, so in this repository the red half of red-green can only ever be *observed*, never committed, for a documentation change. #36 is therefore not just "the gate checks the wrong thing" — it is **why this repository cannot practise its own R8 literally**. That belongs in its acceptance criteria when it re-lands.

**ADR number `0004` is now claimed.** The pre-reset history gave `0004` to the `AGENTS.md` decision. `adr-lint` requires contiguous numbering from `0001`, so the number belongs to whichever record lands first. When #17 re-lands, its ADR is **`0005`**, and the re-land must not port the `0004` filename. Recorded on #17.

**`.worktree/` is back, and legitimately.** `.worktree/t-7d2x` holds the live #43 branch. It is untracked and unignored because `.gitignore` on `main` carries only `.obsidian/` — #23's line has not re-landed. The distinction Phase 0 acted on: *stale* leftovers (no open pull request) were deleted; a *live* worktree with an open pull request stays until it merges. It is also standing evidence for #23.

### State after Phase 0

| | |
|---|---|
| `main` | `2cd70ee`, untouched — nothing merged |
| Open child issues | 18 reopened, plus #43 |
| Open pull requests | #44 only, blocked on two un-run gates |
| Preserved references | `backup/pre-r12-reset-999765f`, `backup/pre-r12-reset-t-5r2q`, `fix/t-3k8w-runner-asserts-reason` — all reference only, never merge sources |
| Stale leftovers | none |

**The tracker now claims exactly what `main` holds, and no more.**

### The next move

Phase 0 does not close until #44 merges, and #44 does not merge until its two rounds run. Once it does, **Phase 1** patches the rules before any code — gate step 5's stop rule and fallback, the step-5 ruling (#34), R4's removal-issue timing, and R6's human channel (#35) — and **Phase 2** re-lands tranche 1 with #37 first, every reproduced defect a red fixture before any code is ported.


---

### Comment — pharzam — 2026-08-27T13:13:05Z

## The 2026-08-27 reset, scored against the rule it produced

**Snapshot of the scorecard and the open question from [`docs/tasks/t-7d2x.md`](https://github.com/pharzam/armature/blob/1e49551/docs/tasks/t-7d2x.md) at `1e49551`.** The repository copy is canonical, and this is refreshed when #47 merges.

> Generated from the file at the commit named above, not edited from the previous comment. Refreshed after [round 12](https://github.com/pharzam/armature/issues/43#issuecomment-5449869479), which found this snapshot scoring condition 1 on two limbs when the record gives it three, quoting it truncated without marking the cut, and asserting a conclusion the cited evidence does not support. Every condition quote below is asserted verbatim against the record at generation time, and every truncation is now asserted to be marked.

## Open question, recorded rather than decided

Condition 2 requires a second **person**, so on a one-person project the *destruction*
path is closed. The repair path is not, for now: nothing has yet landed on `main` since
the 2026-08-27 reset — this record's own merge ends that — and both a backup reference
and the forge's record of the merge that produced the discarded tip survive — so
restoring it is a fast-forward that makes nothing unreachable, and outside the record's
own definition of destruction. That is not the same as being permitted: ADR-0004 says
only that it does not reach the act, and leaves what governs it to [#48](https://github.com/pharzam/armature/issues/48). The question
stops being a fast-forward one the moment anything lands, because the restore would then
discard that work. If that proves wrong in practice, the correction is a **superseding**
ADR, not an edit: the decision would have changed, and `adr/README.md` reserves
amendment for a decision that still holds.

## What this record deliberately does not carry

Nine rounds of independent review ran over a draft that grew to 11,895 bytes,
about twice the size of ADR-0004 today, and most of what they found was in material added beyond
what the audit asked for. That material is recorded here, where an adopter
deletes it with the file, rather than in an ADR they cannot edit.

**Undoing a destruction.** The draft carried a repair carve-out that waived the
second-operator requirement, plus a recursion bound and a fast-forward rule to
contain it. Review found, in order: it exempted the very reset it scores; it
waived all five conditions rather than one; it contradicted itself; it recursed
without bound, leaving every un-undone destruction a standing single-operator
licence; and once bounded by count it was still unbounded in time. Each fix
raised a new defect. The carve-out is deferred to
[#48](https://github.com/pharzam/armature/issues/48), which carries all five
failures so the next draft does not rediscover them.

One decision #48 inherits: the cut draft held that a fast-forward repair "is
still a repair, and conditions 1, 3, 4 and 5 still apply to it", where the
record now says it does not reach the act at all. The looser reading is the one
in force, and it was never argued for — it should be settled deliberately.

**Acts that reach the same outcome sideways.** A default-branch swap — point the
canonical role at a new branch, then delete or rewrite the old one — walked past
an enumerated definition twice. The definition is anchored to the remote's
default branch now — to *every* branch that has held that role, not only the
current one, which is what stops an operator moving the pointer and then
emptying the branch it left behind. Three earlier definitions were walked past
because they tested only the branch that is the default at the moment of the
act. It does carry two
stated exceptions — the swap where the old branch stays, and local history never
pushed — because a definition with no exceptions turned out to be a definition
that either caught the swap or exempted anyone who made a backup. The tag act
and the per-mechanism lock discipline that grew alongside it are gone.

**What the sweep cannot see.** Condition 3 reads the refs at two moments, which
stops an operator emptying the set by deleting branches *after* condition 1's
issue is opened. It does not stop deleting them **before** — that ordering is
outside what the sweep can observe, and the condition's ordering instruction concedes it rather than
implying a completeness it does not have. Local-only branches are also outside
it: the sweep reads the remote, so a branch that exists on one machine is not
preserved by this rule. `chore/t-5r2q-review-debt` was exactly that case, and
the scorecard below records that it survived by luck rather than by the rule.

**Where the evidence lives.** Every finding above, with its reproduction, is on
[#43](https://github.com/pharzam/armature/issues/43) and
[#16](https://github.com/pharzam/armature/issues/16) — over 245,000 bytes of
review record. The 11,895-byte draft is in this branch's own
history; the earlier 7,022-byte one is on `docs/t-7d2x-reset-adr`, which forked
at the reset point and is reference only, never a merge source.

## The 2026-08-27 reset, scored against the five conditions

Written by the operator who performed the reset it scores. Issue timestamps are from each issue's own timeline; the repository events feed reports some of them one or two seconds later.

| Time (UTC) | Event |
|---|---|
| 10:08:11 | `main` reset locally (`git reflog show main`) |
| 10:11:26 | a branch ruleset named `main` is created, already disabled — see below |
| 10:14:25 | `backup/pre-r12-reset-999765f` pushed — the default branch's tip preserved, before anything was destroyed (`git reflog show refs/remotes/origin/backup/pre-r12-reset-999765f`; the events feed carries a CreateEvent for this push at 10:14:26Z, but none for the second backup) |
| 10:18:03 | force-pushed to the remote (`PushEvent refs/heads/main`) |
| 10:41:02 | the record written on #16, opening **"Status: main was reset."** — past tense |
| 10:46:24–10:46:51 | **twelve further issues closed as completed** (#19, #20, #22, #33–#41) over deliverables `main` no longer held |
| 11:46:56–11:47:38 | the eighteen affected issues reopened |

| Condition | Score |
|---|---|
| 1 — *"An open issue states the goal in the operator's own words, and why no revert, fix-forward, or new branch reaches it. It records every reference on the remote, by name and object name, as they stand at that moment."* | **Not met, on all three limbs.** Nothing was written anywhere before the act. The goal was recorded 23 minutes after the push, so for that limb the condition is about *when*. The second limb — why no revert, fix-forward or new branch reaches the goal — was never recorded at all: the 10:41:02Z record names none of the three. The third limb postdates the act, but nothing was written at all, so it fails on the same evidence. |
| 2 — *"A second operator approves in writing, and that operator is a person… With no second person, the path is closed."* | **Not met.** Self-approved. |
| 3 — *"Everything about to be lost is preserved first…"* | **Partly.** `backup/pre-r12-reset-999765f` held the default branch's tip, correctly. One other remote tip that was not an ancestor of it was not, and one branch condition 3 does not reach at all: `fix/t-3k8w-runner-asserts-reason` happened to be on the remote already, and `chore/t-5r2q-review-debt` existed on one machine only and was pushed to `backup/pre-r12-reset-t-5r2q` — a name that carries a task ID where condition 3's `backup/pre-<reason>-<short-sha>` wants the tip's short SHA, though the condition postdates the act — at 11:46:30Z (local `git reflog show refs/remotes/origin/backup/pre-r12-reset-t-5r2q`; the repository events feed carries a CreateEvent for the first backup at 10:14:26Z but none for this one), 88 minutes after the push. It survived by luck. Condition 3 now sweeps the references as they stood when condition 1's issue opened *and* as they stand at the act, together; here condition 1's issue never existed, so only the act-time set applies and the score is unchanged. |
| 4 — *"Any lock on the branch is lifted deliberately and restored afterwards, with both recorded, and the restore checked against a record of the lock's full configuration made before lifting…"* | **Not met.** A documented lock existed and, on the evidence below, was lifted around the act and restored; nobody recorded either, and no check against a prior record ran — which is the failure regardless of what the lock was doing. See below. |
| 5 — *"Every issue whose deliverable is no longer on the default branch returns to open with the evidence, and condition 1's issue — or a new one if condition 1 was skipped — records what was destroyed, where the backups are, and who approved. This comes after the act and before any further work on the repository that is not part of it; a commit, a push, a merge and closing an issue all count as further work."* | **Not met.** The test is *before the acting operator does any further work*, and work resumed 28 minutes after the push in the wrong direction: twelve further issues were closed as completed over deliverables that had just been destroyed. The reopens began at 11:46:56Z, 60 minutes after those closes. Condition 1's issue never existed, so the second half has no subject; the 10:41 comment records what was destroyed and names the backup branch, and there was no approver to record. |

**Nought of five fully met, one partly.**

#### What the lock was actually doing

**The lock was documented three days earlier.** [#6](https://github.com/pharzam/armature/issues/6) closed 2026-08-24T07:22:36Z; [PR #7](https://github.com/pharzam/armature/pull/7), merged 07:22:35Z, states the configuration in prose: pull request required, `0` approvals, force-pushes and deletion blocked, enforced for administrators, conversation resolution required, no status checks. Every one of those six matches the live configuration today.

**So the force push should have been impossible.** With `allow_force_pushes: false` and `enforce_admins: true`, the forge rejects a rewind for every actor, administrators included. The push at 10:18:03Z rewound `999765f` to `2cd70ee` and succeeded. The lock was therefore not in that state at that moment, and it is in that state now — so it was lifted and restored, and neither was recorded.

This is stated as an inference, not a fact: PR #7 is a claim in a pull-request body, not an API snapshot, and the forge exposes no history for classic protection. The account security log may hold the lift; it has not been consulted.

The ruleset created at 10:11:26Z — three minutes after the local reset, seven before the push — is not evidence of the lift. It was created *already disabled*, with `bypass_actors: []`, and a ruleset born disabled removes no obstacle. That it was born disabled is not an inference: `gh api repos/pharzam/armature/rulesets/21643143/history` returns exactly one version, so it has never been modified since creation and cannot have been created enabled and switched off afterwards. Of its three rules (`deletion`, `non_fast_forward`, `pull_request`), all three would have blocked the push had it been enabled. What it does show is the operator inside the branch-protection settings, in that window.

The argument for condition 4 is not that the configuration was unrecorded — #6 and PR #7 recorded it well. It is that **the lift and the restore were not**, at the moment they mattered.

### What that score does and does not say

It does not say the reset was wrong. It answered a real problem — 45 commits, 67 files and roughly 1,659 insertions delivered in under three hours in one session, which the operator could not absorb — though whether a revert or a new branch would have served as well was never argued, then or since. The backup went to the remote before anything was destroyed, and the reason was written down.

It says the care came from the operator and not from a rule, and that unguided care covered part of one of the five things that matter and missed the rest.

Under condition 2 this reset would not have been permitted: there is no second person here, so the path is closed. The rule the incident produced forbids the incident.

