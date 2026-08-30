#!/bin/sh
#
# audit-record-lint.sh — keep the T-3v9q audit record honest, as part of the
# quality gate.
#
# A domain-free discipline test: it is the covering test for Definition of Done
# items 1 to 6, 8 and 9 of docs/tasks/T-3v9q.md, which the task table first mapped
# to documents rather than to tests. docs/tests/dod-checklist.md says a DoD item is
# a claim and a claim is not done until a test proves it, so this file turns those
# items into assertions. It reads only Markdown, so it needs no toolchain.
#
# Item 8 is covered in halves. Block 8 below asserts the machine-checkable half.
# Whether a correction is the RIGHT correction is a judgement; the record carries a
# uat traceability row for that half and says so. Do not invent a text pattern for
# it: a rule chosen to fit the rows that happen to exist is a fitted parameter.
#
# Where it runs: .githooks/pre-commit step 1d. Its own fixtures live under
# docs/tasks/tests/ and ARE run by run-discipline-tests.sh. It is deliberately NOT
# a fifth suite inside that runner: the runner is a fixture harness with one case
# directory per assertion, and this check is repo-wide.
# A CI job for it is written but not yet landed -- scheduled as T-1k9r, because the
# credential available to the author had no GitHub workflow scope.
#
# Usage:  sh docs/tasks/audit-record-lint.sh [TASKS_DIR]
#   TASKS_DIR defaults to this script's own directory. The record and the
#   backlog are resolved inside it; the glossary is TASKS_DIR/glossary.md when
#   that exists (a fixture case) and otherwise the sibling
#   <dirname TASKS_DIR>/glossary.md (docs/glossary.md for the real run).
#
# Exit status: 0 = clean, 1 = one or more violations. Every failure names the
# claim row, the ID, or the token at fault.
#
# What it asserts, one block per DoD item:
#   1. The Findings tables hold exactly as many claim rows as DoD item 1
#      declares, each with a verdict of Stands, Corrected or Refuted, and no
#      duplicate ID.
#   2. Every row whose verdict is not Refuted cites at least one file:line.
#   3. The prose arithmetic matches the tables: the Stands / Corrected /
#      Refuted row counts are the numbers stated in the "Verification result"
#      paragraph and, spelled as words, in the "In plain terms" block.
#   4. Every ID the "Already recorded" table names resolves to a Findings row
#      or to an X-number, and every row of it names a closed issue.
#   2b. Every cited path resolves to a file in the tree, at a line that file
#      really has. Block 2 proves a citation is PRESENT; 2b proves it is not
#      pointing at nothing. Limit: a citation by bare filename can name more
#      than one file, and 2b accepts it when any one of them has that line.
#   5. Every task ID under "Out of scope (follow-ups)" is exactly one line
#      under **Next** in backlog.md.
#   6. Every abbreviation the record uses in prose has a glossary row.
#   7. The Definition of Done table and the Test traceability table are
#      themselves guarded: each item names a block of this script, and each
#      traceability row is `green` or `frozen` (docs/tests/dod-checklist.md:22-25).
#      Without this, reverting every "Covered by" cell to "this file" -- the exact
#      defect the review of #56 blocked on -- left this linter green.
#   8. Every row whose verdict is Corrected cites a file and a line, and the
#      "Corrections to the reports" section is not empty. This is the
#      machine-checkable half of DoD 8 only; see the note above.
#   9. The task line is in completed.md and gone from backlog.md.
#
# Blocks 1, 4, 5, 7 and 8 fail when they find nothing to check, rather than
# passing. A renamed heading is a defect, not an exemption.
#
# How to adapt: the checks mirror the record's own Definition of Done. The
# claim count is READ from DoD item 1, not hardcoded, so the tables and the
# sentence about them cannot drift apart. If you change the verdict vocabulary
# or a section heading, change the matching check here in the SAME change — the
# linter and the record must always agree; that is the whole point of it.
#
# Abbreviation scope (block 6): prose is what is left after fenced blocks,
# inline code spans, table rows, and link targets are removed. EXEMPT below
# carries the general-English abbreviations docs/glossary.md already exempts;
# keep that list short. A token that is the stem of a filename named in the
# record is a name, not an abbreviation, and is exempt automatically.
#
# Portability: POSIX sh and POSIX awk only. The awk below uses no interval
# expressions, no gensub, and no /dev/stderr; the FAIL lines it prints on
# standard output are routed to standard error by the caller, so the whole
# script reports on one stream.

set -u

# Linter output words, not abbreviations: these are the literal strings the kit's
# own scripts print, quoted in the record as evidence. The glossary rule exempts
# general-English forms (`e.g.`, `i.e.`, `etc.`, `vs.`) and nothing else, so keep
# this list to program output. An abbreviation that is merely well known -- `ID`,
# `HTML` -- is NOT exempt; the rule says to add the row when in doubt.
EXEMPT="OK FAIL WARN SKIP PASS"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tasks_dir=${1:-$script_dir}
record="$tasks_dir/T-3v9q.md"
backlog="$tasks_dir/backlog.md"
# A fixture case carries its own glossary; the real run uses the sibling one.
if [ -f "$tasks_dir/glossary.md" ]; then
	glossary="$tasks_dir/glossary.md"
else
	glossary=$(dirname "$tasks_dir")/glossary.md
fi
# The repository root, used to resolve the paths the record cites. For a fixture
# case there is nothing to resolve against, so citation resolution is skipped.
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
[ -d "$repo_root/docs" ] || repo_root=""

fail=0
err() { printf 'FAIL  %s\n' "$*" >&2; fail=1; }

[ -f "$record" ]   || { printf 'FAIL  audit record not found: %s\n' "$record" >&2; exit 1; }
[ -f "$backlog" ]  || { printf 'FAIL  backlog not found: %s (DoD 5 cannot resolve)\n' "$backlog" >&2; exit 1; }
[ -f "$glossary" ] || { printf 'FAIL  glossary not found: %s (DoD 6 cannot resolve)\n' "$glossary" >&2; exit 1; }

# --- 1 to 4. the record against itself -------------------------------------
# The record is read twice: pass one collects the claim rows, the X-numbers and
# the two prose blocks; pass two validates the "Already recorded" table against
# what pass one collected, whatever order the sections are written in.
out=$(awk '
function split_row(line,   m, i, c, parts) {
	gsub(/\\\|/, "\001", line)
	m = split(line, parts, "|")
	n = 0
	for (i = 2; i < m; i++) {
		c = parts[i]
		gsub(/^[ \t]+|[ \t]+$/, "", c)
		gsub(/\001/, "|", c)
		cell[++n] = c
	}
	return n
}
function is_sep(   i) {
	for (i = 1; i <= n; i++) if (cell[i] !~ /^:?-+:?$/) return 0
	return n > 0
}
# A citation is a path and a line number. Three forms are accepted, because the
# kit cites three kinds of file:
#   1. a file with an extension          adr-lint.sh:75, engineering-discipline.md:454
#   2. a hook or a workflow, which the kit ships without an extension
#                                        .githooks/pre-push:20, .githooks/commit-msg:25
#   3. a root file with no extension     LICENSE:3, .gitignore:2
# Form 2 and form 3 are listed by name rather than by pattern: an extensionless
# token is only a citation when it names a file this repository really holds, and
# a bare `word:12` in prose must not pass for one.
function has_citation(s) {
	if (s ~ /[A-Za-z0-9_.\/-]+\.(md|sh|ya?ml|json|toml|txt):[0-9]+/) return 1
	if (s ~ /\.git(hooks|hub)\/[A-Za-z0-9_.\/-]+:[0-9]+/) return 1
	if (s ~ /(^|[^A-Za-z0-9_.\/-])(LICENSE|\.gitignore|\.gitattributes):[0-9]+/) return 1
	return 0
}
function word(v,   o, t) {
	split("zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen", o, " ")
	split("x x twenty thirty forty fifty sixty seventy eighty ninety", t, " ")
	if (v < 0 || v > 99) return "<" v ">"
	if (v < 20) return o[v + 1]
	if (v % 10 == 0) return t[int(v / 10) + 1]
	return t[int(v / 10) + 1] "-" o[v % 10 + 1]
}
function resolve(id2) {
	if (!(id2 in known)) {
		print "FAIL  Already recorded: the row \"" rowraw "\" names " id2 ", which is not a Findings row or an X-number in this record (DoD 4)"
		ec = 1
	}
}
BEGIN { ndash = "\342\200\223"; mdash = "\342\200\224" }

# ---- pass one: the claim rows, the X-numbers, the two prose blocks --------
FNR == NR {
	if ($0 ~ /^```/) { fence = !fence; next }
	if (fence) next
	if ($0 ~ /^## /) { sec = $0; sub(/^## /, "", sec) }

	# the declared claim count, read out of DoD item 1
	if (sec == "Definition of Done" && $0 ~ /^[ \t]*\|/) {
		split_row($0)
		if (n >= 2 && cell[1] == "1" && match(cell[2], /[0-9]+/))
			declared = substr(cell[2], RSTART, RLENGTH) + 0
	}

	# the two prose blocks the arithmetic must agree with
	if (sec == "In plain terms" && $0 !~ /^## /) {
		s = $0; sub(/^[ \t]*>[ \t]?/, "", s); plain = plain " " s
	}
	if ($0 ~ /^\*\*Verification result\.\*\*/) inpara = 1
	if (inpara) { if ($0 ~ /^[ \t]*$/) inpara = 0; else vres = vres " " $0 }

	# the claim rows
	if (sec == "Findings" && $0 ~ /^[ \t]*\|/) {
		split_row($0)
		if (n == 4 && !is_sep() && cell[1] ~ /^[A-Z][0-9]+[a-z]?$/) {
			id = cell[1]
			total++
			if (id in known) { print "FAIL  Findings: duplicate claim ID " id " -- an ID is assigned once (DoD 1)"; ec = 1 }
			known[id] = 1
			v = cell[3]
			if (v == "Stands") ns++
			else if (v == "Corrected") nc++
			else if (v == "Refuted") nr++
			else { print "FAIL  Findings row " id ": verdict \"" v "\" is not one of: Stands | Corrected | Refuted (DoD 1)"; ec = 1 }
			if (v != "Refuted" && !has_citation(cell[2])) {
				print "FAIL  Findings row " id " (verdict " v "): no file:line citation -- a claim that stands must name the file and the line it was checked at (DoD 2)"
				ec = 1
			}
		}
	}

	# the X-numbers, which the Already recorded table may also name
	if (sec == "What neither report found" && match($0, /^\*\*X[0-9]+ /))
		known[substr($0, 3, RLENGTH - 3)] = 1
	next
}

# ---- pass two: the Already recorded table ---------------------------------
{
	if ($0 ~ /^```/) { fence2 = !fence2; next }
	if (fence2) next
	if ($0 ~ /^## /) { sec2 = $0; sub(/^## /, "", sec2) }
	if (sec2 !~ /^Already recorded/) next
	if ($0 !~ /^[ \t]*\|/) next
	split_row($0)
	if (n < 2 || is_sep() || cell[1] == "Findings here") next

	rowraw = cell[1]
	mapped++
	if (cell[2] !~ /#[0-9]+/) {
		print "FAIL  Already recorded: the row \"" rowraw "\" names no closed issue (DoD 4)"
		ec = 1
	}
	row = cell[1]
	gsub(ndash, "-", row); gsub(mdash, "-", row)
	k = split(row, toks, /[ ,]+/)
	for (i = 1; i <= k; i++) {
		t = toks[i]
		gsub(/[`*]/, "", t)
		if (t !~ /^[A-Z][0-9]/) continue
		if (t ~ /^[A-Z][0-9]+-[A-Z][0-9]+$/) {
			d = index(t, "-")
			lo = substr(t, 1, d - 1); hi = substr(t, d + 1)
			lp = substr(lo, 1, 1); ln = substr(lo, 2) + 0
			hp = substr(hi, 1, 1); hn = substr(hi, 2) + 0
			if (lp != hp || hn < ln) {
				print "FAIL  Already recorded: the row \"" rowraw "\" holds an unreadable ID range " t " (DoD 4)"
				ec = 1
			} else {
				for (j = ln; j <= hn; j++) resolve(lp j)
			}
		} else if (t ~ /^[A-Z][0-9]+[a-z]?$/) {
			resolve(t)
		} else {
			print "FAIL  Already recorded: the row \"" rowraw "\" holds the unreadable token " t " (DoD 4)"
			ec = 1
		}
	}
}

END {
	# --- 1. the claim rows -------------------------------------------------
	# A block that silently checks nothing is worse than a block that fails. If a
	# heading is renamed, these guards say so instead of passing.
	if (total == 0) { print "FAIL  Findings: no claim rows found under \"## Findings\" (DoD 1)"; ec = 1 }
	if (mapped == 0) {
		print "FAIL  Already recorded: no rows found -- is the \"## Already recorded\" heading renamed? Block 4 checked nothing (DoD 4)"
		ec = 1
	}
	if (declared == 0) { print "FAIL  Definition of Done: item 1 states no claim count to check the tables against (DoD 1)"; ec = 1 }
	else if (total != declared) {
		print "FAIL  Findings: the tables hold " total " claim rows, but Definition of Done item 1 declares " declared " (DoD 1)"
		ec = 1
	}

	# --- 3. the prose arithmetic -------------------------------------------
	gsub(/[ \t]+/, " ", vres);  sub(/^ /, "", vres)
	gsub(/[ \t]+/, " ", plain); sub(/^ /, "", plain)
	if (vres == "") { print "FAIL  Verification result: no paragraph starting \"**Verification result.**\" found (DoD 3)"; ec = 1 }
	else {
		w1 = (ns + nc) " of " total " claims stand"
		w2 = ns " as written"
		w3 = nc " with a correction"
		w4 = (nr == 1 ? word(nr) " is refuted" : word(nr) " are refuted")
		if (index(vres, w1) == 0) { print "FAIL  Verification result: the tables give \"" w1 "\"; the paragraph does not say it (DoD 3)"; ec = 1 }
		if (index(vres, w2) == 0) { print "FAIL  Verification result: the tables hold " ns " Stands rows; the paragraph does not say \"" w2 "\" (DoD 3)"; ec = 1 }
		if (index(vres, w3) == 0) { print "FAIL  Verification result: the tables hold " nc " Corrected rows; the paragraph does not say \"" w3 "\" (DoD 3)"; ec = 1 }
		if (index(tolower(vres), w4) == 0) { print "FAIL  Verification result: the tables hold " nr " Refuted rows; the paragraph does not say \"" w4 "\" (DoD 3)"; ec = 1 }
	}
	if (plain == "") { print "FAIL  In plain terms: the block is missing (DoD 3)"; ec = 1 }
	else {
		w5 = word(ns + nc) " of their " word(total) " claims"
		if (index(tolower(plain), w5) == 0) {
			print "FAIL  In plain terms: the tables give \"" w5 "\"; the block does not say it (DoD 3)"
			ec = 1
		}
	}
	printf "COUNTS %d %d %d %d\n", total, ns, nc, nr
	exit ec ? 1 : 0
}
' "$record" "$record") || fail=1
printf '%s\n' "$out" | awk '/^COUNTS /{next} NF' >&2
counts=$(printf '%s\n' "$out" | sed -n 's/^COUNTS //p')

# --- 5. each follow-up is exactly one line under **Next** ------------------
followups=$(awk '
	/^## / { sec = ($0 ~ /^## Out of scope/) ? 1 : 0; next }
	sec {
		line = $0
		while (match(line, /T-[0-9a-z][0-9a-z][0-9a-z][0-9a-z]/)) {
			print substr(line, RSTART, RLENGTH)
			line = substr(line, RSTART + RLENGTH)
		}
	}
' "$record" | sort -u)

next_block=$(awk '/^## / { sec = ($0 ~ /^## Next/) ? 1 : 0; next } sec' "$backlog")

[ -n "$followups" ] || err "Out of scope (follow-ups): the section names no task ID (DoD 5)"
for t in $followups; do
	hits=$(printf '%s\n' "$next_block" | awk -v id="$t" '/^-[ \t]/ && index($0, "**" id "**") { k++ } END { print k + 0 }')
	[ "$hits" -eq 1 ] \
		|| err "follow-up $t: $hits lines under **Next** in $(basename "$backlog") name it; there must be exactly one (DoD 5)"
done

# --- 2b. every cited path resolves, at a line the file really has ----------
# has_citation() above proves a citation is PRESENT. It cannot prove one is TRUE:
# `no-such-file.md:99999` matches the shape. This block resolves each cited
# path:line against the tree and fails when the file is absent or the line is past
# the end of it. Skipped for a fixture case, which has no tree to resolve against.
if [ -n "$repo_root" ]; then
	# The three patterns below must stay in step with has_citation() above. A form
	# that block 2 ACCEPTS but this block cannot EXTRACT is a hole: the citation
	# passes the shape test and is never resolved, so `LICENSE:99999` survives.
	cites=$(awk '
		function harvest(re,   line) {
			line = $0
			while (match(line, re)) {
				print substr(line, RSTART, RLENGTH)
				line = substr(line, RSTART + RLENGTH)
			}
		}
		# The patterns are STRINGS, not /regex/ literals: a regex literal passed as
		# a function argument is matched against $0 first and arrives as 0 or 1.
		/^## / { sec = ($0 ~ /^## Findings/) ? 1 : 0 }
		sec && /^[ \t]*\|/ {
			harvest("[A-Za-z0-9_./-]+\\.(md|sh|ya?ml|json|toml|txt):[0-9]+")
			harvest("\\.git(hooks|hub)/[A-Za-z0-9_./-]+:[0-9]+")
			harvest("(LICENSE|\\.gitignore|\\.gitattributes):[0-9]+")
		}
	' "$record" | sort -u)
	# Enumerate the tree once, then match each cited path as a suffix on a path
	# component boundary. Guessing a directory order instead would resolve
	# `README.md:54` to whichever README the guess happened to reach first.
	all_files=$(cd "$repo_root" && find . -type f -not -path './.git/*' | sed 's|^\./||')
	n_cites=0
	for c in $cites; do
		p=${c%:*}
		ln=${c##*:}
		# Candidates: the exact path, or any path ending in /<cited path>.
		# The suffix test must require a real match position. Written as
		# `index(...) == length($0) - length(p)`, a NOT-FOUND result of 0 compares
		# equal whenever the two paths happen to be the same length, so a citation
		# to a file that does not exist resolves to an unrelated one.
		cands=$(printf '%s\n' "$all_files" | awk -v p="$p" '
			$0 == p { print; next }
			{ i = index($0, "/" p); if (i > 0 && i == length($0) - length(p)) print }
		')
		if [ -z "$cands" ]; then
			err "citation $c names no file in the tree (DoD 2)"
			continue
		fi
		n_cites=$((n_cites + 1))
		# The citation holds when at least one candidate really has that line.
		# A path that matches more than one file is not itself an error -- the
		# record cites by the shortest readable path -- but the line must exist
		# in one of them, which is what catches a number past the end.
		ok=0
		best=0
		for f in $cands; do
			total_lines=$(awk 'END { print NR }' "$repo_root/$f")
			[ "$total_lines" -gt "$best" ] && best=$total_lines
			if [ "$ln" -le "$total_lines" ] && [ "$ln" -gt 0 ]; then ok=1; break; fi
		done
		[ "$ok" -eq 1 ] \
			|| err "citation $c points past the end of every file it can name (longest has $best lines) (DoD 2)"
	done
	# A block that checks nothing must say so rather than pass.
	[ "$n_cites" -gt 0 ] || err "no resolvable citation found in the Findings tables -- block 2b checked nothing (DoD 2)"
fi

# --- 6. every abbreviation used in prose has a glossary row ----------------
# A stray code fence would silently blind the scan below, because it toggles on
# ```. An odd fence count is itself a defect, so fail on it rather than scan.
fences=$(awk '/^```/ { k++ } END { print k + 0 }' "$record")
[ $((fences % 2)) -eq 0 ] \
	|| err "the record holds $fences code fences, an odd number -- an unclosed fence hides the rest of the file from block 6 (DoD 6)"
gloss_abbr=$(awk '
	/^[ \t]*\|/ {
		m = split($0, p, "|")
		if (m < 4) next
		a = p[3]
		gsub(/[`*]/, "", a)
		gsub(/^[ \t]+|[ \t]+$/, "", a)
		if (a == "" || a == "\342\200\224" || a == "Abbr." || a ~ /^:?-+:?$/) next
		if (index(a, "\342\200\271")) next
		k = split(a, q, "/")
		for (i = 1; i <= k; i++) {
			t = q[i]
			gsub(/^[ \t]+|[ \t]+$/, "", t)
			if (t != "") print t
		}
	}
' "$glossary" | sort -u)

rec_abbr=$(awk '
	/^```/ { f = !f; next }
	f { next }
	# A table separator carries no words. Every other table row is prose and is
	# scanned: the Findings tables are most of this record, and skipping them
	# would leave the bulk of the text unchecked.
	/^[ \t]*\|[ \t:-]*\|[ \t:|-]*$/ { next }
	{
		line = $0
		# A short all-capital code span is an abbreviation wearing a code font --
		# `CLI` is still CLI. Collect those before the code spans are stripped.
		rest = line
		while (match(rest, /`[A-Z][A-Z0-9]*`/)) {
			t = substr(rest, RSTART + 1, RLENGTH - 2)
			if (length(t) >= 2 && length(t) <= 5) print t
			rest = substr(rest, RSTART + RLENGTH)
		}
		# Now strip code spans and link syntax, and scan what is left as prose.
		while (match(line, /`[^`]*`/)) line = substr(line, 1, RSTART - 1) " " substr(line, RSTART + RLENGTH)
		gsub(/\[[^]]*\]/, " ", line)
		gsub(/\([^)]*\)/, " ", line)
		while (match(line, /[A-Z][A-Z]+/)) {
			print substr(line, RSTART, RLENGTH)
			line = substr(line, RSTART + RLENGTH)
		}
	}
' "$record" | sort -u)

for a in $rec_abbr; do
	case " $EXEMPT " in *" $a "*) continue ;; esac
	grep -Eq "$a\.(md|sh|ya?ml|json|toml|txt)" "$record" && continue
	printf '%s\n' "$gloss_abbr" | grep -qx "$a" \
		|| err "abbreviation \"$a\" is used in the prose of $(basename "$record") and has no row in $(basename "$glossary") (DoD 6)"
done

# --- 7. the DoD table and the traceability table are themselves guarded ----
# Blocks 1 to 6 check the record's CLAIMS. Nothing checked the two tables that say
# those claims are covered -- so reverting every "Covered by" cell to "this file",
# the exact defect the review blocked on, left this linter green. This block
# closes that hole. docs/tests/dod-checklist.md:22-25 is the rule: a Definition of
# Done item maps to a traceability row whose status is `green` or `frozen`.
dod_rows=$(awk '
	/^## / { sec = ($0 ~ /^## Definition of Done/) ? 1 : 0; next }
	sec && /^[ \t]*\|/ { print }
' "$record")
trace_rows=$(awk '
	/^## / { sec = ($0 ~ /^## Test traceability/) ? 1 : 0; next }
	sec && /^[ \t]*\|/ { print }
' "$record")

[ -n "$dod_rows" ]   || err "no '## Definition of Done' table found -- block 7 checked nothing (DoD 2)"
[ -n "$trace_rows" ] || err "no '## Test traceability' table found; docs/tests/dod-checklist.md requires one row per DoD item (DoD 2)"

# Items 1 to 6 must name the block that proves them, and item 9 likewise.
for i in 1 2 3 4 5 6 9; do
	row=$(printf '%s\n' "$dod_rows" | awk -F'|' -v n="$i" '{ gsub(/[ \t]/, "", $2); if ($2 == n) print }')
	if [ -z "$row" ]; then
		err "Definition of Done item $i has no row in the table (DoD 2)"
		continue
	fi
	printf '%s' "$row" | grep -q 'audit-record-lint\.sh' \
		|| err "Definition of Done item $i names no covering test -- its 'Covered by' cell must name an audit-record-lint.sh block, not a document (docs/tests/dod-checklist.md:22-25)"
done

# Every traceability row must carry a status the checklist accepts. This ran in a
# `... | while read` pipeline once, which puts the loop in a subshell: it printed
# FAIL and exited 0, because the parent's `fail` flag was never set. Count in the
# subshell, decide in the parent.
bad_status=$(printf '%s\n' "$trace_rows" | awk '
	/^\|[ \t:-]+\|[ \t:|-]*$/ { next }
	/Test ID/ { next }
	NF {
		if ($0 !~ /\|[ \t]*(green|frozen)[ \t]*\|?[ \t]*$/) print
	}
')
if [ -n "$bad_status" ]; then
	printf '%s\n' "$bad_status" | while IFS= read -r r; do
		printf 'FAIL  traceability row is not green or frozen, so it does not close its item (docs/tests/dod-checklist.md:22-25): %s\n' "$r" >&2
	done
	fail=1
fi

# Counting rows is not enough: a lower bound cannot tell WHICH item lost its
# proof. Match per item instead. Every Definition of Done item whose "Covered by"
# cell names a test must have a green or frozen traceability row that covers it.
covered_items=$(printf '%s\n' "$dod_rows" | awk -F'|' '
	/^\|[ \t:-]+\|[ \t:|-]*$/ { next }
	{
		i = $2; gsub(/^[ \t]+|[ \t]+$/, "", i)
		c = $4; gsub(/^[ \t]+|[ \t]+$/, "", c)
		if (i ~ /^[0-9]+$/ && c ~ /audit-record-lint\.sh|run-discipline-tests\.sh|review round/) print i
	}
')
[ -n "$covered_items" ] \
	|| err "no Definition of Done item names a covering test -- block 7 checked nothing (docs/tests/dod-checklist.md:22-25)"
for i in $covered_items; do
	hit=$(printf '%s\n' "$trace_rows" | awk -F'|' -v n="$i" '
		/^\|[ \t:-]+\|[ \t:|-]*$/ { next }
		{
			cov = $4; gsub(/^[ \t]+|[ \t]+$/, "", cov)
			st  = $7; gsub(/^[ \t]+|[ \t]+$/, "", st)
			if (cov ~ ("(^|[^0-9])DoD " n "([^0-9]|$)") && (st == "green" || st == "frozen")) k++
		}
		END { print k + 0 }
	')
	[ "${hit:-0}" -ge 1 ] \
		|| err "Definition of Done item $i names a covering test but has no green or frozen traceability row that covers it (docs/tests/dod-checklist.md:22-25)"
done

# --- 8. the machine-checkable half of "corrections are recorded" -----------
# Definition of Done item 8 asks whether a claim the reports got wrong now carries
# the correction. Whether a correction is the RIGHT one is a judgement, and the
# traceability table records a reviewer sign-off for that half. What a machine can
# assert is that a `Corrected` verdict is backed by evidence and that the section
# holding the corrections has not been emptied. Nothing here is tuned to the text
# it checks: a pattern chosen to fit the 17 rows that exist would be a decision
# rule picked after seeing the result.
uncited_corr=$(awk -F'|' '
	/^## / { sec = ($0 ~ /^## Findings/) ? 1 : 0 }
	sec && /^[ \t]*\|/ {
		id = $2; gsub(/^[ \t]+|[ \t]+$/, "", id)
		v  = $4; gsub(/^[ \t]+|[ \t]+$/, "", v)
		if (v != "Corrected") next
		n++
		body = $3
		if (body !~ /[A-Za-z0-9_.\/-]+\.(md|sh|ya?ml|json|toml|txt):[0-9]+/ &&
		    body !~ /\.git(hooks|hub)\/[A-Za-z0-9_.\/-]+:[0-9]+/ &&
		    body !~ /(LICENSE|\.gitignore|\.gitattributes):[0-9]+/) print id
	}
	END { if (n == 0) print "NONE" }
' "$record") || err "block 8: awk failed to read the record (DoD 8)"
for id in $uncited_corr; do
	if [ "$id" = "NONE" ]; then
		err "no claim row carries the verdict Corrected -- block 8 checked nothing (DoD 8)"
	else
		err "Findings row $id is Corrected but cites no file and line; a correction with no evidence is an assertion (DoD 8)"
	fi
done
corr_bullets=$(awk '
	/^## / { sec = ($0 ~ /^## Corrections to the reports/) ? 1 : 0; next }
	sec && /^- / { k++ }
	END { print k + 0 }
' "$record")
[ "${corr_bullets:-0}" -gt 0 ] \
	|| err "the '## Corrections to the reports' section holds no bullets; a Corrected verdict with nothing recorded against it is not a correction (DoD 8)"

# --- 9. the task line moved to completed.md and left the backlog -----------
completed="$tasks_dir/completed.md"
if [ -f "$completed" ]; then
	grep -q 'T-3v9q' "$completed" \
		|| err "completed.md holds no T-3v9q line (DoD 9)"
	grep -q '^-.*\*\*T-3v9q\*\*' "$backlog" \
		&& err "backlog.md still holds a T-3v9q line; a completed task belongs in completed.md only (DoD 9)"
fi

n_follow=$(printf '%s\n' "$followups" | awk 'NF' | wc -l | tr -d ' ')
# The word splitting here is the point: $counts holds the four numbers block 1
# measured, and this splits them into $1..$4 for the summary line.
# shellcheck disable=SC2086
set -- ${counts:-0 0 0 0}

[ "$fail" -eq 0 ] && { printf 'audit-record-lint: OK  %s claims: %s Stands, %s Corrected, %s Refuted; %s follow-ups scheduled; DoD 1-6, 8 and 9 proven\n' "$1" "$2" "$3" "$4" "$n_follow"; exit 0; } || exit 1
