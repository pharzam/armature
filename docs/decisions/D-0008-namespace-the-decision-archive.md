# D-0008. Give the decision archive its own prefixed identifier sequence

Date: 2026-09-09

## Status

Accepted

## Context

[D-0007](D-0007-split-adr-archive-kit-decisions.md) split this repository's own
governance decisions out of the constitution into `docs/decisions/` and, to keep
history legible, had them **keep their original `docs/adr/` filenames** (`0005`–
`0012`), cited **by path**, with a bare `ADR-NNNN` reserved for the living
`docs/adr/` sequence. That rule held only while the living sequence stopped short of
the archive's numbers. It stopped holding once the living sequence reached `0005` and
`0006`: two different records now sit at each of those numbers — a living
`ADR-0005`/`ADR-0006` in `docs/adr/` and an archived one here — and nothing but the
unenforced "cite the archive by path" discipline separates them. That discipline had
already failed on `main`: a bare `ADR-0005` in the audit resolved, by the stated
rule, to the wrong record. The living sequence grows, so the overlap only widens;
[#180](https://github.com/pharzam/armature/issues/180) measured it.

The starting digit is not what separates two sequences — a **namespace** is.
Renumbering the archive to start at zero *without* a prefix was measured worse: it
would triple the shared range, because eight records numbered from zero land almost
exactly on the range the living sequence already occupies.

## Decision

The archive carries a **prefixed, zero-based** identifier sequence, `D-0000`–`D-0007`,
mapped one-to-one from the former filenames:

| Former `docs/adr/` filename | Archive identifier | Title |
| --- | --- | --- |
| `0005` | `D-0000` | Independent review may be an agent |
| `0006` | `D-0001` | Keep deriving expectations from the prose |
| `0007` | `D-0002` | Link coverage belongs to link-lint |
| `0008` | `D-0003` | Stop the gate on a frozen head |
| `0009` | `D-0004` | Refocus on the adopter |
| `0010` | `D-0005` | Cut the self-facing checks |
| `0011` | `D-0006` | Fail on a missing named suite |
| `0012` | `D-0007` | Split docs/adr/: archive the kit's own governance decisions |

No number is shared with the living `docs/adr/` sequence, now or as either grows. The
archive is henceforth cited **by its `D-NNNN` identifier**, not only by path — which
retires the unenforced by-path discipline rather than leaning on it harder. A bare
`ADR-NNNN` still means the living sequence. The titled mapping is repeated for the
reader in [`README.md`](README.md).

**This record amends [D-0007](D-0007-split-adr-archive-kit-decisions.md) on two of its
clauses.** D-0007's directory split, its constitutional-reference rule and its
amendment trace stand unchanged; only these two are amended — so D-0007 keeps its
`Accepted` status with an `Amended by` pointer rather than being superseded, since the
split decision itself still holds.

1. **Its numbering clause is reversed.** D-0007 decided the archive keeps its
   `docs/adr/` filenames and is cited by path; this record renumbers it into the
   `D-NNNN` namespace and cites it by identifier. D-0007's numbering paragraph stays
   in place, unedited, as the dated record of the former policy.

2. **Its immutability-exception clause is extended a third time, and wider.**
   [D-0005](D-0005-cut-the-self-facing-checks.md) permitted demoting a link to a
   *deleted* file to a code-span; D-0007 permitted a **path-repoint of a moved link,
   the visible text unchanged**, and closed with "applied exactly twice … Nothing else
   in a landed body may change." Renaming the archive breaks that bound: every
   intra-archive cross-link and two living `docs/adr/` Status lines must
   **re-identify** — the visible identifier `ADR-0010` becomes `D-0005`, not only its
   path. This is a **third, genuinely wider** shape than the two before it, which both
   deliberately preserved the visible text; it is recorded here plainly, not dressed
   as "no larger" than its predecessors. It stays bounded and meaning-preserving: it
   is *forced* (leaving the old identifier would manufacture the very false-mention
   defect this record fixes), it changes an identifier's spelling and never a
   decision's content, and the mapping above records every old→new pair so no referent
   is lost.

## Consequences

- **Collision is impossible, not merely smaller** — permanently, and regardless of how
  either sequence grows, because the two live in different namespaces.
- **The by-path discipline retires.** The archive is citable by identifier, so the
  unenforced rule the audit already broke is no longer load-bearing.
- **The immutability exception now has three recorded shapes** — a de-link of a
  deleted target (D-0005), a path-repoint of a moved target (D-0007), and a
  re-identification of a renamed archive (this record). Each is bounded, mechanical and
  meaning-preserving; nothing that revises a decision's *content* is permitted, and the
  `docs/adr/` constitution's immutability rule is untouched (no living ADR *body* is
  edited — only the editable Status line of `0004`, which re-identifies its two
  archived amend-records).
- **External references cannot be rewritten.** Commit messages, pull-request bodies and
  closed issue threads still say `ADR-0008`. The mapping in [`README.md`](README.md) is
  the only thing that keeps such a citation resolvable — it is provenance, not optional.
- **This is an archive record, not a constitutional ADR.** It governs a directory the
  adopter deletes, so it fails the "constitutes a project" test for `docs/adr/`; like
  D-0007 before it, it lives in the archive and may cite a forge issue.
