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

The exit code alone proves the fix. A split list never reaches this file: the
one path becomes the three words `good-path`, `with` and the filename, so the
numbering test errors with `[: good: integer expression expected`, awk cannot
open `…/good-path`, and five things are reported missing from a fragment that is
not a file — a `Date:` line and four sections, fifteen failures across the three
fragments — none of it true of the record you are reading.

It does **not** report a duplicate ADR number, although an early draft of this
note said so. That symptom needs several records whose first four characters
agree, which a spaced *checkout prefix* produces — every record then begins with
the same fragment — and a spaced case directory does not.
