# Recipe Plan — {{title}}

**Slug**: {{slug}}
**Baseline revision**: {{baseline_revision}}
**Lifecycle version**: {{lifecycle_version}}
**Review process version**: {{review_process_version}}
**Recipe path**: {{where recipe-implement writes, e.g. recipes/<slug>/recipe.yaml}}
**State**: {{ready | blocked}}
**Date**: {{YYYY-MM-DD}}

<!--
Produced via the nolte-goose `recipe-plan` skill from
project/recipes/{{slug}}/requirements.md. Slug, title, baseline revision,
lifecycle version and review process version are carried from that artifact
unchanged. The recipe path, the state and the date are decided by this skill.
-->

## Elements

| Id | Recipe element | Serves | Decided value or shape |
|---|---|---|---|
| P-1 | {{field or entry, e.g. `parameters[repo_path]`}} | R-1 | {{value}} |

## Coverage

| Requirement | Elements |
|---|---|
| R-1 | P-1 |

<!-- Every requirement id from requirements.md appears; every P-<n> appears in at least one row. -->

## Criteria

| Criterion | Verdict | Element or reason |
|---|---|---|
| {{R-001}} | {{by construction / risk}} | {{P-n / reason}} |

<!-- Every criterion of the pinned revision's ruleset.md appears exactly once. -->

## Conflicts

| Requirement | Collides with | Returned to author |
|---|---|---|

<!-- "none" when empty. A non-empty table sets State to blocked. -->
