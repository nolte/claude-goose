# Implementation Plan: Portable Process Logic

**Branch**: `004-portable-process-logic` | **Date**: 2026-08-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-portable-process-logic/spec.md`

## Summary

Move every rule of the review process into host-neutral artifacts, reduce each host binding to
generated invocation material, and prove the result by shipping a second binding that runs the
process without Goose.

The approach follows from one measured fact. `O-12` in `tests/goose-implementation-review/RESULTS.md`
records a constraint that was ignored twice while stated only in the recipe's background field, and
honoured on the first attempt once it appeared at the point of invocation. So a binding cannot be an
empty pointer. It can, however, contribute nothing of its own: bindings are **generated** from
`constraints.md` and `invocation-contract.md`, and the gate re-renders and compares.

That guarantee has two parts, and an earlier draft of this summary claimed only the first. A
hand-written rule cannot survive in a *generated* region, because the next comparison overwrites it.
It can survive indefinitely in a binding **template**, where the renderer reproduces it faithfully and
the comparison stays green — so `FR-018` requires every template line to sit in a declared region, and
`FR-019` forbids normative voice in the one region that is not generated. What neither part catches —
the same rule restated in different words inside a host-neutral artifact — goes in `OMISSIONS.md`
rather than being counted as covered. See research `R7`.

Host identity goes in the report header and stays out of `DIGEST v1` — putting it in the digest would
make every cross-host comparison self-report as a reproducibility failure, breaking the one comparison
this feature exists to enable.

The digest does not survive the release entirely untouched, though, and an earlier draft of this plan
said it did. It carries `process=<semver>`, so the bump to `2.0.0` rewrites that one field — the golden
files read `process=0.2.0` inside their digest block today, which refutes the claim outright.
`VERSION.md` defines MAJOR as the bump that "invalidates existing golden files"; this is that. The
correction is to re-pin the goldens' `process=` field once as part of this release and to require every
other digest field to stay byte-identical. `FR-008` is untouched by this: `process=` is a property of
the process, not of the host, so it does not vary between two hosts running the same version.

## Technical Context

**Language/Version**: POSIX `sh` and `awk` for the renderer inside the reusable tree; `bash` plus
`python3` for repository-level gate scripts, matching `scripts/check-recipe-schema.sh`. Deliverables
are Markdown and YAML.

**Primary Dependencies**: Goose 1.45.0 (first host binding); Claude Code CLI (second host binding);
the pinned `pre-commit` toolchain (`markdownlint-cli` 0.49.1, `yamllint` 1.38.0,
`pre-commit-hooks` 6.0.0) and Vale for the gate. **The reusable tree acquires no new runtime
dependency** — this is a constraint, not an observation.

**Storage**: Files. No database, no state outside the repository.

**Testing**: `task ci` for the static gate; real review runs recorded in
`tests/goose-implementation-review/RESULTS.md`; golden files under
`tests/goose-implementation-review/expected/` reconciled on the `DIGEST v1` block only.

**Target Platform**: Linux and macOS workstations; GitHub Actions runners via the shared workflows
pinned at `nolte/gh-plumbing@v1.1.26`.

**Project Type**: Documentation and process artifacts, plus one small POSIX-shell renderer. Nothing
is compiled or packaged.

**Performance Goals**: Not applicable in the usual sense. The one budget that matters: the new check
class must run in the shared CI job, so it may not need Goose, Vale, or a network — it is a render and
a file comparison.

**Constraints**: Offline-capable throughout. Published baseline revisions under `baselines/goose/`
remain immutable. Files hashed in `.specify/integrations/*.json` are not hand-edited. All authored
material is English (Constitution, Authoring Constraints). Prose wraps at 100 columns by repository
convention.

**Scale/Scope**: One process definition, two host bindings, nine constraints (seven lifted from the
recipe's absolute constraints, two from the coverage-budget and delta rules — T004 and T005), five
declared inputs, three golden files of which two are reports carrying a digest, and two new check
classes: `binding-render`, and `portability`, which implements a guard that until now existed only as
prose.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates resolved from `.specify/memory/constitution.md` v1.0.0.

### Initial check — before Phase 0

| Principle | Verdict | Basis |
|---|---|---|
| **I. Reusable by Construction** | PASS | The feature's purpose. New artifacts sit inside `process/`, take no repository-specific value, and the renderer is placed in the reusable tree precisely so a consumer can add a binding without this repository's tooling |
| **II. Plans Are Versioned Artifacts** | PASS | `process.md` keeps its per-stage preconditions, outputs, completion conditions and verification. The process carries its own semver, bumped here to `2.0.0` |
| **III. Auditable Revisions** (NON-NEGOTIABLE) | PASS | `VERSION.md` gains a history entry naming the old and new recipe paths and what a consumer must do. Superseded constraint ids are marked, never reused. **On the clause "never deleted or edited in place"**: no stage is removed — Stage 1 and Stage 6 survive, and the rule text they restate is replaced by a reference to the id that now holds it. The rule is relocated, not dropped, and what disappears is the *second* copy, which `FR-001` forbids keeping. `VERSION.md` records the relocation, so a reader can reconstruct what preceded `2.0.0` from the artifact alone |
| **IV. Host-Contract Fidelity** | PASS | The generated recipe uses only documented Goose fields; `goose run --explain` continues to gate it. Nothing reaches behind the documented interface. Adding a second host does not weaken this — the Goose binding still targets 1.45.0 explicitly |
| **V. Dogfooding** | PASS | `FR-016` requires a real review through each binding before release, and `FR-012` requires the self-review to produce no findings |
| **VI. Evidence-Backed Claims** (NON-NEGOTIABLE) | PASS | The central design decision rests on `O-12`, a recorded failure, not on plausibility. Cross-host digest agreement is explicitly *not* assumed — `FR-017` requires it measured and any difference explained |

**No violations. Complexity Tracking is empty.**

One item deserves stating rather than leaving implicit: adding a generator is new machinery in a
repository that has deliberately had none. It is justified because the two alternatives were weighed
and rejected on evidence — a bare pointer risks re-running `O-12`, and a hand-copied preamble puts a
manual step exactly where drift enters. See research `R2`.

### Post-design re-check — after Phase 1

| Principle | Verdict | What the design added |
|---|---|---|
| **I** | PASS | `contracts/binding-render.md` fixes the renderer's dependency budget at POSIX `sh` plus `awk`, so the reusable tree keeps its empty dependency set. Research `R8` wires the portability guard into the gate, closing the gap where a hard-coded absolute path in the first executable file in that tree would go unnoticed |
| **II** | PASS | `data-model.md` gives the binding an explicit state machine (`absent` → `generated` → `committed` → `drifted` → `regenerated`), with `drifted` defined as a gate-failure state that is never released |
| **III** | PASS | Research `R6` records why this is MAJOR rather than the convenient MINOR: the input contract survives, but the documented command line does not |
| **IV** | PASS | The renderer splices text and never round-trips YAML, so the recipe's comments — which carry findings from real runs — survive verbatim. Schema and parse classes run against the rendered file |
| **V** | PASS | `quickstart.md` scenarios 4, 5, 6 and 9 are the dogfooding evidence, each with a stated pass condition |
| **VI** | PASS | Research `R9` records a pre-existing false claim in `process.md` — a "Stages not yet implemented" table listing four stages the same file implements — and requires it corrected rather than re-published |

**Still no violations.** The re-check surfaced no new tension; it tightened two items — the dependency
budget and the portability guard — that the initial check had only asserted.

## Project Structure

### Documentation (this feature)

```text
specs/004-portable-process-logic/
├── plan.md                       # This file
├── research.md                   # Phase 0 — R1..R10 and what stays open
├── data-model.md                 # Phase 1 — artifacts, derivation, state
├── quickstart.md                 # Phase 1 — nine validation scenarios
├── contracts/
│   ├── invocation-contract.md    # The host-neutral input contract
│   ├── binding-render.md         # The renderer's interface and dependency budget
│   └── report-host-field.md      # The one report-format change
├── checklists/
│   └── requirements.md           # Spec quality checklist (complete)
└── tasks.md                      # Phase 2 — NOT created by /speckit-plan
```

### Source Code (repository root)

```text
process/goose-implementation-review/
├── README.md                     # CHANGED  — how to run under each host
├── VERSION.md                    # CHANGED  — 2.0.0 plus a history entry
├── process.md                    # CHANGED  — host-neutral; stale stage table corrected (R9)
├── constraints.md                # NEW      — the rules, with stable ids
├── invocation-contract.md        # NEW      — named inputs plus binding obligations
├── report-template.md            # CHANGED  — Host header field; DIGEST v1 untouched
├── tools/
│   └── render-bindings.sh        # NEW      — POSIX sh plus awk
└── bindings/
    ├── goose/
    │   ├── recipe.yaml.tmpl      # NEW      — host shape plus host-specific notes
    │   └── recipe.yaml           # MOVED    — generated; was at the tree root
    └── claude-code/
        ├── run.sh.tmpl           # NEW
        └── run.sh                # NEW      — generated

scripts/
└── check-portability.sh          # NEW      — the guard from PORTABILITY.md, now wired

baselines/
└── SOURCE-FORMAT.md              # CHANGED  — drops the specs/ reference the guard rejects

.pre-commit-config.yaml           # CHANGED  — binding-render and portability classes; recipe paths
Taskfile.yml                      # CHANGED  — RECIPE var follows the move
CLAUDE.md                         # CHANGED  — documented invocation path
OMISSIONS.md                      # CHANGED  — the two limits of the region checks
tests/goose-implementation-review/
├── expected/*.md                 # CHANGED  — Host header; digest `process=` re-pinned to 2.0.0
├── PORTABILITY.md                # CHANGED  — guard is wired, not merely documented
├── QUICKSTART-STATUS.md          # CHANGED  — new invocation paths, second binding
└── RESULTS.md                    # CHANGED  — runs for FR-016 and FR-017 appended
```

**On `baselines/SOURCE-FORMAT.md`**: wiring the portability guard turns a documented procedure into an
executed one, and the first thing it finds is pre-existing. Line 7 references
`specs/002-qa-documentation-base/data-model.md`, which check 3 of the guard rejects because a consumer
never receives that tree. The file sits at the root of `baselines/`, not inside a published revision,
so the immutability rule does not protect it and it can be made self-sufficient. This is the same
defect class `PORTABILITY.md` already records under "Guard history" — found the same way, by running
the check instead of remembering it.

**Structure Decision**: A three-layer split inside the existing `process/goose-implementation-review/`
tree — host-neutral definition at the root, `tools/` for the renderer, `bindings/<host>/` for
generated invocation material. No new top-level directory: the repository's three trees
(`baselines/`, `process/`, `tests/`) are split by rate of change, and none of this changes at a
different rate from the process it belongs to.

The recipe moves into `bindings/goose/` rather than staying at the root. That move is the reason for
the MAJOR bump, and it is taken deliberately: leaving one host at the root and every other host in
`bindings/` would make the second binding look like an afterthought, which is the opposite of what
User Story 3 asks for.

## Complexity Tracking

> No Constitution Check violations. This table is intentionally empty.
