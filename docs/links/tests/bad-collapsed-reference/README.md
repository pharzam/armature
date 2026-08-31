# Bad — L6 through the collapsed reference form

`[text][]` is the collapsed reference: its label **is its own text**. A checker
that reads the label from the second bracket finds an empty string and drops it,
which is a silent pass on exactly what L6 exists to catch. The full form
`[text][label]` is caught while this one is not, so the hole hides behind a
passing sibling.

- A good collapsed reference: [good-ref][].
- The defect, a collapsed reference nothing defines: [no-such-label][].

[good-ref]: target.md
