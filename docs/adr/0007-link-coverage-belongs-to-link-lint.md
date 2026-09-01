# 0007. Link coverage belongs to link-lint, not to the entry-point check

Date: 2026-09-01

## Status

Accepted

## Context

[ADR-0006](0006-derive-expectations-from-prose.md) measured `agents-lint.sh` while
rejecting a metadata layer, and found the larger saving elsewhere: assertion
**A19** resolved the root `AGENTS.md`'s own links, while
[`link-lint.sh`](../links/link-lint.sh) — shipped later — resolves links and
anchors across every Markdown file in the tree, `AGENTS.md` included. The same work,
done twice.

That ADR sent the question to [#67](https://github.com/pharzam/armature/issues/67)
rather than deciding it, and said one thing about it that was **wrong**:

> It is **not** a clean deletion: `A19` carries a *per-file* coverage floor, and
> `link-lint`'s floor is tree-wide and would not notice `AGENTS.md` losing every
> link.

**That claim does not survive measurement.** Stripping every link from a passing
fixture's `AGENTS.md` produces five failures, not one: `A14` fires once per rule —
twelve times on the real file — because it independently requires every rule line
to link its own derived anchor, using its own extraction. `A23` fires too. A19's
floor never fires alone, and "AGENTS.md loses its links and nothing notices" is not
a reachable state. The floor's real subject was A19's own extraction, not the
document, so removing the extraction leaves it nothing to guard.

An ADR is immutable below its Status line, so that paragraph is corrected here
rather than edited there.

A second claim in the same paragraph — that nothing else would be lost — was also
wrong, and in the more expensive direction. An independent plan review found that
A19 rejected an **absolute** link target and `link-lint` did not: joining an
absolute target onto the linking file's directory resolves to the real file
whenever that file sits at the repository root, which is exactly where an entry
point lives. Verified: a root-level `[x](/docs/thing.md)` passed `link-lint` with
`OK`. The common case was the silent one.

Both errors share a cause worth naming: coverage was declared redundant *in
aggregate* instead of branch by branch.

## Decision

We will make **`link-lint` the single owner of in-tree link and anchor coverage**,
and remove `agents-lint`'s A19.

- **A19 is deleted**, with the `links resolved` field it fed dropped from
  `agents-lint`'s success line, since the script no longer measures it.
- **Its one non-redundant branch becomes `L7`** in `link-lint`: an in-tree target
  must not be absolute. This is a net *gain* — A19 guarded one file, `L7` guards
  every file.
- **A19's number is not reused.** The sequence runs A1–A18, A20–A26, and the gap
  records a removal rather than hiding it.
- **`bad-entry-point-dead-link`** is added to `link-lint`'s fixtures as the
  redundancy test, so the claim this decision rests on is checkable rather than
  asserted.

We reject two alternatives:

- **Keep a reduced A19 holding only its coverage floor.** The floor's subject is
  A19's own extraction; deleting the extraction leaves a check with nothing to
  check.
- **Add an assertion that `link-lint.sh` exists**, so a later deletion of it could
  not silently drop coverage. The plan review found the fact that settles it:
  [`.githooks/pre-commit`](../../.githooks/pre-commit) guards *every* linter call
  with `if [ -f … ]` and states that CI carries no such guard, so a deleted
  `link-lint.sh` already fails CI. The kit has no precedent for one check asserting
  a sibling's existence, and singling out one linter would misdescribe a uniform,
  deliberate design.

## Consequences

`agents-lint` gets about 78 lines shorter and keeps a single subject: whether the
entry points agree with the documents they summarise. Whether their links *resolve*
is now someone else's job, and that job is done for every file rather than one.

**A dependency is created and is not mechanically guarded.** `agents-lint` no
longer checks these links because `link-lint` does. If `link-lint` is narrowed or
its walk changes, entry-point coverage shrinks from a different file. CI failing on
a deleted `link-lint.sh` is the backstop; a *narrowed* one is not caught, and
`bad-entry-point-dead-link` is the only thing standing in that gap.

**The slug rule now lives in two places with nothing keeping them in step.**
`link-lint`'s `slug()` began as a copy of A19's, and A19's named function has gone
with it; what remains in `agents-lint` is the same rule written inline in the
rule-anchor derivation. If one changes and the other does not, one check resolves
anchors the other rejects. Recorded in
[`links/README.md`](../links/README.md) as a limit rather than left to be
discovered.

Two of A19's branches were listed as untested in the fixture suite's own notes —
the floor and the absolute-path rejection. One is now proven unreachable and the
other is `L7` with a fixture, so both entries leave that list. The lesson stands
without them: **an assertion no fixture drives is one nobody has checked the
reasoning of either.**
