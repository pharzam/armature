# D-0005. Cut the self-facing checks, and de-link immutable references to them

Date: 2026-09-07

## Status

Accepted

## Context

[D-0004](D-0004-refocus-on-the-adopter.md) refocused the project on the adopter and
directed the removal of the mechanisms whose only mission is this repository itself
— the `audit-record` stack and the `agents-lint` meta-chain (the independent
assessment's findings F1 and F2). This record governs how that removal is carried
out where it collides with an existing rule.

Two of those files are the target of resolvable Markdown links that sit inside
**immutable ADR bodies**: `docs/agents/agents-lint.sh` is linked from ADR-0004,
D-0000 and D-0001, and `docs/tasks/T-3v9q.md` from ADR-0004. The ADR convention
holds everything below an ADR's Status line immutable
([`README.md`](../adr/README.md)). `link-lint` fails on a link whose target is gone. So
there is no state that both deletes these files and keeps the gate green without
touching an immutable body — the rule against a broken link and the rule against
editing a landed ADR cannot both hold once the file is deleted.

## Decision

We will remove the two mechanisms across the two deletion pull requests this record
covers, and where a removed file is the target of a resolvable link inside an
immutable ADR body, we will make the **minimal mechanical de-link**: convert
`[text](path)` to a bare code-span `` `text` ``. The visible words are unchanged;
only the now-broken hyperlink is removed.

We reject leaving the links to dangle — that fails `link-lint` and stops the gate.
We reject rewriting the ADRs' prose — a larger breach of immutability than demoting
one link, and unnecessary: an ADR is a dated record, and prose that describes a
mechanism the kit later removed reads correctly as history once the record carries
a supersession or amendment pointer. This exception is therefore narrow: it lets a
link to a deliberately-deleted file become a code-span, and nothing more.

D-0001 and D-0002 exist only to justify `agents-lint`; they are superseded by
this record when that mechanism goes. ADR-0004 keeps its decision — the two root
entry-point files stay — but the "one deterministic check over them" it also
decided is retired here, so it is amended, not superseded.

## Consequences

- `link-lint` stays green through the deletions; the immutable ADR bodies keep their
  wording, now read as the history of a decision later amended or superseded.
- The immutability rule gains one recorded, bounded exception: a link to a removed
  file may be demoted to a code-span. Nothing else in a landed ADR body may change.
- The Status edits an accepted ADR permits are split across the two removal pull
  requests: the group-1 pull request amends ADR-0004 to `Accepted. Amended by
  D-0005` (its "one deterministic check" half retires; the entry-point files
  stay), and the group-2 pull request supersedes D-0001 and D-0002 when
  `agents-lint` goes.
- The removal itself lands in two reviewed pull requests: the `audit-record`
  mechanism (with `T-3v9q.md`) and the `agents-lint` meta-chain. Each carries its
  own de-links and reference fixes so that `link-lint` is green at every landed head.
