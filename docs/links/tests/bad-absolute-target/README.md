# Bad — L7, an absolute link target

An absolute target is a portability defect, not a resolvable path. A forge
resolves `/target.md` against the **site** root, not the repository; a local
viewer resolves it against the **filesystem** root. It is wrong either way, and
the reader lands nowhere in both.

It is silent because the arithmetic hides it: joining an absolute target onto the
linking file's directory gives a path that, **for a file at the repository root**,
resolves to the real file and passes. That is exactly where an entry point lives.

- A good relative link: [the target](target.md).
- The defect: [an absolute target](/target.md).
