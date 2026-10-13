---
name: recipe-audit
description: "Audits a Goose recipe against a pinned baseline revision by invoking the review process's Claude Code binding with the process's own five inputs; states no rule of its own and evaluates no criterion. The rules live in the process's `constraints.md`; the criteria in the pinned revision's `ruleset.md`. Invoke when the user asks to audit, review or check a Goose recipe against the documented rules or best practices, or as the last phase of the recipe lifecycle after recipe-implement; also German. Don't use to write or repair a recipe (recipe-implement), or for material that is not a Goose recipe or extension configuration."
tags: [review, goose]
phase: review
summary: "Runs the Goose implementation review over a recipe through its Claude Code binding and returns the report."
use_when:
  - "you want a Goose recipe checked against the documented rules with every finding sourced"
  - "recipe-implement has produced a validated recipe and the lifecycle needs its audit"
dont_use_when:
  - situation: "You want the recipe written or fixed"
    alternative: recipe-implement
  - situation: "You want the recipe's requirements captured or planned"
    alternative: recipe-requirements-elicit
see_also:
  - recipe-implement
  - recipe-plan
---

# Recipe Audit

Starts one run of the Goose implementation review over a recipe and hands back the report. The
review process defines the stages, the constraints and the report shape; the pinned baseline
revision defines the criteria. This skill defines nothing: it maps five inputs onto the process's
Claude Code binding and returns where the report landed.

## Why this is a skill, not an agent

- **It invokes a host process and returns a path.** The review itself runs inside the binding as
  its own headless session; nothing here needs an isolated context of its own.
- **The inputs are the operator's.** Which subject, which revision, where the report goes: each is
  a value the operator supplies at invocation, the pattern the portfolio's artifact-type rule assigns
  to skills.
- Counter-dimension considered: a read-only, non-interactive audit fits an agent's isolation. It is
  outweighed because the binding already provides that isolation and a narrowed tool list; a second
  isolation layer would add nothing the process does not already enforce.

## User-language policy

Respond in the user's language. The report is written by the review process in English; do not
translate or paraphrase it.

## Inputs

The five inputs of `process/goose-implementation-review/invocation-contract.md`, with the same
names, the same required-or-optional status and the same defaults. This skill adds none.

| Name | Required | Default | Meaning |
|---|---|---|---|
| `subject_path` | yes | *none permitted* | The implementation to review; a file or a directory |
| `baseline_revision` | no | `latest` | Which baseline revision to apply. `latest` resolves to the lexicographically greatest revision present |
| `output_path` | no | `./review-report.md` | Where the report is written |
| `compare_to` | no | `""` | A prior report, to classify findings as new, resolved or unchanged. Empty means no comparison |
| `max_bytes_per_pass` | no | `0` | Byte budget for one pass. `0` means unlimited |

Inside a lifecycle run the caller passes `baseline_revision` from the requirement artifact and
`output_path` as `project/recipes/<slug>/review-report.md`. Those are values, not changed defaults.

## Preconditions

1. `${CLAUDE_PLUGIN_ROOT}` resolves, and
   `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/bindings/claude-code/run.sh` exists
   and is executable. If not, stop: the plugin is installed without its process tree, and this
   skill has nothing to invoke.
2. `claude` is on `PATH`. The binding checks this too and exits `2`; report its message verbatim.
3. `subject_path` was given. Without it, stop with the binding's own message — the input has no
   default and this skill does not invent one.

## Procedure

1. Collect the five inputs from the invocation. Leave every omitted optional input unset so the
   binding applies the contract default; do not resolve `latest` here.
2. Run, from the current working directory:

   ```sh
   "${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/bindings/claude-code/run.sh" \
     --subject_path "<subject_path>" \
     [--baseline_revision "<value>"] [--output_path "<value>"] \
     [--compare_to "<value>"] [--max_bytes_per_pass "<value>"]
   ```

   Pass only the options the caller supplied. Wait for the process to finish; it starts a headless
   Claude Code session of its own and may take several minutes.
3. On exit code `0`: read the report at `output_path`, then reply with the report path, the
   `Host:` header line, and the `DIGEST v1` block verbatim. Say what was examined and what was not,
   quoting the report's coverage statement.
4. On any non-zero exit: reply with the binding's stderr verbatim and stop. Do not retry, do not
   change an input, do not edit the subject.

## Output

The review report at `output_path`, produced by the review process. Its header records
`Host: claude-code`, the process version and the resolved baseline revision. This skill writes no
other file.

## Where the rules are

This skill carries none. What a review may and may not do is stated once, in
`process/goose-implementation-review/constraints.md`, and carried into the binding at the point of
invocation by the process's own renderer. What counts as a finding is stated in the pinned
revision's `ruleset.md` and `coverage.md`. A reader who wants to know why a finding appeared reads
those files, not this one.

## Hard rules

These govern this skill's behaviour, not the review's.

- Add no input, rename no input, change no default.
- Do not read the subject, the baseline or the process files in order to judge anything; the
  binding does that.
- Never edit anything under `subject_path`, before or after the run.
- Never retry a failed run or re-run with a different revision to "make it pass".
- Never summarise findings in your own words in place of the digest; the digest is the comparable
  core and is quoted verbatim.
