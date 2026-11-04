# Recipe Requirements — Baseline Drift Check

**Slug**: baseline-drift-check
**Baseline revision**: 2026-08-02
**Lifecycle version**: 0.1.0
**Review process version**: 1.0.0
**Generic artifact**: project/requirements/baseline-drift-check.md
**State**: confirmed
**Date**: 2026-09-24

<!--
HAND-WRITTEN for the first lifecycle run (feature 005, task T024), in the shape of the
nolte-goose recipe-requirements-elicit template. Not produced by that skill: its delegation
target cannot run in a consumer until an upstream fix ships (specs/005 research R5). The
baseline check below was done by reading baselines/goose/2026-08-02/ruleset.md and coverage.md.
-->

## Purpose

Check one published baseline revision for source drift: for each source record in its
`sources.md`, compare the recorded upstream commit with the current commit of the same
documentation file and print the rows the maintainer appends to `verification.md`. Automates
Stage 2 of `baselines/MAINTENANCE.md` for the maintainer of `baselines/`.

## Inputs

| Id | Name | Required | Default | Imports a file | Serves |
|---|---|---|---|---|---|
| R-1 | `revision` | yes | none | no | R1, R7 |
| R-2 | `baselines_dir` | no | `./baselines` | no | R1, R8 |
| R-3 | `repo` | no | `aaif-goose/goose` | no | R2, R8 |

`baselines_dir` is a path the recipe *reads from*, not a file to import: the recipe reads one file
under it that it locates itself. Typing it as a file input would inline a single file and hide the
directory (the same reason the review process types `subject_path` as a string).

## Host capabilities

| Id | Capability | Why needed | Executes code |
|---|---|---|---|
| R-4 | Read files under `baselines_dir` | R1 | no |
| R-5 | Run `gh api` against the upstream repository | R2 | yes |

Both are supplied by the Developer extension, which is enabled by default in Goose 1.45.0
(`RESULTS.md` O-1). Whether to declare it explicitly is a plan decision.

Revised 2026-09-24 after the first `recipe-plan` run, which flagged the output vocabulary and the
R-007 expectation; both corrected here rather than in the plan.

## Execution mode

headless — the maintainer runs it from a task or a schedule with no one at the keyboard (R4). The
recipe must therefore carry a `prompt`.

## Output shape

Free text to standard output: one `verification.md` table row per source record, in the exact
column order of that file (date, source id, rule, observed commit, result), followed by a one-line
summary count of `unchanged` / `drifted` / `unreachable` — the vocabulary `SOURCE-FORMAT.md`
defines for `verification.md`. On a missing revision: one sentence, no rows.
Nothing is machine-read downstream; the maintainer pastes the rows.

## Prohibited behaviour

- Never write to `verification.md` or to any file.
- Never modify anything under `baselines_dir`.
- Never decide drift from HTTP `ETag` or `Last-Modified` headers; only commit ids count.
- Never fetch or read documentation page content; only commit metadata.

## Baseline check

| Requirement | Criterion or gap | Consequence |
|---|---|---|
| R-2, R-3 | R-003 (optional parameters carry defaults) | by construction — both carry defaults |
| R-2 | R-004 (file parameters carry no defaults) | not applicable — typed as a string, not a file |
| Execution mode headless | R-010 (headless recipe declares `prompt`) | by construction — the plan must include a prompt element |
| R-5 | R-007 (code-executing extensions are surfaced) | not triggered — R-007's decision procedure covers `inline_python` and `stdio`; a `builtin` extension is outside it (found by the first `recipe-plan` run) |
| R-4, R-5 | GAP-EXT-SEMANTICS | cannot be decided by the audit; expected `undecided` if an extension is declared |
| Output shape | GAP-RECIPE-FIELDS | not triggered — no `response`, `retry`, `settings`, `sub_recipes` needed |

## Open points

- none
