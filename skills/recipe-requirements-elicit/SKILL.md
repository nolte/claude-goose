---
name: recipe-requirements-elicit
description: "Captures what a Goose recipe must do, as an artifact a stranger can build from. Delegates the interview method and the generic requirement artifact to `nolte-shared:requirements-elicit`; adds only the questions a Goose recipe needs answered — inputs, host capabilities, execution mode, output shape, prohibitions — and checks each answer against the pinned baseline revision. Invoke when the user wants to start a new Goose recipe, says what a recipe should do but has not written it down, or asks for the requirements of a recipe; also German. Don't use to plan the recipe (recipe-plan), to write it (recipe-implement), or for requirements that are not about a Goose recipe (nolte-shared:requirements-elicit directly). Fails closed when nolte-shared is not installed. Supports resume per spec/claude/resumable-work/."
tags: [requirements, goose]
phase: plan
summary: "Elicits a Goose recipe's requirements: the generic interview via nolte-shared, plus the five recipe dimensions and a baseline check."
use_when:
  - "you want to build a Goose recipe and need its requirements written down first"
  - "recipe-plan needs a confirmed recipe requirement artifact that does not exist yet"
dont_use_when:
  - situation: "You already have a confirmed recipe requirement artifact and want the plan"
    alternative: recipe-plan
  - situation: "The requirements are not about a Goose recipe"
    alternative: nolte-shared:requirements-elicit
see_also:
  - nolte-shared:requirements-elicit
  - recipe-plan
resumable: true
---

# Recipe Requirements Elicitation

Phase one of the Goose recipe lifecycle. Produces `project/recipes/<slug>/requirements.md`: what the
recipe must do, stated so that `recipe-plan` — or a person — can build from it without asking the
author. The generic part of the work is done by `nolte-shared:requirements-elicit`; this skill adds
the recipe-specific part and nothing else.

## Why this is a skill, not an agent

- **Mid-flow interactivity is the contract.** The delegated interview is one question per turn with
  teach-back, and the five recipe dimensions are asked the same way. An agent's isolated context
  cannot hold that dialogue.
- **It orchestrates another skill.** `Skill(skill="nolte-shared:requirements-elicit")` runs inside
  this session; the pattern is the one `pull-request-merge` uses for `review`.
- **A persistent on-disk artifact** with a state (`draft` → `confirmed`) that the next phase reads.
- Counter-dimension considered: the baseline check is a read-only computation an agent could do.
  Outweighed because its result is presented to the author for a decision mid-interview, not
  returned as a report afterwards.

## User-language policy

Conduct the interview in the user's language. Write the artifact in English, with the recipe
dimension names and criterion ids verbatim.

## Precondition — the delegation target

Before anything else, invoke the shared skill:

```text
Skill(skill="nolte-shared:requirements-elicit")
```

If the invocation is refused because the skill name is unknown, stop and reply exactly:

```text
recipe-requirements-elicit needs nolte-shared:requirements-elicit, which is not installed.
Install the nolte-shared plugin at v0.1.11 or later from the nolte/claude-shared marketplace.
Nothing was written.
```

Do not conduct an interview of your own in its place, do not try an un-namespaced name, and do not
write any file. The generic method is that skill's, and a copy of it here is the duplicate this
plugin exists to avoid.

## Operations

### 1. `elicit` — the default

1. **Resolve the baseline revision first.** If the operator named one, use it; otherwise take the
   lexicographically greatest directory under `${CLAUDE_PLUGIN_ROOT}/baselines/goose/`. Record the
   concrete id; the word `latest` never appears in an artifact. Read `lifecycle_version` from
   `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md` and `review_process_version` from
   `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/VERSION.md`.
2. **Run the delegated interview** (`nolte-shared:requirements-elicit`, operation `elicit`) for the
   recipe as the bounded context. It writes `project/requirements/<slug>.md`. Use the same `<slug>`
   for this skill's artifact. Do not ask any generic question through this skill's own text.
3. **Ask the recipe question set** in `references/recipe-question-set.md`: inputs, host
   capabilities, execution mode, output shape, prohibited behaviour. One question or one tightly
   coupled group per turn. What the author cannot answer becomes an open point.
4. **Run the baseline check** as that file describes: read the pinned revision's `ruleset.md` and
   `coverage.md` at run time and record, per captured requirement, the criterion or gap it meets and
   the consequence. Present each row to the author before writing — this is where a requirement
   that would fail the audit by construction is changed or knowingly kept.
5. **Teach back the recipe profile** — inputs, capabilities, mode, output, prohibitions — in the
   author's terms. On explicit confirmation the state is `confirmed`; otherwise `draft`.
6. **Write** `project/recipes/<slug>/requirements.md` from `templates/recipe-requirements.template.md`,
   naming the generic artifact by path, with both version fields and the concrete baseline id.
   Confirm the path back to the user and say which state it is in.

### 2. `validate` — check an existing artifact

Run against a given `project/recipes/<slug>/requirements.md`, hand-written or produced here:

- [ ] The generic artifact named in the header exists
- [ ] `baseline_revision` is a concrete id and exists under `${CLAUDE_PLUGIN_ROOT}/baselines/goose/`
- [ ] Both version fields are present
- [ ] Every input row carries all of: required, default, imports-a-file, serves
- [ ] Execution mode is one of `interactive`, `headless`, `both`, with a reason
- [ ] The Baseline check section is present — "none" or rows — and every id it names exists in the
      pinned revision
- [ ] Every input that imports a file and is optional appears in the Baseline check with the
      criterion that forbids a default on it
- [ ] Open points are listed, or "none"
- [ ] `State` is `confirmed` only if no open point remains and a teach-back is recorded

Report pass or fail per item. Never fix content: a missing value is the author's to supply.

## Resuming a run

State is persisted to `.resume/recipe-requirements-elicit/<run-id>.yml` after the delegated
interview completes and after each recipe dimension is confirmed, per `spec/claude/resumable-work/`
in `nolte/claude-shared`. On re-invocation, scan that directory for `status: in_progress` runs whose
inputs match and offer `resume / start-new / discard`.

## Hard rules

- Never ask a generic requirements question through this skill's own text; that is the shared
  skill's work.
- Never write a guessed value where the author could not answer; write an open point.
- Never write `latest` as a baseline revision.
- Never mark the artifact `confirmed` without an explicit teach-back confirmation.
- Never omit the Baseline check section; "none" is a claim, silence is not.
- Never proceed without the delegation target; fail closed with the message above.
