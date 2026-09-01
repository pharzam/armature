# 0002. CRLF record with a real date

Date: 2026-09-01

## Status

Proposed

## Context

A fixture ADR for adr-lint's self-test. Not a real project decision. Every line
in it ends with a carriage return, the way a file written on Windows does.

## Decision

Carry a real date and a second status value, so this record covers the regular
expression branch of the date check and a different arm of the status set.

## Consequences

The two records together reach both date branches. One record would leave half
the check untested.
