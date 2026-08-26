# Issue-first workflow

The rules for the **tickets** the [quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate)
already assumes. The gate tells a task author to read "the ticket's acceptance
criteria"; this document says how those tickets are opened, scoped, and linked.

## In plain terms

> No change starts without an open issue, and every change lands through a pull
> request that links back to it. One issue is one goal. Decisions are written down
> where the next person — human or agent — can find them.

> **How to adapt this file.** This is a generic policy. The kit is **forge-free**,
> so an *issue* here means a tracked ticket in whatever forge you use (or none),
> and forge-specific issue/PR templates ship **inert** under [`templates/`](templates/) —
> copy them into place only when you adopt that forge. Replace each `‹…›` marker
> (your `‹task-ID scheme›`, your forge's linking keywords if they differ), delete
> a rule you consciously reject — and record why in an [ADR](adr/) — then delete
> this note. The decision to work this way is [ADR-0003](adr/0003-adopt-issue-first-workflow.md).

These rules bind **every operator — each human and each LLM coding agent.** They
are numbered R1–R11 so a review or a commit can cite one by number.

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

## R3 — Solution selection: state-of-the-art and best practice only

Choose the state-of-the-art, best-practice solution. Prefer a proven standard over
a custom build. Record the chosen option **and the rejected alternatives** as a
decision note — an [ADR](adr/) if the choice is architecturally significant, else a
short comment on the issue. A choice made with no record is a choice a later reader
will re-open.

## R4 — No workarounds

A workaround is never the default. If one is genuinely unavoidable, it needs the
written approval of **two different operators** on the issue, and it is logged as
technical debt with its **own removal issue**. A workaround with no removal issue
is a permanent defect wearing a temporary label.

## R5 — Deterministic over LLM-based

Prefer deterministic mechanisms — scripts, linters, type checks, CI gates — over
an LLM judgement, wherever a rule can be checked by a machine. A human operator may
explicitly choose the LLM approach for a specific case; that choice is recorded on
the issue with its reason.

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

## What is enforced where

A rule is only as real as what enforces it. This table is honest about which rules
a mechanism backs today and which are written-rule-only until you wire a gate. The
kit already ships the green rows.

| Concern | Written rule | Local hook | CI | Branch protection | Status |
| ------- | ------------ | ---------- | -- | ----------------- | ------ |
| Land only via a PR (never a direct push to the default branch) | R1 | [`pre-push`](../.githooks/pre-push) | — | ‹require a PR before merge› | Hook ships; branch protection is your step |
| Conventional Commits | [Commit messages](engineering-discipline.md#commit-messages) | [`commit-msg`](../.githooks/commit-msg) | [`pr-title`](ci/github-actions-pr-title.yml) | — | Enforced |
| ADR + PRD discipline | R5, [Testing](engineering-discipline.md#testing) | [`pre-commit`](../.githooks/pre-commit) | [`adr-lint`, `prd-lint`](ci/) | — | Enforced |
| A PR links an issue (`Closes`/`Refs #N`) | R1 | — | [`pr-link-lint`](ci/pr-link-lint.sh) | ‹require the check before merge› | Check ships; branch protection is your step |
| Test coverage bar | R8 | — | ‹add a coverage gate› | — | Written rule until wired |

This layers **on top of** the [`tasks/`](tasks/) backlog, it does not replace it:
the issue is the outward ticket, the `‹task-ID scheme›` card in
[`tasks/backlog.md`](tasks/backlog.md) is the local detail. The gate gains an
implicit **step 0 — open an issue** before step 1 (Isolate).
