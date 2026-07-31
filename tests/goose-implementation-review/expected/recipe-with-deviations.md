# Review Report: fixtures/recipe-with-deviations

**Subject**: tests/goose-implementation-review/fixtures/recipe-with-deviations (no revision)
**Process version**: 0.1.0
**Baseline**: 2026-07-31 for Goose v1.45.0
**Run date**: <run date>
**Compared to**: none

## Coverage

**Examined**: recipe.yaml (recipe definition; 2 declared extension configurations)
**Not examined**: none
**Baseline gaps**: recipe `response` / `retry` / `settings` / `sub_recipes` validation rules — not exercised by this subject

## Findings

### blocking: Required field `description` is absent

- **Criterion**: R-001
- **Location**: recipe.yaml:top-level
- **Outcome**: deviation
- **Source**: Recipe Reference Guide, "Required Fields" — https://goose-docs.ai/docs/guides/recipes/recipe-reference/ (consulted 2026-07-31)
- **Rationale**: `title` is present, `description` is not. The reference lists both as required.

### blocking: File parameter `config_file` carries a default

- **Criterion**: R-004
- **Location**: recipe.yaml:parameters[config_file]
- **Outcome**: deviation
- **Source**: Recipe Reference Guide, verbatim: "File parameters cannot have default values to prevent importing sensitive files." (consulted 2026-07-31)
- **Rationale**: `config_file` declares `input_type: file` with `default: "~/.config/goose/secrets.yaml"`. This is the precise case the rule names — a default path into a credential file.

### blocking: Template variable `undefined_var` has no parameter definition

- **Criterion**: R-005
- **Location**: recipe.yaml:instructions
- **Outcome**: deviation
- **Source**: Recipe Reference Guide, verbatim: "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." (consulted 2026-07-31)
- **Rationale**: `{{ undefined_var }}` is referenced in `instructions` but absent from `parameters`.

### blocking: Parameter `unused_param` is never referenced

- **Criterion**: R-005
- **Location**: recipe.yaml:parameters[unused_param]
- **Outcome**: deviation
- **Source**: Recipe Reference Guide, verbatim: "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." (consulted 2026-07-31)
- **Rationale**: `unused_param` is defined but appears in neither `instructions` nor `prompt`. This is the second direction of the same rule and is reported separately, because the two defects are fixed differently.

### advisory: Recipe declares a code-executing extension

- **Criterion**: R-007
- **Location**: recipe.yaml:extensions[0]
- **Outcome**: judgment call
- **Source**: Recipe Reference Guide — `inline_python` is documented as "inline Python code executed using `uvx`" (consulted 2026-07-31)
- **Rationale**: This recipe executes Python at run time. No consulted source says it should not; this is surfaced so the trust decision is made knowingly, not asserted as a defect.

## Criteria Applied

| Criterion | Result |
|---|---|
| R-001 | finding |
| R-002 | pass |
| R-003 | pass |
| R-004 | finding |
| R-005 | finding (×2) |
| R-006 | pass (plus one undecided from a declared baseline gap) |
| R-007 | finding (judgment call) |

### Additionally expected

- **advisory / undecided**: extension configuration well-formedness, from the baseline's declared
  gap "extension configuration internals". The gap touches an in-scope part, so per `FR-007` it must
  surface as `undecided` rather than as a silent pass.

---

<!--
  GOLDEN FILE. Written before implementation so expected outcomes are fixed in advance.

  Sort order is severity (blocking before advisory), then location. Two runs over this
  fixture must produce byte-identical output apart from the run date.

  Note R-003: `config_file` and `unused_param` are optional and both carry defaults, so
  R-003 passes even though R-004 fails on the same parameter. The two rules are checked
  independently and must not be merged — a subject can satisfy one and violate the other.
-->
