# AGENTS.md

Agent context for **Armature**, the engineering-discipline kit. Read this before
you change anything in this repository.

This file is the compressed form of the rules. Where it disagrees with the
document it summarises, **the document wins** — and the disagreement is a defect
to fix in the same change
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
covering, test-first plan that is reviewed once and recorded on the issue.

1. **Isolate.** Work in a per-task git worktree branched off `origin/main`, never in the operator's own checkout.
2. **Honor the guardrails.** Before you write code, read the acceptance criteria, [`docs/guardrails.md`](docs/guardrails.md), and the [ADRs](docs/adr/) the ticket references.
3. **Test first.** Write the failing test, watch it fail for the right reason, then write the code.
4. **Make long tasks visible.** Anything that can run over ten seconds shows which step runs and that it lives.
5. **Review until findings decay.** Independent blind rounds, a different lens each round, until one finds nothing material.
6. **Be honest, keep evidence.** Report a failure as a failure, and review the producing code before a costly action.
7. **Keep the documentation current.** Every document the change leaves stale is fixed in the same pull request.
8. **Close out in the same PR.** Tick the boxes, write the verdict, and move the task line from backlog to completed.

## The issue rules

The workflow defines **twelve** numbered rules; cite one by number in a review or
a commit. A line marked `(written rule)` has no mechanism behind it today, and the
honest account of what is enforced is that document's own
[enforcement table](docs/issue-workflow.md#what-is-enforced-where), never this
file.

- **R1** — [Issue first](docs/issue-workflow.md#r1--issue-first): no commit and no pull request without an open issue behind it.
- **R2** — [Duplicate check before a new issue](docs/issue-workflow.md#r2--duplicate-check-before-a-new-issue): search the open and the closed issues before you open one (written rule)
- **R3** — [Apply the solution-selection standard](docs/issue-workflow.md#r3--apply-the-solution-selection-standard): compare the candidates, then record the selected and the rejected ones (written rule)
- **R4** — [No workarounds](docs/issue-workflow.md#r4--no-workarounds): two operators approve one in writing, and it gets its own removal issue (written rule)
- **R5** — [Deterministic over LLM-based](docs/issue-workflow.md#r5--deterministic-over-llm-based): prefer a script, a linter or a gate to a model's judgement.
- **R6** — [Agent-to-agent communication through the issue](docs/issue-workflow.md#r6--agent-to-agent-communication-through-the-issue): never ask another agent directly; comment on the issue with a severity (written rule)
- **R7** — [Decision transparency on every action](docs/issue-workflow.md#r7--decision-transparency-on-every-action): state the action, the reason and the tradeoffs before the commit that carries it (written rule)
- **R8** — [Test-driven, strict: red, then green](docs/issue-workflow.md#r8--test-driven-strict-red-then-green): plan on the issue, write the tests, watch them fail, then write code (written rule)
- **R9** — [Test freeze after confirmation](docs/issue-workflow.md#r9--test-freeze-after-confirmation): once a fresh context confirms them, a later failure opens a bug sub-issue (written rule)
- **R10** — [Sync with governance](docs/issue-workflow.md#r10--sync-with-governance): keep this file and the governance documents in step; a conflict stops work (written rule)
- **R11** — [Single-goal issues](docs/issue-workflow.md#r11--single-goal-issues): one issue is one actionable, demoable goal at a limited scale (written rule)
- **R12** — [Slice and prioritize](docs/issue-workflow.md#r12--slice-and-prioritize): an ordered, DoD-covering plan, the test slice first, reviewed once on the issue (written rule)

## Checks you can run

These read only text, so they need no toolchain. Install the hooks once per clone
with `git config core.hooksPath .githooks`; the first five then run before every
commit, and in CI. The last one you run yourself.

```
sh docs/adr/adr-lint.sh
sh docs/prd/prd-lint.sh
sh docs/agents/agents-lint.sh
sh docs/tasks/audit-record-lint.sh
sh docs/tests/run-discipline-tests.sh
git diff --check
```

[`docs/ci/pr-link-lint.sh`](docs/ci/pr-link-lint.sh) reads a pull-request body, so
it runs in CI only and has no local run. Armature has no product test suite and no
product toolchain: never invent a build, lint or test command for it.

## Branches, worktrees, commits, and pull requests

Work in a per-task git worktree under `‹worktree dir›/<task>`, branched off
`origin/main`, never in the operator's own checkout. Commit at each logical step,
with a subject that follows Conventional Commits — `<type>: <ID> <description>`
when it carries a task. Rebase onto the latest `origin/main` and land with a plain
merge; **never squash**. The pull-request body links its issue with `Closes #N`,
or `Refs #N` when it does not close it.

## The task index

[`docs/tasks/backlog.md`](docs/tasks/backlog.md) holds one line per open task, and
[`docs/tasks/completed.md`](docs/tasks/completed.md) the dated log of finished
ones. Any detail belongs in that task's own file, never in either index. The same
pull request that lands the work moves the line from one to the other.

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
| [`docs/adr/`](docs/adr/) | Architecture decisions, with the context and the consequences of each one. |
| [`docs/tests/`](docs/tests/) | The test levels, a pattern for each, and the Definition-of-Done coverage checklist. |
| [`docs/facts/`](docs/facts/) and [`docs/prd/`](docs/prd/) | Customer facts kept as evidence, and the requirements derived from them. |
| [`.githooks/`](.githooks/) and [`docs/ci/`](docs/ci/) | What the gate enforces locally, and what CI enforces as the authority. |

## Keeping this file honest

`docs/agents/agents-lint.sh` derives its expectations from the documents above —
the gate steps, the rules, their anchors and titles, and which rules a mechanism
backs — so a change there turns this file red rather than quietly stale. It proves
coverage, not semantic agreement: a reviewer still has to check that each summary
means what its source means. See
[`docs/agents/README.md`](docs/agents/README.md).
