---

description: "Task list for feature implementation"
---

# Tasks: Researched Documentation Base for Goose QA

**Input**: Design documents from `/specs/002-qa-documentation-base/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Verification tasks ARE included. The spec makes zero unsourced statements a *release
condition* (`SC-001`), not a target, and `FR-008` is untestable without a drift check that actually
runs. The quickstart scenarios are the test suite.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Starting point — this feature does not begin at zero

`001-goose-implementation-review` shipped two baseline revisions while building its review process.
Measured state:

| | |
|---|---|
| Revisions | `2026-07-31`, `2026-07-31b` — both **published and immutable** |
| Criteria | 10 |
| Source records | 8 |
| Records carrying a `source_commit` | **0** — so drift cannot currently be detected at all |
| `verification.md` | absent |
| `MAINTENANCE.md` | absent |

**Consequence that shapes every phase**: adding `source_commit` to existing records is a change to a
published revision, which the immutability rule forbids. It therefore requires a **new revision**,
not an edit. That is Phase 2's central task.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1, US2, US3, US4
- Include exact file paths in descriptions

## Path Conventions

Per plan.md: `baselines/goose/<revision>/` for revision content, `baselines/MAINTENANCE.md` for the
procedure. The new revision introduced here is `2026-08-01`.

---

## Phase 1: Setup

**Purpose**: The maintenance procedure and record formats that the new revision will conform to

- [ ] T001 Write `baselines/MAINTENANCE.md` implementing `contracts/drift-detection.md`: the two staleness rules, the URL-to-source-path mapping, the cadence table, and the prohibition on using `ETag`/`Last-Modified`
- [ ] T002 [P] Define the source record format in `baselines/SOURCE-FORMAT.md` per `data-model.md` "Source Record": the fields, which are conditional on `class`, and why an `authoritative` record without `url` or an `observed` record without `method` is invalid
- [ ] T003 [P] Define the verification record format in `baselines/SOURCE-FORMAT.md`, stating that `verification.md` is append-only inside a published revision and that this is the single permitted edit

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Produce a revision whose records can actually be drift-checked. Nothing in US4 works without this.

**⚠️ CRITICAL**: `2026-07-31b` cannot be amended. This phase creates `2026-08-01` as its successor.

- [ ] T004 Create `baselines/goose/2026-08-01/` and copy `criterion-format.md` from `2026-07-31b` unchanged, so the revision carries its own schema copy
- [ ] T005 Resolve the documentation source path for each authoritative record, mapping `https://goose-docs.ai/docs/<path>/` to `documentation/docs/<path>.md`, and record any URL whose mapping cannot be confirmed as having no `source_path`
- [ ] T006 Query the current commit for each resolved source path via `gh api "repos/aaif-goose/goose/commits?path=<path>&per_page=1"` and record the SHA
- [ ] T007 Write `baselines/goose/2026-08-01/sources.md` carrying all eight records from `2026-07-31b` plus `source_path` and `source_commit` for every authoritative one, and `method` plus `host_version` for every observed one
- [ ] T008 [P] Write `baselines/goose/2026-08-01/ruleset.md` carrying the ten criteria from `2026-07-31b` unchanged in substance, with a "What changed" section stating that only source records gained drift anchors
- [ ] T009 [P] Write `baselines/goose/2026-08-01/coverage.md` carrying the six declared gaps with their trigger conditions, and `goose_version: v1.45.0`
- [ ] T010 Create `baselines/goose/2026-08-01/verification.md` with one initial record per source: date, result `unchanged`, and the observed commit where applicable

**Checkpoint**: A revision exists whose every authoritative record can be drift-checked. User stories can begin.

---

## Phase 3: User Story 1 - Every Statement Carries Its Source (Priority: P1) 🎯 MVP

**Goal**: No statement in the base is unsourced, and this is enforced rather than reviewed.

**Independent Test**: Count criteria and count sourced criteria in a revision; they must be equal, and every named source must resolve to a record.

- [ ] T011 [US1] Write the completeness check into `baselines/MAINTENANCE.md`: for a given revision, every criterion names a `source`, and every named source exists in that revision's `sources.md`
- [ ] T012 [US1] Run that check against `baselines/goose/2026-08-01/` and record the counts in `baselines/goose/2026-08-01/verification.md`
- [ ] T013 [US1] Run the same check against `2026-07-31` and `2026-07-31b` and record the result; a failure there is a defect in a published revision and must be reported, not silently corrected
- [ ] T014 [P] [US1] Add a "deliberately not included" section to `baselines/goose/2026-08-01/ruleset.md` listing every candidate rule rejected for lacking an admissible source, with the reason (quickstart Scenario 2)
- [ ] T015 [US1] Verify wording against evidence class per quickstart Scenario 3: every criterion whose source is `observed` must read as an observation naming the host version, never as a documented requirement. Applies to `R-002` and `R-010`

**Checkpoint**: US1 is independently testable. The base provably contains no unsourced statement.

---

## Phase 4: User Story 2 - A Third Party Can Verify Without Asking the Author (Priority: P2)

**Goal**: Someone who did not write the material can resolve its citations unaided.

**Independent Test**: Hand a sample of at least 20 statements to a second reader; measure how many they resolve using only the sample and the cited sources.

- [ ] T016 [P] [US2] Write the sampling procedure into `baselines/MAINTENANCE.md`, modelled on `tests/goose-implementation-review/SC-003-SAMPLE.md`: each row carries the claim, where to check it, the URL, and the quoted passage
- [ ] T017 [US2] Generate `baselines/goose/2026-08-01/VERIFICATION-SAMPLE.md` with at least 20 statements drawn from the revision, each self-contained so no lookup is needed
- [ ] T018 [US2] Mark rows whose source class is `observed` as requiring extra scepticism, stating that a row reading as though documentation required the behaviour is to be marked unresolved
- [ ] T019 [US2] Have a reader who did not author the material complete the sample and record the result in `baselines/goose/2026-08-01/verification.md`. **Cannot be self-certified** — threshold is 95% per `SC-002`
- [ ] T020 [P] [US2] Add the quote field to every authoritative record in `baselines/goose/2026-08-01/sources.md` so a reader need not open the URL to see what was relied upon

**Checkpoint**: The citations are shown to carry for someone other than their author.

---

## Phase 5: User Story 3 - Gaps Are Visible as Gaps (Priority: P3)

**Goal**: What the base does not cover is declared, consumable, and worked in order of demand.

**Independent Test**: Every gap has a trigger condition; a subject meeting one produces an `undecided` finding in a real review, never a pass.

- [ ] T021 [P] [US3] Verify every gap in `baselines/goose/2026-08-01/coverage.md` carries an id and a trigger condition, and record the check in `verification.md`
- [ ] T022 [US3] Run a review from `001` against a subject that triggers `GAP-EXT-SEMANTICS`, using `--params baseline_revision=2026-08-01`, and confirm the report shows it as `undecided` rather than passing (quickstart Scenario 7)
- [ ] T023 [US3] Record gap priority by observed demand in `baselines/MAINTENANCE.md` per `research.md` Finding 3: `GAP-EXT-SEMANTICS` first, `GAP-RECIPE-FIELDS` second, and the four that can never fire under `001`'s current scope last
- [ ] T024 [US3] Research `GAP-EXT-SEMANTICS` — what constitutes a well-formed value for each extension type — and either produce new criteria or narrow the gap with what was searched, recording sources with `source_commit`
- [ ] T025 [US3] Publish the outcome of T024 as revision `baselines/goose/<next>/`, leaving `2026-08-01` unmodified, and state in its coverage which gap narrowed and why a comparison will show that as cause `baseline`

**Checkpoint**: The gap list is a working queue, and closing one demonstrably converts it into criteria.

---

## Phase 6: User Story 4 - Drift Against Upstream Is Detected (Priority: P4)

**Goal**: A source that moved is flagged before the base is used to review anything.

**Independent Test**: Run the drift check; sources whose upstream commit matches report `unchanged`, and a deliberately stale stored commit reports `drifted`.

- [ ] T026 [P] [US4] Write the executable drift check into `baselines/MAINTENANCE.md`: per authoritative record, query the current commit and compare against the stored `source_commit` (Rule A)
- [ ] T027 [P] [US4] Write the observed-source rule into `baselines/MAINTENANCE.md`: compare the record's `host_version` against the revision's `goose_version` (Rule B), with re-measurement via the record's `method`
- [ ] T028 [US4] Run the drift check against `baselines/goose/2026-08-01/` and append one verification record per source to its `verification.md`
- [ ] T029 [US4] Verify drift is actually detected: set a stored `source_commit` to a known older SHA in a scratch copy, re-run, and confirm the result is `drifted` — never `unchanged`
- [ ] T030 [US4] Verify the unreachable path: run the check with the API unavailable and confirm the result records `unreachable`, never `unchanged` (quickstart Scenario 4)
- [ ] T031 [US4] Verify Rule B independently: compare an `observed` record against a different declared `goose_version` and confirm it reports `drifted` even though its documentation did not move (quickstart Scenario 5)

**Checkpoint**: The base ages visibly rather than silently.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T032 [P] Run every scenario in `specs/002-qa-documentation-base/quickstart.md` and record outcomes in `baselines/goose/2026-08-01/verification.md`
- [ ] T033 [P] Verify append-only enforcement per quickstart Scenario 8: append a verification record, confirm earlier records and the criteria are untouched
- [ ] T034 [P] Verify revision retention per quickstart Scenario 9: confirm `2026-07-31` and `2026-07-31b` are byte-identical to their committed state apart from appended verifications
- [ ] T035 Update `CLAUDE.md` with `baselines/MAINTENANCE.md`, the drift-check command, and the rule that `ETag`/`Last-Modified` must not be used
- [ ] T036 Update `specs/001-goose-implementation-review/contracts/baseline-contract.md` to note that revisions from `2026-08-01` onward carry drift anchors, without changing what `001` requires

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories, because no record can be drift-checked until it carries an anchor
- **User Stories (Phase 3–6)**: All depend on Phase 2
- **Polish (Phase 7)**: Depends on the desired stories being complete

### User Story Dependencies

- **US1 (P1)**: Depends only on Foundational. Delivers the MVP
- **US2 (P2)**: Depends on US1 — a sample can only be drawn from statements known to be sourced
- **US3 (P3)**: Depends on Foundational. T022 additionally needs feature `001` runnable
- **US4 (P4)**: Depends on Foundational, specifically on `source_commit` existing. This is the story the whole of Phase 2 exists to enable

### Within Each User Story

- Format definitions (Phase 1) before any task that emits records in that format
- T005 → T006 → T007: paths resolve before commits are queried before records are written
- Verification tasks after the material they verify
- Story complete and its checkpoint verified before the next priority

### Parallel Opportunities

- T002 and T003 in Setup
- T008 and T009 in Foundational, once T007 fixes the source records
- T014 in US1; T016 and T020 in US2; T021 in US3; T026 and T027 in US4
- US3 and US4 can proceed in parallel once US1 is complete

---

## Parallel Example: User Story 4

```bash
# Both rules are written into MAINTENANCE.md but govern different record classes:
Task: "Write Rule A (authoritative: compare source commit) into baselines/MAINTENANCE.md"
Task: "Write Rule B (observed: compare host version) into baselines/MAINTENANCE.md"

# Then the three verifications, each proving a different failure is caught:
Task: "Verify drifted is reported for a stale stored commit"
Task: "Verify unreachable is reported when the API is unavailable"
Task: "Verify Rule B fires on a version change with no documentation change"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup — formats first, so the new revision conforms from the start
2. Complete Phase 2: Foundational — revision `2026-08-01` with drift anchors
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: quickstart Scenarios 1, 2 and 3
5. At this point the base provably contains no unsourced statement and every claim is worded within
   its evidence

### Incremental Delivery

1. Setup + Foundational → a drift-checkable revision exists
2. US1 → no unsourced statements (MVP)
3. US2 → citations shown to carry for a second reader
4. US3 → the gap list becomes a working queue
5. US4 → the base ages visibly

### Release Gate

Per `quickstart.md`, scenarios 1–5 and 7–9 must pass. Scenario 6 needs a second reader and may trail,
but **must not be claimed on the author's own assessment** — T019 exists for exactly that reason.

Scenario 1 is non-negotiable: a single unsourced statement blocks publication, and everything else in
this feature rests on that holding.

---

## Notes

- [P] tasks touch different files and have no dependency on incomplete work
- **Published revisions are never edited.** T004–T010 create a successor rather than amending
  `2026-07-31b`, and T025 does the same again. The only permitted edit to a published revision is
  appending a verification record
- T013 may find a defect in an already-published revision. It is to be **reported**, not corrected —
  correcting it in place would break the guarantee that a report citing that revision stays
  interpretable
- Commit after each task or logical group
