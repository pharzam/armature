# Good case — every link resolves

This case exercises each rule the linter applies, in its passing form. It is the
only case here that exits 0.

- A relative file link: [the target](target.md).
- A link with a fragment: [a real heading](target.md#a-real-heading).
- A same-file fragment: [the note below](#a-note-in-this-file).
- A directory link: [the sub directory](sub/).
- An em-dash heading, the slug trap: [R5 anchor](target.md#r5--deterministic-over-llm-based).
- An external link, which is out of scope: [example](https://example.com/nothing).
- A placeholder target, skipped by design: [`‹adopter doc›`](‹adopter doc›.md).
- A template placeholder shape, also skipped: [ADR-NNNN](NNNN-short-title.md).
- A reference-style link: [by reference][the-ref].
- A collapsed reference, whose label is its own text: [the-ref][].
- A nested, badge-shaped link: [![the target](target.md)](target.md).
- A CommonMark angle destination: [angled](<target.md>).
- A raw HTML anchor: <a href="target.md">html link</a>.
- A link-shaped EXAMPLE in a code span, which is not navigation and is not
  resolved: `[not a link](does-not-exist.md)`.

[the-ref]: target.md

## A note in this file

The same-file fragment above resolves to this heading.
