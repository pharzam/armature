# Bad — L8 beside L6, a bare destination with a space in a reference definition

CommonMark allows nothing after a definition's destination but a title, so the
line below defines nothing: the destination is `L8`, and the use of the label is
`L6`. Two reports, both true.

- A good link: [the target](target.md).
- The use: [not a link][lbl].

[lbl]: Design Notes/target.md
