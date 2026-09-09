# T-7zjv — Give the decisions archive its own `D-`prefixed identifier sequence

Tracks [issue #180](https://github.com/pharzam/armature/issues/180). Completed line:
[completed.md](completed.md). Plan and its independent review are recorded on the
issue thread (R12).

## Why

[#160](https://github.com/pharzam/armature/issues/160) split the kit's own
governance decisions into [`docs/decisions/`](../decisions/README.md) and had them
keep their original filenames (`0005`–`0012`) as provenance, cited **by path**, with
a bare `ADR-NNNN` meaning the living [`docs/adr/`](../adr/README.md) sequence. That
held only while the living sequence stopped at `0004`. It stopped holding once the
living sequence reached `0005` and `0006`: two records now sit at each of those
numbers, separated only by an unenforced "cite the archive by path" discipline — and
that discipline has already failed on `main` (a false bare reference). The starting
digit does not separate two sequences; a **namespace** does.

## What

Option 1 of the issue: give the archive a **prefixed, zero-based** sequence
`D-0000`–`D-0007`, so no number is ever shared with the living ADRs, now or as either
grows — and the archive gains the ability to be cited **by identifier**, retiring the
fragile by-path-only discipline. A mapping table preserves every old→new pair for the
external references (commit messages, closed threads) that cannot be rewritten.

The rename forces edits inside closed archived bodies (their cross-links repoint and
their visible identifiers re-identify). This is a **third, wider** recorded exception
to body-immutability — one axis beyond the two the kit already recorded — meaning it
changes the visible identifier, not only a path; it is meaning-preserving and revises
no decision. A new archive record `D-0008` records it and **amends** the split
record's numbering clause **and** its immutability-exception clause.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card (this file) and a pre-registered acceptance grep.
2. Classify every occurrence by link target in three buckets — living (keep),
   archive (rewrite identifier + path), historical prose naming a literal old token
   (leave unchanged).
3. Rename the eight records; repoint every intra-archive cross-link; renumber the
   [`decisions/README.md`](../decisions/README.md) index and add the mapping table.
4. Sweep the external path references and the archived bare mentions; correct the
   false reference in the audit; leave every living reference untouched.
5. Write `D-0008`; set the split record's Status to `Accepted. Amended by D-0008`;
   rewrite the citation clause in **both** READMEs so they agree (R10); add a
   [glossary](../glossary.md) entry for the new identifier form.
6. Run every discipline check and the acceptance grep; run independent decay review
   rounds on a frozen head.
7. Close out: move this task's line to [`completed.md`](completed.md), write back the
   task's lesson to [`guardrails.md`](../guardrails.md) §2, tick the DoD, write the
   verdict, and open the kept-surface-neutralisation follow-up issue.

## Definition of Done

See the acceptance criteria on [issue #180](https://github.com/pharzam/armature/issues/180).
The load-bearing ones: every archived record shares no number with the living
sequence; a mapping table exists; all path references resolve and `link-lint` passes;
every bare mention is classified and only the archived ones are rewritten (the living
`ADR-0005`/`ADR-0006` citations in `AGENTS.md` and `engineering-discipline.md` stay);
the false reference is corrected; the citation clause in both READMEs states the new
scheme and they agree; `D-0008` amends the split record's numbering and immutability
clauses; the new identifier form earns a glossary entry; and a grep for the old bare
forms returns only the mapping table and intended historical prose.

## The kept-surface follow-up (R11)

Renaming updates the token on the surfaces an adopter keeps (`review-record-lint.sh`,
`run-discipline-tests.sh`, both review-record CI workflows), so their citations stay
true under the new scheme. **Neutralising** their dependency on the deletable archive
— making them self-contained — is a different fix with a different test and opens its
own issue, a fourth residual class after
[#164](https://github.com/pharzam/armature/issues/164) →
[#166](https://github.com/pharzam/armature/issues/166) →
[#167](https://github.com/pharzam/armature/issues/167).
