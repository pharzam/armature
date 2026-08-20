# Customer facts

This directory holds the **facts documents** collected from the customer: the
requirements, statements, and domain facts the customer gave you. It is the
project's raw source of truth about what the customer said.

The convention has two layers. Each layer has one job. Do not merge them.

## The two layers

**Layer 1 — the raw facts, stored as-is (this directory).**
Each customer document is committed word for word. You do **not** paraphrase,
summarise, or rewrite the customer's words. You add only a provenance header —
who said it, when, and where it came from — so a later reader can trust the
record. This layer is **evidence**, and it obeys the same rule as any evidence in
this kit ([Honesty and evidence](../engineering-discipline.md#honesty-and-evidence)):
it stays untouched so a claim can be checked against the words that produced it.
A raw facts document is immutable once committed, exactly like an
[ADR](../adr/) — see [Correcting a facts document](#correcting-a-facts-document).

**Layer 2 — the derived requirements, written in your own words (elsewhere).**
Your clean requirements, glossary terms, and [ADRs](../adr/) are written *from*
the raw facts, in [Simplified Technical English](../glossary.md) and under the
[plain-language](../engineering-discipline.md#plain-language-summaries) rules.
Every derived statement **cites the raw fact it came from** by its ID (below).
This is where interpretation is allowed; the raw layer is where it is forbidden.

The result: the customer's exact words survive in Layer 1, your clean
requirements live in Layer 2, and the citation between them lets any reader trace
a requirement back to the fact that justifies it.

## Fact IDs — how a requirement points back

Each facts document gets a stable ID: `F-NNNN`, assigned once, never reused or
renumbered. Number the individual facts inside a document too, so a requirement
can cite one exact fact rather than a whole document:

- `F-0007` — the whole document.
- `F-0007#3` — the third numbered fact in that document.

A derived requirement then reads, for example: "The export runs nightly
(`F-0007#3`)." A reader follows the ID straight to the customer's own words.

> **Fact-ID scheme.** `F-NNNN` sequential mirrors the [ADR](../adr/) numbering and
> suits one collector working a session at a time. If several people or agents
> collect facts in parallel, switch to a random suffix instead — a sequential
> counter forces everyone to agree on "the next number" and they collide, the same
> trap the [backlog](../tasks/backlog.md) calls out for task IDs. Pick one scheme,
> state it here, and keep it.

## Adding a facts document

1. Copy [`template.md`](template.md) to `F-NNNN-short-slug.md`, using the next
   free ID.
2. Fill the provenance header: source, who collected it, the date, and the
   origin (meeting, email, call, or the original file).
3. Paste the customer's words into the body **unchanged**, one numbered fact per
   point. If the source is a file (a PDF, a spreadsheet), keep the original in the
   repo next to this record and link it from the header, so the record is complete.
4. Commit it. From here it is immutable.
5. Write or update the derived requirements in Layer 2, citing the new `F-NNNN`
   facts. Promote any new domain term into [`glossary.md`](../glossary.md) in the
   same change — the [glossary rule](../engineering-discipline.md#glossary) binds
   this work like any other.
6. Add the document to the [index](#index) below.

## Correcting a facts document

A raw facts document is immutable, because it is evidence. You do not edit the
customer's recorded words after the fact. If a fact was captured wrong, or the
customer later corrects it, add a **new** facts document that records the
correction and its date, and note the supersession in both records' headers — the
same immutable-record discipline the [ADRs](../adr/README.md) use. The original
stays, so the history of what the customer said, and when, is never lost.

## Index

| Fact doc | Source | Collected | Status |
| -------- | ------ | --------- | ------ |
| _none yet_ | | | |

<!-- Add one row per facts document as you collect them. Keep the newest at the bottom. -->
