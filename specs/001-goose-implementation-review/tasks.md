---

description: "Task list for feature implementation"
---

# Tasks: Review Process for Goose Implementations

**Input**: Design documents from `/specs/001-goose-implementation-review/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Test tasks ARE included. The tasks template treats them as optional, but this feature
requires them: `FR-005`/`SC-002` (identical findings across runs) is an untestable claim without
fixtures and golden files, and Constitution Principle III requires a verification step per stage.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

**Revision note**: Renumbered after `/speckit-analyze`. Twelve findings were remediated; the tasks
added for them are marked ⟵ in this list. No task had been completed, so renumbering was free.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

Paths follow the Structure Decision in `plan.md`: `baselines/` (versioned criteria), `process/`
(method and execution shell), `tests/` (fixtures and golden files). The review subject is never part
of this tree — it arrives as the `subject_path` parameter.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the directory skeleton the whole feature rests on

- [X] T001 Create directory skeleton `baselines/goose/`, `process/goose-implementation-review/`, and `tests/goose-implementation-review/{fixtures,expected}/` per plan.md Structure Decision
- [X] T002 [P] Write `process/goose-implementation-review/README.md` stating what this directory is, that it is copied wholesale into consuming repositories, and that it must contain nothing specific to this repository (Principle I)
- [X] T003 [P] Write `baselines/README.md` stating the immutability rule: a published revision directory is never edited in place; corrections create a new revision (`FR-011`)
- [X] T004 [P] Create `process/goose-implementation-review/VERSION.md` initialised to `0.1.0`, documenting the MAJOR/MINOR/PATCH semantics from plan.md and stating that this axis is independent of both the repository version and the baseline revision (Principle II) ⟵

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The formats every user story depends on. No story can start until these exist.

**⚠️ CRITICAL**: These define the shared contracts. Changing them later invalidates every fixture.

- [X] T005 Derive the criterion format template from `contracts/baseline-contract.md` section "Criterion entry schema" — that section is normative and must not be paraphrased; this task produces a copy for embedding into revisions ⟵
- [X] T006 [P] Write the report template `process/goose-implementation-review/report-template.md` implementing `contracts/review-report.md`, including the mandatory `Process version`, `Coverage` and `Criteria Applied` sections and the fixed sort order (severity, then location)
- [X] T007 [P] Write the multi-stage process definition `process/goose-implementation-review/process.md`, declaring each stage with preconditions, outputs, completion condition, and verification step, and referencing `VERSION.md` as its version of record (Principle II, Principle III)
- [X] T008 Write `baselines/goose/2026-07-31/criterion-format.md` as the revision's own copy of the schema from T005, so this revision stays interpretable after the schema evolves (`FR-011`) ⟵
- [X] T009 Seed the first baseline revision at `baselines/goose/2026-07-31/ruleset.md` from the rules already sourced in `research.md`: the four recipe validation rules and the required/optional field sets, each carrying its source URL and consulted date
- [X] T010 [P] Write `baselines/goose/2026-07-31/sources.md` recording each source with URL, version, consulted date, and evidence class per `002-qa-documentation-base` FR-001
- [X] T011 [P] Write `baselines/goose/2026-07-31/coverage.md` declaring `goose_version: v1.45.0`, the covered topics, and every known gap — including the unverified configuration file noted in `research.md` Finding 4

**Checkpoint**: Criterion format, report format, process stages, process version, and a minimal published baseline exist. User stories can begin.

---

## Phase 3: User Story 1 - Evidence-Backed Review Report (Priority: P1) 🎯 MVP

**Goal**: Produce a report in which every finding names its location and its documented source.

**Independent Test**: Run against one fixture; confirm every finding traces to both a location in the fixture and a named source, verifiable without asking the author.

### Tests for User Story 1

- [X] T012 [P] [US1] Create fixture `tests/goose-implementation-review/fixtures/recipe-with-deviations/recipe.yaml` containing known, sourced defects: a file parameter carrying a default, an unused parameter, and a missing required field
- [X] T013 [P] [US1] Create fixture `tests/goose-implementation-review/fixtures/recipe-clean/recipe.yaml` that satisfies every criterion in the seeded baseline
- [X] T014 [P] [US1] Create fixture `tests/goose-implementation-review/fixtures/no-goose-material/notes.md` containing no recognizable recipe, for the Edge Case in spec.md
- [X] T015 [P] [US1] Create the reference fixture `tests/goose-implementation-review/fixtures/reference-recipe/recipe.yaml` of representative size, and document in `tests/goose-implementation-review/RESULTS.md` that it is the artifact defining "representative" for `SC-005` ⟵
- [X] T016 [P] [US1] Create fixture `tests/goose-implementation-review/fixtures/recipe-oversized/recipe.yaml` too large to review in one pass, for the coverage Edge Case in spec.md ⟵
- [X] T017 [US1] Write golden file `tests/goose-implementation-review/expected/recipe-with-deviations.md` listing the exact findings expected for T012, in the sort order fixed by `contracts/review-report.md`
- [X] T018 [P] [US1] Write golden file `tests/goose-implementation-review/expected/recipe-clean.md` — zero findings, but with `Coverage` and `Criteria Applied` present, proving a clean subject is distinguishable from an unexamined one

### Implementation for User Story 1

- [X] T019 [US1] Write the review recipe `process/goose-implementation-review/recipe.yaml` implementing `contracts/recipe-interface.md`: `title`, `description`, `instructions`, and the four parameters with `subject_path` required and default-less
- [X] T020 [US1] Implement the subject-discovery stage in `process/goose-implementation-review/process.md`, identifying in-scope recipe definitions and their declared extension configurations (`FR-001`) and emitting the coverage statement (`FR-008`)
- [X] T021 [US1] Implement the criterion-evaluation stage in `process/goose-implementation-review/process.md`, producing a finding per deviation with `criterion_id`, `location`, `outcome`, `severity`, `rationale` (`FR-002`, `FR-003`)
- [X] T022 [US1] Implement the undecided-outcome rule in `process/goose-implementation-review/process.md`: a criterion that cannot be decided from the material is reported as `undecided` with its reason and never counted as passing (`FR-007`)
- [X] T023 [US1] Implement report rendering against `process/goose-implementation-review/report-template.md`, emitting `process_version` and `baseline_revision` in the header and rejecting publication when any finding lacks criterion, location, or source (`SC-001`)
- [X] T024 [US1] Implement and verify the read-only invariant in `process/goose-implementation-review/process.md`: record a checksum of every file under `subject_path` before the run, re-check after, and fail the run if any differ. Record the check in `tests/goose-implementation-review/RESULTS.md` (`FR-006`) ⟵
- [X] T025 [US1] Implement partial-coverage handling in `process/goose-implementation-review/process.md`: when a subject cannot be reviewed in one pass, the unreviewed parts are listed in `not_examined` with a reason, so a partial review can never read as complete (`FR-008`, `SC-006`) ⟵
- [X] T026 [US1] Run the review against fixture T012 and reconcile against golden file T017; record the run in `tests/goose-implementation-review/RESULTS.md`
- [ ] T027 [US1] Run the review against fixtures T013, T014 and T016, confirming a clean report, a "nothing reviewable found" report, and an explicitly partial report respectively
- [X] T028 [US1] Run the review with `subject_path` set to `process/goose-implementation-review/recipe.yaml` — the process reviewing its own recipe (Principle V, quickstart Scenario 6) — and fix every finding it raises against itself
- [ ] T029 [US1] Have a person who did not author the baseline resolve a sample of at least 20 findings from the T026 report to their sources unaided, and record the resolution rate in `tests/goose-implementation-review/RESULTS.md`. Below 90%, correct the offending citations before proceeding (`SC-003`) ⟵

**Checkpoint**: US1 is independently testable and delivers value. This is the MVP.

---

## Phase 4: User Story 2 - Stated, Reproducible Baseline (Priority: P2)

**Goal**: A report states which baseline it used, and repeating a run reproduces it exactly.

**Independent Test**: Run twice against an unchanged fixture and unchanged baseline; the two reports must be byte-identical apart from the run date.

### Tests for User Story 2

- [X] T030 [P] [US2] Add the reproducibility procedure to `tests/goose-implementation-review/RESULTS.md`: run T012 twice and diff the two reports byte for byte
- [ ] T031 [P] [US2] Create fixture `tests/goose-implementation-review/fixtures/recipe-version-mismatch/recipe.yaml` declaring a Goose version outside the baseline's stated range, for the version-mismatch Edge Case
- [ ] T032 [P] [US2] Add the offline procedure to `tests/goose-implementation-review/RESULTS.md`: run a review with upstream unreachable, for the "reference documentation cannot be reached" Edge Case ⟵

### Implementation for User Story 2

- [ ] T033 [US2] Implement baseline pinning in `process/goose-implementation-review/recipe.yaml`: the `baseline_revision` parameter selects a revision directory and defaults to `latest`
- [X] T034 [US2] Emit `process_version`, `baseline_revision`, `goose_version`, and `run_date` into the report header per `contracts/review-report.md` (`FR-004`)
- [ ] T035 [US2] Implement the version-mismatch rule in `process/goose-implementation-review/process.md`: a subject built against a version outside the baseline range yields one dedicated finding, not a flood of derived deviations
- [ ] T036 [US2] Implement the upstream drift check in `process/goose-implementation-review/process.md`: an available newer baseline revision is reported as its own finding, never applied silently mid-review (`FR-010`)
- [ ] T037 [US2] Implement offline behaviour in `process/goose-implementation-review/process.md`: with upstream unreachable, the review proceeds against the pinned baseline and states that drift could not be checked, or refuses — never reviewing silently against nothing ⟵
- [ ] T038 [US2] Create a second baseline revision `baselines/goose/<later-date>/` containing at least one corrected or added criterion, so revision handling is exercised against real data rather than assumed ⟵
- [ ] T039 [US2] Verify revision retention: confirm `baselines/goose/2026-07-31/` is byte-identical to its published state after T038, and that a report naming it remains interpretable (`FR-011`). Record in `tests/goose-implementation-review/RESULTS.md` ⟵
- [X] T040 [US2] Verify the byte-identity check from T030 passes; if it fails, record the divergence in `specs/001-goose-implementation-review/plan.md` Complexity Tracking, since the deterministic-checker deferral must then be revisited

**Checkpoint**: Reviews are reproducible and their yardstick is stated.

---

## Phase 5: User Story 3 - Usable Against Foreign Implementations (Priority: P3)

**Goal**: The process runs in a repository that is not this one, with no edits.

**Independent Test**: Copy `process/` and `baselines/` into an unrelated repository containing a recipe, run, and obtain a valid report without editing either directory.

### Tests for User Story 3

- [X] T041 [P] [US3] Write the portability check procedure in `tests/goose-implementation-review/PORTABILITY.md`: copy both directories to a scratch location outside this repository, run against a recipe there, record the outcome
- [X] T042 [P] [US3] Write a grep-based guard in `tests/goose-implementation-review/PORTABILITY.md` that fails when `process/` or `baselines/` contains this repository's name, an absolute path, or any author-specific value

### Implementation for User Story 3

- [ ] T043 [US3] Remove every subject-specific and repository-specific value from `process/goose-implementation-review/`, converting each into a declared parameter with a documented default (`FR-009`)
- [ ] T044 [US3] Document required inputs and their defaults in `process/goose-implementation-review/README.md`, so a foreign consumer can run the process without reading its internals
- [ ] T045 [US3] Execute the portability check from T041 against two unrelated repositories and record both runs in `tests/goose-implementation-review/PORTABILITY.md` (`SC-004` requires at least two)

**Checkpoint**: The process is reusable, satisfying the project's central non-negotiable.

---

## Phase 6: User Story 4 - Change Between Reviews (Priority: P4)

**Goal**: A repeat review classifies each finding as new, resolved, or unchanged, and names the cause.

**Independent Test**: Review, fix one deviation, review again with `compare_to`; the fixed finding must read `resolved` with cause `subject`.

### Tests for User Story 4

- [ ] T046 [P] [US4] Create fixture `tests/goose-implementation-review/fixtures/recipe-with-deviations-fixed/recipe.yaml` — T012 with exactly one deviation corrected
- [ ] T047 [P] [US4] Write golden file `tests/goose-implementation-review/expected/delta-subject-change.md` with the expected delta classification for the T012 → T046 transition

### Implementation for User Story 4

- [ ] T048 [US4] Implement the `compare_to` parameter in `process/goose-implementation-review/recipe.yaml` per `contracts/recipe-interface.md`, defaulting to empty
- [ ] T049 [US4] Implement delta classification in `process/goose-implementation-review/process.md`: each finding marked `new`, `resolved`, or `unchanged` against the prior report (`FR-012`)
- [ ] T050 [US4] Implement cause attribution in `process/goose-implementation-review/process.md`, distinguishing `subject` from `baseline` so a finding that vanished due to a baseline change is never reported as a fix
- [ ] T051 [US4] Verify T047, then repeat against the second revision from T038 with the subject unchanged, confirming cause reads `baseline`

**Checkpoint**: The review becomes an improvement loop rather than a single verdict.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Release readiness

- [ ] T052 [P] Run every scenario in `specs/001-goose-implementation-review/quickstart.md` end to end and record outcomes in `tests/goose-implementation-review/RESULTS.md`
- [ ] T053 [P] Reconcile `baselines/goose/2026-07-31/coverage.md` against the criteria actually implemented, so no covered-but-unimplemented criterion is claimed (`SC-006`)
- [ ] T054 Time a full review of the reference fixture from T015, from invocation to a triaged findings list, and record the measurement in `tests/goose-implementation-review/RESULTS.md`. Over 15 minutes, record what dominated the time before adjusting scope (`SC-005`) ⟵
- [ ] T055 [P] Confirm every generated report is plain text, readable without special tooling, and diffs cleanly under version control; record the check in `tests/goose-implementation-review/RESULTS.md` (`FR-013`) ⟵
- [ ] T056 Update `CLAUDE.md` with the now-existing `baselines/`, `process/`, and `tests/` trees and the commands to run a review
- [ ] T057 Re-run the self-review from T028 against the finished process and confirm it raises no finding it would flag in another subject (Principle V)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Stories (Phase 3–6)**: All depend on Phase 2. US1 first; US2–US4 may then run in parallel
- **Polish (Phase 7)**: Depends on the desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: Depends only on Foundational. Delivers the MVP
- **US2 (P2)**: Depends on Foundational. Consumes US1's report rendering but is independently testable via the reproducibility diff
- **US3 (P3)**: Depends on Foundational. Independently testable by copying the directories out
- **US4 (P4)**: Depends on US1 producing at least one report to compare against, and on T038's second revision for the baseline-cause case — the only genuine cross-story dependencies

### Within Each User Story

- Fixtures and golden files before implementation, so expected outcomes are fixed in advance
- Format definitions (Phase 2) before any task that emits them
- T005 before T008: the revision's copy is derived from the normative schema, never authored twice
- Story complete and its checkpoint verified before moving to the next priority

### Parallel Opportunities

- T002, T003, T004 in Setup
- T006, T007, T010, T011 in Foundational (T005 first, then T008 and T009 before their dependents)
- All fixture and golden-file tasks within a story (T012–T016, T018; T030–T032; T041–T042; T046–T047)
- US2 and US3 can proceed in parallel once US1 is complete

---

## Parallel Example: User Story 1

```bash
# Launch all fixtures for User Story 1 together:
Task: "Create fixture tests/goose-implementation-review/fixtures/recipe-with-deviations/recipe.yaml"
Task: "Create fixture tests/goose-implementation-review/fixtures/recipe-clean/recipe.yaml"
Task: "Create fixture tests/goose-implementation-review/fixtures/no-goose-material/notes.md"
Task: "Create fixture tests/goose-implementation-review/fixtures/reference-recipe/recipe.yaml"
Task: "Create fixture tests/goose-implementation-review/fixtures/recipe-oversized/recipe.yaml"

# Then the golden files (T017 depends on T012; T018 is independent):
Task: "Write golden file tests/goose-implementation-review/expected/recipe-clean.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational — defines the formats; changing them later invalidates fixtures
3. Complete Phase 3: User Story 1, ending with the self-review at T028 and the third-party
   verification at T029
4. **STOP and VALIDATE**: quickstart Scenarios 1, 2, 6, 8, 9 and 12
5. At this point the process produces evidence-backed reports, has reviewed itself, leaves its
   subject untouched, states its coverage honestly, and its citations have been shown to hold up for
   someone other than their author

### Incremental Delivery

1. Setup + Foundational → formats, process version, and a minimal published baseline exist
2. US1 → evidence-backed reports (MVP)
3. US2 → reproducibility, a stated yardstick, and revision retention
4. US3 → reusable in foreign repositories, satisfying Principle I
5. US4 → delta between reviews

### Release Gate

Per `quickstart.md`, Scenarios 1–6 and 8–12 must pass before release; Scenario 7 (US4) may trail and
Scenario 13 is a recorded measurement rather than a gate. T024, T028 and T057 are non-negotiable:
Principle V forbids releasing an artifact that has not performed real work in this repository, and
an unverified read-only promise (T024) is the one defect that could damage a consumer's repository
rather than merely misinform them.

---

## Notes

- [P] tasks touch different files and have no dependency on incomplete work
- The seeded baseline (T008–T011) is the minimum viable baseline permitted by
  `contracts/baseline-contract.md`. It is deliberately thin: `002-qa-documentation-base` is what
  grows it. Its declared gaps are what keep the thinness honest rather than dangerous
- Tasks marked ⟵ were added by the `/speckit-analyze` remediation. They exist because the analysis
  found requirements with no task at all (`FR-006`, `FR-011`, `FR-013`, `SC-003`, `SC-005`), a
  constitution principle with no task (II), and two edge cases with no fixture
- Commit after each task or logical group
- Stop at any checkpoint to validate a story independently
