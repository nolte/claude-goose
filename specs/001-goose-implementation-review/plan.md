# Implementation Plan: Review Process for Goose Implementations

**Branch**: `001-goose-implementation-review` | **Date**: 2026-07-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-goose-implementation-review/spec.md`

## Summary

Deliver a read-only review process that examines Goose recipe definitions and the extension
configurations they declare, and emits a findings report in which every finding cites both its
location in the subject and the documented rule it derives from. Criteria come from a pinned,
versioned baseline (produced by `002-qa-documentation-base`), never from the reviewer's judgment
alone, so two runs over unchanged inputs yield identical results.

The technical approach separates **what is checked** (the baseline ruleset, plain Markdown) from
**what runs the check** (a Goose recipe). That split is what makes the process reusable against
foreign repositories: the ruleset carries no knowledge of any particular subject, and the recipe
takes the subject as a parameter.

## Technical Context

**Language/Version**: None in the MVP. Deliverables are declarative: Markdown for the ruleset and
the process definition, YAML for the Goose recipe. A scripted checker is deliberately deferred —
see Complexity Tracking.

**Primary Dependencies**: Goose **v1.45.0** (released 2026-07-29, `aaif-goose/goose`) — the recipe
schema and extension types this process consumes. Documentation source of record:
`https://goose-docs.ai/`. Baseline content is supplied by feature `002-qa-documentation-base`.

**Storage**: Files under version control. Baselines are directories per revision; reports are
written per run. No database.

**Testing**: Fixture-driven. A set of sample recipes with deliberately known defects, each paired
with its expected findings. A run is correct when it reproduces the expected set exactly — this is
what makes `SC-002` (identical findings across runs) checkable rather than aspirational.

**Target Platform**: Goose CLI and Desktop, v1.45.0 or compatible. The ruleset itself is
host-independent and readable without Goose.

**Project Type**: Library plus agent integration — a reusable ruleset with an executable shell.

**Performance Goals**: `SC-005` — an operator reaches a triaged findings list within 15 minutes for
a single typical implementation. No throughput target; this is an interactive, per-subject process.

**Constraints**: Read-only toward the subject (`FR-006`); the subject is never executed; the process
must run offline against a pinned baseline; findings must be reproducible (`FR-005`).

**Scale/Scope**: MVP covers recipe definitions and their declared extension configurations for one
subject per run. Context artifacts, subagents, MCP apps and session recipes are explicitly out of
scope (`FR-001`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates derived from `.specify/memory/constitution.md` v1.0.0:

| Principle | Gate | Status |
|---|---|---|
| I. Reusable by Construction | Ruleset and process contain no path, name, or state specific to this repository; the subject is a declared input with a documented default | **PASS** — enforced by the ruleset/shell split; verified by the foreign-repository fixture |
| II. Plans Are Versioned Artifacts | The review process declares its stages with preconditions, outputs, and completion conditions, and carries its own semantic version | **PASS** — stages in `process.md`; version in `process/goose-implementation-review/VERSION.md`, on an axis independent of both the repository and the baseline revision (see Versioning below) |
| III. Auditable Revisions | Baseline revisions are append-only, superseded ones retained; every stage carries a verification step producing observable evidence | **PASS** — revision directories are never edited in place; each stage's evidence is its fixture outcome |
| IV. Host-Contract Fidelity | Integration uses only the documented recipe interface; supported host version stated explicitly; no fork or runtime patching of Goose | **PASS** — v1.45.0 stated above; the process reads recipe files and does not modify or wrap Goose |
| V. Dogfooding | The artifact performs real work in this repository before release | **PASS** — see below |
| VI. Evidence-Backed Claims | Every rule cites a documented source; unsourced expectations do not become rules; undecidable criteria are reported as such | **PASS** — enforced by `FR-002` and `FR-007`; the ruleset schema makes a source field mandatory |

**On Principle V.** Dogfooding initially appeared blocked: this repository contains no Goose recipes
to review, so the process would have nothing real to run against. It resolves cleanly because the
process is *itself* delivered as a Goose recipe — its first real subject is its own recipe. That run
is not a demonstration but a genuine review, and it doubles as the first fixture.

**Post-Phase-1 re-evaluation**: Re-checked after the design artifacts below were written. No gate
changed status. The design introduced no new host coupling, no subject-specific state in the
ruleset, and no rule without a source field.

## Project Structure

### Documentation (this feature)

```text
specs/001-goose-implementation-review/
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
├── README.md                     # the immutability rule for revisions
└── goose/
    └── <revision>/               # e.g. 2026-07-31; never edited in place once published
        ├── criterion-format.md   # the schema THIS revision's criteria conform to
        ├── ruleset.md            # the criteria, each with id, expectation, decision procedure, source
        ├── sources.md            # source records: URL, version, consulted date, evidence class
        └── coverage.md           # what this revision covers and what it declares as a gap

process/
└── goose-implementation-review/
    ├── README.md             # what a consuming repository needs to know; declared inputs
    ├── VERSION.md            # semantic version of the process itself (Principle II)
    ├── process.md            # the multi-stage review process: stages, preconditions, outputs
    ├── recipe.yaml           # Goose recipe shell; takes the subject as a parameter
    └── report-template.md    # the shape of a review report

tests/
└── goose-implementation-review/
    ├── RESULTS.md            # recorded outcomes of fixture and quickstart runs
    ├── PORTABILITY.md        # foreign-repository check procedure and its recorded runs
    ├── fixtures/             # sample subjects, including ones with known defects
    └── expected/             # expected findings per fixture (golden files)
```

**Structure Decision**: Three top-level directories, split by rate of change and by reuse boundary.
`baselines/` changes when upstream documentation changes and is the only versioned-by-revision tree.
`process/` changes when the review method changes and is what a foreign repository consumes.
`tests/` exists because `SC-002` (identical findings across runs) and `FR-005` are otherwise
untestable claims. The subject under review is never part of this tree — it arrives as a parameter.

### Versioning: two independent axes

Constitution Principle II requires the process to carry its own semantic version, independent of the
repository version. It is also independent of the baseline revision — these are two axes that move
for different reasons and must not be conflated:

| Axis | Lives in | Increments when |
|---|---|---|
| **Process version** | `process/goose-implementation-review/VERSION.md` | The review method changes — a new stage, an altered report format, a changed parameter contract |
| **Baseline revision** | `baselines/goose/<revision>/` | Upstream documentation changes, or criteria are added, corrected, or retired |

Semantics for the process version: **MAJOR** when the parameter contract or report format changes in
a way that breaks existing consumers or invalidates existing golden files; **MINOR** when a stage or
capability is added compatibly; **PATCH** for wording and clarification.

Every report names both the process version and the baseline revision. Without both, a reader
cannot tell whether a changed finding came from a changed method or a changed yardstick — the same
distinction `FR-012` demands for deltas.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations. One deliberate deferral is recorded here because it constrains what the
MVP can promise:

| Deferral | Why | Consequence to accept |
|-----------|------------|--------------------------------------|
| No scripted checker; the recipe drives an agent that applies the ruleset | A script would need its own YAML parser and rule engine before a single rule exists, and would fix the rule format prematurely | `FR-005` (identical findings across runs) is enforced by fixtures rather than guaranteed by construction. If fixtures show drift, a deterministic checker becomes necessary and this deferral must be revisited. |

**Update, 2026-07-31 — the deferral is now largely moot.** Measuring the host's behavior showed that
five of the seven criteria in the first baseline revision are enforced by Goose's own parser. Their
decision procedures were changed to delegate to `goose run --recipe <file> --explain`, which makes
those findings **deterministic by construction** rather than by fixture — a real parser, not an
agent's judgment, decides them.

What remains agent-decided is `R-002` and `R-007`, and only `R-002` is a rule check. That is a much
smaller surface for `FR-005` to rest on than the original deferral assumed, and it is the surface
worth writing a checker for if drift ever appears.

**Qualification, after the first real run.** "Deterministic by construction" is too strong. The host
stops at the first defect, so one invocation decides one criterion; reaching the others requires
derived probes — copies of the subject with earlier defects neutralized. The parser's verdict on any
given file is reproducible, but the *sequence of probes* an agent builds to get there is not
guaranteed to be. Determinism therefore holds per check, not per report, and `FR-005` still rests on
fixture comparison for the report as a whole.

The finding cuts both ways: the host enforcing most criteria also means most of the first revision
duplicates a check that already exists. `R-002` is the exception — the documentation states the rule
and the parser ignores it — and it is the strongest argument that this feature is worth building.
Future baseline growth should favour criteria the host does **not** enforce.

**Second update, 2026-07-31 — `FR-005` verified, and the deferral is vindicated.** T040 required
recording any divergence here. Four rounds of it occurred, and all four were *specification*
defects rather than consequences of having no scripted checker:

1. Byte-comparing whole reports is the wrong test — prose varies harmlessly while findings match.
2. The subject manifest hash was never defined precisely enough to reproduce.
3. Findings derived from baseline gaps had no identity of their own.
4. Location notation was unspecified; line numbers and structural addresses were both "correct".

Each was fixed in the contract, and two consecutive runs then produced byte-identical digests
matching the golden file. Writing a deterministic checker first would have frozen one arbitrary
answer to each of these four questions before anyone knew the questions existed. The deferral stands,
and the reproducibility surface is now the digest rather than the whole report.
