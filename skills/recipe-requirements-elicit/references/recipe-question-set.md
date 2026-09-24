# Recipe Question Set

The five dimensions a Goose recipe needs answered beyond what the generic interview captures, the
probes for each, and the baseline-check procedure that turns answers into criterion references.
Everything generic — funnel order, teach-back, confidence gating, the eight-dimension gap matrix —
is `nolte-shared:requirements-elicit`'s and is not repeated here.

One question or one tightly coupled group per turn. Offer divergent readings as options rather than
asking "can you clarify". Record what the author cannot answer as an open point, never as a value.

## 1. Inputs

What the recipe takes from its caller. Each becomes a candidate parameter.

- "Walk me through what someone has to hand this recipe before it can start."
- Per input: "Is it required every time, or can it be left out?" — if optional: "What should it be
  when left out?" A missing default for an optional input is an open point, not a guess.
- Per input: "Is this a path the recipe reads, a value it uses as-is, a choice from a fixed list,
  a number, or yes/no?"
- Per path-shaped input: "Should the recipe read that file's contents, or only know where it is?"
  — this decides `Imports a file`, and it is the question most often answered wrong.
- "Is there an input you would want pre-filled for convenience?" — probe: a pre-filled
  file-importing input is the case `R-004` exists for.

## 2. Host capabilities

What the recipe needs the host to be able to do.

- "What does the recipe have to be able to *do* — read files, run commands, reach the network,
  call another recipe, ask the user something?"
- Per capability: "Does that mean running code on the machine?" — record `Executes code: yes/no`.
  Any `yes` is surfaced in the baseline check under `R-007` and `GAP-EXT-SEMANTICS`.
- "Is there anything the recipe must be *unable* to do?" — feeds dimension 5.

## 3. Execution mode

- "Will someone be at the keyboard while it runs, or does it run on its own — in a pipeline, on a
  schedule, from another tool?"
- If "on its own" or "both": record `headless`. This is a requirement, not a detail, because it
  decides whether the recipe needs a `prompt` (`R-010`). If the author does not know, record the
  mode as an open point and say the audit will report `R-010` as undecided.

## 4. Output shape

- "When it finishes, what should exist that did not before? A file, a message, a structured
  answer, a change somewhere?"
- "Does anything downstream read that output by machine?" — a `yes` means a structured response,
  which the baseline lists under `GAP-RECIPE-FIELDS`.
- "What should it hand back when it cannot finish?"

## 5. Prohibited behaviour

- "What must this recipe never do, even if asked?" — offer concrete negatives: write outside a
  directory, delete, push, spend money, contact a service, modify its own inputs.
- "What should never happen to the input material?"

## Baseline check

Run after the five dimensions are answered. Read the pinned revision at run time — never a list
baked into this file, so a later revision changes the mapping without editing this skill:

```text
${CLAUDE_PLUGIN_ROOT}/baselines/goose/<baseline_revision>/ruleset.md
${CLAUDE_PLUGIN_ROOT}/baselines/goose/<baseline_revision>/coverage.md
```

For each captured requirement, find the criterion or gap whose `applies_to` and expectation match
it, and record one row in the artifact's Baseline check table. The mapping below is what the
`2026-08-02` revision yields; confirm each id exists in the pinned `ruleset.md` before writing it:

| Captured | Look for | Consequence to record |
|---|---|---|
| An optional input with `Imports a file: yes` | The criterion forbidding defaults on file parameters (`R-004` in 2026-08-02) | violates by construction |
| An optional input with no default | The criterion requiring defaults on optional parameters (`R-003`) | violates by construction |
| Execution mode `headless` or unknown | The criterion requiring `prompt` for headless use (`R-010`) | by construction if a prompt is planned; otherwise cannot be decided until the mode is known |
| Any host capability | The criterion surfacing code-executing extensions (`R-007`) and the gap on extension field semantics (`GAP-EXT-SEMANTICS`) | reported as judgment call / cannot be decided by the audit |
| A structured output, a retry need, a sub-recipe, or settings | The gap on those recipe fields (`GAP-RECIPE-FIELDS`) | cannot be decided by the audit |

When no row applies, the table reads "none". The section is never omitted: "none" is a claim,
silence is not.

## What this file does not do

It does not decide anything. A row here tells the author what the audit will say later, so the
decision — keep the requirement, change it, or accept an `undecided` — is made now, on the record,
rather than discovered after the recipe is written.
