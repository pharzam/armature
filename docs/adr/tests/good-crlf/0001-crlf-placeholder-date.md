# 0001. CRLF record with the placeholder date

Date: YYYY-MM-DD

## Status

Accepted

## Context

A fixture ADR for adr-lint's self-test. Not a real project decision. Every line
in it ends with a carriage return, the way a file written on Windows does.

## Decision

Carry the shipped placeholder date, so this record covers the branch that
compares the value against the literal `YYYY-MM-DD`.

## Consequences

With the carriage return left on, that comparison fails and the linter reports
`Date must be YYYY-MM-DD ...; got 'YYYY-MM-DD'` — it rejects the value it asks
for, because the character that makes them differ does not print.
