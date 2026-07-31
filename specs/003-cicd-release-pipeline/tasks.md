---

description: "Task list for feature implementation"
---

# Tasks: CI/CD and Release Pipeline

**Input**: Design documents from `/specs/003-cicd-release-pipeline/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Test tasks ARE included and are the point of the feature. `SC-002` requires that
introducing one defect per check class makes exactly that check fail; `FR-010` states that a check
which cannot fail is not a check. A gate whose checks have never failed is decoration.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

**Every task names the `FR-`/`SC-` it serves.** In feature `002` the first task list named four of
twenty-one requirements, and five requirements ended up with no task at all. The traceability is what
makes the coverage check mechanical.

## Starting point — measured, not assumed

| | |
|---|---|
| Remote | Exists: `git@github.com:nolte/claude-goose.git` |
| Branches on the remote | `main` only; **`develop` does not exist** |
| `default_branch` | `main` — the commons sets `develop` |
| `allow_merge_commit` / `allow_rebase_merge` | Both `true` — the commons sets squash-only |
| Branch protection | **None**, on any branch |
| Settings App | Demonstrably working in this account (`gh-plumbing/develop` is protected); has never acted here, because no `.github/settings.yml` exists |
| Shared workflows | `nolte/gh-plumbing@v1.1.26`, verified present |
| Prose rules | `nolte/vale-style@v0.1.17`, verified present |

**The divergence above is the feature's proof of effect.** After the settings file lands, those
values must flip; if they do not, the mechanism is not acting here (quickstart Scenario 4b).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1, US2, US3
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: The entry point and tool pinning every later phase depends on

- [X] T001 Create `Taskfile.yml` with a `ci` target and one target per check class, so the gate is one command locally and in CI (`FR-008`, `SC-004`)
- [X] T002 [P] Create `requirements-ci.txt` pinning every check tool to an exact version — no ranges, no `latest` (`FR-012`, `SC-013`)
- [X] T003 [P] Create `.pre-commit-config.yaml` declaring the static checks, so CI and a workstation run identical definitions (`SC-004`)
- [X] T004 [P] Create `.vale.ini` consuming styles from `nolte/vale-style@v0.1.17` rather than authoring rules here (`FR-005`, `FR-028`)
- [X] T005 Create `OMISSIONS.md` with the five known omissions from plan.md, each carrying a reason and a revisit condition (`FR-030`, `SC-012`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The integration branch and the pinning discipline. No story can be verified without these.

**⚠️ CRITICAL**: `develop` does not exist yet. Every workflow in this feature targets it.

- [X] T006 Create `develop` from the current `main` and push it, so the branch every pull request targets exists (`FR-013`)
- [X] T007 Write `.github/settings.yml` extending `nolte/gh-plumbing:.github/commons-settings.yml`, declaring only what the commons does not: this repository's required-check contexts and its `develop` branch entry (`FR-014`, `FR-015`, `FR-017`)
- [X] T008 Record the pre-sync baseline (`default_branch`, `allow_merge_commit`, `allow_rebase_merge`) in `OMISSIONS.md` so the settings mechanism's effect is measurable afterwards (`FR-014`)

**Checkpoint**: The integration branch exists and the settings file is ready to prove itself.

---

## Phase 3: User Story 1 - Static verification before merge (Priority: P1) 🎯 MVP

**Goal**: Every pull request to `develop` gets a separately named verdict on seven check classes.

**Independent Test**: Introduce one defect per class; exactly the corresponding check fails.

### Implementation

- [X] T009 [US1] Implement the YAML parse check as a `Taskfile.yml` target over every `*.yml`/`*.yaml` (`FR-001`)
- [X] T010 [P] [US1] Implement the Markdown lint check over every `*.md` (`FR-002`)
- [X] T011 [P] [US1] Implement the recipe schema check against `process/goose-implementation-review/recipe.yaml` (`FR-003`)
- [X] T012 [P] [US1] Implement the offline internal link check — relative paths and anchors, no network (`FR-004`)
- [X] T013 [P] [US1] Implement the prose lint check via Vale (`FR-005`)
- [X] T014 [P] [US1] Implement the recipe parse check invoking `goose run --recipe … --explain`, which exercises the host's own parser at no LLM cost (`FR-006`)
- [X] T015 [P] [US1] Implement the format check — trailing whitespace, final newline, line endings (`FR-007`)
- [X] T016 [US1] Create `.github/workflows/static-gate.yml` calling `nolte/gh-plumbing/.github/workflows/reusable-pre-commit.yaml@v1.1.26`, running unconditionally on every pull request to `develop` with no path filters (`FR-009`, `FR-028`)
- [X] T017 [US1] Declare a minimum permission set in `static-gate.yml` — read only (`FR-026`)
- [X] T018 [US1] Report each class as a separately named unit so a failure names its cause (`FR-007`, `SC-001`)

### Verification — the part that makes the gate real

- [X] T019 [US1] Prove the YAML check fails: introduce an unbalanced quote, confirm only that class fails, revert (`FR-010`, `SC-002`)
- [X] T020 [P] [US1] Prove the Markdown, link and format checks fail on their respective defects, one at a time (`FR-010`, `SC-002`)
- [X] T021 [P] [US1] Prove the prose check fails on a word the Vale style rejects (`FR-010`, `SC-002`)
- [X] T022 [US1] Prove both recipe checks fail: remove a required field for the schema check, then break parsing for the `--explain` check (`FR-010`, `SC-002`)
- [ ] T023 [US1] Run `task ci` on a clean checkout and confirm it reports the same seven classes with the same verdict as CI (`SC-004`)
- [ ] T024 [US1] Re-run the gate on the same commit with a cold cache and confirm an identical verdict; record that this holds against a fixed shared-repository state, not unconditionally (`FR-011`, `SC-003`)
- [ ] T025 [US1] Confirm a Markdown/YAML-only pull request reaches a verdict without waiting on any full review run (`FR-031`, `SC-005`)

**Checkpoint**: US1 is independently testable. Seven checks exist and every one has been shown to fail.

---

## Phase 4: User Story 2 - Branch roles and protection as code (Priority: P2)

**Goal**: Branch behaviour is declared in a committed file, not clicked into a UI.

**Independent Test**: Delete a protection rule through the UI; it returns on the next sync.

- [ ] T026 [US2] Push `.github/settings.yml` to the default branch and confirm the App acts: `default_branch` becomes `develop`, `allow_merge_commit` and `allow_rebase_merge` become `false` (`FR-014`, quickstart Scenario 4b)
- [ ] T027 [US2] Declare the seven static-gate checks as required status contexts on `develop` in `.github/settings.yml` — the commons leaves these empty by policy, so they are satisfied here (`FR-015`)
- [ ] T028 [US2] Declare the feature-branch prefixes the governing branching model requires (`FR-017`)
- [ ] T029 [US2] Create `.github/workflows/automerge.yml` calling the shared automerge workflow pinned at `@v1.1.26` (`FR-016`, `FR-028`)
- [ ] T030 [US2] Verify protection is restored after deletion through the platform UI (`SC-007`)
- [X] T031 [US2] Verify a direct push to the release-presentation branch is rejected (`SC-008`)
- [ ] T032 [US2] Verify an approved pull request with green required checks merges without a manual click (`SC-006`)

**Checkpoint**: Branch behaviour survives a UI edit, which is what "as code" has to mean.

---

## Phase 5: User Story 3 - Release cut, published, propagated (Priority: P3)

**Goal**: A release reaches `published` without anyone editing the release by hand.

**Independent Test**: Publication refuses in each of its three refusal cases and succeeds in none of them.

- [ ] T033 [P] [US3] Create `.github/workflows/release-drafter.yml` calling the shared drafter at `@v1.1.26`, accumulating notes on `develop` (`FR-018`, `FR-028`)
- [ ] T034 [P] [US3] Create `.github/release-drafter.yml` declaring the note categories (`FR-018`)
- [ ] T035 [US3] Create `.github/workflows/release-publish.yml` calling the shared publish workflow at `@v1.1.26`, `workflow_dispatch` only, exposing `tag` and `dry_run` (`FR-019`, `FR-022`)
- [ ] T036 [US3] Declare that release and delivery workflows are never cancelled in flight (`FR-027`)
- [ ] T037 [US3] Create `.github/workflows/release-propagate.yml` calling the shared propagation workflow at `@v1.1.26` (`FR-024`)
- [ ] T038 [US3] Record in `OMISSIONS.md` that propagation will not start under the default token, with its revisit condition — `FR-024` requires the incompleteness to be visible (`FR-024`, `FR-030`)
- [ ] T039 [US3] Declare in `OMISSIONS.md` that the repository has no version-bearing files, so nothing is treated as authoritative for a version (`FR-025`)
- [ ] T040 [US3] Verify refusal 1: dispatch publish for a tag with no drafter-produced draft (`FR-020`, `SC-010`)
- [ ] T041 [US3] Verify refusal 2: dispatch publish for a hand-crafted tag and confirm no tag is created or rewritten (`FR-021`, `SC-010`)
- [ ] T042 [US3] Verify refusal 3: dispatch publish while required checks on `develop` are red (`SC-010`)
- [ ] T043 [US3] Verify `dry_run: true` evaluates every condition and leaves the release a draft (`FR-022`, `SC-009`)
- [ ] T044 [US3] Verify the run surfaces the target tag, the triggering user, and the run identity (`FR-023`)
- [ ] T045 [US3] Publish a real release and confirm no release-editing command was run against it (`SC-009`, `SC-011`)

**Checkpoint**: The release chain runs end to end, and refuses in every case it should.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T046 [P] Create `.github/workflows/dependency-review.yml` calling the shared dependency-review workflow at `@v1.1.26` (`FR-029`)
- [ ] T047 [P] Record in `OMISSIONS.md` how each supply-chain obligation is discharged — by record rather than by a scan with findings, since the repository ships no dependency manifest (`FR-029`, `FR-030`)
- [ ] T048 [P] Verify every workflow declares an explicit minimum permission set (`FR-026`)
- [X] T049 [P] Verify no definition in this repository contains a floating reference: `grep -rn 'uses:.*@\(develop\|main\|master\)$' .github/` returns nothing (`SC-013`)
- [ ] T050 Verify every stage the governing design names is answerable from `OMISSIONS.md` as "runs" or "omitted, because … revisit when …" (`FR-030`, `SC-012`)
- [ ] T051 Verify portability: copy the added artifacts into a second repository and run `task ci` without editing any of them (`FR-032`, `SC-014`)
- [ ] T052 Verify no file hashed in `.specify/integrations/*.json` was hand-edited (`FR-033`)
- [ ] T053 Update `CLAUDE.md` with the gate entry point, the pinned shared-workflow version, and the rule that checks live in `.pre-commit-config.yaml` rather than inline in workflows

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — creates `develop`, which every workflow targets
- **User Stories (Phase 3–5)**: All depend on Phase 2
- **Polish (Phase 6)**: Depends on the desired stories being complete

### User Story Dependencies

- **US1 (P1)**: Depends only on Foundational. Delivers the MVP
- **US2 (P2)**: Depends on US1 — required-check contexts (T027) can only name checks that exist
- **US3 (P3)**: Depends on US2 — publication refuses on a red gate, which presupposes required checks

This is a genuinely sequential feature: each story's verification needs the previous one's output.

### Within Each User Story

- Implementation before its verification tasks
- T007 before T026: the file exists before it is pushed and measured
- T033/T034 before T035: a draft must exist before publication can be attempted

### Parallel Opportunities

- T002, T003, T004 in Setup
- T010–T015 in US1 — different check classes, different targets
- T020, T021 in US1 verification
- T033, T034 in US3; T046–T049 in Polish

---

## Parallel Example: User Story 1

```bash
# The six independent check classes:
Task: "Implement the Markdown lint check in Taskfile.yml"
Task: "Implement the recipe schema check in Taskfile.yml"
Task: "Implement the offline link check in Taskfile.yml"
Task: "Implement the prose lint check in Taskfile.yml"
Task: "Implement the recipe parse check in Taskfile.yml"
Task: "Implement the format check in Taskfile.yml"

# Then prove they fail — the tasks that make the gate real:
Task: "Prove the Markdown, link and format checks fail on their defects"
Task: "Prove the prose check fails on a rejected word"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup — entry point and pinned tools
2. Complete Phase 2: Foundational — `develop` exists
3. Complete Phase 3: User Story 1, ending with T019–T022
4. **STOP and VALIDATE**: quickstart Scenarios 1–4
5. At this point every change is verified before merge, and each check has been shown to fail

### Incremental Delivery

1. Setup + Foundational → the integration branch exists
2. US1 → static verification (MVP)
3. US2 → branch behaviour as code
4. US3 → the release chain

### Release Gate

Per `quickstart.md`, scenarios 1–4 and 8–13 must pass. Scenarios 5–7 depend on platform permissions
and may trail.

**Scenario 2 — T019 through T022 — is non-negotiable.** Every other green result assumes the checks
can fail. If they cannot, the gate reports coverage that does not exist, which is worse than having
no gate at all.

---

## Notes

- [P] tasks touch different files and have no dependency on incomplete work
- **The settings mechanism's effect is measured, not assumed** (T008, T026). The repository currently
  diverges from the portfolio commons in three observable ways; those values must flip after the
  first sync
- **Propagation is expected not to complete** under the default token. That is a recorded
  incompleteness (T038), not a defect to debug
- Pinning is verified for this repository's own definitions only (T049). The shared workflows'
  internal `@develop` references are outside a consumer's control and are recorded as a stated limit
- Commit after each task or logical group
