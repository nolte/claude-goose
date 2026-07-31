# Data Model: Review Process for Goose Implementations

**Feature**: `001-goose-implementation-review` | **Date**: 2026-07-31

Entities are documents and records, not database tables. "Field" means a named part a reader or an
automated check can locate.

## Review Subject

The Goose implementation under review. Supplied per run; never stored in this project.

| Field | Required | Notes |
|---|---|---|
| `location` | yes | Path or URL of the material under review |
| `identity` | yes | Stable enough that a later review can be shown to address the same subject |
| `revision` | no | Commit or version of the subject, when it has one. Absent for loose files |
| `in_scope_parts` | yes | The recipe definitions and declared extension configurations found (`FR-001`) |

**Validation**: A subject with no recognizable recipe definition is not "clean" — it yields a
coverage statement declaring nothing reviewable was found (Edge Case 1).

## Review Baseline

A published revision of the criteria. Produced by `002-qa-documentation-base`.

| Field | Required | Notes |
|---|---|---|
| `revision_id` | yes | Identifies this revision; unique and never reused |
| `goose_version` | yes | The host version the criteria apply to (`FR-004`) — e.g. `v1.45.0` |
| `criteria` | yes | The set of Review Criteria |
| `coverage` | yes | Topics covered and topics declared as gaps (`FR-006`) |
| `superseded_by` | no | Set when a later revision replaces this one; the revision itself is retained (`FR-011`) |

**State transitions**: `draft → published → superseded`. A published revision is never edited; a
correction produces a new revision. Nothing transitions back.

## Review Criterion

One checkable expectation. The unit that produces findings, and the only entity this project does
not define here.

**Fields are defined normatively in [`contracts/baseline-contract.md`](./contracts/baseline-contract.md),
section "Criterion entry schema", and are deliberately not repeated here.** That file is the
interface to `002-qa-documentation-base`, which produces criteria; restating the eight fields in
this document would create a second definition that drifts from the contract the moment either side
changes.

Role in this model: a Criterion belongs to exactly one Baseline revision, and every Finding names
the Criterion it came from. Criterion ids are stable across revisions so findings stay comparable
over time (`FR-012`).

**Validation**: `source` is mandatory at the schema level. This is the structural enforcement of
Constitution Principle VI — an unsourced expectation cannot be expressed as a criterion at all.

## Finding

One criterion, evaluated against one location, with an outcome worth reporting.

| Field | Required | Notes |
|---|---|---|
| `criterion_id` | yes | Links back to the criterion, and through it to the source |
| `location` | yes | Where in the subject (`FR-002`) — file and position |
| `outcome` | yes | `deviation`, `judgment_call`, or `undecided` |
| `severity` | yes | Inherited from the criterion; may be lowered with a stated reason, never silently |
| `rationale` | yes | Why this outcome. For `undecided`, what was missing (`FR-007`) |
| `delta_status` | no | `new`, `resolved`, `unchanged` — set only when compared to a prior report (`FR-012`) |
| `delta_cause` | no | `subject` or `baseline` — which side caused the change (Edge Case, `FR-012`) |

**Validation**: `outcome: undecided` never counts toward a passing result. A finding lacking
`location` or a resolvable `criterion_id` is invalid and blocks report publication (`SC-001`).

## Coverage Statement

What a run actually examined. Present in every report.

| Field | Required | Notes |
|---|---|---|
| `examined` | yes | In-scope parts that were reviewed |
| `not_examined` | yes | In-scope parts that were not, each with a reason |
| `baseline_gaps` | yes | Topics the baseline declares as uncovered, propagated from `002` (`FR-007`) |

**Validation**: An empty `not_examined` is a claim of complete coverage and must be true. Silence is
not permitted — the field is required precisely so partial reviews cannot masquerade as full ones
(`SC-006`).

## Review Report

The complete result of one run.

| Field | Required | Notes |
|---|---|---|
| `subject` | yes | The Review Subject as identified at run time |
| `process_version` | yes | Semantic version of the review process itself (Principle II) |
| `baseline_revision` | yes | Which revision was applied (`FR-004`) |
| `goose_version` | yes | Carried from the baseline |
| `run_date` | yes | When the review was performed |
| `coverage` | yes | The Coverage Statement |
| `findings` | yes | Zero or more Findings. Zero is a valid, meaningful result |
| `compared_to` | no | A prior report, when a delta was computed |

**Validation**: A report with zero findings must still carry its coverage statement and the criteria
applied, so "nothing found" is distinguishable from "nothing looked at" (`US1` scenario 2).

## Relationships

```text
Review Baseline ──< Review Criterion
                          │
                          │ evaluated against
                          ▼
Review Subject ──────> Finding >────── Review Report
                                              │
                                              └── compared_to ──> Review Report (prior)
```

A Finding never exists without both a Criterion and a Subject location. A Report never exists
without a Baseline revision. These are the structural expressions of `FR-002` and `FR-004`.
