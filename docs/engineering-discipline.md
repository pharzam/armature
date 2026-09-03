# Engineering Discipline

This document lists the engineering practices required on a project. It is a
domain-free starter kit. This folder is self-contained: the main document links
to sibling documents in the same folder, and each sibling is itself a template
you fill for your project. Adapt the kit, then grow it over time — each new
practice gets its own short section below, with a link to the fuller reference
where one exists.

The practices come as one **quality gate**: a fixed, ordered sequence that every
substantive task must pass. A gate works because it stores the team's hard-won
lessons. You follow the step; you do not re-learn the lesson the hard way.

This document is the project's *how*. For the *what and why* — the problem the
project solves — see the
[Problem statement](onboarding-for-engineers.md#1-problem-statement).

## How to adapt this kit

**Before you fill anything, start from a clean history.** Your project is a *new*
repository, not a fork of the kit — do not keep Armature's git history or remote.
Use GitHub's *Use this template*, or detach by hand: delete `.git`, run `git init`,
commit, and add your own remote. Then do the two things below.

Three kinds of thing need your input. Do all three, then delete this section.

**1. Fill the sibling documents.** Each is a generic template with its own
"How to adapt" notes:

- [`guardrails.md`](guardrails.md) — your known-pitfall, decision, and validation
  rules. Referenced by gate step 2.
- [`adr/`](adr/) — your Architecture Decision Records. Start at
  [`adr/README.md`](adr/README.md); copy [`adr/template.md`](adr/template.md) for
  each new record.
- [`facts/`](facts/) — the facts documents you collect from a customer, stored
  as-is. Skip this if your project has no external customer. Start at
  [`facts/README.md`](facts/README.md); copy [`facts/template.md`](facts/template.md)
  for each new record.
- [`prd/`](prd/) — your Product Requirements Documents, derived from the facts.
  Skip this if your project tracks no requirements. Start at
  [`prd/README.md`](prd/README.md); copy [`prd/template.md`](prd/template.md) for
  each new record.
- [`tests/`](tests/) — your testing conventions: the levels, a pattern per level,
  the security, scaling, and DoD checklists, and the traceability that ties a test
  to a requirement. Start at [`tests/README.md`](tests/README.md); the product
  tests themselves go in the repo-root [`tests/`](../tests/) drop-in.
- [`glossary.md`](glossary.md) — your shared-vocabulary document.
- [`onboarding-for-engineers.md`](onboarding-for-engineers.md) — the first
  document a new engineer reads.
- [`tasks/backlog.md`](tasks/backlog.md) and
  [`tasks/completed.md`](tasks/completed.md) — your task index.
- [`issue-workflow.md`](issue-workflow.md) — the issue-first rules (R1–R12), the
  ticket policy the gate assumes.
- [`templates/`](templates/) — inert forge issue/PR templates; copy into place
  only if you adopt that forge.

**2. Replace the `‹…›` markers.** These are the per-project values with no file
of their own:

- `‹test runner›` — how tests run in your stack (the command and any rule, for
  example "no external test framework"); the per-level commands
  (`‹unit test command›`, `‹integration test command›`, …) are defined in
  [`tests/test-levels.md`](tests/test-levels.md).
- `‹evidence store›` — where you commit run outputs, logs, or results (for
  example `runs/` or `artifacts/`).
- `‹task-ID scheme›` — how you tag a task (for example `T-` plus four random
  characters).
- `‹worktree dir›` — your per-task isolation directory (for example `.worktree/`).

**3. Turn on enforcement.** The gate below is only as real as what enforces it.
Wire in the two enforcement layers so a violation is caught automatically, not by
memory:

- **Install the git hooks** — run `git config core.hooksPath .githooks` once per
  clone, and **keep that path relative**: `.git/config` is shared by every
  worktree, so an absolute value binds them all to one checkout's hooks. This turns
  on [`.githooks/`](../.githooks/): the `commit-msg` hook checks
  [commit format](#commit-messages), and the `pre-commit` hook runs the five
  repo-file [discipline linters](#testing) and their self-tests, plus the fast
  gate you fill in. See [Git hooks](#git-hooks).
- **Fill the hook and CI `‹…›` steps** for your stack — `‹lint›`, the test-level
  commands from [`tests/test-levels.md`](tests/test-levels.md)
  (`‹unit test command›`, `‹integration test command›`, `‹end-to-end test command›`),
  and the `‹security scanner›` scan — then, if you use GitHub or GitLab, **activate
  CI** by copying
  the matching template from [`docs/ci/`](ci/) into place — see
  [Continuous integration](#continuous-integration-optional). CI is optional but
  recommended; it is the authority the hooks give you fast feedback against.
- **Confirm the discipline linters run** — `sh docs/adr/adr-lint.sh` should print
  `adr-lint: OK`, `sh docs/prd/prd-lint.sh` should print `prd-lint: OK`, and
  `sh docs/agents/agents-lint.sh` should print `agents-lint: OK`. All three ship
  wired into the hook and the CI templates. The third needs a root
  [`AGENTS.md`](../AGENTS.md): keep the [agent entry points](agents/README.md),
  or drop that check along with them.

## Working a task under the quality gate

Every substantive task runs through the same gate. The steps below are the
required order. Each step links to the section that gives its mechanics, and
states any rule that has no section of its own. **Before step 1, an issue is open
for the task** — see [Issue-first workflow](#issue-first-workflow) — and the work is
sliced into an ordered, DoD-covering, test-first plan, reviewed once and recorded
on the issue
([R12](issue-workflow.md#r12--slice-and-prioritize)). Apply the
[solution-selection standard](#solution-selection) when you select the approach,
the plan, the tests, or another technical part of the task.

1. **Isolate.** Do the work in a per-task git worktree under `‹worktree dir›/<task>`,
   branched off `origin/main` — see [Starting a task](#starting-a-task). Never
   work on the operator's main worktree.

2. **Honor the guardrails.** Before you write code, read the ticket's acceptance
   criteria and the docs it references — [`guardrails.md`](guardrails.md) and the
   relevant [ADRs](#architecture-decision-records). They encode the project's known
   pitfalls. Take each one into account rather than re-derive it.

3. **Test first.** A change with no test that covers it is not done — see
   [Testing](#testing).

4. **Make long tasks visible.** If an operation or loop can run longer than 10
   seconds, give an explicit, lightweight progress indicator in the CLI, TUI, or
   GUI — see
   [Progress indicators for long-running operations](#progress-indicators-for-long-running-operations).
   Never leave the operator in the dark.

5. **Review until findings decay.** After the code works, freeze the head and
   run rounds of independent blind reviews on it — see
   [Reviewing until findings decay](#reviewing-until-findings-decay). A fix
   re-freezes; at most two fix-and-review cycles follow the first freeze, and
   the last round ends `nothing material in scope` or
   `not mergeable, findings recorded`. A defect the change *revealed*, off the
   path its Definition of Done names, opens an issue instead of entering the
   branch. A reviewer is a person **or** a fresh agent session; what the round
   must have is [independence](#who-may-review), not a particular kind of
   reviewer. Text that summarises another document gets a
   [clause-by-clause semantic pass](#reviewing-for-semantic-agreement).

6. **Be honest, keep evidence.** State outcomes plainly and commit run evidence
   under `‹evidence store›` — see [Honesty and evidence](#honesty-and-evidence).
   When that evidence comes from a costly action, review the producing code
   *first* — see
   [Review before a costly or irreversible action](#review-before-a-costly-or-irreversible-action).

7. **Keep the documentation current.** Update every doc and code comment that the
   change touches or leaves stale, in the same PR — see
   [Keeping documentation current](#keeping-documentation-current).

8. **Close out in the same PR.** Tick the acceptance boxes, write the verdict,
   and record the ticket in the completed log — see
   [Completing a task](#completing-a-task). Then take the next logical task.

## Solution selection

Use one standard for every technical selection. Apply it when you select how to
resolve a problem, plan the work, test the result, or choose a package, library,
module, framework, service, platform, or vendor. The criteria are considerations,
not a scoring formula.

First, search the problem domain for an existing public solution. Do not build a
custom solution when a suitable public solution exists. Then compare the suitable
candidates manually against all applicable considerations:

- **License and commercial terms:** for open-source software, prefer Apache 2.0,
  MIT, BSD, or a similar permissive license. Use GPL, AGPL, or another copyleft
  license only when the project accepts its obligations. For proprietary software,
  assess price, contract terms, vendor lock-in, data ownership, and an exit path.
- **Project health:** look for stable production use, recent releases and commits,
  responsive maintainers, resolved issues and pull requests, and adoption evidence
  that is relevant to the ecosystem. No specific forge metric is mandatory.
- **Documentation:** require enough public source or product information, setup
  guidance, API reference material, and examples to assess and use the candidate.
- **Security:** check for known, unaddressed vulnerabilities or security advisories.
- **Dependencies:** prefer few direct and transitive dependencies.
- **Determinism:** prefer plain code, rules, and algorithms to an LLM call. For work
  that does not require a model, external service, network, or changing data, prefer
  the candidate that gives the same output for the same input without them.
- **Infrastructure:** prefer little or no additional infrastructure. Add a database,
  broker, cluster, or external service only when the problem requires it.
- **Stack fit:** prefer an idiomatic fit for the stack, a stable API, and no sign
  of deprecation.

No candidate needs to lead on every consideration. Select the candidate that best
fits the task and its constraints. Record the selected option, the rejected
alternatives, and the important tradeoffs. If the selection is architecturally
significant, record it in an [ADR](adr/). Otherwise, record it on the issue.

## Issue-first workflow

Before a task reaches step 1 of the gate, an **issue is open for it** — one
actionable, demoable goal per issue. The change then lands through a pull request
whose body links that issue (`Closes`/`Refs #N`), while the task ID stays in the
commit subject, so the two namespaces coexist. The full rules — R1–R12, and the
honest table of what is enforced where — live in
[`issue-workflow.md`](issue-workflow.md); the decision is
[ADR-0003](adr/0003-adopt-issue-first-workflow.md). The kit is forge-free, so an
"issue" is a ticket in whatever forge you use, and forge-specific issue/PR
templates ship inert under [`templates/`](templates/).

## Reviewing until findings decay

After the code works, **freeze the head**: name the commit, and land nothing on
the branch after it except a fix to a finding. Then run rounds of independent
blind reviews on that commit. Each reviewer is fresh — it does not see your
reasoning — and each round applies a different lens:

- correctness and failure modes — `‹name the failure modes that hurt you most,
  for example data leakage, race conditions, off-by-one, unhandled errors›`,
- guardrails and acceptance criteria,
- clean and simple,
- adversarial bug-hunt,
- semantic agreement — does each changed sentence still mean what its source
  means? See [Reviewing for semantic agreement](#reviewing-for-semantic-agreement).

One pass is never enough. Each round catches a different class of error. The
protocol that bounds the rounds is
[ADR-0008](adr/0008-stop-the-gate-on-a-frozen-head.md#1-the-frozen-head):

- **A fix re-freezes.** Any fix after a round lands as a new frozen head, and
  the next round names it. The close-out bookkeeping lands as a head no round
  names — the task line arriving in the completed log, which gate step 8
  requires of the landing pull request and which cannot exist before the rounds
  finish. The exception covers that bookkeeping alone; where the same commit
  also corrects a claim, that correction is a fix and is named as one. The
  close-out records which of the two it carried, and that no round read it.
- **The last round carries the verdict.** The round that ends the work runs on a
  frozen head that no fix followed. Its verdict is `nothing material in scope`
  when nothing material in scope remains, and `not mergeable, findings recorded`
  on any of three routes: the cap below is reached with something material still
  open; a finding's materiality or classification stands disputed; or the budget
  overran without the operator's approval. Only the first needs the cap.
- **A merge of `main` is the one other thing that may land.** A rebase would
  rewrite the frozen head the verdict names, so a branch under a frozen-head
  verdict integrates by merging `origin/main` into itself — see
  [Integrating branches](#integrating-branches). That merge re-freezes the head,
  consumes no cycle, and needs no new round while it is clean and changes no file
  the branch touched; where it does touch one, a round runs on the new head,
  scoped to those files, and it consumes no cycle either.
- **The cycles are capped.** After the first freeze, at most two fix-and-review
  cycles follow; the plan-review confirmation declares the cap, and two is both
  the maximum and the default where it is silent. On the cap, with something
  material still in scope, the verdict is `not mergeable, findings recorded`.
  That is a legitimate outcome, and its successor state is an issue split: one
  successor issue carrying the branch's work as it stands, on a branch of its own
  with a first freeze of its own, plus a child issue for each open finding the
  successor does not take. Where it takes them all, it alone is the split. The
  stopped branch does not run a further cycle.
- **Material has a test.** A finding is material when it changes an exit code,
  an assertion, a behaviour on an adopter's tree, a claim in the tree, or a
  Definition-of-Done item. Wording, style and layout are not. A claim in the
  tree counts only when a reader could act on it and the change makes it false
  or leaves it false; a sentence that changed and still holds is wording. Each
  finding records its basis in one line.
- **A finding is classified before it is fixed.** *In the change* — introduced
  by this branch, or pre-existing on the path the Definition of Done names — is
  fixed here inside the budget, else it becomes a child issue. *Revealed* —
  pre-existing and off that path — opens a new issue, a blocker if it is a
  silent false green and normal if it fails loudly; it blocks this merge only
  if this branch made it reachable. The last round lists the accepted
  out-of-scope findings with their issue numbers, which do not count against
  `nothing material in scope`. The author opens each issue, with its
  measurement, before the merge. No finding leaves the scope on the author's
  word alone: the reviewer that raised it agrees, or, for one the author raised,
  an independent reviewer does; otherwise the classification is recorded
  disputed and the branch does not merge.
- **The budget is R12's bound.** The plan states it and the plan review sets
  the maximum — [R12](issue-workflow.md#r12--slice-and-prioritize) says so, and
  [the ADR](adr/0008-stop-the-gate-on-a-frozen-head.md#5-the-budget-record)
  fixes the unit and its base. An overrun is a finding reported on the issue,
  never a revision; the growth becomes a child issue unless the operator approves
  it once, on the issue. An overrun the operator has not approved blocks the
  merge: the last round carries it as a finding and returns
  `not mergeable, findings recorded`. That route does not run through the cap —
  an unapproved overrun blocks a merge whether or not anything else is open. **Once** counts per issue, so a successor
  issue starts with an approval of its own; nothing forbids that, and what the
  rule relies on is that the successor's plan review sets its maximum with the
  carried size already measured — a discipline, not a mechanism. Whether an approval may name a
  **ceiling**, and how far one reaches past the figure it was given, is not
  decided: three review rounds produced three rules for it and each was falsified
  by the next, so it is
  [#99](https://github.com/pharzam/armature/issues/99)'s. Until that lands, an
  approval is one number on one issue.

### Who may review

A reviewer is a **human or a fresh agent session**. The requirement is
independence, not the reviewer's species —
[ADR-0005](adr/0005-independent-review-may-be-an-agent.md). Human review is an
escalation, not a universal requirement.

Independence has four levels. A review claims only the ones it actually had:

| Level | What it means | Required for |
| ----- | ------------- | ------------ |
| **Context** | A fresh session whose brief is the issue's problem statement, the acceptance criteria, the source documents and the diff — and **not** the author's reasoning or any earlier round's verdict. | Every review |
| **Method** | A different lens and a different prompt from the round before it. | Every round after the first |
| **Execution** | A separate run with its own record on the issue. | Every review |
| **Model** | A different model, or a different provider. | High-risk work — a governance change, a change to the checks themselves, or anything feeding a [costly or irreversible action](#review-before-a-costly-or-irreversible-action) — **where the adopter has a second model to reach for** |

Two agents given the same prompt, the same context and the same model are not two
reviewers. They are one reviewer run twice, and they share every blind spot. The
levels turn "a fresh context reviewed it" into a specific claim instead of a
comfortable one.

Be exact about what that buys. **No mechanism verifies any of it.** Nothing reads
a review record, and nothing can prove a reviewer truly did not see the author's
reasoning. What the levels buy is a claim precise enough to be *checked by a
reader who bothers*, and precise enough to be **wrong** — which an unfalsifiable
"it was reviewed" never was. That is a real gain and a small one, and overstating
it here would be the same defect this section exists to catch.

**The issue holds both halves, so a brief must say which half.** R7 puts the
author's action, reasons and tradeoffs on the issue, and R12 puts the plan there;
context independence says the reviewer must not read them. They live in the same
thread. So the reviewer's brief **names what it may read** — the issue's problem
statement and acceptance criteria, the source documents, and the diff at a fixed
commit — and the author's decision comments are outside it. On a forge where one
thread carries everything this is a discipline, not a mechanism: a reviewer can
always scroll, and an honest record says what it was handed rather than what it
was meant to avoid.

**Where the adopter runs out of levels, the ladder stops and the record says so.**
A one-person team with one model cannot reach model independence, and cannot put a
second human operator on top of a tie. That is a limit of the adopter, not a
failure of the review: claim the levels you had, name the ones you could not
reach, and let a later reader weigh the distance. A limit recorded can be judged;
a limit implied cannot.

A [deterministic check](issue-workflow.md#r5--deterministic-over-llm-based) still
outranks any reviewer, human or agent. Review is what is left after every claim a
script can settle has been settled by a script — never a reason to leave a
mechanizable claim to judgement.

### What a round records

A verdict that does not say what it read is not evidence. Each round is one
comment on the issue, headed `## Review record — round N`, with these fields
under these names
([ADR-0008](adr/0008-stop-the-gate-on-a-frozen-head.md#6-the-review-record)):

- `Commit reviewed` — the frozen head, by SHA; a moving target cannot be
  reviewed,
- `Reviewer` — the model and version, or the person,
- `Lens`, `Briefed on`, `Barred from` — the question asked, what the reviewer
  was handed, and what the brief excluded,
- `Independence claimed` — the [levels](#who-may-review) held, and those not
  reached,
- `Cycle` — `0` on this branch's first frozen head for this issue, `k` for the
  k-th fix-and-review cycle after it; the cap is counted from this field,
- `Raw findings` — before triage, each with its one-line basis and its
  classification,
- `Fixes` — what landed, and the new frozen head if one. This one field is the
  **author's**, written as a reply under the round it answers, because the fixes
  do not exist when the round ends; a record without it is complete until they
  land,
- `Verdict` — from a closed set: an intermediate round, one a fix follows, is
  `material`; the last round, the one no fix follows, is
  `nothing material in scope` or `not mergeable, findings recorded`. The values
  do not overlap, so the verdict itself says which of the two positions a record
  holds.

The plan-review confirmation carries `Verdict` — `approve`,
`approve-with-conditions` or `reject` — with `Budget maximum` and `Cycle cap`.
The names are fixed here; the exact syntax a check would match — how a heading is
matched, how the fields are rendered, what value `Cycle` takes — is fixed by that
check, in [#82](https://github.com/pharzam/armature/issues/82). Until one lands,
a record is read by a person. Three things no record proves: that a reviewer did not read a barred comment,
that the model named is the model used, and that every round which ran was
recorded — a round that ran and was not posted leaves no trace, so the stopping
condition is only as sound as the author's posting. The record makes each claim
falsifiable; it does not verify it.

### When reviewers disagree

Escalate by the task's risk: a second reviewer at a higher independence level,
and a human operator at the top. Two reviewers who disagree do not average their
verdicts, and the author does not break the tie. A dispute over whether a
finding is material, or over its classification as in the change or revealed,
routes here the same way. No finding leaves the scope on the author's word
alone: the reviewer that raised it agrees, or, where the author raised it, an
independent reviewer does. Without that assent the classification is **recorded
as disputed** on the issue.

Where an adopter has no second operator to escalate to, the disagreement is
**recorded unresolved** and carried into the adopter's own decision process. An
unresolved disagreement written down is a known risk; one silently broken by the
author is a false green. Either state is a finding still open: the last round on
that branch returns `not mergeable, findings recorded`, and the issue a disputed
finding might owe is not owed until the dispute resolves.

## Reviewing for semantic agreement

A check that passes proves what it measures, not what you meant. The kit's own
linters are explicit about this: [`agents-lint.sh`](agents/agents-lint.sh) proves
presence, structure and coverage over the agent entry points and
[says plainly](agents/README.md) that it does *not* prove that a compressed
sentence means what its source paragraph means.

So when a change edits a summary, a rule, a checklist or any text that stands in
for another document, one round reviews it **clause by clause** against its
source. Not the file as a whole — clause by clause, because that is the grain at
which a summary goes wrong: a qualifier dropped, a "must" softened to "should", a
count left behind after the thing it counts changed.

For each changed clause, the reviewer answers three questions and records the
answers with the round:

1. **Does it still mean what the source means?** A narrower or broader claim is a
   defect, not a paraphrase.
2. **Does the source still say it?** A summary of a paragraph that moved or went
   away is stale, and staleness in a summary reads exactly like currency.
3. **Is anything asserted that no source supports?** An invented number, path or
   command is the worst class of this defect, because it is the most convincing.

This is the review the [DoD checklist](tests/dod-checklist.md) collects, and it is
the residual the deterministic checks hand over by design.

## Review before a costly or irreversible action

Some tasks get their evidence from a costly or irreversible action — a
long-running job, a full-scale sweep, a production migration, a paid external
call at scale, a mass send, a deployment. For these, the code that produces the
result gets its review pass **before** the action, not after.

A bug found after the action wastes the whole action, and usually a second
action to confirm the fix. The same bug caught by a few minutes of reading costs
nothing. So the order is: [test first](#testing), then at least one
[review round](#reviewing-until-findings-decay) over the code that will do the
work, *then* start the action — never act first and review the code afterwards.

A quick **smoke run** on a tiny slice, to prove the wiring, is encouraged. But it
is not a substitute for the review. A smoke run exercises the plumbing, not the
correctness of the result that the action exists to produce.

## Honesty and evidence

State outcomes plainly. Report failing tests, skipped steps, and inconclusive or
below-the-bar results as they are — never hidden, never with the goalposts moved.
Commit the run evidence under `‹evidence store›` so a reader can check the claim
against the data that produced it.

## Architecture Decision Records

Record architecturally significant decisions as an ADR in [`adr/`](adr/), in the
lightweight format described by Michael Nygard. Copy
[`adr/template.md`](adr/template.md) for each new record; the process and the
index live in [`adr/README.md`](adr/README.md), and
[`adr/0001-record-architecture-decisions.md`](adr/0001-record-architecture-decisions.md)
records the decision to use ADRs.

A decision is "architecturally significant" if it affects structure,
non-functional characteristics, dependencies, interfaces, or construction
techniques. When in doubt, write it down.

## Customer facts

Facts you collect from a customer — requirements, statements, domain facts — live
in [`facts/`](facts/) under a two-layer rule, so the customer's exact words and
your interpretation of them never get confused.

**Layer 1 — raw, stored as-is.** Commit each customer document word for word,
with a provenance header (source, collector, date, origin) and nothing rewritten.
This is evidence, and it follows the [Honesty and evidence](#honesty-and-evidence)
rule: it stays untouched so a requirement can be checked against the words that
produced it. A raw facts document is immutable once committed, exactly like an
[ADR](#architecture-decision-records); a correction is a new record, not an edit.

**Layer 2 — derived, in your own words.** Write your requirements, ADRs, and
glossary terms *from* the raw facts, and have each derived statement cite the raw
fact it came from by its `F-NNNN` ID. Layer 2 is where the
[plain-language](#plain-language-summaries) and [glossary](#glossary) rules apply,
and where interpretation is allowed. Layer 1 is where interpretation is forbidden.

The mechanics — the ID scheme, how to add a document, how to correct one — are in
[`facts/README.md`](facts/README.md). A project with no external customer skips
this section and the [`facts/`](facts/) directory entirely.

## Product requirements

Requirements live as **Product Requirements Documents (PRDs)** under
[`prd/`](prd/). A PRD is **Layer 2** of the [Customer facts](#customer-facts) rule:
each requirement is written *from* a raw `F-NNNN` fact and cites it, so a
requirement can always be traced back to the customer's words. Every requirement
carries a stable `REQ-NNN`/`NFR-NNN` ID, a MoSCoW priority, and a phase, and the
convention is enforced by [`prd/prd-lint.sh`](prd/prd-lint.sh). Copy
[`prd/template.md`](prd/template.md) for each new PRD; the mechanics and the ID
scheme are in [`prd/README.md`](prd/README.md), and the decision is
[ADR-0002](adr/0002-record-product-requirements.md). A project with no external
customer, or one too small to track requirements, skips this section and the
[`prd/`](prd/) directory.

## Requirements traceability

The kit's documents form one traceable line, from the customer's words to the test
that proves them:

    fact (F-NNNN#n) → requirement (REQ/NFR) → guardrail → ADR → task (‹task-ID›) → test

Each link already has a home — [`facts/`](facts/) holds the fact, [`prd/`](prd/)
the requirement, [`guardrails.md`](guardrails.md) the pitfall, [`adr/`](adr/) the
decision, [`tasks/`](tasks/) the task, and the test suite the test — and a PRD's
[traceability matrix](prd/README.md) is where the whole line is written down for
one requirement. Two rules keep the last link honest:

- **Test-driven, strict.** Write the failing test first, watch it fail for the
  right reason, then write the code that makes it pass — see [Testing](#testing).
  It is the default order, not an afterthought.
- **Test freeze.** Once a fresh context confirms the tests (after the
  [review rounds](#reviewing-until-findings-decay) settle), they are frozen. A
  frozen test that later fails opens a bug sub-issue; it is not weakened to make
  new code pass.

The full workflow around this — plan on the issue, then red, then green — is R8
and R9 of the [issue-first workflow](issue-workflow.md).

## Glossary

Any change that adds a new term, renames an existing one, or changes what a term
means must update [`glossary.md`](glossary.md) in the same change — the term's own
entry, its "collision to watch for" against outside systems where relevant, and
the quick-reference table. A rename that the glossary does not reflect leaves the
rest of the docs inconsistent with themselves, which is exactly what the glossary
exists to prevent.

**No undefined abbreviation.** Every abbreviation that appears in any conversation,
context, prompt, reply, or response must have an entry in [`glossary.md`](glossary.md).
If an abbreviation is not yet defined there, the same turn that uses it adds it — the
full row: Term, Abbr., Description, and Example. This rule binds **all LLMs and all
human operators** working in this project; it is not optional, and "the reader will
know what it means" is not a substitute for the entry. An abbreviation that is used
but never defined is the exact gap the glossary exists to close, one turn at a time.

The one boundary: general-English abbreviations — for example `e.g.`, `i.e.`, `etc.`,
`vs.` — are exempt, because they are already shared vocabulary. The exemption ends the
moment such a form carries a project-specific meaning; then it is a term like any
other and needs its row. When in doubt, add the entry: a glossary with one line too
many costs a reader a glance, while a missing line costs them the meaning.

## Plain-language summaries

Every doc that carries a **decision-grade finding** — a result that someone is
expected to act on — must state that finding once in plain language, near the
top, in a short **"In plain terms"** block.

The rule for that block: **no unexplained jargon**. If a sentence needs the
[`glossary`](glossary.md) to parse, rewrite it. State the consequence in units the
reader already knows — `‹for example money in currency, time in hours, counts such
as "about 996 times in 1,000" rather than a percentage of a percentage›`. The
block states the consequence, not the derivation. The derivation stays in the
body, where it belongs.

This is not decoration. A finding the reader cannot parse is a finding that
cannot be acted on. The technical body of these docs is written for someone
already fluent in the terminology — which neither a newly-onboarded engineer nor
the person who decides whether to spend money necessarily is.

[`onboarding-for-engineers.md`](onboarding-for-engineers.md) is the workspace-level
version of the same idea. Keep it in step whenever a headline number changes — it
is the first document a new engineer reads, so a stale number there is worse than
a stale number anywhere else.

## Commit messages

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):
`<type>: <description>`, for example `docs: add glossary` or
`feat(cli): add service scale command`. Common types: `feat`, `fix`, `docs`,
`refactor`, `test`, `chore`. Add a blank line and a longer body whenever the
_why_ is not obvious from the summary line alone.

When a commit implements or closes a [backlog](tasks/backlog.md) task, its ID goes
immediately after the colon, before the rest of the description:
`<type>: <ID> <description>`, for example `feat(store): <ID> add SQLite datastore`.
Give each task a stable ID under your `‹task-ID scheme›`. Commits with no task keep
the plain `<type>: <description>` form.

## Testing

Every feature and every bug fix must come with tests — a change with no test that
covers it is not done, no matter how manually verified it looked. Prefer TDD
(write the failing test first, then the code that makes it pass) wherever the task
shape allows it. It is the default way of working, not an afterthought bolted on
once the code already "works". A bug fix's test must fail against the old code and
pass against the fix — otherwise it is not proof that the bug is gone.

Tests run through `‹test runner›`.

The full testing conventions — the levels, a pattern to write each kind, the
security, scaling, and Definition-of-Done (DoD) checklists, and the traceability
that ties a test to what it proves — live in their own section,
[`tests/`](tests/README.md). The rules below are the *must*; that section is the
*how*.

**Four test levels, run cheap-first.** Tests sit on a fixed ladder — **unit**,
**integration**, **end-to-end (E2E)** — plus the process-level **discipline**
tests, defined in [`tests/test-levels.md`](tests/test-levels.md). The cheap levels
— unit and integration, with an optional end-to-end smoke subset — run in the
[`pre-commit` hook](#git-hooks); the whole ladder runs in
[CI](#continuous-integration-optional). Each level has its own command placeholder
— `‹unit test command›`, `‹integration test command›`, `‹end-to-end test command›`,
and `‹security test command›` for the parallel security track — with
`‹test timeout›` bounding a hanging test and `‹test directory›` naming where the
product tests live (the repo-root [`tests/`](../tests/) drop-in).

**Coverage, stated as rules:**

- Every component has a **unit** test.
- Every interface or workflow has an **integration** test.
- Every user-facing scenario has an **end-to-end** test, plus a
  [UAT](tests/template-uat.md) scenario wherever a human sign-off is required.
- Every [PRD](prd/) requirement (`REQ`/`NFR`) and every **Definition of Done
  (DoD)** item is covered by at least one test, tracked by a
  [traceability](tests/traceability-template.md) row — see
  [`tests/dod-checklist.md`](tests/dod-checklist.md).

**Old tests do not get weakened.** New work must not make an existing test fail
silently. If an old test fails, there are exactly three honest moves: **fix the
code** so it passes again; **update the requirement** the test encodes, with a
written reason (a new PRD change-log entry or an issue) and a test changed to match
the new requirement; or **retire the test** deliberately, with a reason, once the
behaviour it guarded is gone. Never weaken or delete a passing old test just to make
new code pass — that is the [test-freeze](#requirements-traceability) rule (R9), and
a frozen test that later fails opens a bug sub-issue.

**Tests scale with the project.** Keep every test independent, deterministic, fast
enough for the hook or CI, tagged by level (so one level can run alone), and resting
on stable interfaces — no brittle selectors or timing. The full list is
[`tests/scaling-checklist.md`](tests/scaling-checklist.md).

**Discipline tests keep the process itself honest.** Beyond tests of the product,
the kit ships five tests of its own conventions:
[`adr/adr-lint.sh`](adr/adr-lint.sh) lints [`adr/`](adr/) against the
[ADR](#architecture-decision-records) rules — filenames, sequential numbering,
required sections, the index, and cross-links —
[`prd/prd-lint.sh`](prd/prd-lint.sh) lints [`prd/`](prd/) against the
[PRD](#product-requirements) rules — requirement IDs, a resolvable cited fact per
requirement, MoSCoW and phase, and the traceability matrix —
[`agents/agents-lint.sh`](agents/agents-lint.sh) lints the root
[agent entry points](agents/README.md) against the documents they summarise —
the gate steps, the rules, the word budget, and the exact Claude import —
[`tasks/audit-record-lint.sh`](tasks/audit-record-lint.sh) lints this repository's
own audit record against its Definition of Done, and
[`ci/pr-link-lint.sh`](ci/pr-link-lint.sh) checks that a pull request's body links
its issue ([R1](issue-workflow.md#r1--issue-first)). They read only text, so they
need no toolchain and can be the project's first tests, before any product code
exists. The four that lint repo files run in the [`pre-commit`](#git-hooks) hook and
in [CI](#continuous-integration-optional); the PR-link check reads the PR body — a
forge artifact absent at commit time — so it runs in CI only. Add a discipline test
whenever a convention is worth enforcing automatically rather than by review; wire
each one into the hook and CI wherever its input is available.

## Continuous integration (optional)

CI runs this whole gate automatically on every change, so it is enforced by the
forge rather than by memory. It is the **authority**: its checks — the
[discipline linters](#testing) the templates ship (ADR, PRD, agent-entry and the
PR-link check), their [fixture self-tests](#testing), the
[test levels](#testing), lint, a security scan, and
the [commit-format](#commit-messages) check — are the ones you make *required*
before a merge. The [git hooks](#git-hooks) run the same rules locally for fast feedback.

It is optional because the kit is forge-free. Ready-to-copy templates for GitHub
Actions and GitLab CI live in [`docs/ci/`](ci/), inert until you copy one into
place and fill its `‹…›` steps — see [`docs/ci/README.md`](ci/README.md). Turn CI
on as part of [adapting the kit](#how-to-adapt-this-kit).

## Git hooks

Git hooks enforce the cheap parts of the gate **before** a commit is recorded, so
a violation never reaches CI or a reviewer. The tracked [`.githooks/`](../.githooks/)
directory holds them, shared by the whole team (unlike the local, untracked
`.git/hooks`). Install once per clone:

```bash
git config core.hooksPath .githooks
```

Two hooks ship with the kit:

- **`commit-msg`** — rejects a subject line that does not follow
  [Conventional Commits](#commit-messages). Ready as-is.
- **`pre-commit`** — first refuses to run at all if the **resolved hooks
  directory** lies outside the working tree being committed to, whatever set it:
  `core.hooksPath` if it is set, and the shared common git directory if it is not —
  which every linked worktree reaches too, so a hook left in `.git/hooks` is the
  same fault by another route (see [`guardrails.md`](guardrails.md)). It also
  refuses when it cannot resolve either path, rather than guessing. Then it runs
  the five repo-file
  [discipline linters](#testing) — ADR, PRD, audit-record, agent-entry and link —
  and their fixture self-tests,
  then the `‹lint›`, the fast [test levels](#testing) (`‹unit test command›`, then
  `‹integration test command›`), and the `‹security scanner›` step you fill in for
  your stack. Keep it cheap-first; the full suite — the end-to-end level and the
  full security scan — belongs in [CI](#continuous-integration-optional).

[`.githooks/README.md`](../.githooks/README.md) has the details and the optional
[`pre-commit` framework](https://pre-commit.com) alternative.

## Progress indicators for long-running operations

Any task, batch job, network operation, or loop that takes more than 10 seconds
must show an active, informative progress indicator. An operation that runs in
silence is an operational bug.

The indicator must give maximum clarity with minimum noise, on whichever
interface the tool targets:

- **CLI / TUI:** Show a dynamic status line, a concise progress bar, or a step
  counter — for example `[3/12] processing batch… (45s elapsed)`, or a
  non-scrolling spinner. Do not flood standard output with unbounded scrollback,
  raw dump logs, or repeated polling lines.
- **GUI / Web:** Show an explicit progress bar, a percentage, or a staged
  checklist with an estimated time or a stage marker — not a generic,
  non-informative loading spinner.

The indicator must answer three questions at a glance: which step runs now, how
much remains, and that the work is still alive rather than stalled or deadlocked.
If you cannot know the total duration or the item count in advance, show an
indeterminate heartbeat with an elapsed timer and a processed-item counter.

## Code comments

Comments should mostly explain _why_, not _what_ — the code already says what it
does, and a comment that repeats that goes stale the first time the code changes
underneath it. Reserve a _what_-level comment for a genuinely complex case where
the code's own shape does not make the logic legible at a glance (a non-obvious
algorithm, a subtle invariant, a workaround for a specific bug or external
constraint) — not as a default habit.

## Keeping documentation current

A change lands with the documentation it affects already updated, in the same PR
— never as a later follow-up task. This covers both the prose docs and the
comments in the code. If the change leaves a statement, a number, an example, or
a comment wrong, fixing it is part of the change, not optional tidy-up. Stale
documentation is a defect, and the [review rounds](#reviewing-until-findings-decay)
treat it as one. The same-change rules for the [glossary](#glossary),
[plain-language summaries](#plain-language-summaries), and
[onboarding](onboarding-for-engineers.md) are specific cases of this general one.

## Starting a task

If you are an agent, every task starts on its own feature branch, checked out in
its own git worktree — never directly on the operator's main worktree (whatever
branch it happened to have checked out), and never as uncommitted changes that
sit on top of someone else's in-progress work. Create the worktree and branch
together under the repo-local `‹worktree dir›` directory (gitignored), branched
off the latest `origin/main`, for example
`git worktree add ‹worktree dir›/<slug> -b <slug> origin/main`. Do the work
there, and remove the worktree (`git worktree remove`) once it is merged or
abandoned. This keeps the main worktree clean and available at all times, and
lets many tasks (including ones run by agents) proceed at the same time without
stepping on each other's working-tree state.

## Commit granularity

Commit at each logical step, not in one large batch at the end of a task. Each
commit should be one coherent, independently buildable-and-testable unit of work
— for example one task's datastore layer, one handler, one adapter — rather than
an entire multi-task feature that lands as a single commit. This keeps history
reviewable and bisectable, and mirrors the stable-task-ID convention, where each
task is already scoped to be its own trackable, independently-completable unit.

## Integrating branches

Prefer rebasing over merging to keep a branch current: rebase your feature branch
onto the latest `main` rather than merge `main` back into it, so history stays
linear and free of incidental merge commits.

Do not squash when you land a branch. The per-commit granularity described above
is deliberate, and a squash-merge discards it — it collapses a task's reviewable,
bisectable steps into a single opaque commit. Land branches so each commit is
preserved on `main`: rebase onto the latest `origin/main` first, then do a
plain merge (not a squash-merge).

One exception, and it runs the other way: a branch already carrying a
[frozen-head verdict](#reviewing-until-findings-decay) merges `origin/main` into
itself instead of rebasing, because a rebase rewrites the frozen head the verdict
names and leaves the review pointing at a commit that no longer exists
([ADR-0008](adr/0008-stop-the-gate-on-a-frozen-head.md#1-the-frozen-head)).

## Completing a task

Before the PR lands, tick the ticket's acceptance-criteria boxes and write the
task's verdict — the plain statement of what the work found or delivered, backed
by the evidence under `‹evidence store›`.

The **same PR that lands a task's work moves it from
[`tasks/backlog.md`](tasks/backlog.md) to
[`tasks/completed.md`](tasks/completed.md)** — delete its backlog line, where it
has one, and add a dated entry to the completed log (most recent first). A task
opened and finished between two landings never reaches the backlog; it is the
arrival in the completed log that gate step 8 requires, not the move. This is
not a separate
follow-up. Doing the move in the landing PR keeps the two files from ever drifting
(a task is never both "Now" and done at once), and the reviewer sees the backlog
bookkeeping alongside the change that earns it. The task's own detail file stays
where it is — only the one-line index entry moves.

## Agent entry points

The repository's rules bind every operator, human and LLM alike — but an agent
only follows rules it finds when it starts. Two files at the repository root close
that gap: [`AGENTS.md`](../AGENTS.md), the vendor-neutral guide, and
[`CLAUDE.md`](../CLAUDE.md), which holds the single line `@AGENTS.md` so Claude
Code loads the same guide with no second copy. The decision, the rejected
alternatives and the tradeoffs are [ADR-0004](adr/0004-ship-agent-entry-points.md).

`AGENTS.md` is a **summary and an index, not a governance document.** The
documents in this folder stay authoritative for their own subject; the guide names
which one, for each class of rule, in its own sources-of-truth table. Where the
two disagree, the document wins, and the disagreement is a defect fixed in the
same change — the [R10](issue-workflow.md#r10--sync-with-governance) case of
[Keeping documentation current](#keeping-documentation-current). A rule that
exists in no document here does not belong in the guide.

Instruction precedence: a higher-priority platform or operator instruction stays
higher priority; within its scope the guide governs work in this repository; a
nested instruction file may add a local constraint and may never weaken the
[quality gate](#working-a-task-under-the-quality-gate).

[`agents/agents-lint.sh`](agents/agents-lint.sh) keeps the guide honest by
deriving its expectations from these documents rather than copying them — so a
renamed rule or a deleted gate step turns the gate red. It checks coverage, not
semantic agreement; see [`agents/README.md`](agents/README.md) for what that does
and does not prove.

## Safety limits

Some mistakes cannot be undone by a later commit. These four are prohibitions, not
preferences, and they bind every operator:

- **Never commit a secret** — a credential, token, private key, or password —
  and never write one into a document, a fixture, or a log. A secret that reaches
  history is compromised even after it is deleted, so the fix is a rotated
  credential, not a revert.
- **Never expose sensitive data.** Customer material lives under
  [`facts/`](facts/) by the two-layer rule; do not copy it into an issue, a
  commit message, or an external service.
- **Never rewrite published history.** No force-push, no rebase of a branch
  others have pulled, no amend of a landed commit. Correct a mistake with a new
  commit that says what it corrects.
- **Never run a destructive, costly, or irreversible operation without explicit
  authorization** — a mass delete, a production migration, a paid call at scale,
  a deployment. Ask first, and review the code that will do the work *before* it
  runs, under
  [Review before a costly or irreversible action](#review-before-a-costly-or-irreversible-action).

The [security checks](tests/security-checklist.md) wired into the hook and CI are
the mechanized half of this section — a secret scan catches what a rule alone
cannot. A scan is a check with a pass condition; the four rules above are the
policy it serves, and they hold whether or not a scanner is configured.
