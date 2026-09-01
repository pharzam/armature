# CRLF bad case

Every line in this file ends with a carriage return, and so does the `EXPECT`
file beside it. That is the point of the case.

`expect-check.sh` reads `EXPECT` and demands the id it holds in the linter's
output. Before it stripped the carriage return, the id was `L1` followed by one,
which matches no output line — so **every** case in this suite failed there
while the linter beside it was reporting correctly. A check failing because the
thing it checks passed.

The link below is dead, so `link-lint` fails `L1` on a CRLF file. That is the
other half: a reference definition is the form the carriage return broke.

[a][r]

[r]: no-such-file.md
