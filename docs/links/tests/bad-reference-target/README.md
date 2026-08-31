# Bad — L1 through a reference-style link

The broken destination is in a definition, not in an inline link. A checker that
only reads `[x](target)` sees a clean file and reports OK, which is the silent
link rot this suite exists to catch.

- A good inline link: [the target](target.md).
- A good reference link: [also the target][good-ref].
- The defect, reached by reference: [a missing file][bad-ref].

[good-ref]: target.md
[bad-ref]: does-not-exist.md
