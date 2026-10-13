# Traceability Comments

How a recipe written by `recipe-implement` records where each of its parts came from, so an audit
finding can be traced back to the plan element and, through it, to the requirement that caused it.
Goose ignores YAML comments, so nothing here changes what the host loads or what any criterion sees.

## Provenance block

The first lines of the recipe file:

```yaml
# nolte-goose lifecycle — slug: <slug>  baseline_revision: <id>
# lifecycle_version: <semver>  review_process_version: <semver>
```

All four values are carried from the plan header unchanged. `baseline_revision` is a concrete id.

## Element comments

A comment on the line before each top-level element, each `parameters[]` entry and each
`extensions[]` entry:

```yaml
# P-2 ← R-1
title: "Baseline Drift Check"

parameters:
  # P-3 ← R-2
  - key: revision
    input_type: string
    requirement: required
    description: "Baseline revision to check for source drift"

extensions:
  # P-6 ← R-4
  - type: builtin
    name: developer
```

Rules:

- A comment names exactly one plan element. Several recipe lines may carry the same element id when
  one element spans them (a `parameters[]` entry is one element; its `options` list is part of it).
- The `R-<m>` after the arrow is the requirement id the plan's Elements table lists for that element.
  When an element serves several requirements, list them comma-separated: `# P-4 ← R-2, R-5`.
- A recipe line with no element comment above it, at the levels listed, is a defect: it means the
  recipe contains something the plan did not decide.
- Comments are not moved or rewritten by a later edit. A change to the recipe goes through the plan
  first; the comment then follows the plan.

## Why comments and not a separate file

A second file can drift from the recipe silently. A comment sits on the line it explains, is
carried along by every copy, and is read by the audit's location field (`file:position`) without
any lookup. The plan remains the index from element id to requirement id, so nothing is duplicated.
