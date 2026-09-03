# Good — the escaped angle spelling resolves to the unescaped path

`[x](<a\>b spaced.md>)` is the spelling `L8` advises for a target holding a `>`,
and CommonMark reads it as a link to `a>b spaced.md`. That file is present here,
so the case is GREEN — and it is green only if the linter applies the escape.

**This is a `good-` case on purpose.** A `bad-` case asserting `L1` cannot isolate
this fix: `EXPECT` names the assertion id, and both the correct reading and the
broken one produce `L1` — one naming `a>b spaced.md`, the other
`a\>b spaced.md`. Measured on issue #114: with the escape handling reverted, a
`bad-`/`L1` case still passed. Inverting it makes the greenness depend on the
behaviour rather than on the id.

Three things have to hold together for this to resolve, and reverting any one of
them turns this case red:

1. the extractor ends an angle destination at its first **unescaped** `>`, so
   `<a\>b spaced.md>` is not truncated to `<a\>`;
2. `L9` does not then read the remainder as junk after a destination;
3. the shell applies the backslash escapes, so the path looked up is
   `a>b spaced.md`.

A control link resolves here so the `L5` floor cannot stand in for the real
assertion.
