# T-7d2x — Destroying history on the default branch

Detail for the [backlog](backlog.md) entry, per that file's one-line rule. Holds the
design notes, the rejected alternatives, and the incident record that
[ADR-0004](../adr/0004-destroying-history-on-the-default-branch.md) deliberately does not
carry.

## Why this file exists rather than a longer ADR

This repository is a template. Adopters copy every file verbatim, cannot edit an accepted
ADR (they are immutable), and cannot delete one without renumbering every later record —
`adr-lint.sh` requires contiguous numbering from `0001`. So an incident record placed in
an ADR would be inherited permanently by every adopter, in a repository where none of it
is true.

This file is in-repo, is not immutable, and an adopter deletes it with one command. The
convention is the kit's own: `backlog.md` says design notes, rejected alternatives, open
questions, and reproduction detail live in `tasks/<id>.md`.

## Open question, recorded rather than decided

Condition 2 requires a second **person**. On a one-person project the path is closed.
That is deliberate, and it is the single most consequential line in the record — it means
this repository cannot destroy history on its own default branch. If that proves wrong in
practice, the correction is a superseding ADR, not an edit: ADR-0004's decision would have
changed, and `adr/README.md` reserves amendment for a decision that still holds.
