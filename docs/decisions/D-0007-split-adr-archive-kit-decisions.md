# D-0007. Split docs/adr/: archive the kit's own governance decisions

Date: 2026-09-08

## Status

Accepted. Amended by [D-0008](D-0008-namespace-the-decision-archive.md)

## Context

`docs/adr/` is meant to be a **constitution template** an adopter copies onto a new
project. It had drifted from that: of eleven records, only `0001`–`0004` constitute
*a project*; `0005`–`0011` govern **the kit itself** — its review protocol, its
linters, its own pivot. An adopter could not shed the kit-facing ones. Deleting
them failed [`adr-lint`](../adr/adr-lint.sh)'s contiguity rule
(`expected 0006, found 0008`); deleting all eleven broke 43 in-tree links across
fifteen files, four of the core documents among them. So the adopter inherited this
repository's own history and had to begin their constitution at `0012`.

This is recorded on [#160](https://github.com/pharzam/armature/issues/160), where
the repository owner chose to keep `0001`–`0004` in `docs/adr/` and move `0005`–
`0011` into a new `docs/decisions/`. (This record sits in `docs/decisions/`, so —
unlike a constitutional record — it may cite a forge issue.)

Two collisions had to be resolved, not stepped around:

- **Numbering.** `adr-lint` mandates contiguity from `0001`, so a `docs/adr/` of
  `0001`–`0004` is legal, but the kit cannot both keep a global "no number is ever
  reused" invariant and let its constitution grow: the next constitutional ADR would
  have to be `0005`, which the moved record already holds.
- **Immutability against a moved link.** Two links sit in immutable ADR bodies and
  cross the new directory boundary: `0010` links the ADR-convention `README.md`, and
  `0011` links `0004`. The ADR convention holds everything below the Status line
  immutable, and `link-lint` fails a broken link — so the move could not leave both
  rules intact untouched.

## Decision

**The directory split.** `docs/adr/` holds only the constitutional records
`0001`–`0004`. Records `0005`–`0011` move to `docs/decisions/`, and this record,
`0012`, is written there. `adr-lint` reads only `docs/adr/`, so the archive is
unlinted — deliberately: a checker whose only subject is this repository's own past
is the self-facing mechanism [D-0004](D-0004-refocus-on-the-adopter.md) turned away
from.

**The constitutional-reference rule.** A record in `docs/adr/` references no issue
or pull request of this repository, and never links into `docs/decisions/`; it
cites only sibling constitutive documents. A record in `docs/decisions/` may link
*up* to `docs/adr/`. These are **written rules** — no mechanism enforces the
direction (`link-lint` checks that a link resolves, not which way it points), so the
plan review and the decay rounds are their enforcement. The rule is stated for the
adopter in [`docs/adr/README.md`](../adr/README.md#what-belongs-in-this-directory),
self-contained, without citing this archive.

**The numbering policy.** `docs/adr/` is the single **living** ADR sequence,
contiguous from `0001`, and it grows — the next constitutional ADR is `0005`.
`docs/decisions/` is a **closed archive**: its records keep the numeric filenames
they had in `docs/adr/` (`0005`–`0011`), plus `0012` written here, as provenance,
and are cited by path. A bare
"ADR-NNNN" henceforth means the `docs/adr/` sequence. This drops the former "global,
no-reuse" invariant in favour of one living sequence and one frozen archive, cited
by path.

**The immutability exception, extended.** [D-0005](D-0005-cut-the-self-facing-checks.md)
permitted one bounded edit to an immutable body: demoting a link to a **deleted**
file to a code-span. This record permits one more, no larger: a **mechanical
path-repoint of a link whose target moved within the tree** — the visible text
unchanged, only the relative path corrected so the link keeps resolving. It is
applied exactly twice, to the two cross-boundary links above
(`docs/decisions/0010`'s link to the ADR-convention README, and
`docs/decisions/0011`'s link to `0004`). A repoint that preserves a working link is
a strictly smaller breach than the de-link D-0005 already accepted.

**The amendment trace.** `0004`'s "Amended by" records (`0010`, `0011`) moved to the
archive. `0004` keeps them as **bare mentions** in its Status line — no link, since a
constitutional record may not link into `docs/decisions/` — and the archived records
point back to `0004`: `0011` links up to it, and `0010` names it in prose (its own
immutable body links into `docs/adr/` only the ADR-convention README, not `0004`).
So the relationship stays legible from both ends.

We reject three alternatives, recorded so none is reopened without new information:

- **Delete the kit-facing records outright.** Fails `adr-lint` contiguity, and
  discards worked examples of the ADR convention an adopter learns from.
- **Freeze `docs/adr/` at `0001`–`0004`.** It keeps a global no-reuse numbering but
  forbids the constitution from ever growing — wrong for a template.
- **Move `0004` out as well.** Measured worse: it breaks five immutable-body links
  rather than four, because `0007` and `0010` cite the ADR-convention `README.md`
  that stays. `0005` is the correct cut point on evidence, not only on
  classification.

## Consequences

- **An adopter's live rules stay green when `docs/decisions/` is removed.** No
  constitutional or core-convention document links into the archive — verified:
  `link-lint` finds zero resolvable links into `docs/decisions/` from the
  constitution or any core convention doc. The archive is not deleted alone: it
  leaves together with the rest of this repository's own history — `docs/audit/`
  and the historical entries in `docs/tasks/completed.md` and `docs/tasks/T-k4vm.md`,
  which link in and which an adopter clears on adoption. Removing that whole set
  keeps every linter green; removing the archive *alone* would red the nine links
  those kit-history files still carry.
- **`docs/adr/` is now four records an adopter adopts**, contiguous and growable,
  and the two reference rules keep it that way — enforced by review, stated honestly
  as written rules with no mechanism.
- **The reference rules are unenforced.** `link-lint` checks resolution, not
  direction; `adr-lint` reads only `docs/adr/`. A kept document that links into the
  archive would pass every check on *this* tree and only break on the adopter's,
  after they delete it — so the rules live or die by the plan review and the decay
  rounds, which is where [`docs/adr/README.md`](../adr/README.md#what-belongs-in-this-directory)
  records them.
- **`0006` and `0007` stay superseded; `0008`–`0011` keep their statuses.** The move
  changes where the records live, not what they decided.
- **The immutability exception now has two recorded shapes** — a de-link of a deleted
  target (D-0005) and a path-repoint of a moved target (this record). Nothing else
  in a landed body may change.
