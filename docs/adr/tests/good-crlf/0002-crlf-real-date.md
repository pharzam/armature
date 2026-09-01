
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

Open with a BLANK LINE, which record 0001 does not. The title check selects the
first non-blank line by field count, and on a CRLF file an empty line is the
record `\r` — not a blank under awk's default field separator, so its field
count is 1 and the blank line itself was chosen as the title. Without this line
the case cannot reach that defect: a record whose first byte is `#` never
exercises the selection.

## Consequences

The two records together reach both date branches, both a padded and an
unpadded title position, and two status values. One record would leave half the
check untested.
