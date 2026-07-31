# Contract: Review Recipe Interface

**Feature**: `001-goose-implementation-review` | **Date**: 2026-07-31

The process is invoked as a Goose recipe. This contract fixes its parameters and outputs. It is the
reuse boundary from Constitution Principle I: everything subject-specific enters through here.

## Host contract

Targets the recipe schema of **Goose v1.45.0** (`aaif-goose/goose`), per
[Recipe Reference Guide](https://goose-docs.ai/docs/guides/recipes/recipe-reference/), consulted
2026-07-31. Only documented fields are used; no undocumented behavior is relied upon
(Principle IV).

## Required recipe fields

Per the reference, `title` and `description` are required, and at least one of `instructions` or
`prompt` must be present. This recipe supplies `title`, `description`, and `instructions`.

## Parameters

| Name | Kind | Required | Default | Purpose |
|---|---|---|---|---|
| `subject_path` | string (a path) | yes | — none, and none needed — | The implementation to review |
| `baseline_revision` | string | no | `latest` | Which baseline revision to apply |
| `output_path` | string | no | `./review-report.md` | Where the report is written |
| `compare_to` | string | no | `""` (empty — no comparison) | A prior report, to compute a delta |
| `max_bytes_per_pass` | number | no | `0` (unlimited) | Byte budget for one pass; files beyond it are reported as not examined |

**Constraints inherited from the host schema**, quoted from the reference:

- "Optional parameters must have default values" — every optional parameter above has one.
- "File parameters cannot have default values to prevent importing sensitive files" — this is why
  `subject_path` has none and is required. Giving it a default would be a schema violation *and* a
  security defect.
- "All template variables must have corresponding parameter definitions, and all defined parameters
  must be used (no unused parameters)" — each parameter above must be referenced in `instructions`,
  or removed.

These constraints are also the first criteria the process applies to *itself* when it reviews its
own recipe (Principle V).

## Extensions

The recipe declares only the extensions it needs to read files and write the report. Types are drawn
from the documented set: `stdio`, `builtin`, `platform`, `streamable_http`, `frontend`,
`inline_python`.

**`inline_python` is not used.** Executing inline code is unnecessary for a read-only review and
would widen the trust surface for a process whose subjects may be untrusted third-party material.

## Outputs

| Output | Form | Notes |
|---|---|---|
| Review report | Markdown at `output_path` | Conforms to `review-report.md` contract |
| Exit condition | Success / failure | Failure means the review could not be performed, *not* that findings were found |

**A review that produces findings is a successful run.** Conflating "found problems" with "failed to
run" would make the process unusable in any automated gate.

## Preconditions

1. `subject_path` exists and is readable.
2. The requested `baseline_revision` exists and is published.
3. When `compare_to` is set, that report exists and names a baseline revision.

A failed precondition aborts before any report is written. A partial report is never emitted — it
would violate `SC-006` by understating coverage without saying so.

## Invariants

- The subject is never written to (`FR-006`).
- The subject is never executed.
- Identical `subject_path` content plus identical `baseline_revision` yields identical findings
  (`FR-005`).
- No parameter carries a value specific to this repository (Principle I).
