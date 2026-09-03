# Bad — L9, an angle destination with junk after a blank

`[x](<a b> junk)` is not a link either: `junk` is not a title. Before
issue #111 the extractor truncated
this to `a b`, which **exists here**, so the line resolved and `link-lint`
reported `OK  2 links resolved` — the linter reading a path the renderer never
produces.

The sibling case `bad-angle-then-junk` covers the no-blank form, which was silent
for a different reason. Two lines produced one silence; both are asserted.
