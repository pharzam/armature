# Bad — L1 after a reference definition on the same line

A definition line can carry more than the definition. A checker that stops
reading the line once it has found `[label]: target` drops every link after it,
so the broken one below hides behind a definition that resolves perfectly well.

- A good inline link: [the target](target.md).

[note]: target.md and see also [this broken one](does-not-exist.md)
