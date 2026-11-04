# nolte-goose

The Goose recipe lifecycle as four Claude Code skills, shipped from this repository as the plugin
`nolte-goose`. Each skill owns one phase, consumes one input artifact, produces one output artifact,
and carries only what is specific to Goose recipes.

| Phase | Skill | Input | Output |
|---|---|---|---|
| Requirements | `recipe-requirements-elicit` | An informally stated need | `project/recipes/<slug>/requirements.md` |
| Plan | `recipe-plan` | A confirmed requirement artifact | `project/recipes/<slug>/plan.md` |
| Implementation | `recipe-implement` | A ready plan | The recipe at the plan's target path |
| Audit | `recipe-audit` | A recipe, a baseline revision | The review report |

**Version of record**: `VERSION.md` in this directory carries the semantic version of the lifecycle.

## Install

The install commands live in the repository's root `README.md` under Usage. They name the
repository, and this directory is checked by the portability guard for exactly that, so they are
not repeated here. Skills route as `/nolte-goose:<name>`.

## Distribution contract

Why these skills ship separately from the shared portfolio plugins, stated because
`spec/claude/plugin-scoping/` in `nolte/claude-shared` accepts exactly one reason — a different
distribution contract — and rejects topic or size:

| Property | Value |
|---|---|
| Consumer audience | Repositories that author Goose recipes |
| Runtime requirement | Goose 1.45.0 on `PATH`; the Claude Code CLI for the audit |
| Prerequisite plugin | `nolte-shared` at `v0.1.11` or later; absence fails closed |
| Release cadence | This repository's own tags; independent of claude-shared's |

The difference from every claude-shared plugin is the runtime requirement.

## Prerequisites

| Need | Used by | Verified against |
|---|---|---|
| Goose | `recipe-implement` (parser check), `recipe-audit` (subject domain) | 1.45.0 |
| Claude Code CLI | `recipe-audit` invokes the review process's Claude Code binding | 2.1.282 |
| `nolte-shared` plugin | `recipe-requirements-elicit` delegates the interview to `nolte-shared:requirements-elicit` | v0.1.11 |

A skill whose delegation target is not installed stops with the name of the missing plugin and its
minimum release, and writes nothing. It does not do the generic work itself.

## Delimitation record

For each skill: which shared capability it delegates to, what it adds, and what the duplicate
check against every skill and agent description in `nolte/claude-shared` (release v0.1.11, all
plugins) found. This table is what a reader is measured against when asked to draw the boundary
from the descriptions alone.

| Skill | Delegates to | Adds | Duplicate check |
|---|---|---|---|
| `recipe-requirements-elicit` | `nolte-shared:requirements-elicit` — the interview method, the eight-dimension gap matrix, the KPI gate, `project/requirements/<slug>.md` | The five recipe dimensions (inputs, host capabilities, execution mode, output shape, prohibitions), the baseline check against the pinned revision, `project/recipes/<slug>/requirements.md` | Equivalent found and delegated to |
| `recipe-plan` | Nothing | The requirement-to-element mapping, the criteria table, the conflicts section, `project/recipes/<slug>/plan.md` | `nolte-engineering:implementation-plan-author` takes only a GitHub issue plus its elicited artifact or an audit report; `nolte-planning:feature-decompose` takes a roadmap item. Neither accepts a bare requirement artifact. Upstream proposal recorded below |
| `recipe-implement` | Goose's own parser for validation (`goose run --recipe <file> --explain`) | The recipe and its extension configuration from the plan, traceability comments, the provenance block | `nolte-engineering:fullstack-developer` implements code against a detected stack; nothing authors a Goose recipe. PR creation is `nolte-shared:pull-request-create` and outside the phase |
| `recipe-audit` | `process/goose-implementation-review/bindings/claude-code/run.sh` — the review process's Claude Code binding | Argument pass-through and plugin-root resolution. Nothing normative | No claude-shared artifact reviews Goose material |

## Upstream dependencies

Recorded here because each blocks a verification step of this plugin, not its authoring.

| Change in `nolte/claude-shared` | Blocks | Status |
|---|---|---|
| `requirements-elicit` must be runnable in a consumer: a `${CLAUDE_PLUGIN_ROOT}/spec/...` fallback in its precondition, or `Portfolio-Scope: portfolio` on its spec | The recorded real run of `recipe-requirements-elicit` | https://github.com/nolte/claude-shared/issues/665 — open |
| `implementation-plan-author` accepting a requirement artifact without a GitHub issue | Nothing today; would let `recipe-plan` delegate its plan format | https://github.com/nolte/claude-shared/issues/666 — open |
| A `.pre-commit-hooks.yaml` exposing `scripts/validate_skills.py` | Frontmatter validation as a gate class instead of a recorded manual step | https://github.com/nolte/claude-shared/issues/667 — open |

## Validator

Frontmatter conformance is checked with claude-shared's `scripts/validate_skills.py` as a recorded
manual step (`OMISSIONS.md`).

| Date | Validator | Result |
|---|---|---|
| 2026-09-24 | `scripts/validate_skills.py` at claude-shared tag `v0.1.11` (the script has no `--version` at that tag) | 4 artifacts; 0 Critical, 4 Warning, 1 Suggestion. Warnings: tags `goose`, `implementation`, `planning` outside that tag's starter vocabulary — `implementation` and `planning` are in the spec's vocabulary at HEAD, `goose` is a permitted new cluster tag. Suggestion: `recipe-implement` does not end in a token the validator knows; `implement` is a finite verb, which the naming spec allows |

## What this directory is not

Not part of the review process. `process/` and `baselines/` are untouched by these skills; the
audit reaches them through the installed plugin's root, and no rule of the review is restated here.
