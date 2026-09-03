# Bad — L9, an angle destination followed by junk

`[x](<a b>junk)` is not a link. CommonMark ends an angle destination at its `>`
and allows only whitespace and a title after it, so a forge renders this line as
text.

Before issue #111 this went **silently
green**: `is_placeholder()` read any `<...>` with trailing text as an adopter
marker, so the line was skipped and `link-lint` reported `OK`. The tell that it is
a destination rather than a marker is the **blank inside the angles** — a marker's
name has none.

`a b` exists here on purpose: without it the line would fail `L1` for an unrelated
reason, and the case would not prove the silence it is written against.
