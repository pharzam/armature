# Glossary

Terms, abbreviations, and short definitions for this project. This is the shared
vocabulary the rest of the docs assume. It is the target of the
[Glossary](engineering-discipline.md#glossary) rule, which has two parts. First: any
change that adds a term, renames one, or changes a meaning updates this file in the
same change. Second — **No undefined abbreviation**: every abbreviation used in any
conversation, context, prompt, reply, or response must have an entry here, and any
LLM or operator who uses one that is missing adds it in the same turn. General-English
abbreviations (`e.g.`, `i.e.`, `etc.`) are exempt unless they carry a
project-specific meaning.

> **How to adapt this file.** The **Kit vocabulary** section below is real content —
> it defines the abbreviations these discipline docs themselves use, so keep it.
> Everything after it is skeleton: keep the format, then fill the domain sections with
> your own terms and rename the sections to match your domain. Delete this note once
> your own terms are in.

## The format — three columns, plus two rules

Each entry is a row in a table:

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹abbr or —›` | `‹one or two sentences. State what it is and why it matters here.›` | `‹a concrete instance that makes it real›` |

Two rules keep the glossary earning its place:

1. **Collision to watch for.** When a term means something different outside this
   project — in a common library, a neighbouring team, or the wider field — say so
   in the Description, in the form "Collision to watch for: …". A word that quietly
   means two things is worse than an unknown word.
2. **Quick-reference table.** Keep the whole glossary skimmable. If it grows past
   what a reader can scan, add a short quick-reference table at the top with just
   Term and one-line meaning, and keep the full entries below.

## Kit vocabulary — the abbreviations these discipline docs use

These are defined here because the kit's own documents use them. Keep this
section as-is; add your domain terms in the sections below.

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| Large Language Model | `LLM` | A machine-learning model that generates and transforms natural-language text. In this kit it is one of the two operator classes the rules bind, alongside the human operator. | An AI assistant that edits these docs must add any abbreviation it uses to this glossary in the same turn. |
| Architecture Decision Record | `ADR` | A short, numbered document that records one architecturally significant decision and its context. Stored under [`adr/`](adr/). | [`adr/0001-record-architecture-decisions.md`](adr/0001-record-architecture-decisions.md) records the decision to use ADRs. |
| Continuous Integration | `CI` | The automated pipeline that builds the project and runs its checks on each change. Collision to watch for: in statistics and machine-learning writing, "CI" usually means *Confidence Interval* — state which you mean. | The cheap validation checks in [`guardrails.md`](guardrails.md) are the ones worth wiring into CI so they run on every change. |
| Facts Document | `—` | A record under [`facts/`](facts/) that stores one customer's requirements or statements as-is, word for word, as immutable evidence. Carries a stable `F-NNNN` ID that derived requirements cite. Collision to watch for: not a data-warehouse "fact table" — this is a source document, not a database row. | `F-0007#3` cites the third fact in facts document `F-0007`; a requirement written from it names that ID. |
| Simplified Technical English | `STE` | A controlled subset of English — the ASD-STE100 standard — with a limited vocabulary and short, active sentences, used for unambiguous technical writing. In this kit it is the language of the derived requirements written from [facts documents](facts/). Collision to watch for: not the same as a [plain-language summary](engineering-discipline.md#plain-language-summaries) — STE is a formal standard, a plain-language summary is just jargon-free prose. | The requirements derived from `F-0007` are written in STE: short, active sentences drawn from the approved word list. |

## 1. `‹Domain area one›`

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹—›` | `‹definition›` | `‹example›` |

## 2. `‹Domain area two›`

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹—›` | `‹definition›` | `‹example›` |
