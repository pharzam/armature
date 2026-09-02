# Bad — L1, a padded destination that used to vanish

CommonMark lets spaces and tabs sit between the parentheses and the destination,
so the link below is real, and its target is missing. A reader that cut the
destination at its first blank was left with nothing, and reported nothing.

- A good link: [the target](target.md).
- The defect: [a missing file]( does-not-exist.md ).
