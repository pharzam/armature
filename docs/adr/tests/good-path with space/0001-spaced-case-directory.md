# 0001. Spaced case directory

Date: YYYY-MM-DD

## Status

Accepted

## Context

A fixture ADR for adr-lint's self-test. Not a real project decision.

The name of the directory that holds this record contains a space. That is the
whole case: adr-lint held its record list in a space-joined string and then
looped over it unquoted, so one path became two words and the run failed on a
directory that violates nothing.

## Decision

Keep the record itself minimal and internally valid, so this case fails only for
the one reason it exists to catch.

## Consequences

The exit code alone proves the fix. A split list cannot reach the per-record
checks, so it reports a duplicate number, an unreadable file and five missing
sections — all at once, and none of them true.
