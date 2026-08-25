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
| [`docs/issue-workflow.md`](docs/issue-workflow.md) | The issue-first workflow (R1–R11): the ticket policy the gate assumes. |
| [`docs/glossary.md`](docs/glossary.md) | The shared vocabulary the other docs assume. |
| [`docs/guardrails.md`](docs/guardrails.md) | Known pitfalls, pre-registered pass/fail rules, and validation. |
| [`docs/adr/`](docs/adr/) | Architecture Decision Records — the *why* behind structural choices — plus [`adr-lint.sh`](docs/adr/adr-lint.sh), the discipline test that keeps them honest. |
| [`docs/facts/`](docs/facts/) | Raw customer facts kept as immutable evidence, and the citation convention that derives requirements from them. |
| [`docs/prd/`](docs/prd/) | Product Requirements Documents derived from the facts, plus [`prd-lint.sh`](docs/prd/prd-lint.sh), the discipline test that keeps them honest. |
| [`docs/tasks/`](docs/tasks/) | The task index — [`backlog.md`](docs/tasks/backlog.md) and [`completed.md`](docs/tasks/completed.md). |
| [`.githooks/`](.githooks/) | Git hooks that enforce the cheap gate locally — a commit-message check and a pre-commit runner. Install with `git config core.hooksPath .githooks`. |
| [`docs/ci/`](docs/ci/) | Optional CI templates (GitHub Actions and GitLab CI) that run the same gate on every PR. Inert until you copy one into place. |
| [`docs/templates/`](docs/templates/) | Optional, inert GitHub/GitLab issue and PR templates that embody the issue-first workflow. Inert until you copy them into place. |

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

   The scaffold is a one-time copy, not a dependency: your project keeps no link
   back to Armature — no `upstream` remote, no fork relationship. Adopt any later
   kit improvements by hand, if and when you want them.
2. Follow **[How to adapt this kit](docs/engineering-discipline.md#how-to-adapt-this-kit)** —
   set the project-wide values (test runner, evidence store, task-ID scheme, worktree
   directory) and fill the sibling documents.
3. **Turn on enforcement.** Install the git hooks with
   `git config core.hooksPath .githooks`, fill their `‹…›` steps, and — if you use
   GitHub or GitLab — activate CI by copying a template from
   [`docs/ci/`](docs/ci/) into place. This makes the quality gate self-enforcing;
   the [ADR linter](docs/adr/adr-lint.sh) and [PRD linter](docs/prd/prd-lint.sh)
   run green out of the box.
4. Search for `‹` to find everything still unfilled; delete every "How to adapt" note
   when the real content is in.
5. Grow it — each new practice gets its own short section, with a fuller reference
   document where one earns its place.
