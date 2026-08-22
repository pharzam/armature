#!/bin/sh
#
# adr-lint.sh — keep docs/adr/ honest, as part of the quality gate.
#
# A domain-free discipline test: it lints the Architecture Decision Records
# against the conventions in template.md and README.md, so the ADR log cannot
# quietly drift. It reads only Markdown, so it needs no toolchain and can be the
# project's first test — before any product code exists. It runs in the
# pre-commit hook and in CI (see docs/ci/), and is the reference the
# "Testing" gate step points to.
#
# Usage:  sh docs/adr/adr-lint.sh [ADR_DIR]
#   ADR_DIR defaults to this script's own directory.
#
# Exit status: 0 = clean, 1 = one or more violations. A missing inbound
# cross-link is a non-fatal WARNing (a brand-new ADR may not be linked yet).
#
# How to adapt: the checks below mirror docs/adr/template.md and README.md. If
# you change the template — add a required section, change the Status vocabulary
# — change the matching check here in the SAME change. The linter and the
# template must always agree; that is the whole point of it.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
adr_dir=${1:-$script_dir}
readme="$adr_dir/README.md"

fail=0
err()  { printf 'FAIL  %s\n' "$*" >&2; fail=1; }
note() { printf 'WARN  %s\n' "$*" >&2; }

[ -d "$adr_dir" ] || { printf 'FAIL  ADR directory not found: %s\n' "$adr_dir" >&2; exit 1; }
[ -f "$readme" ]  || err "missing $readme (the ADR index)"

# Is $1 (stem) or $2 (ADR-NNNN shorthand) referenced from a Markdown file
# outside the ADR directory, or the repo-root README? Non-ADR inbound links are
# what keep the "what" and the "why" connected.
is_cross_linked() {
	_stem=$1; _short=$2
	_docs=$(dirname "$adr_dir")
	_root=$(dirname "$_docs")
	if grep -R -Fl -e "$_stem" -e "$_short" --include='*.md' "$_docs" 2>/dev/null \
		| grep -qv "^$adr_dir/"; then
		return 0
	fi
	[ -f "$_root/README.md" ] && grep -Fq -e "$_stem" -e "$_short" "$_root/README.md" && return 0
	return 1
}

# --- 1. filenames; collect the valid ADR files -----------------------------
adr_files=""
for path in "$adr_dir"/*.md; do
	[ -e "$path" ] || continue
	name=$(basename "$path")
	[ "$name" = "README.md" ] && continue
	[ "$name" = "template.md" ] && continue
	if printf '%s' "$name" | grep -Eq '^[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$'; then
		adr_files="$adr_files $path"
	else
		err "$name: filename must be NNNN-kebab-case.md (four digits, zero-padded)"
	fi
done

if [ -z "${adr_files# }" ]; then
	# No ADRs yet is a valid state for a fresh project.
	[ "$fail" -eq 0 ] && exit 0 || exit 1
fi

# --- 2. sequential + unique numbering --------------------------------------
numbers=$(for p in $adr_files; do basename "$p" | cut -c1-4; done | sort)
prev=""
expected=1
for n in $numbers; do
	[ "$n" = "$prev" ] && err "duplicate ADR number: $n"
	if [ "$prev" != "$n" ]; then
		nval=$(printf '%s' "$n" | sed 's/^0*//'); [ -z "$nval" ] && nval=0
		if [ "$nval" -ne "$expected" ]; then
			err "ADR numbers must be contiguous from 0001; expected $(printf '%04d' "$expected"), found $n"
		fi
		expected=$((expected + 1))
	fi
	prev="$n"
done

# --- 3. per-file structure -------------------------------------------------
for path in $adr_files; do
	name=$(basename "$path")
	num=$(printf '%s' "$name" | cut -c1-4)
	numval=$(printf '%s' "$num" | sed 's/^0*//'); [ -z "$numval" ] && numval=0

	# 3a. title: first non-blank line is "# NNNN. <title>" (padded or unpadded).
	title=$(awk 'NF{print; exit}' "$path")
	printf '%s' "$title" | grep -Eq "^# 0*${numval}\. " \
		|| err "$name: first non-blank line must be '# $num. <title>' (got: ${title:-<empty>})"

	# 3b. Date: a plain 'Date: YYYY-MM-DD' line — a real date or the unfilled
	#     placeholder (the kit ships the placeholder so it self-lints green).
	dateline=$(grep -E '^Date:' "$path" | head -n1)
	if [ -z "$dateline" ]; then
		err "$name: missing 'Date: YYYY-MM-DD' line"
	else
		dateval=$(printf '%s' "$dateline" | sed -E 's/^Date:[[:space:]]*//')
		if [ "$dateval" = "YYYY-MM-DD" ]; then
			:
		elif printf '%s' "$dateval" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
			:
		else
			err "$name: Date must be YYYY-MM-DD (a real date or the placeholder); got '$dateval'"
		fi
	fi

	# 3c. Status: a '## Status' section whose value is in the allowed set.
	if ! grep -Eq '^## Status[[:space:]]*$' "$path"; then
		err "$name: missing '## Status' section"
	else
		statusval=$(awk '/^## Status[[:space:]]*$/{f=1; next} f && NF {print; exit}' "$path")
		case "$statusval" in
			Proposed|Accepted|Deprecated) : ;;
			"Superseded by "*|"Accepted. Amended by "*) : ;;
			*) err "$name: Status '${statusval:-<empty>}' is not one of: Proposed | Accepted | Deprecated | Superseded by … | Accepted. Amended by …" ;;
		esac
	fi

	# 3d. required sections (Nygard shape as fixed by template.md).
	for sec in '## Context' '## Decision' '## Consequences'; do
		grep -Eq "^${sec}[[:space:]]*$" "$path" || err "$name: missing section '$sec'"
	done

	# 3e. index row in README.
	grep -Fq "$name" "$readme" || err "$name: no row for it in $(basename "$readme")'s index table"

	# 3f. no-orphan cross-link (non-fatal warning).
	stem=$(printf '%s' "$name" | sed 's/\.md$//')
	is_cross_linked "$stem" "ADR-$num" \
		|| note "$name: no inbound link ($stem or ADR-$num) from a doc outside $(basename "$adr_dir")/ — cross-link it from the plan/spec it supports"
done

[ "$fail" -eq 0 ] && { printf 'adr-lint: OK\n'; exit 0; } || exit 1
