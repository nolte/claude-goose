# Data Model: Researched Documentation Base

**Feature**: `002-qa-documentation-base` | **Date**: 2026-07-31

Entities are documents and records. "Field" means a named part a reader or a check can locate.

## Statement

The smallest unit that is sourced, verified and can go stale. In the shipped base a statement takes
the form of a criterion, but the model does not require that: a statement is anything the base
asserts about Goose.

| Field | Required | Notes |
|---|---|---|
| `text` | yes | The assertion, worded within the limits of its evidence class |
| `source_ref` | yes | Which Source Record backs it (`FR-001`). **Structurally mandatory** |
| `version_range` | conditional | Required when the behaviour is version-specific (`FR-010`). `SC-003` sets this at 100%: an unversioned claim about versioned behaviour is invalid, not merely imprecise |

**Validation**: A statement without `source_ref` cannot be expressed. This is the structural
enforcement of Constitution Principle VI — not a review checklist item, a schema constraint.

**Wording is bounded by the source's class.** An `authoritative` source permits "must"; an `observed`
one permits only "observed to … in version X". A statement that exceeds its class is a defect even
when it is true.

## Source Record

Where a statement comes from, precise enough to follow without searching (`FR-003`).

| Field | Required | Notes |
|---|---|---|
| `id` | yes | Stable (`S-001`, …), referenced by statements |
| `class` | yes | `authoritative` or `observed`. Community sources are inadmissible (`FR-011`) |
| `url` | conditional | Required for `authoritative`; absent for `observed` |
| `source_path` | conditional | Repository path of the documentation source, when one exists — the anchor for drift detection |
| `source_commit` | conditional | Commit SHA that last touched `source_path` at consultation time |
| `method` | conditional | Required for `observed`: how it was measured, reproducibly |
| `host_version` | yes | The Goose version this record applies to |
| `consulted` | yes | Date |
| `quote` | recommended | The passage relied upon, verbatim, so a reader need not hunt |
| `conflicts_with` | conditional | Other record ids this one contradicts. Required whenever a contradiction is known |
| `resolution` | conditional | Required when `conflicts_with` is set: how the contradiction was handled, and which record governs for which purpose |

**Validation**: An `authoritative` record without `url` is invalid; an `observed` record without
`method` is invalid. Both would be unverifiable by a third party, defeating `US2`. A record with
`conflicts_with` but no `resolution` is invalid — naming a contradiction without saying how it was
handled leaves the reader worse off than not naming it.

**Contradictions are recorded, never resolved away** (`FR-005`, `SC-007`). This is not hypothetical:
the shipped base contains one. `S-001` states "At least one of `instructions` or `prompt` must be
present"; `S-003` measured that a recipe with neither is accepted, and `S-008` measured that a
headless run needs `prompt` regardless. Documentation and behaviour disagree, and both readings are
true of their own scope — loading versus running. Suppressing either would hide the single most
valuable thing the base knows.

**Two staleness rules, by class**:

| Class | Goes stale when | Checked by |
|---|---|---|
| `authoritative` | `source_commit` differs from the current commit for `source_path` | Querying the upstream commit history |
| `observed` | The baseline targets a host version outside `host_version` | Comparing declared versions |

An observation has no document to watch — the documentation may sit untouched while the behaviour
changes in the next release. See `research.md` Finding 2.

## Open Question

A topic where research found no admissible basis. Not a failure — the honest alternative to
invention.

| Field | Required | Notes |
|---|---|---|
| `id` | yes | `GAP-…`, referenced by review findings |
| `topic` | yes | What is not established |
| `searched` | yes | What was looked at, so the effort is not blindly repeated |
| `trigger` | yes | The condition under which a consumer must report it (`FR-007`) |

**Validation**: A gap without `trigger` is unusable — a consumer cannot tell whether it applies, and
would either ignore it (false confidence) or report it always (noise).

## Verification Record

When a statement's source was last confirmed. **Append-only within a revision.**

| Field | Required | Notes |
|---|---|---|
| `source_id` | yes | Which record was checked |
| `checked` | yes | Date |
| `observed_commit` | conditional | The commit found at check time, for `authoritative` records |
| `result` | yes | `unchanged`, `drifted`, or `unreachable` |

**Validation**: Adding a record is permitted inside a published revision; editing or deleting one is
not (`FR-009`). This is the single exception to revision immutability, and it exists because
confirming that nothing changed is not a change to the criteria — see the plan's Complexity
Tracking.

## Coverage Statement

The declared map of what a revision does and does not address. Already present in the shipped
revisions.

| Field | Required | Notes |
|---|---|---|
| `covered` | yes | Topics with criteria, each naming its backing sources |
| `gaps` | yes | The Open Questions, with their triggers |
| `host_version` | yes | The version the whole revision applies to |

## Baseline Revision

The published unit. Immutable once committed or once any review has used it.

| Field | Required | Notes |
|---|---|---|
| `revision_id` | yes | Unique, never reused, ordered so "latest" is unambiguous |
| `statements` | yes | The criteria |
| `sources` | yes | The Source Records |
| `coverage` | yes | The Coverage Statement |
| `criterion_format` | yes | A copy of the schema, travelling inside the revision |
| `verifications` | no | Verification Records; grows after publication |

**State transitions**: `draft → published → superseded`. A published revision is never edited except
by appending verifications. A correction produces a new revision.

## Relationships

```text
Baseline Revision ──< Source Record ──< Statement
        │                    │
        │                    └──< Verification Record   (append-only)
        │
        └──< Open Question ──> consumed as `undecided` by the review process
```

A Statement never exists without a Source Record. A Source Record never exists without a class and a
host version. An Open Question exists precisely where a Statement could not.
