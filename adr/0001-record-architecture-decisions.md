# 0001. Record architecture decisions

Date: YYYY-MM-DD

## Status

Accepted

## Context

We need a lightweight way to record the architecturally significant decisions
made on this project, along with their context and consequences, so that future
contributors understand why the system looks the way it does.

## Decision

We will use Architecture Decision Records (ADRs), as described by Michael Nygard
in
[Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

Each ADR is a short Markdown file in `adr/`, numbered sequentially, using the
template in [`template.md`](template.md):

- **Title** — short noun phrase describing the decision
- **Status** — Proposed, Accepted, Deprecated, or Superseded by ADR-NNNN
- **Context** — the forces at play, in a value-neutral way
- **Decision** — the response to those forces
- **Consequences** — the resulting context, positive and negative

ADRs are immutable once accepted: if a decision changes, a new ADR is written
that supersedes the old one, rather than editing the original.

## Consequences

Anyone reading the project will be able to see the rationale behind past
decisions. Decisions and their context are preserved even as the people involved
change. Adding a new decision costs one small file, versioned with the code it
describes.
