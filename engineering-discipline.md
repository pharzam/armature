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

Two kinds of thing need your input. Do both, then delete this section.

**1. Fill the sibling documents.** Each is a generic template with its own
"How to adapt" notes:

- [`guardrails.md`](guardrails.md) — your known-pitfall, decision, and validation
  rules. Referenced by gate step 2.
- [`adr/`](adr/) — your Architecture Decision Records. Start at
  [`adr/README.md`](adr/README.md); copy [`adr/template.md`](adr/template.md) for
  each new record.
- [`glossary.md`](glossary.md) — your shared-vocabulary document.
- [`onboarding-for-engineers.md`](onboarding-for-engineers.md) — the first
  document a new engineer reads.
- [`tasks/backlog.md`](tasks/backlog.md) and
  [`tasks/completed.md`](tasks/completed.md) — your task index.

**2. Replace the `‹…›` markers.** These are the per-project values with no file
of their own:

- `‹test runner›` — how tests run in your stack (the command and any rule, for
  example "no external test framework").
- `‹evidence store›` — where you commit run outputs, logs, or results (for
  example `runs/` or `artifacts/`).
- `‹task-ID scheme›` — how you tag a task (for example `T-` plus four random
  characters).
- `‹worktree dir›` — your per-task isolation directory (for example `.worktree/`).

## Working a task under the quality gate

Every substantive task runs through the same gate. The steps below are the
required order. Each step links to the section that gives its mechanics, and
states any rule that has no section of its own.

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

5. **Review until findings decay.** After the code works, run rounds of
   independent blind reviews — see
   [Reviewing until findings decay](#reviewing-until-findings-decay).

6. **Be honest, keep evidence.** State outcomes plainly and commit run evidence
   under `‹evidence store›` — see [Honesty and evidence](#honesty-and-evidence).
   When that evidence comes from a costly action, review the producing code
   *first* — see
   [Review before a costly or irreversible action](#review-before-a-costly-or-irreversible-action).

7. **Keep the documentation current.** Update every doc and code comment that the
   change touches or leaves stale, in the same PR — see
   [Keeping documentation current](#keeping-documentation-current).

8. **Close out in the same PR.** Tick the acceptance boxes, write the verdict,
   and move the ticket from backlog to completed — see
   [Completing a task](#completing-a-task). Then take the next logical task.

## Reviewing until findings decay

After the code works, run rounds of independent blind reviews. Each reviewer is
fresh — it does not see your reasoning — and each round applies a different lens:

- correctness and failure modes — `‹name the failure modes that hurt you most,
  for example data leakage, race conditions, off-by-one, unhandled errors›`,
- guardrails and acceptance criteria,
- clean and simple,
- adversarial bug-hunt.

Fix every real finding. Keep the rounds running until one round finds nothing
material. One pass is never enough. Each round catches a different class of
error.

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

## Completing a task

Before the PR lands, tick the ticket's acceptance-criteria boxes and write the
task's verdict — the plain statement of what the work found or delivered, backed
by the evidence under `‹evidence store›`.

The **same PR that lands a task's work moves it from
[`tasks/backlog.md`](tasks/backlog.md) to
[`tasks/completed.md`](tasks/completed.md)** — delete its backlog line and add a
dated entry to the completed log (most recent first). This is not a separate
follow-up. Doing the move in the landing PR keeps the two files from ever drifting
(a task is never both "Now" and done at once), and the reviewer sees the backlog
bookkeeping alongside the change that earns it. The task's own detail file stays
where it is — only the one-line index entry moves.
