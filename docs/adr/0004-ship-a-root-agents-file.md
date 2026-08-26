# 0004. Ship a root AGENTS.md as the agent entry point

Date: 2026-08-26

## Status

Accepted

## Context

The kit's rules bind "all LLMs and all human operators" — the
[glossary rule](../engineering-discipline.md#glossary) says so outright, and
[R6](../issue-workflow.md#r6--agent-to-agent-communication-through-the-issue)
governs how agents talk to one another. Yet the kit shipped no file that an agent
loads by default.

The entry point was
[`onboarding-for-engineers.md`](../onboarding-for-engineers.md), which opens by
asking for half an hour of reading. A human joining a team can spend that. An agent
starting a task does not read it unless a person names it, and a fresh context
starts again from nothing on the next task.

The result: roughly 20,000 words of rules written *about* agents, and nothing
written *for* them. Every rule the kit cares about — the worktree, the test freeze,
red-then-green, never squashing — depended on an operator pasting the right
document into the right session. That is the failure mode
[`guardrails.md`](../guardrails.md) already names for a gate nobody runs.

A root context file has become the common way to close this: agent tooling looks
for a small number of well-known filenames at the repository root and loads what it
finds.

## Decision

We will ship a root **`AGENTS.md`**, under 1,500 words, condensing the
[quality gate](../engineering-discipline.md#working-a-task-under-the-quality-gate)
and [R1–R12](../issue-workflow.md) into agent-facing form, and naming the `‹…›`
values an adopter must fill.

A root **`CLAUDE.md`** holds a pointer to it and nothing else, because some tools
look for that name instead.

`AGENTS.md` is a **summary, not an authority.** It says so in its own second
paragraph: where it disagrees with the document it summarises, the document wins,
and the disagreement is a defect to fix in the same change under
[R10](../issue-workflow.md#r10--sync-with-governance).

We rejected three alternatives:

- **`CLAUDE.md` alone.** It names one vendor. The kit refuses to name a forge, a
  language, or a test runner; naming an agent vendor as the only entry point breaks
  the same principle.
- **A symlink from `CLAUDE.md` to `AGENTS.md`.** It removes the duplication, but
  breaks on Windows checkouts and in tools that read the blob rather than follow
  the link. A two-line pointer costs less than a portability trap.
- **Generating `AGENTS.md` from the documents at build time.** This removes drift
  properly, but needs a toolchain the kit refuses to assume — the discipline tests
  are POSIX shell precisely so a project has tests before it has a build.

## Consequences

**What becomes easier.** An agent picks up the rules without a person pasting them.
A fresh context — the thing [R9](../issue-workflow.md#r9--test-freeze-after-confirmation)
and the review rounds depend on — starts from the same place every time.

**What becomes harder, and the honest cost.** There are now two descriptions of the
same rules, and duplication drifts. The precedence rule above limits the damage but
does not prevent it.

The mitigation is a **drift check** in
[#19](https://github.com/pharzam/armature/issues/19): a discipline test asserting
that `AGENTS.md` covers every gate step and every R-number. Its limit should be
stated plainly rather than discovered later — **it tests coverage, not agreement.**
It can prove that `AGENTS.md` mentions R9; it cannot prove that what it says about
R9 is still true. Agreement stays a review question, and
[R10](../issue-workflow.md#r10--sync-with-governance) is the rule that makes it
one.

We accept that trade because the failure rates are not comparable: an agent-facing
file that does not exist fails every time, while one that drifts fails
occasionally, visibly, and in a way a reader can correct.

**What this creates.** Every change to the gate or to R1–R12 now has a second file
to update in the same change. That obligation is added to
[R10](../issue-workflow.md#r10--sync-with-governance)'s list of governing
documents.
