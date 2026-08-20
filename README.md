# Engineering Discipline Kit

> A domain-free scaffold for running a new software project with discipline — the
> "how we work," ready to compose onto any domain.

**What this is.** This repository is a generic **template**, not a product. It gives
a new project a ready-made engineering-discipline system — a quality gate,
guardrails, ADRs, a glossary, a customer-facts convention, and a task backlog — that
you adapt to your domain and grow over time.

## Start here

1. **[`onboarding-for-engineers.md`](onboarding-for-engineers.md)** — read this first
   (~30 min). It states the [Problem statement](onboarding-for-engineers.md#1-problem-statement)
   and teaches the project's vocabulary.
2. **[`engineering-discipline.md`](engineering-discipline.md)** — how we work: the
   quality gate every substantive task passes, plus branches, tests, reviews, and
   ADRs. Read before your first commit.

## What's inside

| Piece | What it holds |
|-------|---------------|
| [`onboarding-for-engineers.md`](onboarding-for-engineers.md) | The first door: the problem statement and a domain crash course. |
| [`engineering-discipline.md`](engineering-discipline.md) | The quality gate and every working practice. |
| [`glossary.md`](glossary.md) | The shared vocabulary the other docs assume. |
| [`guardrails.md`](guardrails.md) | Known pitfalls, pre-registered pass/fail rules, and validation. |
| [`adr/`](adr/) | Architecture Decision Records — the *why* behind structural choices. |
| [`facts/`](facts/) | Raw customer facts kept as immutable evidence, and the citation convention that derives requirements from them. |
| [`tasks/`](tasks/) | The task index — [`backlog.md`](tasks/backlog.md) and [`completed.md`](tasks/completed.md). |

## Using it as a template

This kit is a **scaffold to compose onto a new domain.** Every document is generic:
it ships with `‹…›` markers for the values only you can supply, and a "How to adapt"
note you delete once the real content is in. The kit itself stays domain-free, so the
same discipline drops onto any project — you add the domain, not the process.

To stand up a new project:

1. Copy the kit into your repository (or use it as a GitHub template).
2. Follow **[How to adapt this kit](engineering-discipline.md#how-to-adapt-this-kit)** —
   set the project-wide values (test runner, evidence store, task-ID scheme, worktree
   directory) and fill the sibling documents.
3. Search for `‹` to find everything still unfilled; delete every "How to adapt" note
   when the real content is in.
4. Grow it — each new practice gets its own short section, with a fuller reference
   document where one earns its place.
