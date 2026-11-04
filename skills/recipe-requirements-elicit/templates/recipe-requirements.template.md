# Recipe Requirements — {{title}}

**Slug**: {{slug}}
**Baseline revision**: {{baseline_revision}}
**Lifecycle version**: {{lifecycle_version}}
**Review process version**: {{review_process_version}}
**Generic artifact**: project/requirements/{{slug}}.md
**State**: {{draft | confirmed}}
**Date**: {{YYYY-MM-DD}}

<!--
Produced via the nolte-goose `recipe-requirements-elicit` skill. The generic
requirement set, gap matrix and KPI live in the generic artifact named above,
written by nolte-shared:requirements-elicit. This file adds only what a Goose
recipe needs. `baseline_revision` is a concrete id, never `latest`.
-->

## Purpose

{{One paragraph: what the recipe accomplishes and for whom.}}

## Inputs

| Id | Name | Required | Default | Imports a file | Serves |
|---|---|---|---|---|---|
| R-1 | {{name}} | {{yes / no}} | {{value / none}} | {{yes / no}} | {{requirement ids from the generic artifact}} |

## Host capabilities

| Id | Capability | Why needed | Executes code |
|---|---|---|---|
| R-{{n}} | {{what the recipe needs from the host}} | {{reason}} | {{yes / no}} |

## Execution mode

{{interactive | headless | both}} — {{reason}}. Headless intent is a requirement: it decides whether
the recipe must carry a prompt.

## Output shape

{{What the recipe hands back: structured or free; what it hands back when it cannot finish.}}

## Prohibited behaviour

- {{what the recipe must never do}}

## Baseline check

| Requirement | Criterion or gap | Consequence |
|---|---|---|
| R-{{n}} | {{R-xxx from ruleset.md, or GAP-xxx from coverage.md}} | {{violates by construction / cannot be decided by the audit / by construction}} |

<!-- "none" when empty. This section is never omitted. -->

## Open points

- {{what the author could not answer; "none" when empty}}
