---

description: "Task list for 004-portable-process-logic"
---

# Tasks: Portable Process Logic

**Input**: Design documents from `/specs/004-portable-process-logic/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: There is no test framework here and nothing is compiled. What the template calls tests are,
in this repository, two things: static check classes in `.pre-commit-config.yaml`, and **real review
runs** recorded in `tests/goose-implementation-review/RESULTS.md`. Verification tasks below are not
optional — Constitution Principle III requires an observable verification per stage, and `FR-012`,
`FR-016` and `FR-017` name specific runs that must happen before release.

**Organization**: Tasks are grouped by user story. Each story phase ends in a state that can be
demonstrated on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Paths are repository-relative. `PROC/` abbreviates `process/goose-implementation-review/`

---

## Phase 1: Setup

**Purpose**: Establish the layout and an attributable starting point

- [X] T001 Create the directory skeleton `process/goose-implementation-review/tools/`, `process/goose-implementation-review/bindings/goose/` and `process/goose-implementation-review/bindings/claude-code/`
- [X] T002 [P] Run `task ci` and confirm it is green before any edit; a red gate beforehand makes every later failure unattributable
- [X] T003 [P] Copy the `DIGEST v1` blocks of `tests/goose-implementation-review/expected/recipe-clean.md` and `recipe-with-deviations.md` into a scratch file so digest stability can be checked after the restructuring. Those are the only two golden files that contain one — `delta-subject-change.md` is a delta classification table with no report header and no digest, so it is out of scope for every digest task here (FR-008)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the host-neutral sources and the renderer. Every user story consumes these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Extract the seven absolute constraints from `process/goose-implementation-review/recipe.yaml` (`instructions`, items 0–6) into a new `process/goose-implementation-review/constraints.md`, each with a stable id `C-1`…`C-7` and a `carried_at_invocation` flag, per data-model.md (FR-001)
- [X] T005 Add the coverage-budget rule and the delta/skip rule to `process/goose-implementation-review/constraints.md` as further ids, then replace their restatements in `process/goose-implementation-review/process.md` Stage 1 and Stage 6 with references to those ids, so each rule exists in exactly one place (FR-001, SC-002)
- [X] T006 Replace the "Invariants across all stages" list in `process/goose-implementation-review/process.md` (currently five bullets, ending the file's body before the stage table) with references to the ids that now hold those rules. "The subject is never written to", "The subject is never executed. Findings come from reading the material" and the pinned-baseline bullet are verbatim restatements of the constraints T004 extracts — the second is word-for-word identical to `recipe.yaml` `instructions` item 2. Leaving them makes a rule exist three times and fails `FR-001` and `SC-002` while T005 reports success on Stage 1 and Stage 6 alone. The reproducibility bullet and the no-repository-reference bullet are properties of the process rather than constraints on a run; keep whichever are not already covered by an id, and say which id covers the rest (FR-001, SC-002)
- [X] T007 Write `process/goose-implementation-review/invocation-contract.md` from `specs/001-goose-implementation-review/contracts/recipe-interface.md`, stripped of host framing, plus the seven binding obligations from `specs/004-portable-process-logic/contracts/invocation-contract.md` (FR-003)
- [X] T008 [P] Correct the "Stages not yet implemented" table and its closing sentence in `process/goose-implementation-review/process.md`: Stage 3b and Stage 6 are implemented and `VERSION.md` records them as shipped in 1.0.0 (research R9, Principle VI)
- [X] T009 Remove the spec-tree references from the reusable tree, which a consumer can never resolve. Three places: the dangling `contracts/review-report.md` reference in `process/goose-implementation-review/report-template.md` line 63, replaced by the rules stated in place; and the `FR-005` citations in `report-template.md` line 21 and `process/goose-implementation-review/process.md` line 329 — a feature-`001` identifier that now also collides with a different `FR-005` in this feature. State what the requirement says instead of naming it. `grep -rnE '\b(FR|US|SC)-?[0-9]' process/` finds the full set; the occurrences inside the stage table are T008's. Carries no `[P]`: it edits `process.md`, which T006 and T008 also edit (FR-011, Principle VI)
- [X] T010 Add the `**Host**:` header field to `process/goose-implementation-review/report-template.md` per `specs/004-portable-process-logic/contracts/report-host-field.md`, leaving the `DIGEST v1` block untouched (FR-007, FR-008)
- [X] T011 Write `process/goose-implementation-review/tools/render-bindings.sh` per `specs/004-portable-process-logic/contracts/binding-render.md`: POSIX `sh` plus `awk` only, `GENERATED` and `HOST-SPECIFIC` marker pairs, `--check` that never writes, exit codes 0/1/2, marker-driven indentation, blank lines left empty, convention-based discovery over `bindings/*/*.tmpl` with the host name taken from the directory and the output path from the template minus `.tmpl`, exit `2` when a host directory holds none or more than one template, plus the two region checks — every template line falls inside exactly one declared region, and no `HOST-SPECIFIC` region uses normative voice, each reported with region and line. **Both region checks run in the default mode too**, and there they exit `2` before writing anything: rendering a template the tool cannot account for would commit the content the rule exists to reject, after which the gate would pass on it indefinitely (FR-005, FR-006, FR-018, FR-019, FR-020, FR-021)
- [X] T012 [P] Write `scripts/check-portability.sh` implementing the three-part guard specified in `tests/goose-implementation-review/PORTABILITY.md`: repository name, absolute paths, references to `specs/` — across both `process/` and `baselines/` (FR-011, research R8)
- [X] T013 Run `scripts/check-portability.sh` once before wiring it, and fix what it finds. It fails on pre-existing content: `baselines/SOURCE-FORMAT.md` line 7 reads "Governed by `specs/002-qa-documentation-base/data-model.md`", which check 3 rejects because a consumer never receives that tree. Make the file self-sufficient — state the format rules in place, as `criterion-format.md` was fixed for the same reason (`PORTABILITY.md`, "Guard history"). The file sits at the root of `baselines/`, not inside a published revision, so the immutability rule does not apply. Without this, T014 makes `task ci` red on content this feature did not write and T015 cannot pass (FR-011, research R8)
- [X] T014 Add a `portability` local hook to `.pre-commit-config.yaml` invoking `scripts/check-portability.sh` on the default stage, so it runs on a workstation and not only in CI
- [X] T015 Run `task ci` and confirm the portability guard passes over `process/goose-implementation-review/tools/render-bindings.sh`, the first executable file in the reusable tree

**Checkpoint**: The host-neutral definition is complete and the renderer exists. Bindings can now be generated.

---

## Phase 3: User Story 1 - Run the process without Goose (Priority: P1) 🎯 MVP

**Goal**: A review runs to a conformant report with no Goose process involved.

**Independent Test**: quickstart.md scenario 5 — invoke the Claude Code binding against
`tests/goose-implementation-review/fixtures/recipe-with-deviations` pinned to `2026-07-31b` and get a
report carrying `Host: claude-code`, a coverage statement and a `Criteria Applied` table.

- [X] T016 [US1] Write `process/goose-implementation-review/bindings/claude-code/run.sh.tmpl`: the host's own shape, the `BEGIN GENERATED` / `END GENERATED` marker pairs for constraints and inputs, and a marked host-specific-notes section
- [X] T017 [US1] Render `process/goose-implementation-review/bindings/claude-code/run.sh` with `tools/render-bindings.sh claude-code` and commit the generated file
- [X] T018 [US1] Verify the rendered `process/goose-implementation-review/bindings/claude-code/run.sh` declares all five contract inputs with matching requiredness and defaults, and introduces none of its own (invocation-contract obligations 1 and 2)
- [ ] T019 [US1] Run a real review through `process/goose-implementation-review/bindings/claude-code/run.sh` over `tests/goose-implementation-review/fixtures/recipe-with-deviations`, baseline `2026-07-31b`, output `./review-claude.md` (FR-015, FR-016)
- [ ] T020 [US1] Verify `./review-claude.md` carries `Host: claude-code`, the coverage statement and the `Criteria Applied` table, and that every finding names a criterion, a location and a source (FR-007, US1 acceptance 1 and 4)
- [ ] T021 [US1] Verify the digest in `./review-claude.md` reads `baseline=2026-07-31b` and that no criterion from a later revision appears — the `O-12` regression check, asked of the second host for the first time
- [ ] T022 [US1] Append the T019 run to `tests/goose-implementation-review/RESULTS.md` with subject, baseline, outcome, the Claude Code CLI version and the model it resolved to, and an explicit statement of whether `O-12` recurred on this host. Goose is pinned to 1.45.0 everywhere; without the second host's version the FR-016 run is not attributable and the T042 comparison carries an unnamed variable (FR-016, Principle IV)
- [ ] T023 [US1] Perform the host-neutral run per quickstart scenario 5b: hand an operator only `process/goose-implementation-review/process.md`, `constraints.md`, `invocation-contract.md` and `report-template.md` plus a subject, with no `bindings/` directory present, and have them produce a report. Record in `tests/goose-implementation-review/RESULTS.md` whether every mandatory section was produced and, if any step required opening a binding, which rule was found living there. This is the only task that tests `FR-002` — every other run goes through a binding, and both bindings are rendered from the same sources, so a rule that had migrated into the binding layer would pass all of them (FR-002, US1 acceptance 3)

**Checkpoint**: The process runs without Goose. This is the outcome the feature was requested for.

`US1` acceptance scenario 2 — the same subject reviewed once with Goose and once without, compared on
digest content — is **not** satisfied here. It needs the Goose run from T033 and the comparison in
T042, both later. Phase 3 delivers the substance of the request; the cross-host evidence for it lands
in Phase 6.

---

## Phase 4: User Story 2 - One source of truth for every constraint (Priority: P2)

**Goal**: The Goose binding becomes generated invocation material, and the gate makes drift impossible
to merge.

**Independent Test**: quickstart.md scenarios 2 and 3 — a hand edit inside a generated region fails
the gate naming the artifact and the repair command; a reworded constraint propagates to every binding
with one command and touches no host-neutral file.

- [ ] T024 [US2] Convert `process/goose-implementation-review/recipe.yaml` into `process/goose-implementation-review/bindings/goose/recipe.yaml.tmpl` with marker pairs, carrying its three host-specific findings — the extensions decision, the unconstructible optional file parameter, and `prompt` versus `instructions` — into a marked host-specific-notes section rather than discarding them (FR-014, data-model "Host-specific note")
- [ ] T025 [US2] Render `process/goose-implementation-review/bindings/goose/recipe.yaml`, leaving the old `process/goose-implementation-review/recipe.yaml` in place for now
- [ ] T026 [US2] Update the `recipe-schema` and `recipe-parse` hooks in `.pre-commit-config.yaml` so their `entry` and `files` follow the recipe to `process/goose-implementation-review/bindings/goose/recipe.yaml`
- [ ] T027 [US2] Update the `RECIPE` variable in `Taskfile.yml` to the new path, then delete the old `process/goose-implementation-review/recipe.yaml` — the pointers move before the file does, so no intermediate state has a hook naming a path that is gone
- [ ] T028 [US2] Add the `binding-render` local hook to `.pre-commit-config.yaml`, invoking `process/goose-implementation-review/tools/render-bindings.sh --check` on the default stage so drift, an undeclared template line and normative voice in a `HOST-SPECIFIC` region all fail before a push (FR-006, FR-018, FR-019, SC-008)
- [ ] T029 [US2] Update the documented invocation and the repository-state description in `CLAUDE.md` to the new layout and path
- [ ] T030 [US2] Rewrite the files table and the running instructions in `process/goose-implementation-review/README.md` to cover both hosts and to state that `bindings/` is generated
- [ ] T031 [US2] Bump `process/goose-implementation-review/VERSION.md` to `2.0.0` with a history entry naming the old path, the new path and what a consumer must change — MAJOR because the documented command line breaks even though the input contract survives (FR-009, FR-010, research R6)
- [ ] T032 [US2] Bring the two report golden files in `tests/goose-implementation-review/expected/` — `recipe-clean.md` and `recipe-with-deviations.md` — up to this release. Three edits each: add the `Host: goose` header line; correct the `**Process version**:` header, which reads `0.2.0` while `VERSION.md` has said `1.0.0` since the first release; and re-pin `process=` inside the `DIGEST v1` block to `2.0.0`. Then diff each digest against the T003 snapshot and confirm the **only** differing field is `process=` — `baseline=`, `subject=` and every finding line byte-identical. The digest carries the process version, so a MAJOR bump moves it by construction; `VERSION.md` defines MAJOR as the bump that "invalidates existing golden files". What must not reach a digest line is the header change (FR-007, FR-008). `delta-subject-change.md` is untouched: it is a classification table with no report header and no digest
- [ ] T033 [US2] Run a real review through the Goose binding at its new path per quickstart scenario 4, writing to `./review-goose.md`; reconcile the result against `tests/goose-implementation-review/expected/recipe-with-deviations.md` on the digest only, and confirm its header carries `Host: goose`, the process version and the baseline revision — SC-006 asks that of every host, not only the one US1 exercised. Runs after T032, which re-pins the golden file's `process=` field; against the old golden the reconciliation reports a difference caused by the release rather than by the run (SC-006, O-11)
- [ ] T034 [US2] Append the T033 run to `tests/goose-implementation-review/RESULTS.md` with its subject, its baseline revision, its outcome and the resulting report, mirroring what T022 records for the Claude Code binding. `FR-016` requires every shipped binding's run to be recorded and `SC-009` counts only *recorded* reviews, so the Goose run being self-evidently the older path does not exempt it (FR-016, SC-009)
- [ ] T035 [US2] Prove drift is caught: hand-edit a generated region of `process/goose-implementation-review/bindings/goose/recipe.yaml`, run `task ci`, confirm the failure names the artifact, the disagreeing source and the repair command, then restore with the renderer (SC-008, quickstart scenario 2)
- [ ] T036 [US2] Prove the region checks fire: add an unmarked line to `process/goose-implementation-review/bindings/goose/recipe.yaml.tmpl` and confirm `task ci` fails naming it (FR-018); then write a sentence in normative voice into its `HOST-SPECIFIC` region and confirm the failure names the region and the line (FR-019). Revert both
- [ ] T037 [US2] Prove the single source holds: reword one rule in `process/goose-implementation-review/constraints.md`, re-render, confirm only files under `bindings/` changed, then revert (SC-002, quickstart scenario 3)

**Checkpoint**: Both bindings are generated and gated. A rule now lives in exactly one place.

---

## Phase 5: User Story 3 - Bind a new host without re-authoring the process (Priority: P3)

**Goal**: Adding a host costs one file and no host-neutral edit.

**Independent Test**: quickstart.md scenario 7 — create a third binding template, render, and observe
that nothing above `bindings/` is modified.

- [ ] T038 [US3] Add an "Adding a host" section to `process/goose-implementation-review/README.md` covering the one-authored-file rule, that the directory name is the host and nothing needs registering, the two region kinds and their marker contract, and where the obligations are stated
- [ ] T039 [US3] Create a scratch third binding template under `process/goose-implementation-review/bindings/`, render with no arguments, confirm it was picked up without registering it anywhere and that `git status --short` shows no file above `bindings/` modified (SC-004, FR-020); then add a second template to that directory and confirm the renderer exits `2` naming the directory (FR-021). Remove both
- [ ] T040 [US3] Verify both shipped bindings declare identical input names, requiredness and defaults by comparing `bindings/goose/recipe.yaml` against `bindings/claude-code/run.sh` (US3 acceptance 3)
- [ ] T041 [US3] Record the outcome of T039 and T040 in `tests/goose-implementation-review/PORTABILITY.md`

**Checkpoint**: All three stories are independently demonstrable.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T042 Compare the digests of `./review-goose.md` and `./review-claude.md` per quickstart scenario 6 and record the result in `tests/goose-implementation-review/RESULTS.md`, with a stated cause for every differing line (FR-017, SC-001)
- [ ] T043 Run the self-review over `process/goose-implementation-review/` and confirm it produces no findings; record it in `tests/goose-implementation-review/RESULTS.md` (FR-012, SC-005, Principle V)
- [ ] T044 Perform the foreign-repository copy test per quickstart scenario 8 — copy `process/` and `baselines/` outside this repository, then run **both** shipped bindings against an unrelated subject from the copy, confirm zero edits were needed and the copies are byte-identical afterwards. `FR-013` says "under any supported host"; exercising one binding leaves the other half of the claim untested, and the Goose binding is the one whose path just moved (FR-013, SC-007)
- [ ] T045 [P] Update `tests/goose-implementation-review/PORTABILITY.md` to state that the guard is wired into the gate rather than a remembered procedure, and record the T044 run in its table
- [ ] T046 [P] Update `OMISSIONS.md` with anything this feature deliberately does not do — in particular the two limits of the region checks: a rule phrased as description inside a `HOST-SPECIFIC` region is not caught, and the same rule restated in different words inside a host-neutral artifact is not caught either. Only unmatched generated regions, undeclared template lines and normative voice are (research R7, SC-002)
- [ ] T047 [P] Update `tests/goose-implementation-review/QUICKSTART-STATUS.md` to reflect the new invocation paths and the second binding
- [ ] T048 Verify SC-003 with a second reader: hand them only `process/goose-implementation-review/invocation-contract.md` and ask them to name every input, its requiredness and its default. Pass is all five inputs, correctly, in under 5 minutes, with nothing else opened. Record the outcome and the elapsed time in `tests/goose-implementation-review/RESULTS.md`. `tests/goose-implementation-review/SC-003-SAMPLE.md` is the precedent for the **method** — a criterion the process cannot self-certify is handed to someone who did not author it, on a prepared sheet. Its *content* is a different criterion belonging to feature `001` (90% of a 20-finding sample confirmable, 20–30 minutes) and must not be applied here (SC-003)
- [ ] T049 Run `task ci` a final time and confirm every class passes, including `binding-render`, `portability`, `recipe-schema` and `recipe-parse` at the new path

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — **blocks all user stories**. It produces the sources every binding is rendered from and the renderer itself
- **US1 (Phase 3)**: Depends on Foundational only
- **US2 (Phase 4)**: Depends on Foundational only. Independent of US1 in principle; running it after US1 keeps the MVP shippable first
- **US3 (Phase 5)**: Depends on Foundational. T040 additionally needs both bindings to exist, so in practice it follows US1 and US2
- **Polish (Phase 6)**: T042 needs the runs from T019 and T033. T043 and T044 need the final layout

### Ordering constraints inside Foundational and US2

- **T012 → T013 → T014 → T015**. The guard is written, run, and its pre-existing failure fixed
  *before* it is wired. Wiring first turns the whole gate red on content this feature did not write,
  and every later task then reports a failure it did not cause — the same attributability argument
  as T002
- **T032 → T033 → T034**. The golden file's `process=` field is re-pinned before a `2.0.0` run is
  reconciled against it, and the run is recorded after it happens, never before (Principle VI)
- **T023** depends on Foundational only. It deliberately does not depend on a binding — that is what
  makes it evidence for `FR-002`

### Why Foundational is large here

This feature is a restructuring, so most of the work is the extraction itself and it genuinely blocks
everything. Splitting it across stories to make the phases look balanced would create an artificial
dependency where the second story could not run until the first had finished extracting a shared file.
The honest shape is a heavy Phase 2 and a thin, sharply testable tail per story.

### Within each user story

- Template before render before verify before record
- A real run before the record of that run — no task writes a result it did not observe (Principle VI)

### Parallel Opportunities

- T002 and T003 during Setup
- T008 and T012 during Foundational: two different files, neither depending on the other. Phase 2 is
  otherwise sequential by file collision — T004 → T005 write `constraints.md`; T005, T006, T008 and
  T009 all edit `process.md`; T009 → T010 both edit `report-template.md`; and T012 → T013 → T014 →
  T015 is the guard chain. T009 therefore carries no `[P]` although its neighbour T008 does
- US1 and US2 can be worked in parallel by two people once Foundational is complete; they touch disjoint files under `bindings/`
- T045, T046 and T047 during Polish — three different files
- T022 and T023 both append to `RESULTS.md` and therefore carry no `[P]`, though neither blocks the other

---

## Parallel Example: Foundational

```bash
# Two independent files, once T004–T007 have landed:
Task: "Correct the stale stage table in PROC/process.md"     # T008
Task: "Write scripts/check-portability.sh"                   # T012
```

Phase 2 offers little parallelism, and that is the honest shape rather than a defect: four tasks edit
`process.md` and two edit `report-template.md`. Do each file in one pass.

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1: Setup
2. Phase 2: Foundational — blocks everything
3. Phase 3: User Story 1
4. **Stop and validate**: quickstart scenario 5. A review runs with no Goose involved
5. At this point the operator's request is satisfied in substance. The Goose recipe still sits at its
   old path, hand-written and not gated — an honest intermediate state, not a shippable release

### Incremental Delivery

1. Setup + Foundational → the host-neutral definition exists
2. US1 → runs without Goose (MVP)
3. US2 → both bindings generated, drift gated, `2.0.0` released
4. US3 → the one-file-per-host property demonstrated
5. Polish → cross-host comparison, self-review, foreign-repository run

### Release condition

Not "the gate is green". A release needs, additionally: T043 (self-review, no findings) and T044
(foreign-repository run under both bindings) — both Principle V conditions — plus T023, the only
evidence that `FR-002` holds, and T042 recorded, whatever it says. A cross-host digest difference does
not block the release; an unexplained one does.

---

## Notes

- `[P]` means different files and no dependency on an incomplete task
- Every verification task names the file it inspects, so its outcome is checkable by someone else
  (Principle II)
- Commit after each task or logical group
- Two of the three golden files carry a `DIGEST v1` block and are reconciled on it alone, never as whole reports (`O-11`). `delta-subject-change.md` is a classification table and is compared as such
- Nothing in Phase 2 may hard-code a path into this repository; T015 exists to catch exactly that

## Follow-ups from the pre-merge reviews of PR #8 (2026-09-25)

Recorded here because each concerns this feature's open phases, not feature 005. None is fixed by
that PR; each is a task for phase 3 or 4 and must be resolved before `T019` is attempted or `T031`
bumps the version.

- **Tool allow list of the Claude Code binding.** Claude Code refuses `find … -exec` and `-delete`
  under a `Bash(find *)` rule, so the Stage 0 manifest command is denied in the headless run; and
  `Bash(sort:*)` is a prefix rule that admits GNU `sort`'s program-executing option, which a
  prompt-injected subject could reach with no approval step. Rework `run.sh.tmpl`: compute the
  manifest in the shell before and after the `claude` call and pass it in the prompt, so the model
  needs no `Bash` at all (`CLAUDE_TOOLS` becomes `Read Glob Grep Write`). Then re-render
- **The subject is not added via `--add-dir`**, so a subject outside the working directory cannot be
  read; and only precondition 1 of the contract is checked before the run starts (`T019` will hit
  this if the subject is not under cwd)
- **`resolve()` uses `awk -v`**, which processes backslash escapes, and maps an unknown placeholder
  to the empty string instead of failing. A path with a backslash is mangled; a typo in a
  placeholder name yields a vacuous constraint
- **`render-bindings.sh` ignores `status=`**, so a constraint marked `superseded` is still spliced
  into every binding. Implement the status filter before the first constraint is retired
- **The `HOST-SPECIFIC` prompt-tail region restates report rules** in lowercase and passes the
  lexical check while violating obligation 5. Move that instruction into a carried constraint or a
  generated region
- **`render-bindings.sh --check` is not yet a gate class** (`T028`); until it is, the header of
  `run.sh` claims a gate that does not exist. `T028` closes it
- **`report-template.md` now requires the `Host` header** while the Goose recipe, the golden
  files and `VERSION.md` have not followed (`T024`–`T032`). Until then the shipped process is
  internally inconsistent; the tasks that reconcile it are the open ones above
