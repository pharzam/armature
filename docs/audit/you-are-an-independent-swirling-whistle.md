# Armature — Independent Assessment Against Its Own Goal

**Assessor's note.** This is an evaluation deliverable, not an implementation plan.
Per the brief I answer four questions with evidence and give a verdict; I do not
propose to change the repository. "Recommendations" name what a *future* editor
would cut or keep — they are findings, not a work order.

**Yardstick (the repo's own claim):** *a lean, domain-free scaffold an adopter
composes onto a new project; a template, not a product; holds no product code and
no product test suite.* Every judgement below is measured against that and only
that.

---

## 1. Inventory summary

| Category | Count | Evidence |
|---|---|---|
| Adopter-facing core docs | ~11 | `engineering-discipline.md` (854 ln), `issue-workflow.md` (217), `guardrails.md` (183), `glossary.md` (106 ln / 24 KB), `onboarding-for-engineers.md` (91), `facts/README.md`+template, `prd/README.md`+template, the `tests/` conventions (README 129 + `test-levels.md` 132 + `dod-checklist.md` 96 + `scaling-checklist.md` 98), ADR/PRD templates |
| Self-facing (governance-of-governance) docs | ~7 | `docs/agents/README.md` (159), `docs/agents/tests/README.md` (179), `docs/links/README.md` (335), `docs/ci/README.md` (226), plus per-task detail files `tasks/T-3v9q.md` (716), `T-k4vm.md`, `T-x1zp.md`, `T-2p6k.md`, `T-6r2d.md` |
| Lint scripts (non-fixture) | 9 | `adr-lint` 534, `prd-lint` 142, **`agents-lint` 1017**, `link-lint` 640, **`audit-record-lint` 959**, `pr-link-lint` 81, `review-record-lint` 297, `run-discipline-tests`, `nested-checkout-check` — **≈3,670 LOC of shell** |
| Fixture trees | **100** (82 `bad-*`, 18 `good*`) | adr 9, prd 11, **agents 39**, links 30, **tasks 12**; + 9 `commit-msg` `.txt` fixtures |
| Git hooks | 3 | `commit-msg`, `pre-commit`, `pre-push` |
| CI templates | 5 workflows | GitHub `ci`/`pr-link`/`pr-title`/`review-record` + `gitlab-ci`; CI-only scripts `pr-link-lint`, `review-record-lint` |
| ADRs | 8 | `0001`–`0008`; **0004–0008 are predominantly about the repo's own mechanisms** |
| Meta-recursion chain depth | ≥4 | `AGENTS.md` summarises the docs → `agents-lint` (1017 ln) checks the summary → **39 fixture trees** check `agents-lint` → `run-discipline-tests` runs the fixtures |

**Two concentration facts that drive the findings:**
- `agents-lint` (1017) + `audit-record-lint` (959) = **54% of all shell LOC**.
- agents (39) + tasks (12) = **51 of the 100 fixture trees** exist to test those
  two self-facing linters.

---

## 2. Findings

Severity: **blocker** (contradicts the goal) · **material** (taxes the goal) ·
**note** (worth recording).

### F1 — The `audit-record-lint` stack is a product test suite for the repo's own history — *blocker* (Q1, Q2: mechanism-without-mission)
`docs/tasks/audit-record-lint.sh` (959 LOC) + `docs/tasks/T-3v9q.md` (716 lines) +
12 fixture trees exist solely to lint *this repository's* record of two external
audits. The repo says so itself: it "is specific to this repository's own audit
record, so an adopter **deletes it** rather than inheriting it"
(`docs/agents/README.md:143`). A "template that holds no product code and no
product test suite" ships ~1,700 lines whose only subject is the repo's own past,
which the adopter must identify and remove. This is the clearest case where
"kit-as-product" cannot excuse the mass — it tests a historical artifact, not a
reusable convention. *Credit the candour; the cost stands.*

### F2 — The `agents-lint` chain is meta-recursion, 4 levels deep and repo-coupled — *material→blocker* (Q2: meta-recursion)
The "why does this exist" chain never reaches an adopter's domain need:
`AGENTS.md` exists to tell agents the rules → `agents-lint.sh` (1017 LOC) exists to
keep `AGENTS.md` honest → **39 fixture trees** (`docs/agents/tests/`, each a mini
mock-repo with its own `AGENTS.md`, `CLAUDE.md`, `docs/`, `EXPECT`) exist to keep
`agents-lint` honest → `run-discipline-tests` runs them. It terminates at *"the
repo's summary of its own rules is accurate,"* not at anything an adopter's project
does. It is also the least liftable artifact in the kit: it derives its
expectations from *this* repo's exact structure — "**eight** ordered steps,
**twelve** numbered rules" (`docs/agents/README.md:69`) — so an adopter with
different governance must rewrite it, not adopt it. D-0001 and D-0002 are
decisions *about this linter*, i.e. decisions about the decision-checking process.

### F3 — The same rules are represented three times; the repo has twice caught itself duplicating enforcement — *material* (Q2: duplicated enforcement)
The R1–R12 rules live in `issue-workflow.md` (source), are re-stated in prose in
`AGENTS.md`, and have their presence asserted by `agents-lint`. The repo itself
documents the recurring pattern: `A19` "resolved this file's links while
`link-lint` resolved every file's… **A19 has since been removed**"
(`docs/agents/README.md:61`, D-0002), and D-0001 records measuring another
duplication. A pattern the kit keeps re-discovering in itself is evidence the
mechanism outran the need.

### F4 — Adopter-facing cognitive tax with no domain payoff — *material* (Q2: complexity that taxes the adopter)
`agents-lint` "**hard-fails** when `AGENTS.md` is absent… it makes this the first
check an adopter *inherits* that a smaller repository does not silently satisfy"
(`docs/agents/README.md:137`). The adopter must also absorb "**Five constraints**…
each enforced by an assertion" on how they may edit `AGENTS.md` (`:98`) and the
"**Two different fives**" section explaining why two counts of five must *not* be
reconciled (`:119`). None of this teaches the adopter anything about *their*
project; it is overhead the mechanism imposes on itself.

### F5 — "Lean" is contradicted by mass — *material* (Q1)
The README's own word is "lean" and it advertises `AGENTS.md` at "**under 1,500
words**" (`README.md:47`) — yet the apparatus behind that one lean file is not:
`engineering-discipline.md` is 854 lines / 49 KB, `glossary.md` is 24 KB, and the
kit ships **3,670 LOC of shell + 100 fixture trees + 8 ADRs**. The leanness is
real only at the surface an agent reads first.

### F6 — `link-lint` is over-specified for a template's internal link checker — *note→material* (Q2: mechanism beyond mission)
`link-lint` (640 LOC) + ~15 of its 30 fixtures handle CommonMark corner cases an
in-tree link checker for a *template* does not need: angle-bracketed spaced
destinations `<Design Notes/target.md>`, `%20` decoded once, escaped-angle targets,
"junk after the angle" (`completed.md` entries T-gm8h, T-6d2n, T-5w8h). Multiple
whole tasks were spent making the linter parse destination *spelling* variants.

### F7 — Recent forward motion is almost entirely self-facing — *blocker* (Q3, Q4)
The last ~25 commits (all dated 2026-09-03) are linter-precision fixes and rulebook
decisions, e.g. `T-8j4p` spent a full four-round task to "**decide the budget
ceiling — there is none**," `T-2r6v` to "**bound the close-out commit to
bookkeeping only**," `T-5w8h` on angle-bracket *spelling* in the link linter.
`backlog.md` **Now = 1 item** (T-q22n, mechanise the review record — self-facing).
**Next = 8 items, 7 self-facing** (triage the repo's own `NOT_PLANNED` issues,
reconcile branch-only ADR-0004 records, kill surviving linter mutants, fix
`adr-lint`, a "self-violation sweep," define "fresh context"). The **one**
adopter-facing item, `T-7m6s` "Adopter day one" (ignore worktree dir, mark LICENSE,
pin action refs), is **deferred to Next**. The motion confirms the loop.

### F8 — Dogfooding did prove the kit, early — *note (positive)* (Q3, argues for calibration)
Self-application caught **real** defects, not just text drift: `T-2j7f` "found and
fixed a real dead link… that had pointed one directory too shallow"; `T-4n8p`/`T-7d2m`
closed a genuine false-green where an absolute `core.hooksPath` bound every worktree
to one checkout's hooks; `T-8q3f` found a "silent false green" in `adr-lint`. These
are the credibility the kit earns by eating its own food. *Do not punish this.*

### F9 — Enforcement honesty is a virtue that also exposes a symptom — *note* (Q3 method)
`issue-workflow.md`'s enforcement table is refreshingly candid: **9 of the 12 rules
are marked `(written rule)`** with no mechanism (R2, R3, R4, R6, R7, R8, R9, R10,
R11). The candour is the repo's best feature. But the distribution is telling: the
heavy machinery (and the *meta*-machinery) clusters on the 3 machine-checkable rules
and on self-consistency, while the substantive human rules — duplicate check,
solution selection, no workarounds, decision transparency — stay unenforced prose.
Effort went where it was easy and self-referential, not where the discipline lives.

---

## 3. Verdicts

**Q1 — Goal validity.** The domain-free half of the goal is genuinely met: the core
docs (`engineering-discipline`, `issue-workflow`, `guardrails`, `glossary`,
`facts`/`prd` conventions, `tests` conventions, ADR/PRD templates, hooks, CI
templates) are real, generic, `‹…›`-marked scaffolding an adopter can lift — that is
the bulk of the *value* and it is sound. The "lean" half has drifted (F5), and a
separable governance-of-governance layer (F1, F2) sits on top of the scaffold rather
than serving an adopter. Because the valuable scaffold is intact and the drift is
additive and removable, this is **drifted, recoverable**.

**Q2 — Over-engineering.** All four named forms are present, each as a pattern, not
a single instance: **meta-recursion** (F2 — the `agents-lint` chain, ≥4 levels, plus
D-0001/D-0002 as decisions about the linter of the linter), **mechanism without
mission** (F1 — `audit-record-lint`, which the repo tells the adopter to delete),
**duplicated enforcement** (F3 — rules stated thrice; A19 and the D-0001
measurement are the repo's own catches), and **complexity that taxes the adopter**
(F4 — hard-fail inheritance, "Five constraints," "Two different fives"). These two
self-facing linters are 54% of the shell and their fixtures are 51% of the corpus;
five of eight ADRs are inward. The over-engineering is a load-bearing fraction of the
repository as it stands: **drifted, structural** (recoverable only by deletion, named
in §4).

**Q3 — The self-governance loop.** Both readings have real evidence. Calibration is
genuine and must be credited: the gate caught actual bugs, not just typos (F8), and
ADR-0003/0005 generalise into discipline an adopter could want. But capture dominates
the *recent* record: by 2026-09-03 the work is the rulebook refining itself in
ever-finer increments — the spelling of an angle bracket in a link linter, whether a
close-out commit may carry a corrected link count, a four-round task to conclude a
budget ceiling does not exist (F7). Self-application that *proved the kit* (Aug 31)
has given way to self-application that *feeds itself* (Sep 3). **Mixed, leaning
capture.**

**Q4 — Forward motion.** Decisive and inward. The single `Now` task and 7 of 8 `Next`
tasks are self-facing; the lone adopter-facing task is deferred; the completed log's
recent half is entirely linter fixes and governance decisions; the open ADRs trend
toward the repo's own process (F7). The remaining work makes the rulebook more
elaborate, not the kit more adoptable — which confirms the loop in Q3. **Drifted,
structural.**

---

## 4. Recommendations

**KEEP — self-facing artifacts that earn their cost**
- `adr-lint`, `prd-lint` + their fixtures, and the `commit-msg` hook + fixtures —
  genuinely reusable discipline an adopter keeps.
- The `issue-workflow.md` enforcement-honesty table — the kit's strongest feature;
  it tells the truth about what is and isn't enforced.
- ADR-0003 (issue-first) and D-0000 (independent review may be an agent) —
  generalizable decisions, not repo-navel-gazing.
- The dogfooding *practice* and its early bug-find record (F8) — the credibility.

**CUT — meta-recursion / mission-less mechanism (exact paths)**
- `docs/tasks/audit-record-lint.sh`, `docs/tasks/T-3v9q.md`, `docs/tasks/tests/`
  (12 trees) — repo-specific; the adopter deletes them anyway, so don't ship them.
- The `agents-lint` meta-chain: `docs/agents/agents-lint.sh`, `docs/agents/tests/`
  (39 trees), `docs/agents/tests/README.md` — or replace with the shrunk version
  below. With it go D-0001 and D-0002, which only justify it.

**SIMPLIFY — merge or shrink**
- `link-lint.sh`: drop the CommonMark spaced-destination / angle / `%20` handling
  and its ~15 edge fixtures; resolve plain in-tree links only (~640 → ~150 LOC).
- If an `AGENTS.md` sync check is wanted at all, make it a ~50-line optional
  *presence* check, and stop `AGENTS.md` re-stating the rules (index only) — that
  kills the triple representation (F3) and the "Two different fives" tax (F4).
- Trim `engineering-discipline.md` (854 ln — the adopter's first read) and
  `glossary.md` (24 KB).

**Cost-per-adoption estimate.** A competent engineer must currently read ~2,300 lines
of core prose plus ~720 lines of mechanism READMEs, and reason about 9 linters and
100 fixtures. A minimal version of the *same* kit — core docs trimmed, the two
self-facing linters and `link-lint`'s edge cases cut — lands near **40% of the
reading and ~30% of the shell** with no loss of adopter value. Present adoption cost
is roughly **2–3× a minimal kit's**.

---

## 5. Honest uncertainty

- **Issue threads unseen.** I read the tree, not the GitHub issue/PR discussions.
  Whether the D-0003 review rounds catch adopter-relevant defects or mostly police
  the repo's own text — the completed log suggests the latter *recently* — would be
  settled by reading the round records on the issues.
- **No evidence of real adopters.** The README's `degit`/"Use this template"
  instructions show intent, but the git history is entirely self-work. A downstream
  repo that lifted the kit, or adopter-filed issues, would settle whether the
  self-facing polish is serving a real audience or only itself.
- **Was "lean" ever a firm goal?** The README says "lean" but also "grow it over
  time"; the tension in F5 may be intended rather than drift.
- **Partial full-text read.** My "not lean" and inventory judgements rest on line/byte
  counts and sampled reads of `engineering-discipline.md` and D-0003, not a
  line-by-line pass of every doc; the size conclusions are robust, a semantic audit of
  every page is not claimed.

---

## ADDENDUM — deeper pass with GitHub issues, PRs, worktrees, full history (read-only)

The first pass judged the tree alone and flagged three uncertainties (issue threads
unseen, no adopter evidence, review-round quality). The forge record settles all
three and moves one verdict. **Nothing here softens the first pass; it hardens it.**

### New inventory facts
- **277 commits in 16 days** (2026-08-19 → 09-03 local), velocity accelerating:
  37 / 58 / 60 / 39 on 08-31 / 09-01 / 09-02 / 09-03. The bulk of the repo was
  written in its last four logged days — the days §2/F7 shows are self-facing.
- **89 issues: 17 open, 72 closed — 36 COMPLETED / 36 NOT_PLANNED (a 50% abandon
  rate).** **PRs: 44 merged, 50 closed-unmerged** (more discarded than landed), 2 open.
- **~15 live task worktrees** under `.claude/worktrees/`, plus
  `backup/pre-r12-reset-*` (×2) and `docs/t-7d2x-reset-adr`(+`-v2`) branches — a
  history-reset around adopting R12. Churn, not just motion.
- **"The unattended milestone": 16 open issues, 0 closed** — every open issue but
  one (#141, a rule-about-a-rule) belongs to it.

### New findings
- **F10 — The open roadmap is a machine to run the loop unattended — *blocker* (Q3/Q4).**
  All 17 open issues are self-facing; 16 are one milestone whose goal is to make the
  kit operate its own process with no human. Its **acceptance test (#132)** is: "Land
  one real backlog task **with no human message on its issue thread**." #124 gives a
  stopped agent session a hand-off record; #125 chains plan/build/round-one; #136 adds
  a "stop control and whole-milestone budget." The chain of "why does this exist"
  terminates at *the loop running itself*.
- **F11 — The repo re-decides its own just-landed decisions — *material* (Q3).** #123
  supersedes D-0003 (landed 6 days earlier, 09-02). By its own words the prior
  stopping-protocol chain #81→#89→#95→#101 "spent **11 rounds and 114 findings on one
  file and found no behaviour defect**." The stopping protocol has now cycled ≥5 times.
- **F12 — The self-measured payoff is thin, and the repo says so — *material* (Q3).**
  #132 records the #78–#115 baseline: "**45.1 hours, 34 rounds and 24 of 272**"
  findings changing behaviour (~9%). #136: the 45-hour run "was **ended by the
  repository owner's instruction on the morning of day three, not by any rule**" — and
  the milestone now automates that manual stop.
- **F13 — The kit diagnosed its own over-fitting, then abandoned the one fix — *blocker* (Q1/Q3).**
  The audit issue #16 (ancestor of this very assessment) says in its own words:
  "It ships about **20,000 words of prose for people, and three small scripts for
  machines**," and "a documents-only repository … is the only place they have ever
  run. **Every rule is therefore fitted to a repo with no product code**." #22
  ("Dogfood the kit on one real product repository") calls itself "the audit's **most
  important finding**" and "the one slice that **cannot land inside this repository**."
  **Both #16 and #22 were closed `NOT_PLANNED` (2026-08-28).** The work that stays
  inside the repo got done; the one task that would test the kit on a real adopter did
  not. #20 ("core/standard/full adoption profiles") — also adopter-facing — also
  `NOT_PLANNED`.

### Verdict changes
- **Q3 moves `mixed, leaning capture` → `capture`.** The loop is not suspected, it is
  a named milestone with an acceptance test; the one adopter-proving task was declined;
  the rulebook re-litigates decisions it just made. Calibration was real *early* (F8
  stands), but the present state is a closed loop by design.
- **Q4 reinforced `drifted, structural`:** 17 of 17 open issues self-facing.
- **Q1 stays `drifted, recoverable` for the artifact**, but the *trajectory* is
  structural: the project has chosen the self-runner and shelved the adopter (#22, #20).
- **Q2 reinforced `drifted, structural`:** the unattended-run machinery is new
  mechanism whose mission is the repo itself.

### Uncertainties now settled
- *Issue threads / review quality* → settled: the repo's own numbers (11 rounds → 0
  behaviour defects; 24/272 behaviour-changing) show the rounds mostly police wording.
- *Real adopters* → settled: none; the dogfood-on-a-real-repo task was deliberately
  abandoned (#22 NOT_PLANNED).
- Still open: whether the owner intends the unattended-run milestone as a *product* in
  its own right (an autonomous-agent harness) rather than as the Armature template —
  if so, the goal itself may be shifting, which only the owner can confirm.
