# Bad — L5, a case with no in-tree links at all

This file holds only an external link and a placeholder, both of which the linter
skips by design. Nothing is left to resolve.

A check that reports OK having resolved nothing is a check that proves nothing —
the same fail-open the discipline-test runner's own coverage floor exists to
catch. So a run that resolves zero links is a failure, not a pass.

- External, out of scope: [example](https://example.com/nothing).
- A placeholder, skipped: [`‹adopter doc›`](‹adopter doc›.md).
