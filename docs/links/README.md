# Link discipline

The check that keeps the documents' own navigation honest.

| File | What it is |
| ---- | ---------- |
| [`link-lint.sh`](link-lint.sh) | Resolves every in-tree Markdown link and heading anchor. Runs in the [`pre-commit` hook](../../.githooks/pre-commit) and in [CI](../ci/). |
| [`tests/`](tests/) | Its fixtures — one `good` case and a `bad-*` case per assertion, plus one per false-green hole a review found. Run by [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh). |
| [`tests/expect-check.sh`](tests/expect-check.sh) | Asserts each `bad-*` case fails for **its own** assertion, not merely that it fails. |

## Why it exists

Armature's product **is** its documents, and they are a web of relative links and
heading anchors. Rename a heading and every anchor pointing at it dies silently:
the page still renders, the link still looks like a link, and a reader following
it lands nowhere. Nothing in the kit caught that until this check.

The gap was found the honest way. A review of [#61](https://github.com/pharzam/armature/issues/61)
noticed that a "311 links resolve" claim had been cited beside the committed
linters as if it were one of them, when it came from a throwaway script. It was
not repeatable, so it was not evidence —
[R5](../issue-workflow.md#r5--deterministic-over-llm-based) says a mechanizable
claim belongs in a mechanism. This is that mechanism.

On its first run over the tree it found a real dead link in
`docs/ci/tests/pr-link/README.md`, which had pointed one directory too shallow
since the file was written.

## What it asserts

| ID | Assertion |
|----|-----------|
| `L1` | Every relative link target resolves to a path that exists. |
| `L2` | Every `#fragment` on an in-tree `.md` target names a heading in that file. |
| `L3` | Every same-file `#fragment` names a heading in the linking file. |
| `L4` | No link target escapes the repository root. |
| `L5` | Coverage floor — a run that resolved **zero** links fails. |
| `L6` | Every reference use `[text][label]` has a matching `[label]: target` definition. |
| `L7` | No in-tree target is an absolute path. |
| `L8` | A bare destination holding a space or a tab is not a link at all: the forge renders the text as written. A reference definition of that shape defines nothing, so a `[text][label]` that uses it draws `L6` beside the `L8` — two reports where there was one `L1`, both true. A definition whose target is an adopter marker holding a blank, `[runner]: ‹the test runner›/run.sh`, is neither: it is skipped like every marker, and its label stays defined. |
| `L9` | An angle destination followed by anything but a title is not a link: CommonMark ends the destination at its `>`, so `[x](<a b>junk)` and `[x](<a b> junk)` render as text. Reported rather than skipped as an adopter marker or truncated to the part before the `>`. |
| `L10` | A link with an empty destination — `[a]()`, `[a](   )` — renders as `<a href="">` and goes nowhere. Reported rather than dropped. |

## What it proves, and what it does not

It proves a link's target **exists**. It does **not** prove the link is the
**right** one: a link to the wrong existing file, or to a real heading that does
not say what the sentence claims, passes every assertion here. That is the
[semantic-agreement review](../engineering-discipline.md#reviewing-for-semantic-agreement),
not this script.

## What it skips, and the limits that leaves

- **External `http(s)` links.** Checking them needs the network, which would cost
  the offline property every [discipline test](../tests/test-levels.md#discipline-tests)
  depends on. A rotted external link is not caught here.
- **Placeholders** — `‹…›` adopter markers, `<…>` shapes, and the ADR template's
  `NNNN-…` form. Flagging one would push an author to "fix" a template by
  inventing a filename, which is the placeholder-integrity failure
  [`AGENTS.md`](../../AGENTS.md) warns about.
- **Fenced code blocks, HTML comments, and inline code spans**, whose links are
  examples, not navigation. A link-shaped example in backticks is not resolved.
- **Fixture case directories** — any path with a `good`, `good-*` or `bad-*` component.
  Their links are deliberately broken: `docs/agents/tests/bad-dead-link/` exists
  to make `agents-lint` reject a dead link, and linting it would report that
  suite's success as failure. **The limit is real and named: a genuinely broken
  link in a fixture's own prose goes unseen.** Fixture *suite* READMEs are not
  skipped — they are prose a reader follows, and that is exactly where the one
  real defect was found.
- **A nested checkout under the root** — a linked worktree, a clone, a submodule.
  The file list is what git lists for this repository, so a copy of the tree
  inside one is never read. Limit 9 below carries the detail.
- **Most links into a path containing a space** — worth knowing before you write
  such a path, not after. Three of the four destination forms cut at the first
  space: `[a](Design Notes/target.md)` is read as a link to `Design` and fails
  `L1`; a `%20` is never decoded and fails too; and the CommonMark angle form
  `[a](<Design Notes/target.md>)` is **skipped in silence**, because what
  survives the cut is `<Design`, which reads as a `‹…›` adopter placeholder.
  Measured: a *correct* spaced link and a *dead* one produce byte-identical
  output, so the check cannot tell those two apart. **The raw HTML form is the
  exception and the one that works** — `<a href="Design Notes/target.md">` is
  captured between its quotes, spaces and all, and resolves. So if your
  repository has a `docs/Design Notes/` or an `RFC 001/`, links into it are
  checked only when written that way. Limits 7 and 8 below carry the detail.

## The forms it reads

A checker blind to a link form is worse than no checker, because the reader
trusts it. Four forms are read:

| Form | Example |
|------|---------|
| Inline | `[x](target.md)` |
| **Nested** | `[![alt](inner.png)](outer.md)` — both destinations |
| Reference | `[x][label]`, and the **collapsed** `[x][]` whose label is its own text |
| Raw HTML | `<a href="target.md">` |

Nested links are found by scanning for **each `](` opener** rather than matching a
whole `[…](…)`: a whole-link match consumes the inner link and advances past the
outer destination, which is a silent false green on the badge idiom.

A CommonMark angle destination `[x](<a path.md>)` is a real link and is resolved,
**spaces and all**: it is read to its closing `>`, the one Markdown spelling in
which a destination may hold a space. An adopter marker only *opens* with `<`, as
in `<id>.md`; they are told apart on the closing `>`, so a real link is never
skipped as a placeholder — and a target that opens `<` and never closes it is an
angle destination cut short, kept whole, which fails `L1` with the whole cut text:
never `L8`, and never the silent skip it used to be. A `%20` is decoded once, so
`[x](Design%20Notes/target.md)`, what a forge writes for a space, resolves; a
failure to resolve a decoded path reports both spellings. Blanks padding a
destination, `[x]( target.md )`, are
trimmed, where the old cut left nothing and the link vanished. A bare destination
holding a space or a tab with no title after it is `L8`: not a link on the forge,
so not one here. So if your repository has a `docs/Design Notes/` or an
`RFC 001/`, every link into it that the forge follows is checked. All of this is
[#78](https://github.com/pharzam/armature/issues/78); limits 7 and 8 below are
what it left.

## Why A19 was removed, and what replaced it

`agents-lint` once carried its own assertion **A19**, resolving the root
`AGENTS.md`'s links. It was removed ([#67](https://github.com/pharzam/armature/issues/67))
because this check walks every Markdown file in the tree and `AGENTS.md` is one of
them ([ADR-0007](../adr/0007-link-coverage-belongs-to-link-lint.md)) — the same work, done once instead of twice, across four link forms instead
of one.

One branch of A19 was **not** redundant: it rejected an **absolute** target, and
this check accepted one. That gap is now `L7`, and closing it here covers every
file in the tree rather than the single file A19 watched.

`bad-entry-point-dead-link` is the fixture that keeps the replacement honest. Note
what it does *not* prove: this check is **filename-agnostic**, so it does not know
`AGENTS.md` is special. The case locks the intent, and would go red if a future
change excluded the repository root from the walk.

## Nine limits, recorded rather than hidden

1. **The slug rule exists in two places and nothing keeps them in step.** It began
   as a copy of `agents-lint.sh`'s A19; that assertion was removed
   ([#67](https://github.com/pharzam/armature/issues/67)) and the named function went
   with it. What survives there is the same rule written inline in the rule-anchor
   derivation (`agents-lint.sh:540`). If one changes and the other does not, one
   check resolves anchors the other rejects — **by hand, with no mechanism**. It also
   drops underscores, which GitHub keeps in an anchor: harmless while no heading in
   the tree uses one, and a defect the day one does.
2. **Duplicate headings are not disambiguated.** GitHub appends `-1` to the second
   occurrence's slug; `anchors_of()` does not, so a legitimate `#foo-1` link would
   be wrongly rejected. No duplicate heading exists in the tree today. This is a
   false *red* — it fails loudly rather than passing silently, which is the right
   direction for a bug to point.
3. **A case-mismatched target passes on a case-insensitive filesystem.** `[ -e ]`
   on macOS accepts `Target.md` for `target.md`, where Linux CI rejects it, so the
   local hook is more lenient than the authority. CI is the authority precisely
   for this class of difference.
4. **A protocol-relative target `//host/path` is reported as an absolute path.**
   It is really an external link, and `L7`'s message misnames it. Inherited
   unchanged from `agents-lint`'s A19, which matched `/*` the same way, so this is
   a limit carried over rather than introduced — recorded here because it was
   never written down there.
5. **A line beginning `[word]: text` is read as a reference definition.** When one
   word follows the colon it is resolved as a target, so `[TODO]: fixme` reports a
   broken link to `fixme`. When more than one follows, as in
   `[TODO]: revisit this later`, the line reports `L8` — not a link — with the
   remedy made conditional, because the author may well have meant prose. An
   earlier form of this entry said CommonMark reads that line as a definition. It
   does not: the spec (§4.7, example 209) allows nothing after the destination and
   its optional title, so the line is a paragraph on the forge, which is what `L8`
   says. Loud either way, and the direction is safe.
6. **The link extractor now exists in two places and nothing keeps them in step.**
   `adr-lint.sh`'s `links_to_record()` reads the same three destination forms this
   file does, the same way, to decide whether a record has an inbound link
   ([#73](https://github.com/pharzam/armature/issues/73)). It resolves nothing —
   that stays this linter's job — but the two must agree about what a link *is*.
   They have disagreed **twice**, and both were found by reading one against the
   other rather than by any mechanism. This one strips a CommonMark angle
   destination and that one did not, so `[a](<x.md>)` resolved here and read as no
   link there. Then the reverse: that one stripped a trailing carriage return and
   this one did not, so every reference definition in a CRLF file reported as
   broken here and resolved there
   ([#76](https://github.com/pharzam/armature/issues/76)). Both are fixed, both
   **by hand, with no mechanism** — the same shape as limit 1, and the reason
   ADR-0007 recorded that one rather than leaving it to be found. One divergence
   is **deliberate, and written on both sides**
   ([#78](https://github.com/pharzam/armature/issues/78)): this linter decodes
   `%20` and `adr-lint` does not. `links_to_record()` compares **basenames**
   only, and `adr-lint`'s filename rule forbids a space in a record's name, so an
   encoded space can only sit in the directory part that comparison drops.
   Measured: `[x](dir%20with%20space/0001-x.md)` counted there before the change
   and counts after. The angle form, a padded destination, and a bare destination
   followed by anything but a title — not a link, so it names no record either;
   `[x](adr/0001-x.md junk)` counted there until the first review round found the
   two apart on it — are read the same way in both, kept in step by hand, as before.
7. **An angle destination that holds a `)` is cut at that `)`.** CommonMark
   (example 492) reads `[a](<b)c>)` as a link to `b)c`; both extractors end a
   destination at the first `)`, so `[e](<Design (draft)/target.md>)` is read as
   `<Design (draft`. Before
   [#78](https://github.com/pharzam/armature/issues/78) every spaced angle
   destination was cut that way, at its first blank, and the cut text
   passed as an adopter marker — the link vanished **in silence**, the one silent
   false green among the spaced forms and the defect that issue was opened for. The
   cut now happens only on a `)`, and what it leaves is kept whole and fails `L1`
   with the whole cut text — `links <Design (draft, but that path does not exist`;
   `adr-lint` reads it as no link, a loud false orphan. The `L8` remedy wraps that
   whole text rather than trying to split a title out of it: a split truncated a
   destination holding ` (`, and the truncation resolved **silently**. What the
   simpler remedy does was then measured input by input at `56d4f06`: take the `L8`
   advice, write it back into the file, run `link-lint` again, and render the
   followed line with `pandoc 3.8.2.1 --from commonmark --to html`. The inputs below
   are grouped by the character the target carries, which is a way to read the list
   rather than a claim that the list is finished.

   | The target carries | Inputs | `link-lint` on the followed line | pandoc on the followed line |
   |---|---|---|---|
   | a `<`, and no `>` | `a <b.md`, `Design Notes/a<b.md`, `a b<` | `OK  2 links resolved`, exit 0 | the text as written, escaped |
   | a `>` | `a>b c.md`, `a b>`; and the truncation sub-case, a blank or a tab after the `>`: `target.md> a/b.md`, `docs> adr/0001.md` | `OK  2 links resolved`, exit 0 — the truncation pair reads back as `target.md` and as the directory `docs` | the text as written, carrying a raw `<a>` or `<docs>` tag where the wrapped target reads as one |
   | a backslash escape | `a\.b c.md`, inline | `OK  2 links resolved`, exit 0, on the literal path | `<a href="a.b c.md">` — a link to a different path |
   | a backslash escape | `a\.b c.md`, by reference definition | `OK  2 links resolved`, exit 0, on the literal path | nothing — see below |

   **The two forms are listed apart because the backslash row is where they part.**
   Every other row was run both ways and gave the same result; that one does not.
   Written inline, `[x](<a\.b c.md>)` renders `<p><a href="a.b c.md">x</a></p>` — a
   link to a path the author did not write. Written as `[lbl]: <a\.b c.md>` it
   renders **no element at all**: the advice makes it a *valid* link reference
   definition, and a definition nothing references renders nothing. Measured at
   `a74e2ef` with a control link present, the inline output is 63 bytes and the
   reference-definition output is 31 — the control alone. Neither form is a link to
   the path as written, and they fail differently, which is why one cell cannot
   hold both.

   The second resolved link in each run is a control that exists, so the count reads 2
   rather than 1, and the truncation rows need `target.md` and a `docs/` directory in
   the tree rather than the literal destination. Removing the target says which path
   each `>` row resolved. `[x](<target.md> a/b.md>)` gives
   `FAIL  L1: <file>:<line> links target.md, but that path does not exist` — two
   spaces after `FAIL`, and the file and line the run prints, which the earlier
   quote dropped — and
   `[lbl]: <docs> adr/0001.md>` names `docs`, shorter than the line names:
   that is the `>`-then-junk read at `link-lint.sh:252`, and it belongs to
   [#97](https://github.com/pharzam/armature/issues/97), whose body names all three
   groups. `[x](<a>b c.md>)` gives `links a>b c.md` and `[x](<a b>>)` gives `links a b>`,
   the path as written, so that read did not run on them; what those two turn on is the
   spelling the advice produces — `L8` echoes the target back unescaped, and
   CommonMark forbids an unescaped `>` inside an angle destination. Measured in
   [#98](https://github.com/pharzam/armature/issues/98) round 1, routed off this
   change's path, and owned by
   [#97](https://github.com/pharzam/armature/issues/97) as its seventh gap. A full `)`-aware
   parse was rejected there: about fourteen lines per branch, it must still exempt
   the `<id>.md` marker, and no link in the tree needs it.

8. **Only `%20` is decoded.** Any other percent-encoding — `%2F`, `%C3%A9`, `%23` —
   is looked up as written and fails `L1` loudly, quoting what the author wrote.
   General decoding was rejected on
   [#78](https://github.com/pharzam/armature/issues/78): a decoded `%23` becomes
   the `#` the fragment split reads and cuts a filename in half, and a byte above
   127 decodes to one byte on this awk and to a multibyte character on a UTF-8
   `gawk`, so a non-ASCII filename would resolve on one machine and not another.
   When a decode did change the path, a failure to resolve it prints both
   spellings — `links Design%20Notes/x.md, decoded to Design Notes/x.md` — so the
   author sees the text they wrote and the path that was looked up.
9. **The file list is the third thing written in two places and kept in step by
   hand.** This linter and `audit-record-lint.sh` (block 2b) list the repository's
   files the same way — what git tracks plus what it does not ignore, read
   NUL-delimited so no name is quoted and with symlinks refused, so a nested
   checkout is one entry and never read, with a `find` walk that prunes any
   directory holding a `.git` entry whenever this directory is not itself the
   repository root, or git lists nothing
   ([#80](https://github.com/pharzam/armature/issues/80)). The same shape as limits
   1 and 6, **by hand, with no mechanism**:
   [`nested-checkout-check.sh`](../tests/nested-checkout-check.sh) drives both
   copies but does not compare them. The shape's own limit: `--exclude-standard`
   reads `.git/info/exclude` and the global ignore file, neither versioned, so two
   operators on one commit can get different lists.

## The `EXPECT` convention

Each `bad-*` directory carries an `EXPECT` file holding only its assertion id.
The [discipline-test runner](../tests/run-discipline-tests.sh) compares **exit
codes only**, so a bad case that started failing for a different reason would
still look green there. [`tests/expect-check.sh`](tests/expect-check.sh) closes
that for this suite, and fails if it finds no case to check.

Of the eleven cases [#78](https://github.com/pharzam/armature/issues/78) added, the
runner sees eight: five `good*` cases that exited 1 before their fix and two
`bad-*` cases that exited 0, plus `bad-angle-cut-destination`, which was never red
on its own and goes red only when `is_placeholder()` is loosened — measured by
mutation, as were the two angle-with-title cases, which are the only ones that
reach the clause ending an angle destination at its `>`. It cannot see the other
three: `bad-bare-spaced-destination` and `bad-bare-spaced-definition`, which exit 1
for `L1` without the fix and for `L8` with it, and `bad-angle-cut-definition`, which
exits 1 either way — only this script tells those apart.
That is the pitfall
[`guardrails.md`](../guardrails.md#gate-pitfalls-kit-wide--keep-these) names, a
harness that compares only exit codes, and why that issue's close-out pastes this
script's output beside the runner's.

It is a script rather than a copy-paste loop, but it is **not yet a gate** — it is
not wired into the runner. Backlog task `T-9c5t` ([#37](https://github.com/pharzam/armature/issues/37))
owns generalizing `EXPECT` across every suite; this suite is ready for it.

## The cases

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `link-lint: OK`, exit 0 | every rule and every form in its passing shape — inline, nested, reference, HTML, angle destination, a fragment, a same-file fragment, a directory, the double-hyphen slug, an external link, both placeholder shapes, and a link-shaped example in a code span |
| `good-crlf` | `link-lint: OK`, exit 0 | the same file with **Windows line endings**. Its three reference definitions — a path, a path with a fragment, and a same-file fragment — each failed `L1`, `L2` and `L3` before the carriage return was stripped; the inline, angle and raw-HTML forms beside them never did, and are there to show where the boundary was. Its endings are pinned by [`.gitattributes`](../../.gitattributes); without that pin, anyone whose git is set to `core.autocrlf=input` or `true` strips the returns the next time they stage it — the conversion happens on the way *into* the blob, not on checkout — and the case then passes while testing nothing. Git normally skips that conversion for a file whose blob already holds returns, but `eol=crlf` keeps these blobs as line feeds on purpose, so that guard does not cover them |
| `bad-dead-path` | FAIL `L1`, exit 1 | a link to a file that does not exist |
| `bad-crlf-expect` | FAIL `L1`, exit 1 | the same, on a case that is **CRLF throughout — its `EXPECT` file included**. That is what gives [`expect-check.sh`](tests/expect-check.sh)'s own carriage-return strip a case: it reads `EXPECT` and demands that id in the linter's output, and before the strip the id was `L1` plus a return, which matches no line — so every case in this suite failed there while the linter beside it was right. The case is *named* `crlf` on purpose, which is what puts it inside the runner's case-name check |
| `bad-dead-fragment` | FAIL `L2`, exit 1 | a real file, an anchor it does not have |
| `bad-same-file-fragment` | FAIL `L3`, exit 1 | a bare `#anchor` this file does not have |
| `bad-escapes-root` | FAIL `L4`, exit 1 | a target that climbs out of the tree |
| `bad-no-links` | FAIL `L5`, exit 1 | a file with nothing left to resolve — the fail-open |
| `bad-reference-target` | FAIL `L1`, exit 1 | a broken destination reached only through a `[label]:` definition |
| `bad-nested-link` | FAIL `L1`, exit 1 | a badge-shaped link whose **outer** target is broken and inner one is not |
| `bad-undefined-label` | FAIL `L6`, exit 1 | a reference label nothing defines |
| `bad-absolute-target` | FAIL `L7`, exit 1 | an absolute target, which resolves for any file at the repository root and so passes silently |
| `bad-entry-point-dead-link` | FAIL `L1`, exit 1 | the **redundancy test** — a dead link in a root `AGENTS.md`, locking the coverage that `agents-lint`'s A19 used to provide |
| `bad-collapsed-reference` | FAIL `L6`, exit 1 | the collapsed `[x][]` form, whose empty second bracket makes a naive reader drop it |
| `bad-definition-trailing-link` | FAIL `L1`, exit 1 | a broken link *after* a reference definition on the same line. Since [#78](https://github.com/pharzam/armature/issues/78) the same line also draws `L8`: `[note]: target.md and see also …` is not a definition, because CommonMark allows nothing after the destination and its title, so the label defines nothing. Its `EXPECT` stays `L1`, which the trailing link still reports |
| `good-angle-spaced-destination` | `link-lint: OK`, exit 0 | the CommonMark angle form into a directory whose name holds a space, `[x](<Design Notes/target.md>)` — the spelling that was skipped in silence |
| `good-percent-encoded-space` | `link-lint: OK`, exit 0 | the same path written `Design%20Notes/target.md`, decoded once before it is resolved |
| `bad-angle-spaced-dead` | FAIL `L1`, exit 1 | a dead target behind an angle destination with a space — the case that tells a correct spaced link from a broken one, which nothing could before |
| `bad-bare-spaced-destination` | FAIL `L8`, exit 1 | `[x](Design Notes/target.md)`, a bare destination with a space, which is not a link. The runner cannot see this case; see above |
| `bad-padded-destination` | FAIL `L1`, exit 1 | `[x]( does-not-exist.md )`, blanks padding a dead destination, which the old cut reduced to nothing and dropped in silence |
| `good-placeholder-spaced-definition` | `link-lint: OK`, exit 0 | `[runner]: ‹the test runner›/run.sh`, a definition whose target is an adopter marker holding a blank; the first review round found it drawing a false `L6`, because the `L8` rule had dropped the label before the placeholder test could speak |
| `good-angle-spaced-title` | `link-lint: OK`, exit 0 | `[x](<Design Notes/target.md> "The target")`, the angle form with a title after it, the case's only link. The `>` is what lets the title follow; remove the inline branch's angle clause and the whole text is kept, skipped as a marker, and the case trips `L5` |
| `good-angle-spaced-definition` | `link-lint: OK`, exit 0 | the same, reached through a reference definition; remove the definition branch's angle clause and it trips `L5` |
| `bad-angle-cut-destination` | FAIL `L1`, exit 1 | `[x](<Design Notes/target.md)`, an angle destination with no closing `>`, kept whole and reported; loosen `is_placeholder()` back to "opens with `<`" and it passes in silence |
| `bad-bare-spaced-definition` | FAIL `L8`, exit 1 | `[lbl]: Design Notes/target.md` and a use of `[lbl]`: `L8` on the line and `L6` on the use, both true. The runner cannot see this case; see above |
| `bad-angle-cut-definition` | FAIL `L1`, exit 1 | `[lbl]: <Design Notes/target.md`, an angle destination in a reference definition with no closing `>`. The definition branch keeps it whole and fails `L1` with the whole text; without that clause the line is `L8` with a `<<…>` remedy and its use a false `L6`. The runner cannot see it — it exits 1 either way — so only `expect-check.sh` tells the two apart. |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

Run one: `sh docs/links/link-lint.sh docs/links/tests/good`
Run the reasons: `sh docs/links/tests/expect-check.sh`
