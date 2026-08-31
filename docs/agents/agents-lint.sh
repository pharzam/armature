#!/bin/sh
#
# agents-lint.sh — keep the repository's agent entry points honest, as part of
# the quality gate.
#
# A domain-free discipline test. It lints the root AGENTS.md and the root
# CLAUDE.md against the rules in docs/agents/README.md and against the documents
# they summarise. It reads only text, so it needs no toolchain and runs anywhere.
#
# DERIVE, OR FAIL. The check holds almost no expectation of its own. It reads the
# gate steps out of docs/engineering-discipline.md, the rules and their heading
# anchors and titles out of docs/issue-workflow.md, the mechanized-rule set out
# of that document's "What is enforced where" table, and the shipped-check set
# out of the file tree. So this script can never become a second source of truth:
# a renamed rule, a new R13, a deleted gate step or a newly shipped linter turns
# the gate RED, instead of leaving AGENTS.md and this script agreeing with each
# other and disagreeing with the kit. Every expectation that is NOT derived — the
# thirteen headings, the required literals, the inbound-pointer table — is held
# here in one place and named in the header, the way adr-lint.sh holds the three
# Nygard sections. If you change AGENTS.md's shape, change this list in the SAME
# change; the two must always agree, and that is the whole point of the file.
#
# WHAT IT PROVES: presence, structure and coverage.
# WHAT IT DOES NOT PROVE: semantic agreement — that a compressed sentence means
# what its source paragraph means. It checks coverage, not semantic agreement.
# A stub carrying the right headings, the right anchors and titles, the right
# literals and six filler words per item would pass every assertion below. That
# a summary is a CORRECT summary, that the precedence text is right, that the
# sources table maps each class of rule to the RIGHT document, that a command
# does what its line claims, and that no ‹…› marker was filled with a plausible
# guess, are all review responsibilities — the R12 plan review, the uncapped
# blind review rounds (docs/engineering-discipline.md), and the fresh-context
# confirmation that freezes the tests under R9.
#
# Usage:  sh docs/agents/agents-lint.sh [ROOT]
#   ROOT is the repository root to lint; it defaults to this script's
#   grandparent. A trailing slash is stripped first, because
#   docs/tests/run-discipline-tests.sh passes a case directory WITH one.
#   A fixture case directory IS a miniature repository root: it holds its own
#   AGENTS.md, CLAUDE.md, README.md and docs/, and every input is resolved
#   inside ROOT and nowhere else. There is no shared-fixture fallback and no
#   `if [ -f ] then check` branch anywhere below, so every assertion runs
#   identically for a fixture and for the real repository.
#
# Exit status: 0 = clean, 1 = one or more violations (or a missing hard
# dependency), 2 = a usage error. Exactly 1 — never merely non-zero — is what
# the fixture harness demands of a bad case: it treats any other non-zero code
# as a crashed linter rather than a rejection. Every failure names the assertion
# id and the section, heading, rule number, path or literal at fault.
#
# HARD GATES. A1, A2 and A3 are missing inputs; A8 and A9 are structural
# preconditions — if the heading sequence is wrong, or a stray heading-shaped
# line exists, no section can be scoped, so continuing would print a cascade of
# derived failures for one edit. Those five print one line and exit 1 at once.
# Every other assertion accumulates, so one run reports every violation.
#
# What it asserts, one block per assertion:
#   A1  root AGENTS.md exists and is not empty.                    (hard gate)
#   A2  root CLAUDE.md exists and is not empty.                    (hard gate)
#   A3  the four documents the expectations derive from exist.     (hard gate)
#   A4  root AGENT.md (singular) does not exist.
#   A5  CLAUDE.md holds exactly one non-blank line.
#   A6  that line is byte-exactly `@AGENTS.md`.
#   A7  AGENTS.md holds fewer than MAX_WORDS words.
#   A8  its `## ` heading sequence EQUALS the required list.       (hard gate)
#   A9  it holds no other heading-shaped line, fences included.    (hard gate)
#   A10 every required section holds a real body.
#   A11 the gate section reproduces every step the SOURCE declares, in order,
#       with the source title byte for byte.
#   A12 every gate-step line carries prose, not just a title.
#   A13 the spelled step count equals the SOURCE count.
#   A14 every rule the SOURCE defines has exactly one line, carrying that
#       rule's own derived anchor and its source title.
#   A15 every rule line carries prose — listing `R1 R2 R3` is not coverage.
#   A16 no rule is named that the SOURCE does not define.
#   A17 the spelled rule count equals the SOURCE count.
#   A18 a rule line ends with ` (written rule)` exactly when the SOURCE
#       enforcement table gives it no mechanism, and never contains that
#       phrase when it does.
#   A19 every relative link target resolves under ROOT.
#   A20 the sources-of-truth table names real documents, assigns each a
#       substantive authority, and names the two documents this check derives
#       from in rows of their own.
#   A21 every ready-to-run check the TREE ships is named as its own command
#       line, so the section cannot go stale when a linter is added.
#   A22 every `sh <path>` the file presents, anywhere, resolves to a real file.
#   A23 fifteen required literals appear, each inside its own named section.
#   A24 README.md and docs/onboarding-for-engineers.md LINK the entry point
#       from the section a new operator reads.
#   A25 this script's own header states what it does not prove.
#
# A13, A17, A11 and A14 together are the anti-truncation anchors: without the
# spelled counts, deleting a step or a rule from the SOURCE and from AGENTS.md
# in one change would leave the two agreeing and this check green.
#
# CONSEQUENCES THE AUTHOR OF AGENTS.md MUST HONOUR. Each is enforced above and
# each constrains how the file may be written:
#   - Gate step 0 (an issue is open, with a reviewed ordered plan) is written as
#     PROSE or a `- ` bullet, NEVER as `0. **Title**`. The source states it in
#     prose, so A11 derives eight steps; a ninth numbered line would go red.
#   - The file carries exactly one `#`-initial title line and the thirteen `## `
#     headings, and NOTHING else beginning with `#` — a shell comment inside a
#     fenced block included. A heading-shaped line ends the section above it, so
#     content after it would never be checked (A9).
#   - The `## Sources of truth` table's second column header reads exactly
#     `Authoritative for`; A20 keys its header-row skip on that literal.
#   - A rule line ends with ` (written rule)` for every rule the enforcement
#     table does not back, and contains that phrase nowhere at all for the rest.
#
# TWO DIFFERENT FIVES, so a later reader does not "fix" one to match the other.
# docs/engineering-discipline.md and docs/tests/test-levels.md count five
# discipline LINTERS: adr-lint, prd-lint, pr-link-lint, audit-record-lint and
# agents-lint. A21's derived set and AGENTS.md's `## Checks you can run` count
# five REPO-FILE checks under docs/*/ outside docs/ci/: adr-lint, prd-lint,
# audit-record-lint, agents-lint and run-discipline-tests. Same size, different
# membership, both correct. pr-link-lint reads a pull-request body, so it has no
# local run and is excluded from A21 by construction.
#
# Where it runs: .githooks/pre-commit step 1e, the `agents-lint` job in CI, and
# both inert CI templates. Its own fixtures live under docs/agents/tests/ and
# ARE run by docs/tests/run-discipline-tests.sh. It is deliberately NOT a suite
# inside that runner: the runner is a fixture harness with one case directory
# per assertion, and this check is repo-wide — the same split audit-record-lint
# documents.
#
# Portability: POSIX sh and POSIX awk/sed/grep only. No bash-isms, no gensub, no
# ERE interval expressions, no /dev/stderr, no `find -maxdepth`. An unmatched
# glob stays literal in POSIX sh, so every glob loop carries an `[ -e ]` guard.
# Pathname expansion is off (`set -f`) except where A21 needs it, so a target or
# a literal containing `*` cannot glob. FAIL lines are printed by the shell to
# standard error, so the whole script reports on one stream.

set -u
set -f

# --- pre-registered constants ----------------------------------------------
# Declared here, and in this commit, BEFORE AGENTS.md exists. docs/guardrails.md
# says a decision rule chosen after seeing the result is a fitted parameter, not
# a rule; MAX_WORDS comes from the issue that commissioned this file.
MAX_WORDS=1500
MIN_SECTION_WORDS=15
MIN_ITEM_WORDS=6

nl='
'

case $# in
0|1) : ;;
*)   printf 'agents-lint: usage: sh %s [ROOT]\n' "$0" >&2; exit 2 ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
self="$script_dir/$(basename -- "$0")"
default_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
root=${1:-$default_root}
root=${root%/}
[ -n "$root" ] || root=/

agents="$root/AGENTS.md"
claude="$root/CLAUDE.md"
discipline="$root/docs/engineering-discipline.md"
workflow="$root/docs/issue-workflow.md"

fail=0

# err ID MESSAGE — record one violation and keep going.
err() { printf 'FAIL  %s: %s\n' "$1" "$2" >&2; fail=1; }

# die ID MESSAGE — a hard gate: report and stop, so one edit prints one line.
die() { printf 'FAIL  %s: %s\n' "$1" "$2" >&2; exit 1; }

# emit ID MULTILINE — record one violation per line of MULTILINE.
emit() {
	[ -n "$2" ] || return 0
	printf '%s\n' "$2" | while IFS= read -r _line; do
		printf 'FAIL  %s: %s\n' "$1" "$_line" >&2
	done
	fail=1
}

# words — count whitespace-separated tokens on standard input. The same rule as
# `wc -w`, used by A7 and A10 alike so both counts are reproducible by hand.
words() { awk '{ n += NF } END { print n + 0 }'; }

# sect FILE HEADING — print the body under an exact HEADING, up to the next
# heading at the same or a shallower level. Entry is exact equality, not a
# prefix match. Level-awareness is what stops a deeper `### ` subheading from
# ending its own parent section; A9 is what stops a `#`-initial line inside a
# fenced block from ending one early. An empty extraction is always a violation
# at the call site, never a silent pass.
sect() {
	awk -v h="$2" '
		function lvl(s,   n) { n = 0; while (substr(s, n + 1, 1) == "#") n++; return n }
		$0 == h { s = 1; hl = lvl($0); next }
		s && substr($0, 1, 1) == "#" && lvl($0) <= hl { s = 0 }
		s
	' "$1"
}

# word_to_int WORD — the spelled numbers A13 and A17 read out of prose.
word_to_int() {
	case $1 in
	one) echo 1 ;; two) echo 2 ;; three) echo 3 ;; four) echo 4 ;;
	five) echo 5 ;; six) echo 6 ;; seven) echo 7 ;; eight) echo 8 ;;
	nine) echo 9 ;; ten) echo 10 ;; eleven) echo 11 ;; twelve) echo 12 ;;
	*) echo -1 ;;
	esac
}

# prose_words LINE PREFIX_ERE — count the words a summary line carries once its
# marker prefix, its link targets and the enforcement marker are removed. Only
# tokens holding an ASCII alphanumeric count, so an em dash is not a word.
prose_words() {
	printf '%s\n' "$1" | awk -v pre="$2" '
		{
			line = $0
			sub(pre, "", line)
			sub(/ \(written rule\)$/, "", line)
			while (match(line, /\]\([^)]*\)/))
				line = substr(line, 1, RSTART - 1) " " substr(line, RSTART + RLENGTH)
			n = split(line, w, /[ \t]+/)
			c = 0
			for (j = 1; j <= n; j++) if (w[j] ~ /[A-Za-z0-9]/) c++
			print c
		}'
}

# The thirteen required headings, in order. Held here the way adr-lint.sh holds
# the Nygard sections: change AGENTS.md's shape and change this list in the SAME
# change.
HEADINGS='## What this repository is
## How these instructions rank
## Start here
## The quality gate
## The issue rules
## Checks you can run
## Branches, worktrees, commits, and pull requests
## The task index
## Placeholders and adopter values
## Safety limits
## Decisions and questions
## Sources of truth
## Keeping this file honest'

# --- A1. AGENTS.md is present and not empty --------------------------------
[ -f "$agents" ] || die A1 "AGENTS.md not found or empty: $agents"
[ "$(words < "$agents")" -gt 0 ] || die A1 "AGENTS.md not found or empty: $agents"

# --- A2. CLAUDE.md is present and not empty --------------------------------
[ -f "$claude" ] || die A2 "CLAUDE.md not found or empty: $claude"
[ "$(words < "$claude")" -gt 0 ] || die A2 "CLAUDE.md not found or empty: $claude"

# --- A3. the documents the expectations derive from ------------------------
# One loop over the four paths, not four statements, so the single fixture that
# deletes one of them really does prove the branch for all four. Deliberately
# NOT a soft wrapper: a missing or renamed source document is a defect, not an
# exemption, and an expectation derived from nothing would check nothing.
for f in docs/engineering-discipline.md docs/issue-workflow.md README.md docs/onboarding-for-engineers.md; do
	[ -f "$root/$f" ] || die A3 "$f not found (the expectations derived from it cannot resolve)"
done

# --- A4. no root AGENT.md (singular) ---------------------------------------
# -e, not -f, so a directory or a symlink is caught too. No wider denylist of
# vendor filenames: another vendor entry point needs its own decision, and a
# denylist over root files would go red on a legitimate CONTRIBUTING.md.
[ -e "$root/AGENT.md" ] && err A4 'root AGENT.md exists; the entry point is AGENTS.md (plural), and a second name gives an agent two competing sources of instruction (ADR-0004)'

# --- A5, A6. CLAUDE.md is one exact import line ----------------------------
claude_lines=$(sed 's/[ 	]*$//' "$claude" | awk 'NF { k++ } END { print k + 0 }')
[ "$claude_lines" -eq 1 ] || err A5 "CLAUDE.md holds $claude_lines non-blank lines; it must hold exactly one, the import, so no policy can be duplicated there"
claude_first=$(sed 's/[ 	]*$//' "$claude" | awk 'NF { print; exit }')
[ "$claude_first" = '@AGENTS.md' ] || err A6 "CLAUDE.md's import line is \"$claude_first\"; it must be exactly @AGENTS.md"

# --- A7. the word budget ----------------------------------------------------
agents_words=$(words < "$agents")
[ "$agents_words" -lt "$MAX_WORDS" ] || err A7 "AGENTS.md holds $agents_words words; the pre-registered budget is under $MAX_WORDS"

# --- A8. the heading sequence equals the required list ---------------------
got_headings=$(awk '/^## / { print }' "$agents")
if [ "$got_headings" != "$HEADINGS" ]; then
	diffline=$(printf '%s\n' "$got_headings" | WANT="$HEADINGS" awk '
		BEGIN { wn = split(ENVIRON["WANT"], w, "\n") }
		{ g[NR] = $0; gn = NR }
		END {
			m = (gn > wn) ? gn : wn
			for (i = 1; i <= m; i++)
				if (g[i] != w[i]) {
					printf "heading %d: got \"%s\", want \"%s\"", i, (i in g ? g[i] : "<none>"), (i <= wn ? w[i] : "<none>")
					exit
				}
		}')
	die A8 "AGENTS.md's section headings do not equal the required list — $diffline"
fi

# --- A9. no other heading-shaped line --------------------------------------
# Without this, a single line beginning with `#` inside a fenced block would
# truncate its section for every scoped assertion below while staying invisible
# to A8, which reads only `## ` lines. Everything after it — an invented
# command, a false enforcement claim, a filled placeholder — would go unchecked.
# A9 is what makes sect() provably total over AGENTS.md.
first_nonblank=$(awk 'NF { print; exit }' "$agents")
hashlines=$(awk 'substr($0, 1, 1) == "#" { printf "%d\t%s\n", NR, $0 }' "$agents")
if [ -n "$hashlines" ]; then
	oldIFS=$IFS; IFS=$nl
	seen_title=0
	for hl in $hashlines; do
		num=${hl%%	*}
		text=${hl#*	}
		if [ "$seen_title" -eq 0 ]; then
			seen_title=1
			if [ "$text" = "$first_nonblank" ]; then
				case $text in
				'## '*) : ;;
				'# '*) continue ;;
				esac
			fi
		fi
		case $nl$HEADINGS$nl in
		*"$nl$text$nl"*) continue ;;
		esac
		IFS=$oldIFS
		die A9 "line $num begins with '#' but is neither the title nor a required heading: $text. A heading-shaped line ends the section above it, so content after it is never checked; fenced blocks in this file carry no comments"
	done
	IFS=$oldIFS
fi

# --- A10. every required section has a real body ---------------------------
oldIFS=$IFS; IFS=$nl
for h in $HEADINGS; do
	n=$(sect "$agents" "$h" | words)
	[ "$n" -ge "$MIN_SECTION_WORDS" ] && continue
	IFS=$oldIFS
	err A10 "section \"$h\" holds $n words; a required section needs a body of at least $MIN_SECTION_WORDS"
	IFS=$nl
done
IFS=$oldIFS

# --- the gate steps, DERIVED from the source -------------------------------
STEPS=$(awk '
	/^## / { sec = ($0 == "## Working a task under the quality gate") ? 1 : 0; next }
	sec && /^[0-9]+\. \*\*/ {
		t = $0
		sub(/^[0-9]+\. \*\*/, "", t)
		sub(/\*\*.*$/, "", t)
		print t
	}' "$discipline")
n_steps=$(printf '%s' "$STEPS" | awk 'NF { n++ } END { print n + 0 }')

GATE=$(sect "$agents" '## The quality gate')
got_steps=$(printf '%s\n' "$GATE" | awk '/^[0-9]+\. \*\*/ { print }')
n_got_steps=$(printf '%s' "$got_steps" | awk 'NF { n++ } END { print n + 0 }')

# --- A11. the gate section reproduces every step, in order -----------------
if [ "$n_steps" -eq 0 ]; then
	err A11 'no gate step could be derived from docs/engineering-discipline.md — the heading "## Working a task under the quality gate" was renamed, so this assertion checked nothing'
elif [ "$n_got_steps" -ne "$n_steps" ]; then
	err A11 "AGENTS.md's \"## The quality gate\" lists $n_got_steps numbered steps; docs/engineering-discipline.md declares $n_steps (step 0 is prose in the source and must stay prose here)"
else
	i=0
	oldIFS=$IFS; IFS=$nl
	for title in $STEPS; do
		i=$((i + 1))
		want="$i. **$title**"
		got=$(printf '%s\n' "$got_steps" | awk -v k="$i" 'NR == k { print; exit }')
		case $got in
		"$want"*) continue ;;
		esac
		IFS=$oldIFS
		err A11 "gate step $i must begin with \"$want\"; got \"$got\""
		IFS=$nl
	done
	IFS=$oldIFS
fi

# --- A12. every gate-step line carries prose -------------------------------
if [ "$n_got_steps" -gt 0 ]; then
	out=$(printf '%s\n' "$got_steps" | awk -v min="$MIN_ITEM_WORDS" '
		{
			line = $0
			sub(/^[0-9]+\. \*\*[^*]*\*\*/, "", line)
			while (match(line, /\]\([^)]*\)/))
				line = substr(line, 1, RSTART - 1) " " substr(line, RSTART + RLENGTH)
			n = split(line, w, /[ \t]+/)
			c = 0
			for (j = 1; j <= n; j++) if (w[j] ~ /[A-Za-z0-9]/) c++
			if (c < min)
				printf "gate step %d carries %d words of prose; a step needs at least %d — a bare title list is not a summary\n", NR, c, min
		}')
	emit A12 "$out"
fi

# --- A13. the spelled step count matches the source ------------------------
spelled=$(printf '%s\n' "$GATE" | awk '
	match($0, /\*\*(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\*\* ordered steps/) {
		m = substr($0, RSTART, RLENGTH)
		sub(/^\*\*/, "", m); sub(/\*\*.*$/, "", m)
		print m; exit
	}')
if [ -z "$spelled" ]; then
	err A13 'the gate section states no spelled step count; it must say "**<number>** ordered steps", so deleting a step from both the source and this file cannot pass unnoticed'
else
	got_n=$(word_to_int "$spelled")
	[ "$got_n" -eq "$n_steps" ] || err A13 "the gate section says \"**$spelled** ordered steps\" ($got_n); docs/engineering-discipline.md declares $n_steps"
fi

# --- the rules, DERIVED from the source ------------------------------------
# id|anchor|title. The anchor is the GitHub heading slug the source's own
# `## R<n> — Title` line produces, so a renamed rule breaks the link here.
RULES=$(awk '
	/^## R[0-9]+ / {
		id = $0; sub(/^## /, "", id); sub(/ .*$/, "", id)
		title = $0; sub(/^## R[0-9]+ [^A-Za-z]* /, "", title)
		s = tolower(substr($0, 4))
		gsub(/[^a-z0-9 -]/, "", s)
		gsub(/ /, "-", s)
		printf "%s|%s|%s\n", id, s, title
	}' "$workflow")
n_rules=$(printf '%s' "$RULES" | awk 'NF { n++ } END { print n + 0 }')

# --- the mechanized rules, DERIVED from the enforcement table --------------
# Scoped with sect() to the one table, never a whole-file scan for pipe rows.
# A row that does not split into six columns is a VIOLATION, not a skip: one
# dropped trailing pipe would otherwise silently shrink this set and flip a
# rule's honest marking.
MECH_OUT=$(sect "$workflow" '## What is enforced where' | awk -F'|' '
	function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
	/^\|[ \t:|-]*$/ { next }
	/^\|/ {
		rows++
		if (NF != 8) { printf "E|enforcement-table row does not split into six columns (NF=%d): %s\n", NF, $0; next }
		st = trim($7)
		if (st == "Status") next
		if (st ~ /^Written rule/) next
		n = split($3, a, /[^A-Za-z0-9]+/)
		for (i = 1; i <= n; i++) if (a[i] ~ /^R[0-9]+$/) printf "M|%s\n", a[i]
	}
	END { if (rows == 0) print "E|the \"## What is enforced where\" table holds no rows — the heading was renamed, so no rule can be marked" }')
MECH=' '
oldIFS=$IFS; IFS=$nl
for m in $MECH_OUT; do
	case $m in
	'M|'*) case $MECH in *" ${m#M|} "*) : ;; *) MECH="$MECH${m#M|} " ;; esac ;;
	'E|'*) IFS=$oldIFS; err A18 "${m#E|}"; IFS=$nl ;;
	esac
done
IFS=$oldIFS
[ "$MECH" = ' ' ] && err A18 'no rule is marked as mechanized by the "## What is enforced where" table — the table was emptied, so this assertion checked nothing'

RSEC=$(sect "$agents" '## The issue rules')

# --- A14, A15, A18. one line per rule, with anchor, title, prose and marker -
FOUND=' '
if [ "$n_rules" -eq 0 ]; then
	err A14 'no rule could be derived from docs/issue-workflow.md — its "## R<n> — Title" headings were renamed, so this assertion checked nothing'
else
	oldIFS=$IFS; IFS=$nl
	for r in $RULES; do
		id=${r%%|*}
		rest=${r#*|}
		anchor=${rest%%|*}
		title=${rest#*|}
		cnt=$(printf '%s\n' "$RSEC" | awk -v p="^- [*][*]$id[*][*] " '$0 ~ p { n++ } END { print n + 0 }')
		rline=$(printf '%s\n' "$RSEC" | awk -v p="^- [*][*]$id[*][*] " '$0 ~ p { print; exit }')
		IFS=$oldIFS
		if [ "$cnt" -ne 1 ]; then
			err A14 "rule $id has $cnt lines in \"## The issue rules\"; it must have exactly one, shaped \`- **$id** — [$title](docs/issue-workflow.md#$anchor): …\`"
		else
			FOUND="$FOUND$id "
			case $rline in
			*"issue-workflow.md#$anchor"*) : ;;
			*) err A14 "rule $id's line does not link its own derived anchor issue-workflow.md#$anchor" ;;
			esac
			case $rline in
			*"$title"*) : ;;
			*) err A14 "rule $id's line does not carry its source title \"$title\"; an anchor alone lets a line describe the wrong rule" ;;
			esac
			pw=$(prose_words "$rline" "^- [*][*]$id[*][*] ")
			[ "$pw" -ge "$MIN_ITEM_WORDS" ] || err A15 "rule $id: $pw words of prose; a rule line needs at least $MIN_ITEM_WORDS — listing the identifier is not covering the rule"
			case $MECH in
			*" $id "*)
				case $(printf '%s' "$rline" | tr 'A-Z' 'a-z') in
				*'written rule'*) err A18 "rule $id's line says \"written rule\", but the enforcement table gives it a shipping mechanism today" ;;
				esac
				;;
			*)
				case $rline in
				*' (written rule)') : ;;
				*) err A18 "rule $id's line must END with the literal \" (written rule)\"; the enforcement table backs it with no mechanism, and a claim that it is enforced would be false" ;;
				esac
				;;
			esac
		fi
		IFS=$nl
	done
	IFS=$oldIFS
fi

# --- A16. no invented or stale rule ----------------------------------------
if [ -n "$RSEC" ]; then
	out=$(printf '%s\n' "$RSEC" | KNOWN="$RULES" awk '
		BEGIN {
			n = split(ENVIRON["KNOWN"], k, "\n")
			for (i = 1; i <= n; i++) {
				split(k[i], p, "|")
				okid[p[1]] = 1
				okanchor[p[2]] = 1
			}
		}
		{
			line = $0
			while (match(line, /issue-workflow\.md#r[0-9]+[-a-z0-9]*/)) {
				a = substr(line, RSTART, RLENGTH)
				sub(/^.*#/, "", a)
				if (!(a in okanchor)) print "AGENTS.md links issue-workflow.md#" a ", which docs/issue-workflow.md does not define"
				line = substr(line, RSTART + RLENGTH)
			}
		}
		/^- \*\*R[0-9]+\*\* / {
			id = $0
			sub(/^- \*\*/, "", id)
			sub(/\*\*.*$/, "", id)
			if (!(id in okid)) print "AGENTS.md names rule " id ", which docs/issue-workflow.md does not define"
		}' | sort -u)
	emit A16 "$out"
fi

# --- A17. the spelled rule count matches the source ------------------------
spelled=$(printf '%s\n' "$RSEC" | awk '
	match($0, /\*\*(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\*\* numbered rules/) {
		m = substr($0, RSTART, RLENGTH)
		sub(/^\*\*/, "", m); sub(/\*\*.*$/, "", m)
		print m; exit
	}')
if [ -z "$spelled" ]; then
	err A17 'the rules section states no spelled rule count; it must say "**<number>** numbered rules", so deleting a rule from both the source and this file cannot pass unnoticed'
else
	got_n=$(word_to_int "$spelled")
	[ "$got_n" -eq "$n_rules" ] || err A17 "the rules section says \"**$spelled** numbered rules\" ($got_n); docs/issue-workflow.md defines $n_rules"
fi

# --- A19. every relative link resolves -------------------------------------
LINKS=$(awk '
	{
		line = $0
		while (match(line, /\]\([^)]*\)/)) {
			t = substr(line, RSTART + 2, RLENGTH - 3)
			line = substr(line, RSTART + RLENGTH)
			sub(/#.*$/, "", t)
			if (t != "" && t !~ /^https?:/ && t !~ /^mailto:/) print t
		}
	}' "$agents")
n_links=0
oldIFS=$IFS; IFS=$nl
for t in $LINKS; do
	n_links=$((n_links + 1))
	IFS=$oldIFS
	case $t in
	/* | *../*) err A19 "AGENTS.md links $t, which leaves the repository root" ;;
	*) [ -e "$root/$t" ] || err A19 "AGENTS.md links $t, which is not a path in this repository" ;;
	esac
	IFS=$nl
done
IFS=$oldIFS
[ "$n_links" -gt 0 ] || err A19 'AGENTS.md holds no relative link — this assertion checked nothing'

# --- A20. the sources-of-truth table ---------------------------------------
SSEC=$(sect "$agents" '## Sources of truth')
S_OUT=$(printf '%s\n' "$SSEC" | awk -F'|' '
	function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
	/^\|[ \t:|-]*$/ { next }
	/^\|/ {
		if (NF != 4) { printf "E|sources-of-truth row does not split into two columns (NF=%d): %s\n", NF, $0; next }
		c1 = trim($2); c2 = trim($3)
		if (c2 == "Authoritative for") { hdr = 1; next }
		rows++
		p = c1
		if (match(c1, /\]\([^)]*\)/)) { p = substr(c1, RSTART + 2, RLENGTH - 3); sub(/#.*$/, "", p) }
		else { gsub(/`/, "", p); p = trim(p) }
		printf "P|%s\n", p
		t2 = c2; gsub(/`/, "", t2); t2 = trim(t2)
		n = split(t2, w, /[ \t]+/)
		c = 0
		for (j = 1; j <= n; j++) if (w[j] ~ /[A-Za-z0-9]/) c++
		if (c < MIN) printf "E|the row for \"%s\" has a thin \"Authoritative for\" cell (%d words; a row needs at least %d) — the table must assign an authority, not name a file\n", p, c, MIN
		else if (index(t2, "\342\200\271") == 1) printf "E|the row for \"%s\" fills its \"Authoritative for\" cell with an unreplaced marker\n", p
	}
	END {
		if (!hdr) print "E|the sources-of-truth table has no header row whose second column reads exactly \"Authoritative for\"; that literal is what tells a header from a data row"
		if (rows == 0) print "E|the sources-of-truth table holds no data rows — this assertion checked nothing"
	}' MIN="$MIN_ITEM_WORDS")
s_paths=' '
oldIFS=$IFS; IFS=$nl
for s in $S_OUT; do
	IFS=$oldIFS
	case $s in
	'E|'*) err A20 "${s#E|}" ;;
	'P|'*)
		p=${s#P|}
		s_paths="$s_paths$p "
		[ -e "$root/$p" ] || err A20 "the sources-of-truth table names \"$p\", which is not a path in this repository"
		;;
	esac
	IFS=$nl
done
IFS=$oldIFS
for need in docs/engineering-discipline.md docs/issue-workflow.md; do
	case $s_paths in
	*" $need "*) : ;;
	*) err A20 "the sources-of-truth table gives $need no row of its own; AGENTS.md must declare the documents this check derives its expectations from" ;;
	esac
done

# --- A21. every check the TREE ships is named ------------------------------
CSEC=$(sect "$agents" '## Checks you can run')
SHIPPED=''
n_shipped=0
set +f
for m in "$root"/docs/*/*-lint.sh "$root"/docs/*/run-*-tests.sh; do
	[ -e "$m" ] || continue
	rel=${m#"$root"/}
	case $rel in
	docs/ci/*) continue ;;
	esac
	SHIPPED="$SHIPPED$rel$nl"
	n_shipped=$((n_shipped + 1))
done
set -f
if [ "$n_shipped" -eq 0 ]; then
	err A21 'no ready-to-run check was found under docs/*/ — this assertion checked nothing'
else
	oldIFS=$IFS; IFS=$nl
	for rel in $SHIPPED; do
		hits=$(printf '%s\n' "$CSEC" | awk -v c="sh $rel" '{ l = $0; sub(/[ \t]+$/, "", l); if (l == c) n++ } END { print n + 0 }')
		[ "$hits" -gt 0 ] && continue
		IFS=$oldIFS
		err A21 "the tree ships $rel, but \"## Checks you can run\" does not present it as its own line \`sh $rel\`"
		IFS=$nl
	done
	IFS=$oldIFS
fi

# --- A22. every command the file presents resolves -------------------------
# A whole-file harvest, not a section-scoped one: several sections carry
# commands by design, and an invented command in inline backticks in any of
# them is exactly what acceptance criterion 5 forbids.
CMDS=$(awk '
	{
		line = $0
		gsub(/`/, "", line)
		while (match(line, /(^|[ \t])sh [A-Za-z0-9_.\/-]+/)) {
			c = substr(line, RSTART, RLENGTH)
			sub(/^[ \t]*sh /, "", c)
			print c
			line = substr(line, RSTART + RLENGTH)
		}
	}' "$agents")
n_cmds=0
oldIFS=$IFS; IFS=$nl
for c in $CMDS; do
	n_cmds=$((n_cmds + 1))
	IFS=$oldIFS
	[ -f "$root/$c" ] || err A22 "AGENTS.md presents \`sh $c\`, which is not a file in this repository"
	IFS=$nl
done
IFS=$oldIFS
[ "$n_cmds" -gt 0 ] || err A22 'AGENTS.md presents no `sh <path>` command — this assertion checked nothing'

# --- A23. the required literals, each in its own section -------------------
# section|literal. The separator is `|` because no heading and no literal here
# holds one. These fifteen are the machine floor under the issue-required
# content items that carry no derivation of their own; the MECHANISM is proven
# by one fixture, and the pairs themselves are data, exactly as A8's thirteen
# headings are.
A23_PAIRS='## What this repository is|no product code
## How these instructions rank|higher priority
## How these instructions rank|nested
## Start here|docs/engineering-discipline.md
## The quality gate|on the issue
## The issue rules|issue-workflow.md#what-is-enforced-where
## Checks you can run|git diff --check
## Checks you can run|no product test suite
## Branches, worktrees, commits, and pull requests|worktree
## Branches, worktrees, commits, and pull requests|Conventional Commits
## Branches, worktrees, commits, and pull requests|Closes
## The task index|docs/tasks/backlog.md
## The task index|docs/tasks/completed.md
## Placeholders and adopter values|‹
## Safety limits|secrets
## Safety limits|authorization
## Decisions and questions|on the issue
## Keeping this file honest|docs/agents/agents-lint.sh
## Keeping this file honest|coverage, not semantic agreement'
oldIFS=$IFS; IFS=$nl
for pair in $A23_PAIRS; do
	h=${pair%%|*}
	lit=${pair#*|}
	IFS=$oldIFS
	body=$(sect "$agents" "$h")
	if [ -z "$body" ]; then
		err A23 "section \"$h\" is empty, so the literal \"$lit\" cannot be found in it"
	else
		printf '%s\n' "$body" | grep -Fq -- "$lit" || err A23 "section \"$h\" does not carry the required literal \"$lit\""
	fi
	IFS=$nl
done
IFS=$oldIFS

# --- A24. the entry point is discoverable ----------------------------------
# file|heading|link-target suffix. One fixture proves the mechanism; the four
# triples are data. A bare mention of the filename in prose does not satisfy it.
A24_TRIPLES='README.md|## Start here|AGENTS.md
README.md|## What'"'"'s inside|AGENTS.md
README.md|## What'"'"'s inside|CLAUDE.md
docs/onboarding-for-engineers.md|### What to read next, in order|AGENTS.md'
oldIFS=$IFS; IFS=$nl
for t in $A24_TRIPLES; do
	f=${t%%|*}
	rest=${t#*|}
	h=${rest%%|*}
	sfx=${rest#*|}
	IFS=$oldIFS
	body=$(sect "$root/$f" "$h")
	if [ -z "$body" ]; then
		err A24 "$f has no body under \"$h\" — the heading was renamed, so a reader is no longer pointed at $sfx"
	else
		printf '%s\n' "$body" | awk -v s="$sfx" '
			{
				line = $0
				while (match(line, /\]\([^)]*\)/)) {
					t = substr(line, RSTART + 2, RLENGTH - 3)
					if (length(t) >= length(s) && substr(t, length(t) - length(s) + 1) == s) found = 1
					line = substr(line, RSTART + RLENGTH)
				}
			}
			END { exit found ? 0 : 1 }' \
			|| err A24 "$f does not link $sfx under \"$h\"; a deliverable nobody is pointed to is the same failure as no deliverable"
	fi
	IFS=$nl
done
IFS=$oldIFS

# --- A25. this script states its own limits --------------------------------
# Acceptance criterion 9 is about THIS file's documentation, and nothing else
# below reads it: the script header, docs/agents/README.md and the suite README
# are none of them inputs to any assertion, so all three could be emptied with a
# green gate. This assertion cannot be given a fixture, because a fixture case
# cannot vary the running script; the suite README records that.
grep -Fq -- 'coverage, not semantic agreement' "$self" \
	|| err A25 "agents-lint.sh's own header no longer states that it checks coverage, not semantic agreement"

# --- summary ----------------------------------------------------------------
if [ "$fail" -eq 0 ]; then
	n_written=0
	oldIFS=$IFS; IFS=$nl
	for r in $RULES; do
		id=${r%%|*}
		case $MECH in
		*" $id "*) : ;;
		*) n_written=$((n_written + 1)) ;;
		esac
	done
	IFS=$oldIFS
	printf 'agents-lint: OK  %d words; %d gate steps; %d rules (%d written-rule-only); %d checks named; %d links resolved\n' \
		"$agents_words" "$n_steps" "$n_rules" "$n_written" "$n_shipped" "$n_links"
	exit 0
fi
exit 1
