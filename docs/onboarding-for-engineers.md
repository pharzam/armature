# Onboarding for engineers

> **Who this is for.** Software engineers joining this project who do **not**
> necessarily know the project's domain. You know how to build software. This
> document teaches you the project's terminology and the one or two facts that
> shape every decision, then hands you off to the deeper docs.
>
> **Read this first.** Every other document is written for someone already fluent
> in the terminology. This one gets you to that point. Budget half an hour.

> **How to adapt this file.** This is a skeleton. Fill each `‹…›` marker with your
> project's own content, delete the sections you do not need, and — most
> importantly — keep the headline numbers in step. This is the first document a
> new engineer reads, so a stale number here is worse than a stale number
> anywhere else (see the [plain-language-summaries](engineering-discipline.md#plain-language-summaries)
> rule). Delete this note when the file is real.

## 1. Problem statement

`‹Describe the product in plain language, with no unexplained jargon. What does it
do, for whom, and what question was the project set out to answer. If the project
has already answered part of that question, say so here.›`

## 2. Crash course: the domain

`‹The vocabulary a reader hits in every other document, in dependency order — each
term building on the last, not alphabetical. This is the same vocabulary as
[glossary.md](glossary.md), but taught in prose, because definitions in isolation
are hard to absorb. Use small diagrams and worked examples where they help.›`

### 2.1 `‹First concept›`

`‹Explain it. Prefer a concrete example or a small ASCII diagram.›`

### 2.2 `‹Second concept, building on the first›`

`‹…›`

## 3. What the system actually does

`‹The core mechanism, concretely. If there is one central design — a main loop, a
pipeline, a state machine — draw it and walk through it once.›`

## 4. Why it is hard

`‹The one or two numbers, or the one hard constraint, that make this project
difficult. State the consequence in units the reader already knows. This is the
section that stops a new engineer from proposing the obvious thing that does not
work.›`

## 5. How this project works

### The one cultural thing to understand

`‹State the single most important cultural value — the thing that surprises new
engineers and that they must not fight. For a research project it might be "we are
more afraid of fooling ourselves than of being slow"; for a product it might be
something else entirely.›`

Consequences you will meet immediately, and which are not negotiable:

- `‹non-negotiable 1 — link the guardrail or gate it comes from›`
- `‹non-negotiable 2›`

### Repo layout

| Path | What |
|------|------|
| `‹path›` | `‹what lives there›` |
| [`AGENTS.md`](../AGENTS.md) | The agent entry point — the whole gate and R1–R12 in one short file. [`CLAUDE.md`](../CLAUDE.md) imports it for Claude Code. |
| [`engineering-discipline.md`](engineering-discipline.md) | **How we work**: the quality gate, solution selection, branches, worktrees, commits, tests, reviews, and ADRs. Read before your first commit. |
| [`glossary.md`](glossary.md) | The shared vocabulary. Skim it; come back constantly. |
| [`facts/`](facts/) | Facts collected from the customer, stored as-is as immutable evidence. Derived requirements cite them by `F-NNNN` ID. |
| [`prd/`](prd/) | Product Requirements Documents, derived from the facts; each `REQ`/`NFR` cites an `F-NNNN` fact. |
| [`issue-workflow.md`](issue-workflow.md) | The issue-first rules (R1–R12): the ticket policy the gate assumes. |
| [`tasks/backlog.md`](tasks/backlog.md) | What to work on next. |

### What to read next, in order

0. [`AGENTS.md`](../AGENTS.md) — the one-page summary, if you are a coding agent
   (or a human who wants the shape before the detail).
1. [`engineering-discipline.md`](engineering-discipline.md) — how we work.
2. [`issue-workflow.md`](issue-workflow.md) — the issue-first rules the gate assumes.
3. [`glossary.md`](glossary.md) — skim, then reference.
4. [`guardrails.md`](guardrails.md) — the pitfalls and the frozen numbers.
5. [`tasks/backlog.md`](tasks/backlog.md) — what needs doing.

### Where the project stands

`‹A short, honest status: what is built, what is in progress, and what the open
question is. Keep this in step with the backlog and the headline numbers above.›`
