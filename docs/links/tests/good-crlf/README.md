# link-lint CRLF fixture

Every line in this file ends with a carriage return, the way a file written on
Windows does. It is pinned that way by the repository `.gitattributes`. Without
the pin, anyone whose git is set to `core.autocrlf=input` or `true` strips the
returns the next time they **stage** it — that conversion runs on the way *into*
the blob, not on checkout — and this case then passes while testing nothing.

Git normally skips that conversion for a file whose index blob already holds
carriage returns, so an ordinary CRLF-tracked file survives a re-commit. This one
is not protected by that: `eol=crlf` keeps the blob as line feeds on purpose, so
there is nothing for the guard to grip.

The reference definitions below are the form that broke. The extractor cuts a
destination at the first space or tab, and a carriage return is neither, so
`target.md` arrived carrying one and no path matched it.

An inline destination was never affected — the closing parenthesis separates the
carriage return from the path — so this file carries both forms, and only one of
them was ever broken.

## Own Head

| Form | Link | Was it broken? |
| ---- | ---- | -------------- |
| inline | [a](target.md) | no |
| angle | [b](<target.md>) | no |
| raw HTML | <a href="target.md">c</a> | no |
| reference definition | [d][r] | **yes, L1** |
| reference definition with a fragment | [e][f] | **yes, L2** |
| reference definition, same file | [g][s] | **yes, L3** |

[r]: target.md
[f]: target.md#head-one
[s]: #own-head
