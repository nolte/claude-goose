# Contract: Recipe Artifacts

**Feature**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24

The shape of the two artifacts the lifecycle introduces, and the comment convention inside the
recipe. `data-model.md` states the rules; this file fixes the on-disk form so a person can write
either artifact by hand and have the next skill accept it (spec `FR-002`).

Three id schemes meet in these artifacts and must not be confused. Since lifecycle 0.3.0:

| Id | Names | Owned by |
|---|---|---|
| `RR-<n>` | A recipe requirement | `requirements.md` here |
| `R-0nn` | A baseline criterion | `ruleset.md` of the pinned revision |
| `R<n>` | A requirement of the generic artifact | `project/requirements/<slug>.md`, written by `nolte-shared:requirements-elicit` |

Plan elements are `P-<n>`. An artifact written under 0.2.0 or earlier uses `R-<n>` for a recipe
requirement and is no longer accepted by the next phase.

## `project/recipes/<slug>/requirements.md`

```markdown
# Recipe Requirements — <title>

**Slug**: <slug>
**Baseline revision**: <YYYY-MM-DD[x]>          # concrete id; never `latest`
**Lifecycle version**: <semver>                 # from skills/VERSION.md
**Review process version**: <semver>            # from the review process's VERSION.md
**Generic artifact**: project/requirements/<slug>.md
**State**: draft | confirmed
**Teach-back**: <YYYY-MM-DD, confirmed by the author> | none   # since lifecycle 0.2.0; absent in 0.1.0 artifacts
**Date**: <YYYY-MM-DD>

## Purpose

<one paragraph: what the recipe accomplishes and for whom>

## Inputs

| Id | Name | Required | Default | Imports a file | Serves |
|---|---|---|---|---|---|
| RR-1 | <name> | yes / no | <value> / none | yes / no | <requirement ids from the generic artifact> |

## Host capabilities

| Id | Capability | Why needed | Executes code |
|---|---|---|---|
| RR-<n> | <what the recipe needs from the host> | <reason> | yes / no |

## Execution mode

<interactive | headless | both>, with the reason. Headless intent is a requirement, not a detail:
it decides whether the recipe must carry a prompt.

## Output shape

<what the recipe hands back, structured or free>

## Prohibited behaviour

- <what the recipe must never do>

## Baseline check

| Requirement | Criterion or gap | Consequence |
|---|---|---|
| RR-<n> | <R-xxx from ruleset.md, or GAP-xxx from coverage.md> | violates by construction / cannot be decided by the audit |

"none" when empty. The section is never omitted.

## Open points

- <what the author could not answer>
```

## `project/recipes/<slug>/plan.md`

```markdown
# Recipe Plan — <title>

**Slug**: <slug>
**Baseline revision**: <id>                     # carried from requirements.md
**Lifecycle version**: <semver>                 # carried from requirements.md
**Review process version**: <semver>            # carried from requirements.md
**Recipe path**: <where recipe-implement writes>
**State**: ready | blocked
**Date**: <YYYY-MM-DD>

## Elements

| Id | Recipe element | Serves | Decided value or shape |
|---|---|---|---|
| P-1 | <field or entry, e.g. `parameters[repo_path]`> | RR-1 | <value> |

## Coverage

| Requirement | Elements |
|---|---|
| RR-1 | P-1, P-4 |

Every requirement id from requirements.md appears; every P-<n> appears in at least one row.

## Criteria

| Criterion | Verdict | Element or reason |
|---|---|---|
| R-001 | by construction | P-2 |
| R-010 | risk | headless intent unknown |

Every criterion of the pinned revision's ruleset.md appears exactly once.

## Conflicts

| Requirement | Collides with | Returned to author |
|---|---|---|

"none" when empty. A non-empty table sets State to blocked.
```

## Traceability comments in the recipe

Each top-level element, each `parameters[]` entry and each `extensions[]` entry carries a comment on
the line before it:

```yaml
# nolte-goose lifecycle — slug: <slug>  baseline_revision: <id>
# lifecycle_version: <semver>  review_process_version: <semver>

# P-1 ← R4
title: "Baseline Drift Check"

parameters:
  # P-3 ← RR-1, R1, R7
  - key: revision
    input_type: string
    requirement: required
    description: "Baseline revision to check for source drift"
```

The leading block is the provenance spec `FR-024` requires. A comment names exactly one plan
element; a plan element may be named by several recipe lines when it spans them.
