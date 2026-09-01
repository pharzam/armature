# Bad — L1, a dead link in the root entry point

This case is the **redundancy test**. `agents-lint`'s A19 used to resolve this
file's own links; it was removed because `link-lint` walks every Markdown file in
the tree, and the root `AGENTS.md` is one of them. This case is what makes that
claim checkable rather than asserted.

Stated plainly, so the case is not read as proving more than it does:
`link-lint` is **filename-agnostic**. It walks `*.md` and does not know that
`AGENTS.md` is special, so to the linter this is an ordinary dead-link case. What
it locks is the **intent** — and it would still go red if a future change excluded
the repository root from the walk, which is the failure that would silently drop
entry-point coverage.

- A good link: [the target](target.md).
- The defect: [a document the tree does not hold](docs/governance.md).
