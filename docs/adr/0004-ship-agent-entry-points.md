# 0004. Ship agent entry points

Date: YYYY-MM-DD

## Status

Accepted

## Context

The kit binds **every operator — each human and each LLM coding agent** — to its
[quality gate](../engineering-discipline.md#working-a-task-under-the-quality-gate)
and to the twelve rules in [`issue-workflow.md`](../issue-workflow.md). Those
documents are complete and authoritative. What the repository did not have was a
file an agent **loads at startup**, at the root, where a coding tool looks. The
gap was never the rules; it was discoverability at the moment work begins.

Three forces shaped the decision.

**The kit is vendor-neutral and forge-free.** It already ships forge-specific
issue and pull-request templates *inert* under [`../templates/`](../templates/),
to be copied into place only when a project adopts that forge. The audit record
reasoned from that pattern to the opposite conclusion of this record: finding K6
in [`../tasks/T-3v9q.md`](../tasks/T-3v9q.md) — verdict *Stands* — says "the kit's
own pattern is to ship tool-specific files inert under `docs/templates/` … so that
is where one belongs." [R10](../issue-workflow.md#r10--sync-with-governance) says
a conflict between governance documents stops work until a decision note or an ADR
resolves it. **This record is that resolution.** The pattern does not transfer:
an inert copy is never loaded at agent startup, and startup discoverability is the
entire gap. `docs/templates/` exists for files that change a forge's live
behaviour the moment they land; a root instruction file changes nothing but what a
reader is told.

**A summary can drift from its source.** Any short guide is a second telling of
rules that live elsewhere. Left unchecked it goes stale silently, and a stale
instruction file is worse than none — an agent follows it confidently.

**The number 0004 has a history.** `origin/backup/pre-r12-reset-999765f` carries
an `Accepted` `0004-ship-a-root-agents-file.md`; `origin/archive/issue-16` carries
a different `0004-destroying-history-on-the-default-branch.md`; `main` carried
neither, because a branch reset removed them. This record is a third, different
decision at that number, taken deliberately rather than by restoring either.

## Decision

We will ship **two root files**, and one deterministic check over them.

**`AGENTS.md` (plural) is the entry point.** It is the vendor-neutral guide the
widest set of coding agents already look for. We reject a root `AGENT.md`
(singular): it is not the established cross-tool filename, and shipping both would
give an agent two competing sources of instruction with no rule about which wins.
The check asserts that `AGENT.md` does not exist.

**`CLAUDE.md` holds exactly one line, `@AGENTS.md`.** The import gives Claude Code
the same guide with no second copy that can drift. We reject `CLAUDE.md` alone: it
serves one vendor and locks the kit to one company's convention. We reject a
symlink, which is less portable across platforms and tooling than a regular file,
and generated instructions, which need a toolchain and hide where a rule came
from. We also reject a full copy of the governance documents: it would exceed
useful startup context and create a second source of truth. Any further vendor
entry point is a separate decision with its own compatibility test.

**Instruction precedence is stated in the file itself.** A higher-priority
platform or operator instruction stays higher priority. Within its scope this file
governs work in this repository. The documents under [`../`](../) remain
authoritative for their own subject. A future nested instruction file may add a
local constraint and may **never** weaken the quality gate; a conflict stops work
until an ADR or a decision note resolves it.

**The source-of-truth boundary is explicit.** `AGENTS.md` is a summary and an
index, not a governance document. It names, in its own `## Sources of truth`
table, which document is authoritative for each class of rule. Where the two
disagree, the document wins and the disagreement is fixed in the same change under
R10. A rule that exists in no source document does not belong in the summary —
which is why the [safety limits](../engineering-discipline.md#safety-limits) and
the [agent entry points](../engineering-discipline.md#agent-entry-points) were
written into `engineering-discipline.md` first, and only then summarised.

**Drift is mitigated by derived expectations, not by a copied list.**
[`../agents/agents-lint.sh`](../agents/agents-lint.sh) reads the gate steps out of
`engineering-discipline.md`, the rules and their heading anchors and titles out of
`issue-workflow.md`, the mechanized-rule set out of that document's
[enforcement table](../issue-workflow.md#what-is-enforced-where), and the
shipped-check set out of the file tree. So a renamed rule, a new rule, a deleted
gate step or a newly shipped linter turns the gate **red**, rather than leaving
the summary and the check agreeing with each other and disagreeing with the kit.

## Consequences

- **An agent has one short, accurate first door**, and a human reader has one more
  index into documents that were already complete.
- **The check proves coverage, not semantic agreement.** It cannot prove that a
  compressed sentence means what its source paragraph means. That a summary is a
  *correct* summary stays a review responsibility, and the check's own
  documentation says so rather than implying more.
- **`AGENTS.md` is rigid.** Its heading sequence must *equal* a fixed list, and it
  may carry no other heading-shaped line — a `#` comment inside a fenced block
  included, because such a line ends the section above it and hides everything
  after it from every scoped check. Equality is deliberate: it is what makes "no
  extra section" true, and an ordered subsequence would reopen that hiding place.
  The kit already accepts this trade for its [ADR template](README.md), but this
  cost falls on **adopters**, who are the most likely to want a domain section of
  their own. Adding one means editing the check in the same change.
- **The check is the one in the kit that hard-fails on a slimmed repository.**
  `adr-lint.sh` exits 0 on an empty `adr/`, and the fixture runner skips an absent
  suite; `agents-lint.sh` fails when `AGENTS.md` is missing, because a check that
  skips its own subject proves nothing. An adopter who drops the entry points must
  drop them together — the two root files, `docs/agents/`, the hook step and the
  CI job — in one change. [`../agents/README.md`](../agents/README.md) documents
  that path.
- **Restoring the historical `0004-ship-a-root-agents-file.md` under its own
  number is now foreclosed.** Its content is superseded by this record, and the
  number is taken. The open backlog task about that collision is partly, not
  wholly, discharged: the branch-level duplication it describes still exists.
- **Two governance sections now exist that did not before** — `## Agent entry
  points` and `## Safety limits` in `engineering-discipline.md`. The second closes
  a real hole: before this change the kit prohibited nothing about secrets,
  sensitive data, history rewriting, or destructive operations. It had only a
  security *scan* placeholder, which is a check, not a rule.
