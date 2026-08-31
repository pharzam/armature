# Bad — L6, a reference label nothing defines

`[text][label]` with no `[label]:` definition is not a broken link — a forge
renders the brackets as literal text, so it is not a link at all. That is almost
always a typo in the label, and it reads as a link in the source.

- A good reference link: [the target][good-ref].
- The defect: [this label is never defined][no-such-label].

[good-ref]: target.md
