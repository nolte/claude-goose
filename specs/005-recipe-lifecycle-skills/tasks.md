---

description: "Task list for 005-recipe-lifecycle-skills"
---

# Tasks: Recipe Lifecycle Skills

**Input**: Design documents from `/specs/005-recipe-lifecycle-skills/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: There is no test framework here and nothing is compiled. Verification is two things: the
static gate in `.pre-commit-config.yaml`, and **real skill runs** recorded in
`tests/goose-implementation-review/RESULTS.md`. Verification tasks below are not optional —
Constitution Principle III requires observable evidence per stage, and spec `FR-025` and `FR-026`
name the runs that must happen before release. Two of those runs are blocked on work outside this
feature; the tasks that carry the blocks say so and are not skipped or substituted.

**Organization**: Tasks are grouped by user story. Each story phase ends in a state that can be
demonstrated on its own. `SKILLS/` abbreviates `skills/`; `PROC/` abbreviates
`process/goose-implementation-review/`; `RESULTS` abbreviates `tests/goose-implementation-review/RESULTS.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Paths are repository-relative

---

## Phase 1: Setup

**Purpose**: The plugin skeleton, the manifests, and the guard extended to the new tree.

- [X] T001 Run `task ci` and confirm it is green before any edit; a red gate beforehand makes every later failure unattributable
- [X] T002 Create the directory skeleton: `.claude-plugin/`, `skills/recipe-requirements-elicit/templates/`, `skills/recipe-requirements-elicit/references/`, `skills/recipe-plan/templates/`, `skills/recipe-implement/references/`, `skills/recipe-audit/`
- [X] T003 [P] Write `.claude-plugin/plugin.json` exactly as `specs/005-recipe-lifecycle-skills/contracts/plugin-manifest.md` states it — name `nolte-goose`, **no `version` field** (research R1; `OMISSIONS.md` §Version-bearing files must stay true)
- [X] T004 [P] Write `.claude-plugin/marketplace.json` per the same contract: one plugin entry, `source: "."`
- [X] T005 Extend `scripts/check-portability.sh` so its `trees` array reads `(process baselines skills)`; run it and confirm it passes over the empty skeleton and names all three trees in its output (FR-027)
- [X] T006 Write `skills/README.md`: the distribution contract table from `contracts/plugin-manifest.md` (consumer audience, runtime requirement, prerequisite plugin `nolte-shared` at `v0.1.11`, release cadence); the install commands; and the **delimitation record** — one row per skill with the shared capability delegated to, what the skill adds, and the duplicate-check result, taken verbatim from research R3 (FR-007, FR-010); a pointer to the root `README.md` for the install commands — the guard rejects the repository name under `skills/`, so the commands cannot live there (`contracts/plugin-manifest.md` §Installing the plugin). Leave a "Validator" line to be filled by T031. In the same task write `skills/VERSION.md` in the form of `process/goose-implementation-review/VERSION.md`: value `0.1.0`, the three-axis table (lifecycle version, review process version, baseline revision), MAJOR/MINOR/PATCH semantics, and a history table with the initial entry (Constitution II, research R14)

**Checkpoint**: `task ci` is green with the guard covering `skills/`. The plugin is declared but has no skills yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish that the plugin loads and that the audit binding it depends on exists.

- [X] T007 Install the plugin from this working copy into Claude Code (`claude plugin marketplace add /home/nolte/repos/github/claude-goose`, then `claude plugin install nolte-goose@nolte-goose` — both verified against CLI 2.1.282, research R13) and confirm `nolte-goose` appears in `claude plugin list`. Record the Claude Code CLI version used in `skills/README.md`
- [X] T008 Confirm the state of feature 004 User Story 1 by reading `specs/004-portable-process-logic/tasks.md` `T016`–`T023` and `RESULTS`: `PROC/bindings/claude-code/run.sh` must be rendered by `PROC/tools/render-bindings.sh`, committed, and have one recorded real run. If any of that is missing, record in `specs/005-recipe-lifecycle-skills/tasks.md` under Notes that Phase 3 is **blocked on feature 004 US1** and proceed with Phases 4–6, which do not depend on it (plan §Dependencies and order, research R12)

**Checkpoint**: The plugin loads. Whether the audit binding is ready is known and written down, not assumed.

---

## Phase 3: User Story 1 - Audit a recipe against the pinned baseline (Priority: P1) 🎯 MVP

**Goal**: `/nolte-goose:recipe-audit` returns the review process's report, produced by the Claude Code
binding, with nothing normative added.

**Independent Test**: quickstart.md scenario 1 — audit a fixture through the skill and through
`run.sh` directly over the same baseline; the digests are identical and the skill's transcript
contains no review rule in normative voice.

- [X] T009 [US1] Write `skills/recipe-audit/SKILL.md`: frontmatter `name: recipe-audit`, `phase: review`, `tags: [review, goose]`, and a `description` in third person that carries the boundary sentence from `contracts/skill-interfaces.md` verbatim; the exact heading `## Why this is a skill, not an agent` naming the decisive dimension (it invokes a host process and returns a path; a counter-dimension is that a read-only agent would fit, outweighed because the binding already isolates the run); the five-input table copied verbatim from `PROC/invocation-contract.md` with **no input added**; the procedure — resolve `${CLAUDE_PLUGIN_ROOT}`, check `PROC/bindings/claude-code/run.sh` exists there and `claude` is on `PATH`, invoke `run.sh` with each input as its long option, wait, then return the report path and its `DIGEST v1` block verbatim; the refusals from the contract (binding exit code 2 reported verbatim, never retried); and hard rules that the skill states no rule of the review, never edits the subject, and never resolves `latest` itself. The body must not contain a sentence in normative voice about a review rule — point to `PROC/constraints.md` and the pinned `ruleset.md` instead (FR-011, FR-012, FR-013, SC-004)
- [X] T010 [US1] Search `skills/recipe-audit/SKILL.md` for `NEVER`, `MUST`, `USE EXACTLY` and confirm each hit governs the skill's own behaviour, not a review rule; record the hit list and verdict in `RESULTS` under a new "Feature 005" section (SC-004)
- [X] T011 [US1] Gate on T008: proceed only if feature 004 US1 is done. Otherwise stop this phase here, leave T012–T014 unchecked, and record the block in Notes below with the date
- [ ] T012 [US1] Run quickstart.md scenario 1: `recipe-audit` over a copy of `tests/goose-implementation-review/fixtures/recipe-with-deviations/` with `baseline_revision=2026-07-31b` from inside a Claude Code session, then `PROC/bindings/claude-code/run.sh` over the same copy from a shell; `diff` the two `DIGEST v1` blocks. **This is the measurement research R2 marks unverified** — whether a nested `claude --print` completes from a session. If it does not complete, record exactly what happened and stop; the fallback (a skill-shaped binding rendered by `PROC/tools/render-bindings.sh`) is a plan revision, not an improvisation in this task (FR-014, SC-002)
- [ ] T013 [US1] Verify the skill-produced report carries `Host: claude-code`, `baseline=2026-07-31b` in the digest, the coverage statement and the `Criteria Applied` table, and that every finding names a criterion, a location and a source (US1 acceptance 1, 3, 4)
- [ ] T014 [US1] Append the T012 run to `RESULTS`: subject, baseline, Claude Code CLI version, the model it resolved to, the digest comparison line by line, elapsed time, and the nested-invocation outcome stated explicitly (FR-025, Principle VI)

**Checkpoint**: The audit skill is demonstrable and its report is the binding's report. This is the MVP.

---

## Phase 4: User Story 2 - Capture what a recipe must do (Priority: P2)

**Goal**: `/nolte-goose:recipe-requirements-elicit` delegates the interview to
`nolte-shared:requirements-elicit`, adds the five recipe dimensions and the baseline check, and
fails closed when the shared skill is absent.

**Independent Test**: quickstart.md scenarios 2 and 3 — a real elicitation yields both artifacts
with a concrete baseline id and a baseline check; with `nolte-shared` uninstalled the skill stops
with the fail-closed message and writes nothing.

- [X] T015 [P] [US2] Write `skills/recipe-requirements-elicit/references/recipe-question-set.md`: for each of the five recipe dimensions (inputs, host capabilities, execution mode, output shape, prohibited behaviour) the probes to ask, one question per turn, in the funnel style `requirements-elicit` uses; and the **baseline-check procedure** — read `${CLAUDE_PLUGIN_ROOT}/baselines/goose/<pinned id>/ruleset.md` and `coverage.md` at run time, never a baked-in list, and map: an optional input that imports a file → `R-004`; unknown or `headless` execution mode → `R-010`; any host capability → `R-007` and `GAP-EXT-SEMANTICS`; a structured output shape or retry or sub-recipe need → `GAP-RECIPE-FIELDS`. State that criterion ids are read from the pinned revision so a later revision changes the mapping without editing this file (FR-016)
- [X] T016 [P] [US2] Write `skills/recipe-requirements-elicit/templates/recipe-requirements.template.md` exactly as `contracts/recipe-artifacts.md` §`requirements.md` states it, including the header fields, the six sections, and the rule that the baseline-check section reads "none" rather than being omitted
- [X] T017 [US2] Write `skills/recipe-requirements-elicit/SKILL.md`: frontmatter `name`, `phase: plan`, `tags: [requirements, goose]`, `resumable: true`, `description` with the boundary sentence verbatim; the rationale heading; the precondition that `nolte-shared:requirements-elicit` is invocable — invoke it as `Skill(skill="nolte-shared:requirements-elicit")` and, on an unknown-skill refusal, stop with the fail-closed message from `contracts/skill-interfaces.md` naming `nolte-shared` at `v0.1.11` and the marketplace, writing nothing (research R6); the `elicit` operation — resolve `baseline_revision` to a concrete id first (operator-named, else the greatest directory under `${CLAUDE_PLUGIN_ROOT}/baselines/goose/`), run the delegated interview, then the recipe question set, then write `project/recipes/<slug>/requirements.md` from the template naming `project/requirements/<slug>.md` by path, with `lifecycle_version` read from `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md` and `review_process_version` from `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/VERSION.md` (FR-024), in state `draft` until the author confirms the recipe profile in a teach-back, then `confirmed`; the `validate` operation checking the data-model rules and reporting per rule without fixing content; resume state at `.resume/recipe-requirements-elicit/<run-id>.yml` per `spec/claude/resumable-work/`; hard rules — never ask a generic question through this skill's own text, never write a guessed value where the author could not answer (FR-005, FR-006, FR-009, FR-015, FR-017)
- [X] T018 [US2] Run quickstart.md scenario 3 now — it needs no upstream fix: make `nolte-shared` absent (`claude plugin disable nolte-shared`, verified, research R13), invoke `/nolte-goose:recipe-requirements-elicit`, confirm the fail-closed message names `nolte-shared:requirements-elicit`, `v0.1.11` and the marketplace, and that `project/` is untouched; re-enable with `claude plugin enable nolte-shared`; record in `RESULTS` (FR-009, SC-006)
- [X] T019 [US2] Open the upstream change research R5 requires in `nolte/claude-shared`: an issue proposing that `skills/requirements-elicit/SKILL.md` §Precondition gain the `${CLAUDE_PLUGIN_ROOT}/spec/project/requirements-elicitation/<canonical_language>.md` fallback its four sibling skills already have (or, alternatively, that the spec gain `Portfolio-Scope: portfolio`). Record the issue URL in `skills/README.md` under "Upstream dependencies". **Do not copy the spec into this repository** — `spec/project/portfolio-inherited-spec-layer/` forbids it
- [ ] T020 [US2] Gate on T019 shipping in a claude-shared release: bump the pinned release in `skills/README.md` and in the fail-closed message of T017 to that release. Until then this task and T021 stay open and the block is recorded in Notes below with the date
- [ ] T021 [US2] Run quickstart.md scenario 2 for the research R11 recipe (a baseline drift check taking a revision id, comparing each recorded `source_commit` with the current upstream commit, printing rows for `verification.md`, never writing to it): confirm `project/requirements/baseline-drift-check.md` was written by `requirements-elicit` (its template header present) and `project/recipes/baseline-drift-check/requirements.md` names it, carries a concrete `baseline_revision`, all five sections, and a baseline check naming `R-007` and `GAP-EXT-SEMANTICS` for the shell capability; record in `RESULTS` with the interview turn count. Then run quickstart.md scenario 9 step 2: the `validate` operation over a hand-written copy of that artifact with one optional input marked `Imports a file: yes`, and confirm the baseline check names `R-004` with "violates by construction" (FR-015, FR-016, FR-025, SC-008)

**Checkpoint**: The requirements skill is authored and fail-closed is proven. Its real run is either recorded or explicitly blocked upstream.

---

## Phase 5: User Story 3 - Plan the recipe before writing it (Priority: P3)

**Goal**: `/nolte-goose:recipe-plan` maps every requirement to recipe elements and back, marks every
criterion of the pinned revision, and returns requirements that cannot be built as conflicts.

**Independent Test**: quickstart.md scenario 4, first half — from a confirmed requirement artifact,
`plan.md` is `ready` with total coverage in both directions and every criterion listed exactly once.

- [X] T022 [P] [US3] Write `skills/recipe-plan/templates/recipe-plan.template.md` exactly as `contracts/recipe-artifacts.md` §`plan.md` states it
- [X] T023 [US3] Write `skills/recipe-plan/SKILL.md`: frontmatter `name`, `phase: plan`, `tags: [planning, goose]`, `description` with the boundary sentence verbatim (it names `nolte-engineering:implementation-plan-author` as the alternative for issue-driven plans — that is the delimitation, stated in the description); the rationale heading; refusals — input not in state `confirmed` (stop, list the open points), `baseline_revision` absent under `${CLAUDE_PLUGIN_ROOT}/baselines/goose/` (stop, name it); the procedure — read the requirement artifact, read the pinned revision's `ruleset.md` and `coverage.md`, propose one `P-<n>` element per recipe field or entry with the requirement ids it serves, build the coverage table and refuse to write a plan where any requirement or element is unmapped, build the criteria table with **every** criterion of the pinned `ruleset.md` exactly once as `by construction` with its element or `risk` with its reason, list conflicts and set state `blocked` when any exists, write `project/recipes/<slug>/plan.md` from the template; hard rules — never narrow a requirement to remove a conflict, never mark a criterion `by construction` without naming the element (FR-018, FR-019, FR-020)
- [X] T024 [US3] If T021 is blocked, hand-write `project/recipes/baseline-drift-check/requirements.md` in state `confirmed` from research R11 using the T016 template, and `project/requirements/baseline-drift-check.md` in the shape of `requirements-elicit`'s template, both marked in their header as **hand-written for the first lifecycle run** — spec `FR-002` and the data model permit a hand-written predecessor artifact, and saying so keeps `RESULTS` honest about which skill produced what
- [X] T025 [US3] Run quickstart.md scenario 9 steps 1 and 3 first: `/nolte-goose:recipe-plan` over a copy of the artifact set to `State: draft` with one open point must stop, name the open point and write no `plan.md` (FR-004); over a copy that keeps an optional file-importing input it must write `plan.md` with `State: blocked`, the conflicts table naming that input and `R-004`, without narrowing the requirement (FR-020). Record both in `RESULTS`. Then run `/nolte-goose:recipe-plan` on the real artifact; verify `project/recipes/baseline-drift-check/plan.md` is `ready`, the coverage table lists every `R-<n>` and every `P-<n>`, the criteria table lists all ten criteria of revision `2026-08-02` exactly once with `R-010` `by construction` (the recipe is headless and carries `prompt`) and `R-007` `by construction` with the element that surfaces the shell extension; record in `RESULTS` (FR-018, FR-019, FR-025, SC-005)

**Checkpoint**: A plan exists that a stranger can build from, and every criterion the audit will apply is already decided or named as a risk.

---

## Phase 6: User Story 4 - Write the recipe from the plan (Priority: P4)

**Goal**: `/nolte-goose:recipe-implement` writes the recipe from the plan and nothing else, traces
each element back by comment, and validates it with Goose's own parser before reporting done.

**Independent Test**: quickstart.md scenario 4, second half, and scenario 5 — the recipe parses with
`goose run --explain`, every element carries a `P-<n>` comment, and its first audit against the pinned
revision reports zero `deviation` findings.

- [X] T026 [P] [US4] Write `skills/recipe-implement/references/traceability-comments.md`: the provenance block and the `# P-<n> ← R-<m>` convention from `contracts/recipe-artifacts.md` §Traceability comments, with the rule that a comment names exactly one plan element and the note that Goose ignores comments so no criterion is affected (research R10)
- [X] T027 [US4] Write `skills/recipe-implement/SKILL.md`: frontmatter `name`, `phase: build`, `tags: [implementation, goose]`, `description` with the boundary sentence verbatim (names `nolte-shared:pull-request-create` for the PR, which is outside the phase); the rationale heading; preconditions — `goose` on `PATH` (stop otherwise; the parser check is not optional and a skipped check is not a pass), input plan in state `ready` (stop and list the conflicts otherwise); the procedure — write the recipe at the plan's target path with the provenance block, one element per `P-<n>` row and nothing the plan does not list, a comment on each top-level element, parameter and extension entry, then run `goose run --recipe <file> --explain`, and on any line beginning `Error:` report it verbatim and do not present the recipe as done; the output message listing each recipe part with its plan element; hard rules — never add an element without a plan entry, never edit the plan or the requirement artifact to make the recipe fit (FR-021, FR-022, FR-023, FR-024)
- [X] T028 [US4] Run `/nolte-goose:recipe-implement` on `project/recipes/baseline-drift-check/plan.md`; verify the recipe at the plan's path carries the provenance block naming the slug, `baseline_revision` and process version, a `P-<n> ← R-<m>` comment on every element, and that `goose run --recipe <path> --explain` prints no `Error:` line; record in `RESULTS` with the parser output. Then run quickstart.md scenario 9 step 4: over a scratch copy of the plan with one element changed to an undocumented extension type, confirm the skill reports the parser's `Error:` line verbatim and does not present the recipe as done; record it (FR-022, FR-025)
- [ ] T029 [US4] Run quickstart.md scenario 5: `/nolte-goose:recipe-audit` over the recipe directory with the pinned `baseline_revision` and `output_path project/recipes/baseline-drift-check/review-report.md`; confirm zero `deviation` findings, and that `R-007` (`judgment call`) and `GAP-EXT-SEMANTICS` (`undecided`) appear because the recipe declares a code-executing extension. Then run the Goose binding (`PROC/bindings/goose/recipe.yaml`, or `PROC/recipe.yaml` if 004 has not moved it) over the same subject and baseline, and compare the two digests line by line; record every line, its cause if it differs, and the verdict in `RESULTS`. Depends on T012. Together with T012 this is the second of the two fixtures `SC-002` requires (FR-014, FR-026, SC-001, SC-002, SC-007)

**Checkpoint**: One real recipe has passed through all four phases. `SC-001` is measured, not assumed.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T030 Add to `OMISSIONS.md` a "Skill frontmatter validation" entry (after T035, whose issue URL it records): the class is not in the gate because claude-shared exposes no pre-commit hook for `scripts/validate_skills.py`; it runs as a recorded manual step (T031); revisit when `nolte/claude-shared` publishes `.pre-commit-hooks.yaml`. Record the upstream issue URL from T035 there too (research R8)
- [X] T031 Run quickstart.md scenario 7: `git -C /home/nolte/repos/github/claude-shared checkout v0.1.11`, then `python3 /home/nolte/repos/github/claude-shared/scripts/validate_skills.py skills/`; fix every `Critical` in the four `SKILL.md` files; confirm none of the four skill names appears in `skills/` or `plugins/*/skills/` of that checkout (FR-008); record the validator version (`--version`) and the tag on the "Validator" line of `skills/README.md`
- [X] T032 [P] Update `README.md`: under `## Usage` add a `### Develop a recipe with the plugin` subsection with the two install commands and the four skills in phase order, one line each; under `## Structure` add `.claude-plugin/` and `skills/` with one-line comments; keep the file under 200 lines
- [X] T033 [P] Update `CLAUDE.md` with one paragraph on the plugin: the four skills, that `recipe-audit` invokes the Claude Code binding and adds nothing, the `nolte-shared` prerequisite, and that `plugin.json` deliberately has no `version`
- [ ] T034 Run quickstart.md scenario 8 with a second reader: hand them the four `description` lines and those of `requirements-elicit`, `implementation-plan-author`, `fullstack-developer` and `pull-request-create`; ask per recipe skill which shared capability it delegates to and what it adds; record the answers, the elapsed time and the count of wrong attributions in `RESULTS` — pass is zero (FR-006, SC-003). The method precedent is feature 001's `SC-003-SAMPLE.md`; its content and threshold are a different criterion and do not apply
- [X] T035 [P] Open the two remaining upstream proposals in `nolte/claude-shared` as issues and record their URLs in `skills/README.md` under "Upstream dependencies": (a) let `implementation-plan-author` accept a requirement artifact without a GitHub issue, so `recipe-plan` can delegate its plan format later (research R3); (b) publish `.pre-commit-hooks.yaml` exposing `validate_skills.py` (research R8)
- [X] T036 Run quickstart.md scenario 6: `task ci` green with the portability class naming `skills/` in its output, and `grep -rn 'claude-goose' skills/` printing nothing (FR-027)
- [X] T037 Release-condition check, written into `RESULTS` under "Feature 005 — release condition": for each of the four skills, the `RESULTS` entry of its recorded real run (T014, T021, T025, T028), and the lifecycle run (T029). Any skill with no recorded run, or a lifecycle run with an unexplained digest difference, means **not released**; state which blocks remain and their outside condition. No plugin tag is cut while any block is open (FR-025, FR-026, Principle V)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies. T003 and T004 are parallel; T005 needs T002 (the guard exits `2` on a missing tree); T006 needs nothing but is last so the README describes what exists
- **Foundational (Phase 2)**: Depends on Setup. T007 needs the manifests. T008 is a reading task that decides whether Phase 3 can run
- **US1 (Phase 3)**: T009 and T010 depend on Foundational only. **T011–T014 are blocked on feature 004 User Story 1** (`T016`–`T023` there); the binding must be rendered and recorded before the skill that invokes it can be measured
- **US2 (Phase 4)**: T015–T018 depend on Foundational only; T018 (fail-closed) needs no upstream change. **T020–T021 are blocked on an upstream claude-shared release** (T019)
- **US3 (Phase 5)**: Depends on Foundational. T024 exists precisely so US3 is not blocked by US2's block: a hand-written predecessor artifact is permitted by `FR-002`
- **US4 (Phase 6)**: T026–T028 depend on US3's plan. **T029 depends on T012** (the audit skill measured) and is therefore transitively blocked on feature 004 US1
- **Polish (Phase 7)**: T032, T033, T035 are parallel and independent of the blocks; T030 follows T035 because it records that task's issue URL. T031 needs all four `SKILL.md` files. T034 needs the four descriptions. T036 needs everything under `skills/`. T037 is last and reports the blocks rather than resolving them

### Ordering constraints worth stating

- **T002 → T005**. The guard is extended after the tree exists, and run immediately, so the first thing it scans is an empty tree and any later failure is attributable to a specific skill file
- **T009 → T010 → T011**. The skill is written and checked for normative voice *before* the gate on feature 004, so the authoring work is done and reviewable even while the run is blocked
- **T019 → T020 → T021**. The upstream issue is opened first, the pin is bumped only when a release carries the fix, and the run happens only after the bump — never against a local copy of the spec
- **T028 → T029**. The recipe is validated by the parser before it is audited; an audit of a recipe the host rejects measures nothing useful
- **T012 → T029**. The final audit of the lifecycle goes through the skill, so the skill must have been measured first

### Within each user story

Templates and references carry `[P]` because they are separate files with no dependency on the
`SKILL.md`. The `SKILL.md` follows them because it references them by relative path. The real run
follows the `SKILL.md`. The `RESULTS` entry is always the last task of a story: it records what
happened, and nothing is recorded before it happens.

### Parallel Opportunities

- Phase 1: T003 ‖ T004
- Phase 4: T015 ‖ T016, then T017
- Phases 4, 5, 6 authoring (T015–T017, T022–T023, T026–T027) can proceed in parallel with each other once Foundational is done; they touch disjoint directories under `skills/`
- Phase 7: T032 ‖ T033 ‖ T035, then T030

## Parallel Example: Authoring while the runs are blocked

```text
# Both blocks (feature 004 US1, upstream claude-shared) can be open while this runs:
T009 recipe-audit/SKILL.md          ‖  T015+T016 → T017 recipe-requirements-elicit/
T022 → T023 recipe-plan/            ‖  T026 → T027 recipe-implement/
then T018 (fail-closed), T024 (hand-written artifact), T025, T028 in order
```

Everything authored is then verified by T031 and T036 before any blocked run happens, so when a
block lifts, the only work left is the run and its record.

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phases 1–2: skeleton, manifests, guard, README, plugin installed, 004 state known
2. T009–T010: `recipe-audit` authored and checked for normative voice
3. T011–T014 as soon as feature 004 US1 lands
4. **STOP and validate**: the skill's report equals the binding's on the digest

Until 004 lands, the MVP is authored and reviewable but not demonstrable, and `RESULTS` says so.

### Incremental Delivery

- US2 authored → fail-closed proven (T018) → real run when the upstream fix ships
- US3 → a plan from a hand-written or elicited artifact, demonstrable on its own
- US4 → a validated recipe, then the first audit; `SC-001` measured here
- Polish → the reader test, the validator step, the records

### Release condition

Per Constitution Principle V and spec `FR-025`/`FR-026`, the plugin is not tagged until every skill
has a recorded real run and the lifecycle run is recorded with its digest comparison. T037 is the
task that says whether that condition holds. Two known blocks stand between the authored state and
the released state, and both are outside this feature's control; the honest state of the plugin
while they stand is "authored, gated, two runs pending", and the README says so.

## Notes

- **Blocks**: feature 004 US1 not shipped — hit 2026-09-24 at T008/T011: `run.sh` and `run.sh.tmpl`
  exist uncommitted in the working tree, `RESULTS` records no run through them, 004 `T016`–`T023`
  are unchecked. T012–T014 and T029 stay open. Upstream claude-shared fix for `requirements-elicit`
  not released — hit 2026-09-24 at T019/T020; T021 stays open
- T018 measured: `claude plugin disable nolte-shared` failed ("not found in any editable settings scope");
  `claude plugin list` shows `nolte-shared@nolte-shared` at scope `project`, status disabled, and a
  probe session (`claude --print`, no tools) listed only the four `nolte-goose:` skills. So the nested
  run really had no `nolte-shared:requirements-elicit`, by pre-existing state rather than by the
  disable command. The skill stopped with the message verbatim and wrote nothing. Whether the
  interactive session that authored this feature loads `nolte-shared` from another scope was not
  investigated
- T025 measured: the first real run flagged two defects in the hand-written requirement artifact
  (result vocabulary not `SOURCE-FORMAT.md`'s; `R-007` does not cover a `builtin` extension). Both
  were fixed at the requirement level and the plan re-run — the transition the data model's state
  machine prescribes
- `claude plugin update` is a **no-op while HEAD is unchanged**: the cache is labelled with the HEAD
  commit hash, so uncommitted edits under `skills/` reach the installed plugin only after
  `claude plugin uninstall` plus `install`, or after a commit
- T007 measured: `claude plugin install` from a local-path marketplace **copies the working tree**
  (including uncommitted files) into `~/.claude/plugins/cache/nolte-goose/nolte-goose/<HEAD hash>/`
  and labels it with the HEAD commit hash. Later edits under `skills/` reach the installed plugin
  only after `claude plugin update nolte-goose@nolte-goose`. The four skills were listed by
  `claude plugin details`, so `process/` and `baselines/` travel with the plugin as research R1 needs
- The hand-written predecessor artifact of T024 is a legitimate input under `FR-002`, but it is not a
  recorded run of `recipe-requirements-elicit`. T021 remains the only task that satisfies `FR-025`
  for that skill
- Every `RESULTS` entry names the skill, the input artifact, the output artifact, the outcome, and
  the versions involved (Goose, Claude Code CLI, `nolte-shared`). A scenario absent from `RESULTS`
  has not been run
