# Bad — L1, an angle destination cut short in a reference definition

The closing `>` is missing, so this is not the angle form and defines no link on
the forge. The definition branch keeps the text whole and fails `L1` with it, the
same way the inline branch does; without that clause the line is `L8` with a
`<<…>` remedy, and the use beside it a false `L6`.

- A good link: [the target](target.md).
- The use: [a cut definition][lbl].

[lbl]: <Design Notes/target.md
