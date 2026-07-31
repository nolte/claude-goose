# Contract: Baseline Consumed from `002-qa-documentation-base`

**Feature**: `001-goose-implementation-review` | **Date**: 2026-07-31

This is the interface between the two features. `002-qa-documentation-base` produces baselines;
this feature consumes them. Neither may change its side of this contract unilaterally.

## What a published baseline revision must provide

| Element | Requirement | Consumed for |
|---|---|---|
| `revision_id` | Unique, never reused, ordered so "latest" is unambiguous | `FR-004`, report header |
| `goose_version` | The host version the criteria apply to | `FR-004`, version-mismatch finding |
| Criteria set | Each entry conforming to the schema below | Every finding |
| Criterion format | A copy of the schema the revision's criteria conform to, **inside the revision** | Interpreting an old revision after the schema evolves |
| Coverage declaration | Topics covered and topics declared as gaps | `FR-006`, `FR-007` |
| Immutability | Once published, never edited in place | `FR-011`, comparability of old reports |

**The criterion format travels inside each revision, not beside it.** A format stored once at
`baselines/goose/` would silently re-interpret every previously published revision the moment it
changed, which defeats `FR-011`: the revision would still exist but no longer mean what it meant
when it was published. Duplicating the schema per revision is the cost of keeping old reports
interpretable.

## Criterion entry schema

**This section is the normative definition of the criterion schema.** `data-model.md` describes the
entity's role and refers here for its fields; task-generated files such as a revision's copy of the
format are derived from this section. When the schema changes, it changes here first.

Each criterion in the ruleset must carry:

| Field | Required | Consequence if absent |
|---|---|---|
| `id` | yes | Findings cannot be compared across runs (`FR-012`) |
| `expectation` | yes | Not checkable |
| `decision_procedure` | yes | Two reviewers may reach different outcomes, breaking `FR-005` |
| `source` | yes | **Rejected.** An unsourced criterion must not enter the baseline (Principle VI) |
| `evidence_class` | yes | The report cannot convey how strongly a finding is backed (`FR-004` of 002) |
| `severity` | yes | Triage impossible (`FR-003`) |
| `applies_to` | yes | The process cannot tell which artifacts to evaluate it against |
| `version_range` | no | Absent means "all versions the baseline declares" |

## Gap propagation

A topic that `002` declares as a gap MUST cause this process to report the affected criteria as
`undecided`, never as passing. This is the single most important behavior in the contract: it is
what stops an incomplete baseline from producing false confidence.

Concretely: `002` FR-006/FR-007 (declare gaps, make them consumable) is what `001` FR-007 (report
undecidable criteria) rests on. If the baseline stops declaring gaps, this process silently starts
over-reporting success.

## Versioning

- A baseline revision is immutable once published; corrections produce a new revision.
- This process pins a revision per run (`baseline_revision` parameter). It never follows a moving
  target mid-review.
- Drift detection is a separate concern: an available newer revision is reported as its own finding
  (`FR-010`), not applied silently.

## Minimum viable baseline

This process can be built and released against a baseline covering **a single topic**, provided its
gaps are declared. Completeness of the baseline is explicitly not a precondition — honesty about
incompleteness is. This is what decouples the two features' schedules.

## Revisions from 2026-08-01 onward carry more, and require nothing more

Later revisions add `source_commit` and `source_path` to authoritative records, a mandatory
`version_range` on every criterion, a `verification.md` log, and where applicable `conflicts_with`
plus `resolution`.

**None of this changes what a consumer must do.** The fields are for the producer's upkeep — drift
detection and re-verification — and a review that ignores them behaves exactly as before. They are
noted here only so a reader of an older report is not surprised to find a newer revision richer than
this contract requires.

## What this contract does not cover

- How `002` researches its sources — its concern entirely.
- How criteria are worded, beyond the required fields.
- Any storage format. This contract fixes required information, not its serialization.
