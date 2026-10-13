# Contract: Skill Interfaces

**Feature**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24

The four skills, each with its input, its output, the shared capability it delegates to, and the
boundary sentence its `description` must carry. The boundary sentence is what spec `FR-006` and
`SC-003` are measured on: a reader draws the line between the recipe skill and the shared one from
the two descriptions alone.

Every skill responds in the user's language and writes its artifacts in English (Constitution,
Authoring Constraints). Every skill, on an unknown namespaced delegation target, stops with the
message in §Fail-closed message and does nothing else.

## `recipe-requirements-elicit`

| | |
|---|---|
| Phase | `plan` |
| Input | An informally stated need, in conversation |
| Delegates to | `nolte-shared:requirements-elicit` (`elicit` operation) for the generic interview and `project/requirements/<slug>.md` |
| Adds | The recipe question set (five dimensions: inputs, host capabilities, execution mode, output shape, prohibited behaviour), the baseline check against the pinned revision, and `project/recipes/<slug>/requirements.md` |
| Output | `project/recipes/<slug>/requirements.md` in state `draft` or `confirmed` |
| Resumable | Yes; state under `.resume/recipe-requirements-elicit/<run-id>.yml` per `spec/claude/resumable-work/` |

**Boundary sentence** (verbatim in `description`): "Delegates the interview method and the generic
requirement artifact to `nolte-shared:requirements-elicit`; adds only the questions a Goose recipe
needs answered — inputs, host capabilities, execution mode, output shape, prohibitions — and checks
each answer against the pinned baseline revision."

**Operations**: `elicit` (default); `validate` — checks an existing recipe requirement artifact
against the data-model rules and reports pass or fail per rule, never fixing content.

**Baseline resolution**: `baseline_revision` is resolved at the start of `elicit` to a concrete id
(the operator may name one; otherwise the lexicographically greatest under
`${CLAUDE_PLUGIN_ROOT}/baselines/goose/`) and written into the artifact header. The word `latest`
never appears in an artifact.

## `recipe-plan`

| | |
|---|---|
| Phase | `plan` |
| Input | `project/recipes/<slug>/requirements.md` in state `confirmed` |
| Delegates to | Nothing. No shared capability accepts a bare requirement artifact (research `R3`) |
| Adds | The requirement-to-element mapping, the criteria table against the pinned revision, the conflicts section, and `project/recipes/<slug>/plan.md` |
| Output | `project/recipes/<slug>/plan.md` in state `ready` or `blocked` |
| Resumable | No; one approval span |

**Boundary sentence**: "Plans a Goose recipe from a confirmed recipe requirement artifact: maps
every requirement to a recipe element, marks every applicable baseline criterion satisfied by
construction or a risk, and returns requirements that cannot be built as named conflicts. Owns the plan
format because no shared capability accepts a requirement artifact without a GitHub issue; use
`nolte-engineering:implementation-plan-author` for issue-driven plans."

**Refusals**: input in state `draft` → stop, list the open points. Input whose
`baseline_revision` is not present under `${CLAUDE_PLUGIN_ROOT}/baselines/goose/` → stop, name it.

## `recipe-implement`

| | |
|---|---|
| Phase | `build` |
| Input | `project/recipes/<slug>/plan.md` in state `ready` |
| Delegates to | The host's parser for validation: `goose run --recipe <file> --explain`. Nothing authors the recipe on its behalf |
| Adds | The recipe and its extension configuration at the plan's target path, traceability comments, the provenance block, the parser check |
| Output | The recipe file(s) in state `validated`, or a verbatim parser rejection |
| Resumable | No; one approval span |

**Boundary sentence**: "Writes a Goose recipe and its declared extension configuration from a ready
recipe plan, one element per plan entry, each traced back by comment, and validates it with Goose's
own parser before reporting done. Does not open a pull request; use `nolte-shared:pull-request-create`
for that."

**Refusals**: plan in state `blocked` → stop, list the conflicts. Goose not on `PATH` → stop; the
parser check is not optional and a skipped check is not a pass.

## `recipe-audit`

| | |
|---|---|
| Phase | `review` |
| Input | The five inputs of `process/goose-implementation-review/invocation-contract.md`, with the same names, the same required-or-optional status and the same defaults |
| Delegates to | `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/bindings/claude-code/run.sh` (research `R2`) |
| Adds | Nothing normative. Argument pass-through, the plugin-root resolution, and a summary of where the report is |
| Output | The review report at `output_path`; the skill returns its path and the digest block verbatim |
| Resumable | No |

**Boundary sentence**: "Audits a Goose recipe against a pinned baseline revision by invoking the
review process's Claude Code binding with the process's own five inputs; states no rule of its own
and evaluates no criterion. The rules live in the process's `constraints.md`; the criteria in the
pinned revision's `ruleset.md`."

**Inputs, verbatim from the contract**:

| Name | Required | Default |
|---|---|---|
| `subject_path` | yes | none permitted |
| `baseline_revision` | no | `latest` |
| `output_path` | no | `./review-report.md` |
| `compare_to` | no | `""` |
| `max_bytes_per_pass` | no | `0` |

The skill adds no input. Inside a lifecycle run, the caller passes `baseline_revision` from the
requirement artifact and `output_path` as `project/recipes/<slug>/review-report.md`; those are values,
not changed defaults.

**Refusals**: the binding's own exit code 2 conditions (missing subject, missing baselines
directory, `claude` not on `PATH`) are reported verbatim. The skill never retries and never edits the
subject.

## Fail-closed message

```text
<skill> needs <plugin>:<capability>, which is not installed.
Install the <plugin> plugin at <minimum release> or later from <marketplace>.
Nothing was written.
```

The minimum release is the one this feature was verified against and is recorded in
`skills/README.md`; it moves only with a recorded re-verification.
