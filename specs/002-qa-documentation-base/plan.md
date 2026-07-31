# Implementation Plan: Researched Documentation Base for Goose QA

**Branch**: `002-qa-documentation-base` | **Date**: 2026-07-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-qa-documentation-base/spec.md`

## Summary

Grow and maintain the baseline that `001-goose-implementation-review` consumes, under a rule that
makes invention structurally impossible: every statement carries a source, and a statement that
cannot be sourced becomes a declared gap rather than a fact.

The base already exists — two revisions, ten criteria, six gaps, exercised by 24 reviews. This
feature adds what a one-off authoring pass could not: **drift detection against upstream**, a
**cadence** for re-verification, and the discipline to grow the base without weakening its evidence.

The technical approach rests on one measured decision: drift is detected by the **git commit of the
documentation source file**, not by HTTP caching headers, which report site deploys rather than
content changes and would raise constant false alarms.

## Technical Context

**Language/Version**: None. Deliverables are Markdown documents plus a small drift-check procedure
built on `gh api` and `curl`.

**Primary Dependencies**: Goose **v1.45.0** documentation at `https://goose-docs.ai/`, whose source
lives in `aaif-goose/goose` under `documentation/docs/`. The GitHub API supplies commit history for
drift detection. No runtime dependency on Goose itself — this feature produces documents, it does not
run reviews.

**Storage**: `baselines/goose/<revision>/` under version control, one directory per published
revision. Immutable once published.

**Testing**: Verification is by construction and by sampling. A statement without a source reference
cannot be expressed in the criterion format. Whether citations *carry* is tested by a second reader
against a prepared sample — the mechanism already used to close `SC-003` for feature 001.

**Target Platform**: Documents readable without tooling; drift checks need network and `gh`.

**Project Type**: Reference data with a maintenance procedure. Consumed by `001`, which reads
revisions and never writes them.

**Performance Goals**: `SC-005` — a reader locates the source of an arbitrary statement in under one
minute. No throughput target.

**Constraints**: Zero unsourced statements is a release condition, not a target (`SC-001`).
Published revisions are immutable. Community sources are inadmissible (`FR-011`).

**Scale/Scope**: Currently three source records, ten criteria, six gaps. Growth is driven by the gap
list, prioritised by observed demand rather than declaration order.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates derived from `.specify/memory/constitution.md` v1.0.0:

| Principle | Gate | Status |
|---|---|---|
| I. Reusable by Construction | A baseline revision is consumable by any repository; it names no path, project or author of this one | **PASS** — already demonstrated: both revisions ran unmodified inside two foreign repositories |
| II. Plans Are Versioned Artifacts | Revisions carry ids; the maintenance procedure declares its stages with completion conditions **and its own semantic version** | **PASS** — revision ids exist; the procedure is specified in Phase 1 and versioned in `baselines/VERSION.md`, on an axis independent of the repository and of any revision |
| III. Auditable Revisions | Published revisions are append-only and retained; verification history is kept rather than overwritten | **PASS** — enforced by the immutability rule and by `FR-009` |
| IV. Host-Contract Fidelity | The supported Goose version is stated per revision; no reliance on undocumented behaviour except where explicitly recorded as an observation | **PASS** — `goose_version` is mandatory; observations are a declared, separately-worded class |
| V. Dogfooding | The base performs real work here before release | **PASS** — it already does: 24 reviews consumed it, and its gaps produced real `undecided` findings |
| VI. Evidence-Backed Claims | Every statement traces to a source; unsourced material becomes a gap; evidence class bounds wording | **PASS** — enforced structurally: `source` is mandatory in the criterion format, so an unsourced criterion cannot be expressed |

**On Principle VI.** This feature is that principle applied to itself. The safeguard is not review
discipline but the schema: a criterion without a `source` field is not a weak criterion, it is not a
criterion. That has already caught real cases — three candidate rules were rejected during feature
001 for being plausible but unsourced, and are recorded as such.

**Post-Phase-1 re-evaluation**: Re-checked after the design artifacts below. No gate changed status.
The drift procedure introduces a network dependency for *maintenance*, not for *consumption* — a
consumer reads a pinned revision offline, which preserves Principle I.

## Project Structure

### Documentation (this feature)

```text
specs/002-qa-documentation-base/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
baselines/
├── README.md                     # immutability rule and when a revision counts as published
├── MAINTENANCE.md                # NEW — the drift-check and re-verification procedure
├── VERSION.md                    # NEW — semantic version of that procedure (Principle II)
├── SOURCE-FORMAT.md              # NEW — source and verification record schemas
└── goose/
    └── <revision>/
        ├── criterion-format.md   # the schema this revision's criteria conform to
        ├── ruleset.md            # the criteria
        ├── sources.md            # source records: URL, source commit, consulted date, evidence class
        ├── coverage.md           # covered topics and declared gaps, each with a trigger condition
        ├── verification.md       # NEW — per-source verification history and drift state
        └── VERIFICATION-SAMPLE.md # NEW — the SC-002 sample for a second reader
```

**Structure Decision**: The existing revision layout is kept unchanged; feature 001 reads it and two
foreign repositories already consume it. Two files are added rather than altering the four in place.

`verification.md` records something the current files deliberately do not: **when each source was
last confirmed, and against which commit**. Folding that into `sources.md` would mix a stable record
(what a source says) with a moving one (when it was last checked), and the immutability rule would
then force a new revision for every re-verification — turning routine maintenance into revision
churn.

`MAINTENANCE.md` sits outside the revisions because the procedure is not revision-specific and must
not be duplicated per revision. `VERSION.md` accompanies it: Constitution Principle II requires a
multi-stage procedure to carry its own semantic version, on an axis independent of both the
repository and any baseline revision. `SOURCE-FORMAT.md` likewise applies across revisions — unlike
`criterion-format.md`, which travels *inside* each revision because criteria are interpreted against
the schema in force when they were published.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations. One tension is recorded because it shapes the design:

| Tension | Why it exists | Resolution |
|---|---|---|
| Immutable revisions versus routine re-verification | Principle III forbids editing a published revision, but confirming that a source is unchanged is not a change to the criteria | `verification.md` is **append-only within a revision**: adding a confirmation is permitted, editing or removing one is not. A criterion change still requires a new revision. Without this split, either re-verification becomes impossible or the immutability rule is quietly broken |
| Recording a contradiction versus resolving it | `FR-005` requires contradictions between sources to stay visible, while a criterion must still say something definite enough to decide a review | A conflicting record carries `conflicts_with` **and** `resolution`, where the resolution states which record governs *for which purpose* rather than which one wins. The shipped base's real case resolves by scope: the documentation governs whether a recipe loads, the measurement governs whether it runs |

**Correction after `/speckit-analyze`.** The first version of this plan claimed Principle II passed
because "the procedure is specified in Phase 1". Specifying stages is not versioning them; the
principle asks for a semantic version. `baselines/VERSION.md` supplies it. This is the same omission
the analysis caught in feature 001 — recorded here so the pattern is visible rather than repeated a
third time.
