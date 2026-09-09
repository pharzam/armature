# AGENTS.md

Agent context for **Armature**, the engineering-discipline kit. Read this before
you change anything in this repository.

This file is a startup index and summary of how we work here. Where it disagrees
with a document it points to or summarises, **the document wins** — and the
disagreement is a defect to fix in the same change
([R10](docs/issue-workflow.md#r10--sync-with-governance)).

## What this repository is

A domain-free **template**, not a product application. Armature ships the "how we
work" — a quality gate, guardrails, decision records, a glossary, a
facts-and-requirements convention, a test section and a task backlog — for an
adopter to copy onto its own domain. It holds no product code and no product test
suite, so there is nothing here to build, and no toolchain to install.

Two things catch agents out: the `‹…›` markers are deliberate, and the root
[`tests/`](tests/) directory is empty on purpose — it is the adopter's drop-in.

## How these instructions rank

A platform or operator instruction of higher priority stays higher priority than
this file. Within its scope, this file governs work in this repository. The
documents under [`docs/`](docs/) are authoritative for their own subject, and this
file only summarises them. A nested instruction file, added lower in the tree, may
add a local constraint and may **never** weaken the quality gate. A conflict
between any two of them stops work until a decision note or an
[ADR](docs/adr/) resolves it.

## Start here

Read [`docs/engineering-discipline.md`](docs/engineering-discipline.md) for how we
work, then [`docs/issue-workflow.md`](docs/issue-workflow.md) for the ticket rules
that gate assumes.
[`docs/onboarding-for-engineers.md`](docs/onboarding-for-engineers.md) is the
human first door. Which document owns which class of rule is the table under
Sources of truth, written once.

## The quality gate

Every substantive task passes **eight** ordered steps, in this order. Before step
1, an issue is open, and the work is sliced into an ordered, Definition-of-Done
covering, test-first plan that is reviewed once and recorded on the issue. That
plan review is architecture and scope, never implementation approval.

1. **Isolate.** Work in a per-task git worktree branched off `origin/main`, never in the operator's own checkout.
2. **Honor the guardrails.** Before you write code, read the acceptance criteria, [`docs/guardrails.md`](docs/guardrails.md), and the [ADRs](docs/adr/) the ticket references.
3. **Test first.** Write the failing test, watch it fail for the right reason, then write the code.
4. **Make long tasks visible.** Anything that can run over ten seconds shows which step runs and that it lives.
5. **Review until findings decay.** Freeze the head, then run independent blind rounds on it, a different lens each round. A fix re-freezes; at most two fix-and-review cycles follow the first freeze, and the last round ends `nothing material in scope` or `not mergeable, findings recorded` — see [Reviewing until findings decay](docs/engineering-discipline.md#reviewing-until-findings-decay). A defect the change *revealed*, off the path its Definition of Done names, opens an issue instead of entering the branch. A reviewer is a person or a fresh agent session — the requirement is [independence](docs/engineering-discipline.md#who-may-review), not reviewer type — and summarised text gets a clause-by-clause semantic pass.
6. **Be honest, keep evidence.** Report a failure as a failure, and review the producing code before a costly action.
7. **Keep the documentation current.** Every document the change leaves stale is fixed in the same pull request — and any lesson the task taught that the next reader could hit is written back into `guardrails.md` §2 (Known pitfalls).
8. **Close out in the same PR.** Tick the boxes, write the verdict, and record the task line in the completed log.

**Model tiers.** Where a step needs a model, a **reasoning tier** does the deciding
and judging — the plan and its review, solution selection, the review rounds, the
verdict — and an **execution tier** does tactical execution and coding once the plan
is fixed. Routing applies only after
[Determinism](docs/engineering-discipline.md#solution-selection) warrants a model at
all, a deterministic check still outranks any tier, and reviewer
[independence](docs/engineering-discipline.md#who-may-review) wins where it meets
routing. The rule and its tier-to-step map live in
[Model tiers](docs/engineering-discipline.md#model-tiers), recorded in
[ADR-0005](docs/adr/0005-route-work-by-model-tier.md).

## The issue rules

The workflow defines **twelve** numbered rules, R1–R12; cite one by number in a
review or a commit. They are defined once, in
[`docs/issue-workflow.md`](docs/issue-workflow.md) — this file points there rather
than restating them, so there is a single source to keep in step. Which rule a
mechanism backs today, and which is `(written rule)` with none, is that document's
own [enforcement table](docs/issue-workflow.md#what-is-enforced-where), never this
file.

## Checks you can run

These read only text, so they need no toolchain. Install the hooks once per clone
with `git config core.hooksPath .githooks`; the first four then run before every
commit, and in CI; `nested-checkout-check.sh` needs `git`, so it runs in CI only;
and `git diff --check` you run yourself. Keep
[`.gitattributes`](.gitattributes): it holds these scripts at line-feed endings,
without which none of them runs on a Windows checkout.

```
sh docs/adr/adr-lint.sh
sh docs/prd/prd-lint.sh
sh docs/links/link-lint.sh
sh docs/tests/run-discipline-tests.sh
sh docs/tests/nested-checkout-check.sh
git diff --check
```

[`docs/ci/pr-link-lint.sh`](docs/ci/pr-link-lint.sh) and
[`docs/ci/review-record-lint.sh`](docs/ci/review-record-lint.sh) read forge
artifacts, so they run in CI only and have no local run. Armature has no product test suite and no
product toolchain: never invent a build, lint or test command for it.

## Branches, worktrees, commits, and pull requests

Work in a per-task git worktree under `‹worktree dir›/<task>`, branched off
`origin/main`, never in the operator's own checkout. Commit at each logical step,
with a subject that follows Conventional Commits — `<type>: <ID> <description>`
when it carries a task. Rebase onto the latest `origin/main` and land with a plain
merge; **never squash** — but a branch already under a frozen-head verdict merges
`origin/main` in instead, so the reviewed SHA survives. The pull-request body
links its issue with `Closes #N`,
or `Refs #N` when it does not close it.

## The task index

[`docs/tasks/backlog.md`](docs/tasks/backlog.md) holds one line per open task, and
[`docs/tasks/completed.md`](docs/tasks/completed.md) the dated log of finished
ones. Any detail belongs in that task's own file, never in either index. The same
pull request that lands the work records the line in the completed log, moving it
from the backlog where the task had one.

## Placeholders and adopter values

Every `‹…›` marker is a value only the adopter can supply — the test runner, the
evidence store, the task-ID scheme, the worktree directory. Never replace one with
a guess, never invent an adopter's command, path or number, and never delete a
marker to make a check pass. Search for `‹` to find every one of them.

## Safety limits

Never commit secrets, and never expose sensitive data. Never rewrite published
history — no force-push, no amend of a landed commit. Never run a destructive,
costly or irreversible operation without explicit authorization, and review the
code that will do the work before it runs. The full rule is
[Safety limits](docs/engineering-discipline.md#safety-limits).

## Decisions and questions

Record the plan, the selected option, the rejected alternatives, the tradeoffs and
the evidence on the issue — that is where a fresh context picks the work up. Ask
another operator on the issue thread, with a severity and an expected response
time, never directly. An architecturally significant decision becomes an
[ADR](docs/adr/).

## Sources of truth

| Document | Authoritative for |
|----------|-------------------|
| [`docs/engineering-discipline.md`](docs/engineering-discipline.md) | The quality gate, solution selection, testing, reviews, commits and the safety limits. |
| [`docs/issue-workflow.md`](docs/issue-workflow.md) | The numbered rules themselves, and the honest table of what a mechanism backs today. |
| [`docs/guardrails.md`](docs/guardrails.md) | Known pitfalls, pre-registered pass and fail rules, and how a result is validated. |
| [`docs/glossary.md`](docs/glossary.md) | The shared vocabulary, and the rule that every abbreviation earns an entry. |
| [`docs/adr/`](docs/adr/) | Architecture decisions that constitute a project, with the context and the consequences of each one. This repository's own past governance decisions are archived under `docs/decisions/`, which an adopter deletes. |
| [`docs/tests/`](docs/tests/) | The test levels, a pattern for each, and the Definition-of-Done coverage checklist. |
| [`docs/facts/`](docs/facts/) and [`docs/prd/`](docs/prd/) | Customer facts kept as evidence, and the requirements derived from them. |
| [`.githooks/`](.githooks/) and [`docs/ci/`](docs/ci/) | What the gate enforces locally, and what CI enforces as the authority. |
