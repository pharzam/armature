# Issue-first workflow

The rules for the **tickets** the [quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate)
already assumes. The gate tells a task author to read "the ticket's acceptance
criteria"; this document says how those tickets are opened, scoped, and linked.

## In plain terms

> No change starts without an open issue, and every change lands through a pull
> request that links back to it. One issue is one goal. Bigger work is sliced into
> ordered, test-first steps, and the plan is checked once before building begins.
> Decisions are written down where the next person — human or agent — can find them.

> **How to adapt this file.** This is a generic policy. The kit is **forge-free**,
> so an *issue* here means a tracked ticket in whatever forge you use (or none),
> and forge-specific issue/PR templates ship **inert** under [`templates/`](templates/) —
> copy them into place only when you adopt that forge. Replace each `‹…›` marker
> (your `‹task-ID scheme›`, your forge's linking keywords if they differ), delete
> a rule you consciously reject — and record why in an [ADR](adr/) — then delete
> this note. The decision to work this way is [ADR-0003](adr/0003-adopt-issue-first-workflow.md).

These rules bind **every operator — each human and each LLM coding agent.** They
are numbered R1–R12 so a review or a commit can cite one by number.

## R1 — Issue first

Every change needs an **open issue before any commit or pull request**. A pull
request with no linked issue does not merge. The issue is where the goal, the
plan, and the decisions live; the code is the answer to it.

**Linking keywords.** In the PR body, link the issue with the forge's keywords:

| Keyword | Effect |
| ------- | ------ |
| `Closes #N` (also `Fixes #N`, `Resolves #N`) | Auto-closes issue `N` when the PR merges — use it when the PR fully satisfies the issue. |
| `Refs #N` (also `Part of #N`) | Links a parent, meta, or multi-part issue **without** closing it. |

**Two namespaces, keep both.** The kit already puts a task ID (`‹task-ID scheme›`)
in the **commit subject** — see [Commit messages](engineering-discipline.md#commit-messages).
The **issue reference** (`Closes`/`Refs #N`) lives in the **PR body**. The task ID
tracks the unit of work locally; the issue number tracks it in the forge. They
coexist and cross-walk on the task's [backlog](tasks/backlog.md) line.

## R2 — Duplicate check before a new issue

Before opening an issue, search the open **and** closed issues. If the work is
part of a larger one, open it as a child/sub-issue and link the parent, rather
than duplicating an existing thread.

## R3 — Apply the solution-selection standard

Apply the reusable [solution-selection standard](engineering-discipline.md#solution-selection)
to every technical selection. Follow its comparison and recording rules. A
selection with no record is one a later reader will reopen.

## R4 — No workarounds

A workaround is never the default. If one is genuinely unavoidable, it needs the
written approval of **two different operators** on the issue, and it is logged as
technical debt with its **own removal issue**. A workaround with no removal issue
is a permanent defect wearing a temporary label.

## R5 — Deterministic over LLM-based

Apply the deterministic consideration in the
[solution-selection standard](engineering-discipline.md#solution-selection).
Wherever a rule can be checked by a machine, prefer a script, linter, type check,
or CI gate over an LLM judgement. A human operator can select an LLM approach for
a specific case, but must record the selection and its reason as the standard
requires.

## R6 — Agent-to-agent communication through the issue

An LLM agent never asks another agent directly. Every question is a **comment on
the in-progress issue**, addressed to the assignee, with a severity and an expected
response time (for example: `severity: blocker, respond < 4h`). The answer goes on
the same issue thread. This keeps the coordination auditable and lets a fresh
context pick up where another left off.

## R7 — Decision transparency on every action

Before the commit or PR that carries it out, the operator writes a short comment
stating the **action chosen, why, and the tradeoffs**. It is the issue-thread twin
of an ADR's Consequences — smaller in scope, but the same idea: the reasoning is
visible, not lost in a head.

## R8 — Test-driven, strict: red, then green

Plan first: a short, concrete plan (scope, steps, the test list, the risks) goes
**on the issue** before the first test. Then follow the fixed order — (1) write the
tests first, (2) run them and watch them fail (red) for the *right* reason, (3)
write code until they pass (green). This is the [Testing](engineering-discipline.md#testing)
rule stated as an order and tied to the requirement the change serves.

## R9 — Test freeze after confirmation

Once the [review rounds](engineering-discipline.md#reviewing-until-findings-decay)
settle and a **fresh context** (another agent or session, not the author) confirms
the tests, the tests are **frozen**. A frozen test is not weakened or deleted to
make new code pass. If a frozen test later fails, that opens a **bug sub-issue**
scoped to the failure — the failure is the signal, not the test's fault.

## R10 — Sync with governance

These rules are not standalone. Keep them synchronized with
[`engineering-discipline.md`](engineering-discipline.md), the [ADRs](adr/),
[`guardrails.md`](guardrails.md), [`glossary.md`](glossary.md), and the
[PRD convention](prd/README.md). A conflict between them stops work: open a
discussion on the issue and resolve it with a decision note or an ADR, then update
whichever document was wrong.

## R11 — Single-goal issues

One issue is **one actionable, demoable goal at a limited scale.** Large work
becomes a parent issue with child sub-issues, each independently completable. This
mirrors the kit's [commit-granularity](engineering-discipline.md#commit-granularity)
rule, one level up: a task you cannot demo in one step is really several tasks.

## R12 — Slice and prioritize

Before the first test, turn the issue into an **ordered plan**: the steps of work
that together satisfy the issue's Definition of Done (DoD), each scoped to one
domain, each able to pass the
[quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate) on
its own.

- **Cover the DoD.** Every step maps to a DoD item or an acceptance criterion. A
  DoD item with no step is a gap; a step with no DoD item is scope creep. The
  [DoD checklist](tests/dod-checklist.md) is where that coverage is checked off.
- **Order by dependency and TDD.** Put the steps in the order they must happen. The
  **test work is its own step, and it comes first** — writing the tests is the red
  half of [R8](#r8--test-driven-strict-red-then-green), so the test slice outranks
  the code that makes it pass. Foundational and blocking steps precede the steps
  that depend on them.
- **Slice by domain.** One concern per step — for example a test slice, a datastore
  slice, an interface slice, a docs slice. A step too big to demo on its own is a
  child sub-issue under [R11](#r11--single-goal-issues), not a step.
- **One gate per slice.** Every sliced sub-task passes the same
  [quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate);
  slicing is never a shortcut around discipline.
- **Select the plan.** Apply the
  [solution-selection standard](engineering-discipline.md#solution-selection)
  before you write the selected approach as the ordered plan. Compare materially
  different approaches when they exist; no fixed number of candidates is required.
  The standard states where to record the selected and rejected approaches.
- **Review the plan once, then record it.** The ordered plan gets **one round of
  independent review and a reviewer's confirmation** before building begins. This
  is a review of the *plan* — lighter than, and separate from, the
  [code review rounds](engineering-discipline.md#reviewing-until-findings-decay)
  that come after the code works and run inside the cycle cap
  [ADR-0008](adr/0008-stop-the-gate-on-a-frozen-head.md#2-the-cycle-cap-and-the-non-merge-verdict)
  sets. **Comment the plan and the confirmation on the
  issue**, so the next context sees both the plan and that it was checked. The
  reviewer may be a person or a fresh agent session; see
  [Who may review](engineering-discipline.md#who-may-review).
- **The plan review is architecture and scope — not implementation approval.**
  It asks whether the slicing is right, whether the steps cover the DoD, whether
  the approach fits the [guardrails](guardrails.md) and the
  [ADRs](adr/), and **how big the result is allowed to get**. It does not approve
  the implementation, which does not exist yet. A reviewer who agreed to a plan's
  shape has *not* thereby agreed to whatever size arrives under it: a step that
  grows past the scale the plan implied goes back to the issue as a new slice or
  a child sub-issue under [R11](#r11--single-goal-issues), not through on the
  strength of the earlier confirmation. Where scale is a real risk, the plan says
  the bound out loud — and an approach whose size cannot be bounded in advance is
  itself a finding.

R12 makes [R8](#r8--test-driven-strict-red-then-green)'s "plan first" concrete: R8
says a plan goes on the issue before the first test; R12 says what that plan is — an
ordered, DoD-covering, test-first slicing — and that it is reviewed once and
recorded before the red/green cycle begins.

## What is enforced where

A rule is only as real as what enforces it. This table is honest about which rules
a mechanism backs today and which are written-rule-only until you wire a gate. The
kit already ships the green rows.

| Concern | Written rule | Local hook | CI | Branch protection | Status |
| ------- | ------------ | ---------- | -- | ----------------- | ------ |
| Land only via a PR (never a direct push to the default branch) | R1 | [`pre-push`](../.githooks/pre-push) | — | ‹require a PR before merge› | Hook ships; branch protection is your step |
| Conventional Commits | [Commit messages](engineering-discipline.md#commit-messages) | [`commit-msg`](../.githooks/commit-msg) | [`pr-title`](ci/github-actions-pr-title.yml) | — | Enforced |
| ADR + PRD discipline | R5, [Testing](engineering-discipline.md#testing) | [`pre-commit`](../.githooks/pre-commit) | [`adr-lint`, `prd-lint`](ci/) | — | Enforced |
| The linters reject bad input (fixtures) | [Testing](engineering-discipline.md#testing) | [`pre-commit`](../.githooks/pre-commit) | [`discipline-tests`](tests/run-discipline-tests.sh) | — | Enforced |
| A PR links an issue (`Closes`/`Refs #N`) | R1 | — | [`pr-link-lint`](ci/pr-link-lint.sh) | ‹require the check before merge› | Check ships; branch protection is your step |
| Test coverage bar | R8 | — | ‹add a coverage gate› | — | Written rule until wired |
| Slice + prioritize the plan before building (test-first), reviewed once on the issue | R12 | — | — | — | Written rule until wired |
| Reviewer independence and the review record (ten named fields, the cycle among them) | [ADR-0005](adr/0005-independent-review-may-be-an-agent.md), [ADR-0008](adr/0008-stop-the-gate-on-a-frozen-head.md) | — | ‹check the issue carries a review record› | — | Written rule until wired |
| The stopping protocol: a frozen head, the cycle cap and its non-merge verdict, materiality, and where a revealed defect goes | [ADR-0008](adr/0008-stop-the-gate-on-a-frozen-head.md) | — | — | — | Written rule until wired |
| The agent entry points cover the gate and the numbered rules | [ADR-0004](adr/0004-ship-agent-entry-points.md) | [`pre-commit`](../.githooks/pre-commit) | [`agents-lint`](agents/agents-lint.sh) | — | Enforced |

This layers **on top of** the [`tasks/`](tasks/) backlog, it does not replace it:
the issue is the outward ticket, the `‹task-ID scheme›` card in
[`tasks/backlog.md`](tasks/backlog.md) is the local detail. The gate gains an
implicit **step 0 — open an issue** before step 1 (Isolate).
