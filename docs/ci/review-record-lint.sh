#!/bin/sh
#
# review-record-lint.sh — enforce the review record and its chronology.
#
# A domain-free discipline test, the CI twin of
# docs/adr/0008-stop-the-gate-on-a-frozen-head.md section 6 (the review record)
# and docs/issue-workflow.md (R12, the plan and its one review). It reads an
# issue's comments as text and passes only when the record a task leaves behind
# can be parsed and its chronology holds.
#
# Like pr-link-lint.sh and unlike the other linters, it has no repo files to
# lint: issue comments are a forge artifact. So this runs in CI (docs/ci/) and
# NOT in the pre-commit hook, and the forge call lives in the workflow while the
# parsing lives here — which is what makes it testable offline.
#
# Usage:
#   sh docs/ci/review-record-lint.sh [COMMENTS_FILE]
#     COMMENTS_FILE  a file holding the comment stream (used by the self-tests).
#                    With no argument the stream is read from stdin, e.g. in CI:
#                      gh api ... | sh docs/ci/review-record-lint.sh
#
# Exit status: 0 = the record parses and its chronology holds, 1 = it does not.
#
# INPUT CONTRACT. ADR-0008 section 6 leaves the contract to this check, and this
# is it. The stream is the issue's comments oldest-first, each introduced by a
# separator line:
#
#   === comment created=<ISO-8601> updated=<ISO-8601> ===
#   <the comment body, any number of lines>
#
# A FIELD may be written either way, because both are in use and neither is
# wrong: as a table row `| Commit reviewed | <value> |`, or as a section heading
# `### Commit reviewed` with the value on the next non-blank line. The name may
# carry Markdown emphasis — `Cycle`, **Cycle** and Cycle are the same field.
#
# A VALUE is read out of its cell rather than required to be the whole cell. Real
# records write "`0` — `1750556` is this branch's first frozen head", and the
# datum is the `0`. So the SHA, the cycle number and the verdict are each FOUND
# in the value, not matched against it. This is deliberate: a check that forced
# reviewers to strip their own context would be answered by stripping the
# context, not by writing better records.
#
# The timestamps are compared as strings, which is why ISO-8601 in one timezone
# is required: it sorts lexically. The workflow that feeds this is responsible
# for emitting UTC.
#
# WHAT IT ASSERTS.
#   RR1  a plan comment exists                      — R12
#   RR2  a plan-review confirmation exists, carrying `Verdict`, `Budget maximum`
#        and `Cycle cap`                             — R12, ADR-0008 section 6
#   RR3  at least one review record exists           — ADR-0008 section 6
#   RR4  every record carries the reviewer's nine fields
#   RR5  `Commit reviewed` is a hexadecimal SHA, 7 to 40 characters
#   RR6  `Cycle` is a non-negative integer
#   RR7  round numbers run 1..n with no gap; `Cycle` values run 0..k with no gap;
#        and k does not exceed the declared cap
#   RR8  the verdict vocabulary is closed and position-correct: an intermediate
#        round is `material`; the last round is `nothing material in scope` or
#        `not mergeable, findings recorded`
#   RR9  chronology: the plan precedes its review, the review precedes round 1,
#        and the rounds are in ascending order of round number
#
# WHAT IT DOES NOT ASSERT, and cannot. That the reviewer did not read a barred
# comment. That the model named is the model used. That a round which ran was
# posted at all — a round that ran and was not posted leaves no trace here. It
# makes the record parseable and its chronology checkable; it claims nothing
# more, which is what ADR-0008 section 6 says of the record itself.
#
# An edited comment (updated later than created) is REPORTED, not failed:
# ADR-0008 section 5 says a later change is a new comment rather than an edit, so
# an edit is worth a reader's eye but is not by itself a broken record.
#
# `Fixes` is the author's field and lands as a reply after the round, so RR4 does
# not require it: section 6 says a record with no `Fixes` is complete until the
# fixes land.
#
# How to adapt: the field names, the verdict values and the heading come from
# ADR-0008 section 6. If you change that section, change this script in the SAME
# change — the record and its parser must always agree.

set -u

src=${1:-}
if [ -n "$src" ]; then
	[ -f "$src" ] || { printf 'FAIL  review-record-lint: comments file not found: %s\n' "$src" >&2; exit 1; }
	stream=$(cat -- "$src")
else
	stream=$(cat)
fi

printf '%s\n' "$stream" | awk '
function err(id, msg) { printf "FAIL  %s: %s\n", id, msg > "/dev/stderr"; bad++ }
function note(msg)    { printf "note  %s\n", msg }

# Strip a leading/trailing pipe, spaces and backticks from a table cell.
function cell(s) {
	gsub(/^[ \t|]+|[ \t|]+$/, "", s)
	gsub(/[`*_]/, "", s)
	gsub(/^[ \t]+|[ \t]+$/, "", s)
	return s
}

# Does the closed value v appear in the free text s? Values are found, not
# matched, for the reason the header gives.
function has(s, v) { return index(s, v) > 0 }

/^=== comment created=/ {
	created = $0; updated = $0
	sub(/^.*created=/, "", created); sub(/ .*$/, "", created)
	sub(/^.*updated=/, "", updated); sub(/ ===$/, "", updated)
	c_created = created; c_updated = updated
	ncomment++
	if (c_updated != c_created) edited++
	is_plan = 0; is_planrev = 0; in_rec = 0
	next
}

# --- comment classification -------------------------------------------------
/^## Plan review/ {
	is_planrev = 1; seen_planrev++
	if (planrev_at == "") planrev_at = c_created
	next
}
/^## Plan/ {
	is_plan = 1; seen_plan++
	if (plan_at == "") plan_at = c_created
	next
}
/^## Review record/ {
	# The separator between "Review record" and the number is the ADR-s em dash;
	# accept any run of non-digits so a hyphen typed by hand is not a false red.
	line = $0
	# The number FOLLOWS the word "round"; real headings carry context after it,
	# e.g. "round 1 (PR A), lens: ...". Taking the last number on the line reads
	# that context instead, so anchor on the word.
	if (match(line, /[Rr]ound[^0-9]*[0-9]+/) == 0) { err("RR3", "a review record heading names no round number: " line); next }
	seg = substr(line, RSTART, RLENGTH)
	match(seg, /[0-9]+/)
	round_no = substr(seg, RSTART, RLENGTH) + 0
	in_rec = 1; nrec++
	rec_created[nrec] = c_created
	rec_round[nrec] = round_no
	for (f in want) have[nrec, f] = 0
	pending = ""
	next
}

# A field written as `### Name`, with its value on the next non-blank line.
/^#{1,4} / {
	h = $0; sub(/^#+[ \t]+/, "", h)
	inline = ""
	# `# Verdict: \`approve\`` puts the value on the same line as its name.
	if (index(h, ":") > 0) { inline = substr(h, index(h, ":") + 1); h = substr(h, 1, index(h, ":") - 1) }
	h = cell(h); inline = cell(inline)
	pending = ""
	if (is_planrev && h == "Verdict" && inline != "") { pr_verdict = inline; next }
	if (is_planrev && h == "Budget maximum" && inline != "") { pr_budget = inline; next }
	if (is_planrev && h == "Cycle cap" && inline != "") { pr_cap = inline; next }
	if (is_planrev && (h == "Verdict" || h == "Budget maximum" || h == "Cycle cap")) { pending_pr = h; next }
	if (in_rec && (h in want)) {
		have[nrec, h] = 1
		if (inline != "") {
			if (h == "Commit reviewed" && rec_sha[nrec] == "")   rec_sha[nrec] = inline
			if (h == "Cycle"           && rec_cycle[nrec] == "") rec_cycle[nrec] = inline
			if (h == "Verdict"         && rec_verdict[nrec] == "") rec_verdict[nrec] = inline
		} else pending = h
	}
	next
}

pending_pr != "" && NF > 0 {
	v = cell($0)
	if (pending_pr == "Verdict" && pr_verdict == "")        pr_verdict = v
	if (pending_pr == "Budget maximum" && pr_budget == "")  pr_budget = v
	if (pending_pr == "Cycle cap" && pr_cap == "")          pr_cap = v
	pending_pr = ""
}

pending != "" && NF > 0 {
	v = cell($0)
	if (pending == "Commit reviewed" && rec_sha[nrec] == "")   rec_sha[nrec] = v
	if (pending == "Cycle"           && rec_cycle[nrec] == "") rec_cycle[nrec] = v
	if (pending == "Verdict"         && rec_verdict[nrec] == "") rec_verdict[nrec] = v
	pending = ""
}

# --- field rows -------------------------------------------------------------
/^\|/ {
	n = split($0, p, "|")
	if (n < 3) next
	k = cell(p[2]); v = cell(p[3])
	if (is_planrev) {
		if (k == "Verdict")       pr_verdict = v
		if (k == "Budget maximum") pr_budget = v
		if (k == "Cycle cap")      pr_cap = v
	}
	if (in_rec) {
		have[nrec, k] = 1
		if (k == "Commit reviewed") rec_sha[nrec] = v
		if (k == "Cycle")           rec_cycle[nrec] = v
		if (k == "Verdict")         rec_verdict[nrec] = v
	}
	next
}

BEGIN {
	split("Commit reviewed,Reviewer,Lens,Briefed on,Barred from,Independence claimed,Cycle,Raw findings,Verdict", w, ",")
	for (i in w) want[w[i]] = 1
	bad = 0
}

END {
	if (ncomment == 0) { err("RR0", "the comment stream is empty or has no `=== comment ... ===` separators"); exit 1 }

	if (seen_plan == 0)    err("RR1", "no plan comment (R12): expected a comment whose heading starts `## Plan`")
	if (seen_planrev == 0) err("RR2", "no plan-review confirmation (R12): expected a comment whose heading starts `## Plan review`")
	else {
		if (pr_verdict == "") err("RR2", "the plan review carries no `Verdict`")
		else if (!has(pr_verdict, "approve") && !has(pr_verdict, "reject"))
			err("RR8", "the plan review names no plan-review verdict (approve, approve-with-conditions, reject): " pr_verdict)
		if (pr_budget == "") err("RR2", "the plan review carries no `Budget maximum`")
		if (pr_cap == "")    err("RR2", "the plan review carries no `Cycle cap`")
	}

	if (nrec == 0) { err("RR3", "no review record: expected a comment whose heading starts `## Review record`") }

	cap = -1
	if (pr_cap != "" && match(pr_cap, /[0-9]+/) > 0) cap = substr(pr_cap, RSTART, RLENGTH) + 0
	else if (pr_cap != "") err("RR2", "the plan review-s `Cycle cap` holds no number: " pr_cap)

	for (i = 1; i <= nrec; i++) {
		for (f in want)
			if (!have[i, f]) err("RR4", "round " rec_round[i] " carries no `" f "`")

		s = rec_sha[i]
		if (have[i, "Commit reviewed"] && s == "")
			err("RR4", "round " rec_round[i] " names `Commit reviewed` but gives no value")
		if (have[i, "Cycle"] && rec_cycle[i] == "")
			err("RR4", "round " rec_round[i] " names `Cycle` but gives no value")
		if (s != "" && match(s, /[0-9a-fA-F]{7,40}/) == 0)
			err("RR5", "round " rec_round[i] " `Commit reviewed` holds no 7-to-40 character hexadecimal SHA: " s)

		cy = ""
		if (rec_cycle[i] != "" && match(rec_cycle[i], /[0-9]+/) > 0)
			cy = substr(rec_cycle[i], RSTART, RLENGTH)
		if (rec_cycle[i] != "" && cy == "")
			err("RR6", "round " rec_round[i] " `Cycle` holds no non-negative integer: " rec_cycle[i])

		# RR7 — round numbers contiguous from 1, cycles contiguous from 0.
		if (rec_round[i] != i)
			err("RR7", "round numbers are not 1..n without a gap: record " i " is round " rec_round[i])
		if (cy ~ /^[0-9]+$/ && cy + 0 != i - 1)
			err("RR7", "round " rec_round[i] " has `Cycle` " cy "; the k-th record carries cycle k-1")
		if (cy ~ /^[0-9]+$/ && cap >= 0 && cy + 0 > cap)
			err("RR7", "round " rec_round[i] " has `Cycle` " cy ", past the declared cap of " cap)

		# RR9 — rounds in ascending time. Before the verdict work, so an absent
		# verdict cannot skip it.
		if (i > 1 && rec_created[i] < rec_created[i-1])
			err("RR9", "round " rec_round[i] " was posted before round " rec_round[i-1])

		# RR8 — verdict vocabulary, by position.
		v = rec_verdict[i]
		last = (i == nrec)
		if (v == "") { err("RR4", "round " rec_round[i] " names `Verdict` but gives no value"); continue }
		if (last) {
			if (!has(v, "nothing material in scope") && !has(v, "not mergeable, findings recorded"))
				err("RR8", "the last round names no last-round verdict: " v)
		} else {
			# "material" is a substring of "nothing material in scope", so an
			# intermediate round is checked by excluding the two last-round
			# values rather than by finding the word.
			if (has(v, "nothing material in scope") || has(v, "not mergeable, findings recorded") || v !~ /(^|[^A-Za-z])material/)
				err("RR8", "round " rec_round[i] " is followed by another round, so its verdict must be `material`: " v)
		}

	}

	# RR9 — plan, then its review, then the first round.
	if (plan_at != "" && planrev_at != "" && planrev_at < plan_at)
		err("RR9", "the plan review (" planrev_at ") precedes the plan (" plan_at ")")
	if (planrev_at != "" && nrec > 0 && rec_created[1] < planrev_at)
		err("RR9", "round " rec_round[1] " (" rec_created[1] ") precedes the plan review (" planrev_at ")")

	if (bad > 0) exit 1

	if (edited > 0)
		note(edited " comment(s) edited after posting; ADR-0008 section 5 asks for a new comment rather than an edit")
	printf "review-record-lint: OK  %d comments; %d round(s); cap %s\n", ncomment, nrec, (pr_cap == "" ? "-" : pr_cap)
	exit 0
}
'
