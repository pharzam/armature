# Agent entry points

The repository's two root instruction files, and the discipline test that keeps
them honest. The decision behind them is
[ADR-0004](../adr/0004-ship-agent-entry-points.md).

| File | What it is |
| ---- | ---------- |
| [`AGENTS.md`](../../AGENTS.md) | The vendor-neutral agent guide, loaded at the repository root. A short, accurate index and summary of the rules an operator must know before changing this repository. |
| [`CLAUDE.md`](../../CLAUDE.md) | The Claude Code compatibility entry point. Exactly one line, `@AGENTS.md`, so the same guide loads with no second copy that can drift. |
| [`agents-lint.sh`](agents-lint.sh) | The deterministic check over both files. Runs in the [`pre-commit` hook](../../.githooks/pre-commit) and in [CI](../ci/). |
| [`tests/`](tests/) | Its fixtures — one `good` case and a `bad-*` case for every assertion that can be given one (A25 cannot; several assertions have more than one). Run by [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh); [`tests/README.md`](tests/README.md) lists the cases and the gaps. |

## In plain terms

> Every human and every language model that changes this repository has to follow
> its quality gate, but nothing told a coding agent where the rules were when it
> started work. `AGENTS.md` is that one short guide, and `CLAUDE.md` points Claude
> Code at the same file. The long documents stay in charge; this is an index to
> them. A script checks that the guide still lists every gate step and every rule
> the long documents define — but it cannot check that the summary means the same
> thing, so a person still has to read it.

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

## Derive, or fail

[`agents-lint.sh`](agents-lint.sh) holds almost no expectation of its own. It
reads the gate steps out of [`engineering-discipline.md`](../engineering-discipline.md),
the rules and their heading anchors and titles out of
[`issue-workflow.md`](../issue-workflow.md), the mechanized-rule set out of that
document's [enforcement table](../issue-workflow.md#what-is-enforced-where), and
the shipped-check set out of the file tree.

So the check cannot become a second source of truth. A renamed rule, a new R13, a
deleted gate step, or a newly shipped linter at `docs/<dir>/<name>-lint.sh` turns
the gate **red** — rather than leaving `AGENTS.md` and the check agreeing with
each other and disagreeing with the kit.

Deriving was weighed against having the documents **declare** their structure as
machine-readable metadata, and kept — [ADR-0006](../adr/0006-derive-expectations-from-prose.md)
records the measurement. Reading a source document was **49 of this script's code
lines, 7.9%**; the file is long because it explains itself and reports honestly,
not because parsing is hard.

That measurement also found the larger saving, which was not a format change but a
duplication: `A19` resolved this file's links while
[`link-lint`](../links/link-lint.sh) resolved every file's. **A19 has since been
removed** ([ADR-0007](../adr/0007-link-coverage-belongs-to-link-lint.md),
[#67](https://github.com/pharzam/armature/issues/67)), taking about 78 lines with it. Its one non-redundant branch — rejecting an **absolute** target —
moved to `link-lint` as `L7`, where it now covers the whole tree instead of this
one file. Its number is not reused: the sequence runs A1–A18, A20–A26.

That glob is **one level deep**, which is a real limit: a check placed at
`docs/<dir>/<sub>/<name>-lint.sh`, or named in some other shape, is not seen and
so is not required to appear in the guide. The spelled counts (`**eight** ordered steps`, `**twelve** numbered
rules`) are the anti-truncation anchors: without them, deleting a step from the
source *and* from the summary in one change would leave the two agreeing.

## What it proves, and what it does not

It proves **presence, structure and coverage**. It does **not** prove **semantic
agreement** — that a compressed sentence means what its source paragraph means.
It checks coverage, not semantic agreement.

A stub carrying the right headings, the right anchors and titles, the right
literals and six filler words per item would pass every assertion. That a summary
is a *correct* summary, that the precedence text is right, that the sources table
maps each class of rule to the *right* document, that a command does what its
line claims, and that no `‹…›` marker was filled with a plausible guess, are all
review responsibilities — the [R12](../issue-workflow.md#r12--slice-and-prioritize)
plan review, the [blind review rounds](../engineering-discipline.md#reviewing-until-findings-decay),
and the fresh-context confirmation that freezes the tests under
[R9](../issue-workflow.md#r9--test-freeze-after-confirmation).

Two more limits, recorded rather than hidden. Abbreviations in `AGENTS.md` are not
linted against [`glossary.md`](../glossary.md), because the kit ships no glossary
linter — that stays a hand sweep. And the fixture harness compares only exit
codes, so nothing *recurring* proves a bad case still fails for its own assertion;
[`tests/README.md`](tests/README.md) documents the `EXPECT` loop that does, and
names the backlog tasks that own the gap.

## What it costs the author of `AGENTS.md`

Five constraints, each enforced by an assertion. They are real, and an adopter
meets them the first time it extends the file:

1. **The heading sequence must equal the required list exactly** — same headings,
   same order, no extra section. Equality, not presence: an unlisted section is
   content that belongs in a source document. Adding a section means editing
   `agents-lint.sh` in the same change, the way the [ADR template](../adr/README.md)
   and its linter already move together.
2. **No heading-shaped line beyond the title and those headings** — a `#` comment
   inside a fenced block included. A heading-shaped line ends the section above
   it, so anything after it would never be checked. Fenced blocks in `AGENTS.md`
   carry bare commands and no comments.
3. **Gate step 0 is prose, never `0. **Title**`.** The source states it in prose,
   so the derived step count is eight; a ninth numbered line would go red.
4. **The `## Sources of truth` table's second column header reads exactly
   `Authoritative for`** — that literal is what tells a header row from a data row.
5. **No HTML comment.** Text inside `<!-- … -->` is invisible to a reader but
   still counts toward the word budget, the section-body floor and the required
   literals, so a whole required section could be commented out with the gate
   still green. Same class of hole as constraint 2, closed the same way.

## Two different fives

Do not "fix" one of these to match the other; they are both correct.

- **Five discipline linters** — `adr-lint`, `prd-lint`, `pr-link-lint`,
  `audit-record-lint`, `agents-lint`. This is the count in
  [`engineering-discipline.md`](../engineering-discipline.md#testing) and
  [`test-levels.md`](../tests/test-levels.md).
- **Five repo-file checks** — `adr-lint`, `prd-lint`, `audit-record-lint`,
  `agents-lint`, `run-discipline-tests`. This is the set `AGENTS.md` lists under
  `## Checks you can run`, and the set the linter derives from the tree.
  `pr-link-lint` reads a pull-request body, so it has no local run and is
  excluded by construction.

Same size, different membership.

## If you slim the kit

`agents-lint.sh` **hard-fails** when `AGENTS.md` is absent. That is deliberate —
a check that skips its own subject proves nothing — but it makes this the first
check an adopter *inherits* that a smaller repository does not silently satisfy.
Compare [`adr-lint.sh`](../adr/adr-lint.sh), which exits 0 on an empty `adr/`, and
[`run-discipline-tests.sh`](../tests/run-discipline-tests.sh), which skips an
absent suite. ([`audit-record-lint.sh`](../tasks/audit-record-lint.sh) hard-fails
the same way, but it is specific to this repository's own audit record, so an
adopter deletes it rather than inheriting it.)

So if you drop the agent entry points, drop them together: delete `AGENTS.md`,
`CLAUDE.md`, this directory, the `pre-commit` step and the CI job in one change.
Keeping the check while deleting the guide is red on purpose.

## Run it

```
sh docs/agents/agents-lint.sh
sh docs/tests/run-discipline-tests.sh
```

Exit 0 is clean; exit 1 is one or more violations, each naming the assertion and
the section, heading, rule number, path or literal at fault; exit 2 is a usage
error. Pass a directory to lint a different root — that is how the fixtures run.
