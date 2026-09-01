# 0001. Mentioned only

Date: YYYY-MM-DD

## Status

Accepted

## Context

A fixture ADR for adr-lint's self-test. Not a real project decision.

This record exists to be *talked about* and never linked. The suite README names
it three ways — by shorthand, by stem in a code span, and inside a fenced
example that is link-shaped — and links it nowhere.

## Decision

Keep the fixture minimal and internally valid, so it warns only for its own
single, intended reason: no inbound link.

## Consequences

The no-orphan check has a case where a mention is available to be mistaken for a
link.
