# Maintenance Procedure Version

**0.1.0**

The semantic version of the procedure in `MAINTENANCE.md`, as required by Constitution Principle II
("Plans Are Versioned Artifacts"). `MAINTENANCE.md` is a multi-stage plan; specifying its stages is
not the same as versioning them.

## Three independent axes

| Axis | Where | Increments when |
|---|---|---|
| **Procedure version** | this file | The maintenance method changes — a rule, a cadence, a record format |
| **Baseline revision** | `goose/<revision>/` | Criteria or sources change |
| **Review process version** | `process/goose-implementation-review/VERSION.md` | The review method changes |

They move for different reasons and must never be conflated. A revision can be republished without
touching the procedure; the procedure can change without invalidating a revision.

## Semantics

- **MAJOR** — a change that invalidates existing revisions or verification records, e.g. removing a
  required source field or altering what a drift result means.
- **MINOR** — a rule, cadence or record field is added compatibly.
- **PATCH** — wording and clarification with no behavioural change.

## History

| Version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-07-31 | Initial. Two staleness rules, the source and verification record formats, and the gap-priority policy |

**0.x means pre-release.** Per Constitution Principle V, the procedure is not released until it has
performed real work here — a full drift check across a published revision. The first release is
1.0.0.

## Why this file exists at all

An earlier plan for this feature claimed Principle II was satisfied because "the procedure is
specified in Phase 1". It was not: stages were declared, no version existed. The same omission had
already been caught in feature `001`, which is why it is recorded here rather than quietly fixed —
the pattern is more useful than the correction.
