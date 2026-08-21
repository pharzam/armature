<p align="center">
  <img src="assets/armature-logo.jpg" width="360"
       alt="Armature logo: a low-poly human figure rendered as a wireframe armature, ringed by the kit's icons — a shield, documents, a book, a person, and a checklist.">
</p>

# Armature

*The engineering-discipline kit.*

> A domain-free scaffold for running a new software project with discipline — the
> "how we work," ready to compose onto any domain.

**What this is.** This repository is a generic **template**, not a product. It gives
a new project a ready-made engineering-discipline system — a quality gate,
guardrails, ADRs, a glossary, a customer-facts convention, and a task backlog — that
you adapt to your domain and grow over time.

## About the name

**Armature** — say it *AR-mə-chər* (`/ˈɑːr.mə.tʃər/`), three syllables: *ar·ma·ture*.
In sculpture, an armature is the internal wire-and-metal frame a figure is built
around: the skeleton holds the shape, and the clay goes on top. This kit is that
skeleton for a software project — it holds the engineering discipline, and your
domain is the clay you add.

The word traces to Latin *armatura*, "armor, equipment," from *armare* "to arm"
(from *arma*, "weapons, tools") — the same root as *arm* and *armor*. An armature is
the frame that gives a thing its strength.

## Start here

1. **[`docs/onboarding-for-engineers.md`](docs/onboarding-for-engineers.md)** — read this first
   (~30 min). It states the [Problem statement](docs/onboarding-for-engineers.md#1-problem-statement)
   and teaches the project's vocabulary.
2. **[`docs/engineering-discipline.md`](docs/engineering-discipline.md)** — how we work: the
   quality gate every substantive task passes, plus branches, tests, reviews, and
   ADRs. Read before your first commit.

## What's inside

| Piece | What it holds |
|-------|---------------|
| [`docs/onboarding-for-engineers.md`](docs/onboarding-for-engineers.md) | The first door: the problem statement and a domain crash course. |
| [`docs/engineering-discipline.md`](docs/engineering-discipline.md) | The quality gate and every working practice. |
| [`docs/glossary.md`](docs/glossary.md) | The shared vocabulary the other docs assume. |
| [`docs/guardrails.md`](docs/guardrails.md) | Known pitfalls, pre-registered pass/fail rules, and validation. |
| [`docs/adr/`](docs/adr/) | Architecture Decision Records — the *why* behind structural choices. |
| [`docs/facts/`](docs/facts/) | Raw customer facts kept as immutable evidence, and the citation convention that derives requirements from them. |
| [`docs/tasks/`](docs/tasks/) | The task index — [`backlog.md`](docs/tasks/backlog.md) and [`completed.md`](docs/tasks/completed.md). |

## Using it as a template

This kit is a **scaffold to compose onto a new domain.** Every document is generic:
it ships with `‹…›` markers for the values only you can supply, and a "How to adapt"
note you delete once the real content is in. The kit itself stays domain-free, so the
same discipline drops onto any project — you add the domain, not the process.

To stand up a new project:

1. **Start with a clean history.** Your project is a *new* repository, not a fork
   of the kit — it must not keep Armature's git history or remote. Two paths give
   you that for free: click **Use this template** on GitHub, or run
   `npx degit pharzam/armature my-project`. If you already cloned, detach by hand —
   deleting `.git` clears Armature's history and its remote in one move:

   ```bash
   rm -rf .git            # drop Armature's history and remote
   git init && git add -A
   git commit -m "chore: initialize from Armature kit"
   git remote add origin git@github.com:you/my-project.git
   ```

   To pull kit improvements later, keep the link as `upstream`, never `origin`.
2. Follow **[How to adapt this kit](docs/engineering-discipline.md#how-to-adapt-this-kit)** —
   set the project-wide values (test runner, evidence store, task-ID scheme, worktree
   directory) and fill the sibling documents.
3. Search for `‹` to find everything still unfilled; delete every "How to adapt" note
   when the real content is in.
4. Grow it — each new practice gets its own short section, with a fuller reference
   document where one earns its place.
