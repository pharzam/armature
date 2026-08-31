# Bad — L1 through a nested (badge-shaped) link

`[![alt](inner.md)](outer.md)` is the badge idiom: an image wrapped in a link. A
checker that matches a whole `[...](...)` consumes the INNER link and advances
past the outer one, so the outer destination is never resolved. Here the inner
target exists and the outer does not, so only a checker that finds both fails.

- A good inline link: [the target](target.md).
- The defect: [![the inner target](target.md)](does-not-exist.md)
