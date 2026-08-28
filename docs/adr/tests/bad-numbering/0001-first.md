# 0001. First

Date: YYYY-MM-DD

## Status

Accepted

## Context

A fixture ADR for adr-lint's self-test. Not a real project decision.

## Decision

Keep the fixture minimal and internally valid, so a `bad-*` case fails only for
its own single, intended reason.

## Consequences

adr-lint can assert one rule at a time.
