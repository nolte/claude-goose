#!/usr/bin/env sh
#
# GENERATED FILE — do not edit.
#
# Rendered from constraints.md, invocation-contract.md and this directory's
# run.sh.tmpl by tools/render-bindings.sh. An edit here is drift: the gate
# re-renders and compares, and the repair is to run the renderer rather than to
# reconcile this file by hand.
#
# Host: claude-code
#
# This binding starts a review under the Claude Code CLI in headless mode. It
# contributes no rule of its own; everything normative below was spliced from
# constraints.md.

set -u

BINDING_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 2
PROC_DIR=$(CDPATH= cd -- "$BINDING_DIR/../.." && pwd) || exit 2
# baselines/ sits beside the tree the process directory lives in, which is two
# levels up — the layout a consumer gets from copying process/ and baselines/
# together.
TREE_ROOT=$(CDPATH= cd -- "$PROC_DIR/../.." && pwd) || exit 2

# The five contract inputs, mapped onto this host's command line as long options
# of the same names. The defaults are the contract's defaults.
subject_path=""
baseline_revision="latest"
output_path="./review-report.md"
compare_to=""
max_bytes_per_pass="0"

usage() {
  cat <<'USAGE'
usage: run.sh --subject_path <path> [options]

  --subject_path <path>          the implementation to review (no default)
  --baseline_revision <id>       default: latest
  --output_path <path>           default: ./review-report.md
  --compare_to <report>          default: empty, meaning no comparison
  --max_bytes_per_pass <n>       default: 0, meaning unlimited

Every input is declared in ../../invocation-contract.md. This binding adds none
of its own.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  --subject_path) subject_path="${2:?--subject_path needs a value}"; shift 2 ;;
  --baseline_revision) baseline_revision="${2:?--baseline_revision needs a value}"; shift 2 ;;
  --output_path) output_path="${2:?--output_path needs a value}"; shift 2 ;;
  --compare_to) compare_to="${2:?--compare_to needs a value}"; shift 2 ;;
  --max_bytes_per_pass) max_bytes_per_pass="${2:?--max_bytes_per_pass needs a value}"; shift 2 ;;
  -h | --help) usage; exit 0 ;;
  *) printf 'run.sh: unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ -z "$subject_path" ]; then
  printf 'run.sh: --subject_path is not optional and has no default\n' >&2
  usage >&2
  exit 2
fi
[ -e "$subject_path" ] || {
  printf 'run.sh: subject_path does not exist: %s\n' "$subject_path" >&2
  exit 2
}

BASELINES_DIR="$TREE_ROOT/baselines"
[ -d "$BASELINES_DIR" ] || {
  printf 'run.sh: no baselines directory beside the process tree: %s\n' "$BASELINES_DIR" >&2
  exit 2
}

# Placeholder resolution. The contract writes its inputs as double-brace
# placeholders; this host has no templating of its own, so the binding
# substitutes them before the prompt reaches the model. A placeholder that
# survived would carry the words of a constraint without its content.
resolve() {
  awk -v subject_path="$subject_path" \
    -v baseline_revision="$baseline_revision" \
    -v output_path="$output_path" \
    -v compare_to="$compare_to" \
    -v max_bytes_per_pass="$max_bytes_per_pass" '
    {
      line = $0
      while (match(line, /\{\{[ \t]*[A-Za-z_][A-Za-z0-9_]*[ \t]*\}\}/)) {
        key = substr(line, RSTART, RLENGTH)
        gsub(/[{} \t]/, "", key)
        val = ""
        if (key == "subject_path") val = subject_path
        else if (key == "baseline_revision") val = baseline_revision
        else if (key == "output_path") val = output_path
        else if (key == "compare_to") val = compare_to
        else if (key == "max_bytes_per_pass") val = max_bytes_per_pass
        line = substr(line, 1, RSTART - 1) val substr(line, RSTART + RLENGTH)
      }
      print line
    }
  '
}

PROMPT=$(
  cat <<'PROMPT_HEAD' | resolve
Review the implementation at {{ subject_path }} now, following the review
process stage by stage. You are the reviewing agent: perform the review
yourself, then write the report.

Read these three files before you begin. Together they define the whole task:

  process.md            the stages, their preconditions, outputs, completion
                        conditions and verification steps
  constraints.md        the constraints reproduced below, each with the stage
                        that verifies it
  report-template.md    the shape of the report you write

They sit in the process directory named at the end of this prompt. The baseline
revisions sit beside that directory, under baselines/goose/.

Inputs for this run:
PROMPT_HEAD
)

PROMPT="$PROMPT

$(
  cat <<'PROMPT_INPUTS'
- subject_path (required): The implementation to review; a file or a directory
- baseline_revision (optional, default latest): Which baseline revision to apply. `latest` resolves to the lexicographically greatest revision present
- output_path (optional, default ./review-report.md): Where the report is written
- compare_to (optional, default ""): A prior report, to classify findings as new, resolved or unchanged. Empty means no comparison
- max_bytes_per_pass (optional, default 0): Byte budget for one pass. `0` means unlimited
PROMPT_INPUTS
)"

PROMPT="$PROMPT

Absolute constraints, in force for every stage:

$(
  cat <<'PROMPT_CONSTRAINTS' | resolve
USE EXACTLY THE BASELINE REVISION `{{ baseline_revision }}`. Read its criteria from that revision and
no other. If a newer revision exists on disk, that is REPORTED as a BASELINE-DRIFT finding and
otherwise IGNORED — never silently applied, never treated as an improvement, and never merged with
the pinned one. Applying a different revision than the one requested makes the report unreproducible
and every comparison against it meaningless. The only exception is the literal value `latest`, which
resolves to the lexicographically greatest revision; the resolved id, never the word `latest`, goes
in the report.

NEVER modify anything under `{{ subject_path }}`. Checksum every file before subject discovery and
verify after the findings are complete. Any difference fails the run and the report is discarded,
however correct the findings are.

NEVER execute the subject. Findings come from reading the material.

NEVER invent a criterion. Only criteria present in the pinned baseline revision's ruleset may produce
findings. An expectation that seems obviously right but is not in the ruleset is not a finding — at
most it is a proposed criterion for the baseline.

NEVER write a finding without a criterion id, a location, and the source its criterion cites. A
report containing such a finding is invalid and must not be written at all.

NEVER report a declared baseline gap as passing. Gaps become findings with outcome `undecided`.

NEVER phrase a finding more strongly than its criterion's evidence class supports. Only
`authoritative` criteria may state that something is wrong.

Coverage budget for one pass: `{{ max_bytes_per_pass }}` bytes, where `0` means unlimited and is the
normal operating mode. If non-zero, take in-scope files in ascending path order until the budget is
spent. Every file not taken goes in the coverage statement's not-examined list with the reason
"coverage limit". A single file larger than the whole budget is NEVER partially reviewed — it goes in
the not-examined list with the reason "exceeds per-pass budget". A partial review is fine; a partial
review that reads as complete is not.

Prior report to compare against: `{{ compare_to }}`. If that value is non-empty, perform the delta
stage: read that report's digest block and classify every finding as new, resolved or unchanged, with
a cause of subject or baseline. If it is empty, SKIP the delta stage entirely and emit no delta
fields — an absent comparison and an empty comparison are different claims.
PROMPT_CONSTRAINTS
)"

PROMPT="$PROMPT

$(
  cat <<'PROMPT_TAIL' | resolve
Report the result using report-template.md. Include the coverage statement and
the Criteria Applied table even when there are no findings — a clean subject and
an unexamined one look alike otherwise. Record the executing host in the report
header as:

  Host: claude-code

Write the report to {{ output_path }} and state plainly what you examined and
what you did not.
PROMPT_TAIL
)

Process directory: $PROC_DIR
Baselines directory: $BASELINES_DIR"

# What this host is allowed to do during the run. The tool list is narrow on
# purpose: reading, searching, the shell commands the manifest stage needs, and
# writing the report.
#
# Worth recording for anyone comparing the two shipped bindings: under this host
# the read-only promise has partial technical backing, because the tool list is
# declared at invocation and the host enforces it. It is still not complete —
# the report is written with the same Write tool that could reach the subject —
# so the process keeps its own re-checksum stage as the mechanism that actually
# catches a violation.
CLAUDE_TOOLS="Read Glob Grep Write Bash(find:*) Bash(sha256sum:*) Bash(ls:*) Bash(sort:*) Bash(wc:*)"

command -v claude >/dev/null 2>&1 || {
  printf 'run.sh: the claude CLI is not on PATH\n' >&2
  exit 2
}

# The prompt goes in over stdin rather than as a trailing argument. This host
# declares --allowedTools and --add-dir as variadic options, so a prompt placed
# after them is swallowed as one more value and the run dies with "Input must be
# provided either through stdin or as a prompt argument". Measured here, on
# CLI 2.1.221. Stdin is the documented second form and has no such ambiguity.
printf '%s\n' "$PROMPT" | claude \
  --print \
  --permission-mode dontAsk \
  --allowedTools "$CLAUDE_TOOLS" \
  --add-dir "$PROC_DIR" \
  --add-dir "$BASELINES_DIR"
