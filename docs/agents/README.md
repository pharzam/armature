# Agent entry points

The repository's two root instruction files, and the convention they follow. The
decision behind them is [ADR-0004](../adr/0004-ship-agent-entry-points.md).

| File | What it is |
| ---- | ---------- |
| [`AGENTS.md`](../../AGENTS.md) | The vendor-neutral agent guide, loaded at the repository root. A short, accurate index and summary of the rules an operator must know before changing this repository. |
| [`CLAUDE.md`](../../CLAUDE.md) | The Claude Code compatibility entry point. Exactly one line, `@AGENTS.md`, so the same guide loads with no second copy that can drift. |

## In plain terms

> Every human and every language model that changes this repository has to follow
> its quality gate, but nothing told a coding agent where the rules were when it
> started work. `AGENTS.md` is that one short guide, and `CLAUDE.md` points Claude
> Code at the same file. The long documents stay in charge; this is an index to
> them.

## The source-of-truth boundary

`AGENTS.md` is a **summary and an index, not a governance document.** For every
class of rule, a document under [`docs/`](../) is authoritative, and `AGENTS.md`
says which one in its own `## Sources of truth` table. Two consequences:

- **A conflict is a defect, not a choice.** Where `AGENTS.md` disagrees with the
  document it summarises, the document wins, and the disagreement is fixed in the
  same change — [R10](../issue-workflow.md#r10--sync-with-governance).
- **A rule with no source does not belong in it.** Summarising a rule that exists
  nowhere else would make `AGENTS.md` the source of truth for that rule, which is
  exactly the boundary this file draws. That is why the safety boundary was
  written into [`engineering-discipline.md`](../engineering-discipline.md#safety-limits)
  first, and only then summarised.
