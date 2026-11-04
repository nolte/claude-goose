---
name: recipe-implement
description: "Writes a Goose recipe and its declared extension configuration from a ready recipe plan, one element per plan entry, each traced back by comment, and validates it with Goose's own parser before reporting done. Does not open a pull request; use `nolte-shared:pull-request-create` for that. Invoke when a project/recipes/<slug>/plan.md in state ready exists and the user wants the recipe written, or asks to implement, generate or produce the recipe from its plan; also German. Don't use to plan the recipe (recipe-plan), to audit it (recipe-audit), or for code that is not a Goose recipe (nolte-engineering:fullstack-developer)."
tags: [implementation, goose]
phase: build
summary: "Writes the recipe a ready plan describes, traces every element to its plan entry, and validates it with goose run --explain."
use_when:
  - "a recipe plan in state ready exists and the recipe file has not been written"
  - "you want the recipe regenerated after the plan changed"
dont_use_when:
  - situation: "The plan is blocked or does not exist"
    alternative: recipe-plan
  - situation: "The recipe exists and you want it audited"
    alternative: recipe-audit
  - situation: "You want the recipe committed and a pull request opened"
    alternative: nolte-shared:pull-request-create
see_also:
  - recipe-plan
  - recipe-audit
---

# Recipe Implement

Phase three of the Goose recipe lifecycle. Reads `project/recipes/<slug>/plan.md` in state `ready`
and writes the recipe at the plan's target path: exactly the elements the plan lists, each with a
comment naming its plan entry, checked by Goose's own parser before it is reported as done.

## Why this is a skill, not an agent

- **It writes a file the author will commit** under a path the plan chose, in the session where
  the author can see the parser's verdict and act on it.
- **It composes with the neighbouring skills** in one lifecycle; the author moves from plan to
  recipe to audit without leaving the conversation.
- Counter-dimension considered: writing a file from a fully decided plan is deterministic and
  isolated, which fits an agent. Outweighed because a parser rejection is a decision point for the
  author — the fix belongs in the plan — and that hand-back is mid-flow.

## What is delegated

Validation, to the host: `goose run --recipe <file> --explain` is Goose's real parser and costs no
model call. Nothing else. No shared capability authors a Goose recipe; the duplicate check is
recorded in this plugin's `README.md`. Committing and opening a pull request are
`nolte-shared:pull-request-create`'s and outside this phase.

## User-language policy

Respond in the user's language. The recipe's `title`, `description` and parameter descriptions are
written in the language the plan's decided values use.

## Preconditions

1. `goose` is on `PATH`. If not, stop: the parser check is not optional, and a skipped check is not
   a pass.
2. The plan exists and its `State` is `ready`. If it is `blocked`, stop and list the conflicts.
3. `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md` is readable.

## Procedure

1. **Read the plan** — header, Elements, Coverage, Criteria. Read `references/traceability-comments.md`.
2. **Write the recipe** at the plan's target path:
   - the provenance block first, with `slug`, `baseline_revision`, `lifecycle_version` and
     `review_process_version` carried from the plan header unchanged;
   - one recipe element per `P-<n>` row, with its decided value or shape, and nothing the plan does
     not list;
   - a `# P-<n> ← R-<m>` comment on the line before each top-level element, each `parameters[]`
     entry and each `extensions[]` entry, as the reference describes.
   Where the plan names extension configurations that live in their own files, write those beside
   the recipe with the same provenance block.
3. **Validate** with the host:

   ```sh
   goose run --recipe <target path> --explain
   ```

   If any output line begins with `Error:`, reply with that output verbatim, leave the file in
   place for inspection, and stop. Do not present the recipe as done, and do not edit the plan to
   make the recipe fit. The parser stops at the first defect; report what it said, not what you
   suspect it would say next.
4. **Report**: the recipe path, the parser's acceptance, and a table of each recipe part with the
   plan element and requirement it traces to. Say that the next phase is `recipe-audit` with the
   plan's `baseline_revision` and `output_path project/recipes/<slug>/review-report.md`.

## Output

The recipe file(s) at the plan's target path, in state `validated` (parser accepted) or `rejected`
(parser output reported verbatim). No other file is written.

## Hard rules

- Never add an element without a plan entry; an idea that arises while writing goes back to the
  plan.
- Never omit an element the plan lists.
- Never edit the plan or the requirement artifact from this skill.
- Never report the recipe as done without the parser's acceptance, and never skip the parser
  because Goose is missing.
- Never move or rewrite a traceability comment to make a later edit look planned.
- Never commit, push or open a pull request; that is the operator's call and another skill's job.
