---
name: recipe-plan
description: "Plans a Goose recipe from a confirmed recipe requirement artifact: maps every requirement to a recipe element, marks every applicable baseline criterion satisfied by construction or a risk, and returns requirements that cannot be built as named conflicts. Owns the plan format because no shared capability accepts a requirement artifact without a GitHub issue; use `nolte-engineering:implementation-plan-author` for issue-driven plans. Invoke when a confirmed project/recipes/<slug>/requirements.md exists and the user wants the recipe planned, or asks which recipe fields, parameters and extensions a requirement needs; also German. Don't use to capture requirements (recipe-requirements-elicit) or to write the recipe (recipe-implement)."
tags: [planning, goose]
phase: plan
summary: "Turns a confirmed recipe requirement artifact into a recipe plan: elements, coverage both ways, every baseline criterion decided, conflicts returned."
use_when:
  - "a confirmed recipe requirement artifact exists and the recipe has not been planned"
  - "you want to know, before writing, which baseline criteria the design satisfies and which it risks"
dont_use_when:
  - situation: "The requirement artifact does not exist or is still a draft"
    alternative: recipe-requirements-elicit
  - situation: "The plan exists and you want the recipe written"
    alternative: recipe-implement
  - situation: "You are planning from a GitHub issue rather than a recipe requirement artifact"
    alternative: nolte-engineering:implementation-plan-author
see_also:
  - recipe-requirements-elicit
  - recipe-implement
  - recipe-audit
---

# Recipe Plan

Phase two of the Goose recipe lifecycle. Reads `project/recipes/<slug>/requirements.md` in state
`confirmed` and writes `project/recipes/<slug>/plan.md`: which recipe element realises which
requirement, which baseline criteria the design satisfies by construction, and which requirements
cannot be built within the documented rules.

## Why this is a skill, not an agent

- **The output gates on the author.** A conflict is returned to the author for a decision; the plan
  is `blocked` until they make it. That hand-back happens mid-flow.
- **A persistent artifact with a state** (`ready` / `blocked`) that the next phase reads.
- Counter-dimension considered: the mapping is a bounded, read-only computation that fits an
  agent. Outweighed because its result is a plan the author edits and approves, not a report.

## Why this skill owns its format

The duplicate check against every skill and agent in `nolte/claude-shared` (v0.1.11) found no
capability that accepts a requirement artifact without a GitHub issue: `implementation-plan-author`
requires an issue or an audit report, `feature-decompose` a roadmap item. The plan's work-package
shape (id, statement, what it serves, dependencies) is borrowed from `implementation-plan-author`'s
output contract so a later delegation is a drop-in. The upstream proposal is recorded in this
plugin's `README.md`.

## User-language policy

Respond in the user's language. The plan is written in English with ids verbatim.

## Preconditions

1. The input artifact exists and its `State` is `confirmed`. If it is `draft`, stop and list its
   open points; do not plan around them.
2. Its `baseline_revision` names a directory under `${CLAUDE_PLUGIN_ROOT}/baselines/goose/`. If
   not, stop and name the missing revision; never substitute another.
3. `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md` is readable, so the plan can carry the lifecycle
   version it was written under.

## Procedure

1. **Read** the requirement artifact and the generic artifact it names. Read the pinned revision's
   `ruleset.md` and `coverage.md` — from the revision the artifact names, not the newest one.
2. **Propose elements.** For each recipe field or entry the requirements call for — `title`,
   `description`, `instructions`, `prompt`, each `parameters[]` entry, each `extensions[]` entry,
   `response`, `sub_recipes`, and any other documented field — one row `P-<n>` with the requirement
   ids it serves and the decided value or shape. Decide the recipe's target path and record it in
   the header.
3. **Build the coverage table** both ways. Every `R-<n>` from the requirement artifact must appear
   with at least one element; every `P-<n>` must serve at least one requirement. If either fails,
   do not write the plan: name the unmapped id and ask the author whether it is a missing element or
   a requirement that should not exist.
4. **Decide every criterion.** For each criterion in the pinned `ruleset.md`, exactly one row:
   `by construction` with the element that satisfies it, or `risk` with the reason. A criterion
   whose `applies_to` does not match any planned element is still listed, as `by construction` with
   the reason "no element of that kind is planned". Declared gaps from `coverage.md` that the
   planned recipe triggers are listed under Criteria too, as `risk` with the gap id, so the author
   knows the audit will report them `undecided`.
5. **Name conflicts.** A requirement that cannot be realised within the documented rules — for
   example an optional input that must import a file, which the rules forbid a default for — goes
   in the Conflicts table with the rule it collides with. It is returned to the author, not resolved
   by narrowing the requirement. Any row sets `State: blocked`.
6. **Write** `project/recipes/<slug>/plan.md` from `templates/recipe-plan.template.md`, carrying
   `baseline_revision`, `lifecycle_version` and `review_process_version` from the input unchanged.
   Report the path, the state, the element count and, when blocked, each conflict.

## Refusals

| Condition | Response |
|---|---|
| Input `State: draft` | Stop; list the open points; write nothing |
| `baseline_revision` not present under the plugin's baselines | Stop; name it; write nothing |
| Coverage incomplete in either direction | Stop; name the unmapped ids; write nothing |
| A conflict exists | Write the plan with `State: blocked`; list the conflicts; do not narrow the requirement |

## Hard rules

- Never narrow, drop or reinterpret a requirement to remove a conflict.
- Never mark a criterion `by construction` without naming the element, or the reason no element of
  that kind exists.
- Never read a baseline revision other than the one the input names.
- Never leave a criterion of the pinned ruleset unlisted; the table is complete or the plan is not
  written.
- Never invent a recipe field the documentation does not describe; an undocumented need is a
  conflict, not an element.
