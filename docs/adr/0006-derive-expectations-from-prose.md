# 0006. Keep deriving expectations from the prose, not from declared metadata

Date: 2026-08-31

## Status

Accepted. Amended by [ADR-0007](0007-link-coverage-belongs-to-link-lint.md)

## Context

[ADR-0005](0005-independent-review-may-be-an-agent.md) closed one half of a review
recommendation and left the other open. The recommendation, made against
[#58](https://github.com/pharzam/armature/issues/58), was that
[`agents/agents-lint.sh`](../agents/agents-lint.sh) — 1051 lines — should replace
its custom shell parsing with **a real Markdown parser or structured metadata**.
The parser half was rejected there: it spends the zero-toolchain POSIX `sh`
property that lets the discipline tests be an adopter's first test. The metadata
half does not spend that property, so it stayed open as its own task.

The linter works by **deriving** what it expects at run time from the documents
already in the tree — the gate steps from
[`engineering-discipline.md`](../engineering-discipline.md), the rules and their
anchors and titles from [`issue-workflow.md`](../issue-workflow.md), which rules a
mechanism backs from that document's enforcement table, and the shipped-check set
from the file tree. Nothing is hardcoded, so the linter can never become a second
source of truth. The proposal was to have the documents **declare** that structure
instead, so the linter reads a declaration rather than parsing prose.

The question was measured rather than argued, and then an independent reviewer was
briefed to build the strongest case **for** adoption, because a rejection that only
ever heard its own case is not a decision.

**Where the file's size actually is.** Of 1051 lines: 389 comment, 45 blank, **617
code**. The script reads a source document in exactly three places — 9 code lines
for the gate steps, 10 for the rules, 30 for the enforcement table: **49 lines,
7.9% of the code**. Eleven of those 30 are `mech()`, which returns *three* answers
so an unrecognised cell is reported rather than guessed in either direction; that
is semantic care, not parsing, and it survives any serialisation. The realistic
ceiling for metadata is **~38 lines: 6.2% of the code, 3.6% of the whole file**.
Both denominators are given because quoting the parsing share against *code* and
the ceiling against the *file* would flatter the conclusion; it holds either way.

The premise was that the size lives in the parsing. It does not. The largest
assertions are link resolution (65 code lines), entry-point discoverability (54)
and the sources-of-truth table (46), and violations are reported from **49 call
sites** — 48 naming an assertion id literally, plus one at `agents-lint.sh:316`
passing the id in a variable. That figure is given with its method because an
unqualified count of it is method-sensitive: an independent re-derivation of this
ADR reached 49 where a first pass said 50, and a third method 48. The file is long
because it explains itself and reports honestly. Metadata touches none of that.

## Decision

We will **keep deriving expectations from the prose**, and will not add a
declared-metadata layer to the linted documents.

The saving is 3.6% of the file. It does not justify a new format in documents an
adopter copies and edits.

We reject two specific proposals, and record what defeated each, so neither is
re-opened without new information:

- **A general metadata layer** — front matter, a generated index, an anchor/ID
  table. Measured ceiling ~38 code lines, against the cost of a second thing to
  keep true.
- **A substitutive per-rule `Mechanism:` field** replacing the enforcement table,
  proposed by the advocating reviewer as the strongest available shape. It is
  **structurally lossy against the table it would replace.** That table is keyed
  by *concern*, not by rule: four of its nine rows name no numbered rule at all
  (two name a section of `engineering-discipline.md`, two name ADRs), `R1` appears
  in **two** rows with different mechanisms — a `pre-push` hook for direct pushes,
  a CI check for PR links — and one row names `R5` *and* a document together. A
  field hanging under a `## R<n>` heading can express none of that without
  discarding rows or collapsing distinct enforcements.

We accept one correction the advocate made to our own reasoning, and record it
because a decision defended by a bad argument is fragile:

> The rejection was first argued as a trilemma — metadata must either sit beside
> the prose (a second source of truth), be generated from it (the parser moves
> into a generator), or generate it (documents become build outputs). **That
> trilemma was incomplete.** It assumed metadata is *additive*. A **substitutive**
> arrangement, where metadata replaces a piece of prose formatting rather than
> joining it, is a genuine fourth option and creates no drift surface. The
> proposal above is rejected on the table's *shape*, not on the trilemma.

We also correct one claim made **for** adoption, in the same spirit. The advocate
argued that a row naming the wrong rule is invisible to the current parser. It is
invisible to the parser **in isolation**, but not to the system: `A18` cross-checks
the derived set against `AGENTS.md`'s ` (written rule)` markings **in both
directions**, so a mis-attributed row flips two rules' expected markings and turns
the gate red. The error class the proposal would remove is already caught.

## Consequences

`agents-lint.sh` keeps its three derivation blocks. A heading rename in a source
document still turns the gate red rather than leaving a stale summary agreeing with
a stale linter, which is the property the whole design exists for.

The measurement is now on the record, so "the linter is too big, use metadata" is
answered with numbers rather than re-litigated. Re-opening this needs **new
information** — a materially different metadata shape, or a linter grown large
enough that 3.6% becomes worth a format.

**The real saving available is elsewhere, and larger.** `A19` spends 65 code lines
resolving `AGENTS.md`'s own links. [`link-lint.sh`](../links/link-lint.sh), shipped
after this linter, resolves in-tree links and anchors **tree-wide** across four link
forms, and the root `AGENTS.md` is in its file list. That is a bigger reduction than
the entire metadata proposal's ceiling — 65 lines against 38 — with no new format
and no drift surface. It is **not** a clean deletion: `A19` carries a *per-file*
coverage floor, and `link-lint`'s floor is tree-wide and would not notice
`AGENTS.md` losing every link. Deduplicating two checks is a different goal from
choosing a format, so it is
[its own issue](https://github.com/pharzam/armature/issues/67) under R11 rather than
work smuggled into this decision.

One sub-proposal is rejected on cost rather than on principle, and may be revisited:
replacing the spelled counts (`**eight** ordered steps`) with digits would delete
the `NUMBER_WORDS` / `word_to_int` / `beyond_vocabulary` machinery, about 21 lines.
It is refused here because it changes the prose style of governance documents to
suit a linter, and because it is a second goal. The advocate rated it the weaker
half of its own case.
