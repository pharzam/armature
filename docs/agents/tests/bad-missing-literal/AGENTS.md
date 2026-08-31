# AGENTS.md

Agent context for this demonstration root. Read it before any other file here.

## What this repository is

A miniature root used only to test the entry-point linter. It ships no product code
and no product application, so nothing here builds, runs, or needs a toolchain.

## How these instructions rank

A platform instruction of higher priority stays higher priority than this file. The
documents under `docs/` stay authoritative for their own subject. A nested
instruction file may add a local constraint, and may never weaken the gate.

## Start here

Read [`docs/engineering-discipline.md`](docs/engineering-discipline.md) first, then
[`docs/issue-workflow.md`](docs/issue-workflow.md), and come back to this file. The
layout of this root is the table under Sources of truth, written once.

## The quality gate

Every task passes **three** ordered steps. Before step 1 an issue is open, and the
work is sliced into an ordered plan reviewed once and recorded on the issue.

1. **Alpha.** The first demonstration step, which isolates the work before it starts.
2. **Beta.** The second demonstration step, which writes the failing test first.
3. **Gamma.** The third demonstration step, which closes the task out in one change.

## The issue rules

The workflow defines **three** numbered rules. The honest account of what a
mechanism backs today is [that table](docs/issue-workflow.md#what-is-enforced-where),
not this file.

- **R1** — [Alpha rule](docs/issue-workflow.md#r1--alpha-rule): open an issue before any commit lands.
- **R2** — [Beta rule](docs/issue-workflow.md#r2--beta-rule): search the open and the closed issues first (written rule)
- **R3** — [Gamma rule with a deliberately long title](docs/issue-workflow.md#r3--gamma-rule-with-a-deliberately-long-title): record the chosen option and the rejected ones (written rule)

## Checks you can run

Run these from this root. They read only text, so they need no toolchain and no
setup step.

```
sh docs/stub/demo-lint.sh
```

This root has no product test suite and no product toolchain, so no product command
is invented here.

## Branches, worktrees, commits, and pull requests

Work in a per-task git worktree branched off the default branch, never in the
operator's own checkout. Commit messages follow Conventional Commits. The pull
request body links its issue with `Closes #N`, and the branch lands by a plain merge.

## The task index

One line per task in `docs/tasks/backlog.md`, moved to `docs/tasks/completed.md` by
the same pull request that lands the work. Any detail belongs in the task's own
file, never in either index.

## Placeholders and adopter values

Every ‹marker› in this root is unfilled on purpose. Never replace one with a guess,
never invent an adopter's command or path, and never delete a marker to make a
check pass.

## Safety limits

Do not commit secrets and do not expose sensitive data. Do not rewrite published
history, and do not run a destructive or irreversible operation without explicit
authorization — see [the gate](docs/engineering-discipline.md).

## Decisions and questions

Record the plan, the chosen option, the rejected alternatives, the tradeoffs and
the evidence on the issue. Ask another operator on the issue thread, with a
severity, never directly.

## Sources of truth

| Document | Authoritative for |
|----------|-------------------|
| [`docs/engineering-discipline.md`](docs/engineering-discipline.md) | The quality gate and every working practice in this root. |
| [`docs/issue-workflow.md`](docs/issue-workflow.md) | The numbered rules, and what a mechanism backs today. |
| [`README.md`](README.md) | What this demonstration root holds, and where a reader starts. |

## Keeping this file honest

`docs/agents/agents-lint.sh` derives its expectations from the documents above, so a
renamed rule turns the gate red. It proves coverage, not semantic agreement, so a
reviewer still reads the wording.
