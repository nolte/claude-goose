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

**Revision note**: Rewritten after `/speckit-analyze`. Eight findings were remediated; added tasks
are marked ⟵. Every task now names the `FR-`/`SC-` it serves — the first version named only four of
twenty-one, which is precisely why five requirements had no task at all and nobody noticed.

## Starting point — this feature does not begin at zero

`001-goose-implementation-review` shipped two baseline revisions while building its review process.
Measured state:

| | |
|---|---|
| Revisions | `2026-07-31`, `2026-07-31b` — both **published and immutable** |
| Criteria | 10 |
| Source records | 8 |
| Records carrying a `source_commit` | **0** — so drift cannot currently be detected at all |
| `verification.md`, `MAINTENANCE.md` | absent |

**Consequence that shapes every phase**: adding `source_commit` to existing records is a change to a
published revision, which the immutability rule forbids. It therefore requires a **new revision**,
not an edit. That is Phase 2's central task.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1, US2, US3, US4
- Include exact file paths in descriptions

## Path Conventions

Per plan.md: `baselines/goose/<revision>/` for revision content; `baselines/MAINTENANCE.md`,
`VERSION.md` and `SOURCE-FORMAT.md` alongside. The new revision introduced here is `2026-08-01`; its
successor in Phase 5 is `2026-08-02`.

---

## Phase 1: Setup

**Purpose**: The procedure, its version, and the record formats the new revision must conform to

- [X] T001 Write `baselines/MAINTENANCE.md` implementing `contracts/drift-detection.md`: the two staleness rules, the URL-to-source-path mapping, the cadence table, and the prohibition on `ETag`/`Last-Modified` (`FR-008`)
- [X] T002 Create `baselines/VERSION.md` initialised to `0.1.0`, documenting MAJOR/MINOR/PATCH semantics for the maintenance procedure and stating that this axis is independent of both the repository and any baseline revision (Constitution Principle II) ⟵
- [X] T003 [P] Define the source record format in `baselines/SOURCE-FORMAT.md` per `data-model.md` "Source Record": every field, which are conditional on `class`, and why an `authoritative` record without `url` or an `observed` record without `method` is invalid (`FR-001`, `FR-003`, `FR-004`, `FR-011`)
- [X] T004 [P] Define the `conflicts_with` and `resolution` fields in `baselines/SOURCE-FORMAT.md`, stating that a record naming a contradiction without a resolution is invalid, and that a resolution says which record governs *for which purpose* rather than which one wins (`FR-005`) ⟵
- [X] T005 [P] Define the statement `version_range` field in `baselines/SOURCE-FORMAT.md`: an unversioned claim about version-specific behaviour is invalid, not merely imprecise (`FR-010`, `SC-003`) ⟵
- [X] T006 [P] Define the verification record format in `baselines/SOURCE-FORMAT.md`, stating that `verification.md` is append-only inside a published revision and that this is the single permitted edit (`FR-009`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Produce a revision whose records can actually be drift-checked. Nothing in US4 works without this.

**⚠️ CRITICAL**: `2026-07-31b` cannot be amended. This phase creates `2026-08-01` as its successor.

- [X] T007 Create `baselines/goose/2026-08-01/` and copy `criterion-format.md` from `2026-07-31b` unchanged, so the revision carries its own schema copy
- [X] T008 Resolve the documentation source path for each authoritative record, mapping `https://goose-docs.ai/docs/<path>/` to `documentation/docs/<path>.md`, recording any URL whose mapping cannot be confirmed as having no `source_path` (`FR-008`)
- [X] T009 Query the current commit for each resolved source path via `gh api "repos/aaif-goose/goose/commits?path=<path>&per_page=1"` and record the SHA (`FR-008`)
- [X] T010 Write `baselines/goose/2026-08-01/sources.md` carrying all eight records from `2026-07-31b` plus `source_path` and `source_commit` for every authoritative one, and `method` plus `host_version` for every observed one (`FR-001`, `FR-008`)
- [X] T011 Record the known contradiction in `baselines/goose/2026-08-01/sources.md`: `S-001` states at least one of `instructions`/`prompt` is required, while `S-003` measured that neither is enforced and `S-008` measured that headless runs need `prompt`. Set `conflicts_with` and a `resolution` stating the documentation governs loading and the measurements govern running (`FR-005`, `SC-007`) ⟵
- [X] T012 [P] Write `baselines/goose/2026-08-01/ruleset.md` carrying the ten criteria from `2026-07-31b` unchanged in substance, each with a `version_range`, plus a "What changed" section stating that only source records gained drift anchors and version ranges (`FR-010`, `FR-013`, `SC-003`) ⟵
- [X] T013 [P] Write `baselines/goose/2026-08-01/coverage.md` carrying the six declared gaps with their trigger conditions, and `goose_version: v1.45.0` (`FR-006`)
- [X] T014 Create `baselines/goose/2026-08-01/verification.md` with one initial record per source: date, result `unchanged`, and the observed commit where applicable (`FR-009`)

**Checkpoint**: A revision exists whose every authoritative record can be drift-checked, whose statements are version-scoped, and whose one known contradiction is visible.

---

## Phase 3: User Story 1 - Every Statement Carries Its Source (Priority: P1) 🎯 MVP

**Goal**: No statement in the base is unsourced, and this is enforced rather than reviewed.

**Independent Test**: Count criteria and count sourced criteria in a revision; they must be equal, and every named source must resolve to a record.

- [X] T015 [US1] Write the completeness check into `baselines/MAINTENANCE.md`: every criterion names a `source`, every named source exists in that revision's `sources.md`, and every version-specific claim carries a `version_range` (`SC-001`, `SC-003`)
- [X] T016 [US1] Run that check against `baselines/goose/2026-08-01/` and record the counts in its `verification.md` (`SC-001`)
- [X] T017 [US1] Run the same check against `2026-07-31` and `2026-07-31b` and record the result; a failure there is a defect in a published revision and must be **reported, not corrected** (`SC-001`)
- [X] T018 [P] [US1] Add a "deliberately not included" section to `baselines/goose/2026-08-01/ruleset.md` listing every candidate rule rejected for lacking an admissible source, with the reason (`FR-002`, quickstart Scenario 2)
- [X] T019 [US1] Verify wording against evidence class: every criterion whose source is `observed` reads as an observation naming the host version, never as a documented requirement. Applies to `R-002` and `R-010` (`FR-004`, quickstart Scenario 3)
- [X] T020 [US1] Verify the contradiction from T011 is visible to a reader of the revision alone, and that neither side was suppressed in favour of the other (`FR-005`, `SC-007`) ⟵

**Checkpoint**: US1 is independently testable. The base provably contains no unsourced statement.

---

## Phase 4: User Story 2 - A Third Party Can Verify Without Asking the Author (Priority: P2)

**Goal**: Someone who did not write the material can resolve its citations unaided.

**Independent Test**: Hand a sample of at least 20 statements to a second reader; measure how many they resolve using only the sample and the cited sources.

- [X] T021 [P] [US2] Write the sampling procedure into `baselines/MAINTENANCE.md`, modelled on `tests/goose-implementation-review/SC-003-SAMPLE.md`: each row carries the claim, where to check it, the URL, and the quoted passage (`FR-003`, `SC-002`)
- [X] T022 [US2] Generate `baselines/goose/2026-08-01/VERIFICATION-SAMPLE.md` with at least 20 statements, each self-contained so no lookup is needed (`FR-003`, `SC-002`)
- [X] T023 [US2] Mark rows whose source class is `observed` as requiring extra scepticism, and include at least one row covering the recorded contradiction (`FR-004`, `FR-005`) ⟵
- [ ] T024 [US2] Have a reader who did not author the material complete the sample and record the result in `verification.md`. **Cannot be self-certified** — threshold 95% (`SC-002`)
- [X] T025 [P] [US2] Add the `quote` field to every authoritative record in `baselines/goose/2026-08-01/sources.md` so a reader need not open the URL to see what was relied upon (`FR-003`)
- [ ] T026 [US2] Time how long a reader takes to locate the source of an arbitrary statement, and record the measurement; over one minute, record what dominated before adjusting (`SC-005`) ⟵

**Checkpoint**: The citations are shown to carry for someone other than their author.

---

## Phase 5: User Story 3 - Gaps Are Visible as Gaps (Priority: P3)

**Goal**: What the base does not cover is declared, consumable, and worked in order of demand.

**Independent Test**: Every gap has a trigger condition; a subject meeting one produces an `undecided` finding in a real review, never a pass.

- [X] T027 [P] [US3] Verify every gap in `baselines/goose/2026-08-01/coverage.md` carries an id and a trigger condition, and record the check in `verification.md` (`FR-006`, `SC-004`)
- [X] T028 [US3] Run a review from `001` against a subject triggering `GAP-EXT-SEMANTICS` with `--params baseline_revision=2026-08-01`, confirming the report shows it as `undecided` rather than passing (`FR-007`, quickstart Scenario 7)
- [X] T029 [US3] Record gap priority by observed demand in `baselines/MAINTENANCE.md` per `research.md` Finding 3: `GAP-EXT-SEMANTICS` first, `GAP-RECIPE-FIELDS` second, the four that can never fire under `001`'s scope last (`FR-012`)
- [X] T030 [US3] Research `GAP-EXT-SEMANTICS` — what constitutes a well-formed value per extension type — and either produce new criteria or narrow the gap with what was searched, recording sources with `source_commit` (`FR-012`)
- [X] T031 [US3] Publish the outcome of T030 as `baselines/goose/2026-08-02/`, leaving `2026-08-01` unmodified, stating in its coverage which gap narrowed and why a comparison will show that as cause `baseline` (`FR-012`, `FR-013`)

**Checkpoint**: The gap list is a working queue, and closing one demonstrably converts it into criteria.

---

## Phase 6: User Story 4 - Drift Against Upstream Is Detected (Priority: P4)

**Goal**: A source that moved is flagged before the base is used to review anything.

**Independent Test**: Run the drift check; matching commits report `unchanged`, a deliberately stale stored commit reports `drifted`.

- [X] T032 [P] [US4] Write the executable drift check into `baselines/MAINTENANCE.md`: per authoritative record, query the current commit and compare against the stored `source_commit` — Rule A (`FR-008`)
- [X] T033 [P] [US4] Write the observed-source rule into `baselines/MAINTENANCE.md`: compare the record's `host_version` against the revision's `goose_version` — Rule B, with re-measurement via the record's `method` (`FR-008`, `FR-010`)
- [X] T034 [US4] Run the drift check against `baselines/goose/2026-08-01/` and append one verification record per source (`FR-008`, `FR-009`, `SC-006`)
- [X] T035 [US4] Verify drift is actually detected: set a stored `source_commit` to a known older SHA in a scratch copy, re-run, confirm `drifted` — never `unchanged` (`FR-008`)
- [X] T036 [US4] Verify the unreachable path: run with the API unavailable and confirm the result records `unreachable`, never `unchanged` (`FR-008`, quickstart Scenario 4)
- [X] T037 [US4] Verify Rule B independently: compare an `observed` record against a different declared `goose_version` and confirm it reports `drifted` although its documentation did not move (`FR-008`, quickstart Scenario 5)
- [X] T038 [US4] Verify `SC-006` end to end: after a simulated upstream change, confirm every dependent statement is flagged **before** the base is used for a review (`SC-006`) ⟵

**Checkpoint**: The base ages visibly rather than silently.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T039 [P] Run every scenario in `specs/002-qa-documentation-base/quickstart.md` and record outcomes in `baselines/goose/2026-08-01/verification.md`
- [X] T040 [P] Verify append-only enforcement: append a verification record, confirm earlier records and the criteria are untouched (`FR-009`, quickstart Scenario 8)
- [X] T041 [P] Verify revision retention: confirm `2026-07-31` and `2026-07-31b` are byte-identical to their committed state apart from appended verifications (quickstart Scenario 9)
- [X] T042 [P] Confirm every revision file is plain text, readable without special tooling, and diffs cleanly under version control; record in `verification.md` (`FR-014`) ⟵
- [X] T043 Update `CLAUDE.md` with `baselines/MAINTENANCE.md`, the drift-check command, and the rule that `ETag`/`Last-Modified` must not be used
- [X] T044 Update `specs/001-goose-implementation-review/contracts/baseline-contract.md` to note that revisions from `2026-08-01` onward carry drift anchors and version ranges, without changing what `001` requires

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
- **US3 (P3)**: Depends on Foundational. T028 additionally needs feature `001` runnable
- **US4 (P4)**: Depends on Foundational, specifically on `source_commit` existing. This is the story the whole of Phase 2 exists to enable

### Within Each User Story

- Format definitions (Phase 1) before any task that emits records in that format
- T008 → T009 → T010: paths resolve before commits are queried before records are written
- T011 after T010: the contradiction is recorded against records that already exist
- Verification tasks after the material they verify

### Parallel Opportunities

- T003–T006 in Setup (all write different sections of `SOURCE-FORMAT.md`; sequence them if that proves contentious)
- T012 and T013 in Foundational, once T010 and T011 fix the source records
- T018 in US1; T021 and T025 in US2; T027 in US3; T032 and T033 in US4; T039–T042 in Polish

---

## Parallel Example: User Story 4

```bash
# The two rules govern different record classes and can be written independently:
Task: "Write Rule A (authoritative: compare source commit) into baselines/MAINTENANCE.md"
Task: "Write Rule B (observed: compare host version) into baselines/MAINTENANCE.md"

# Then four verifications, each proving a different failure is caught:
Task: "Verify drifted is reported for a stale stored commit"
Task: "Verify unreachable is reported when the API is unavailable"
Task: "Verify Rule B fires on a version change with no documentation change"
Task: "Verify SC-006: dependent statements flagged before the base is used"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup — formats and the procedure version first
2. Complete Phase 2: Foundational — revision `2026-08-01` with drift anchors, version ranges and the recorded contradiction
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: quickstart Scenarios 1, 2 and 3
5. At this point the base provably contains no unsourced statement, every claim is worded within its
   evidence, and its one known contradiction is visible rather than smoothed over

### Incremental Delivery

1. Setup + Foundational → a drift-checkable revision exists
2. US1 → no unsourced statements (MVP)
3. US2 → citations shown to carry for a second reader
4. US3 → the gap list becomes a working queue
5. US4 → the base ages visibly

### Release Gate

Per `quickstart.md`, scenarios 1–5 and 7–9 must pass. Scenario 6 needs a second reader and may trail,
but **must not be claimed on the author's own assessment** — T024 exists for exactly that reason.

Scenario 1 is non-negotiable: a single unsourced statement blocks publication.

---

## Notes

- [P] tasks touch different files and have no dependency on incomplete work
- **Published revisions are never edited.** T007–T014 create a successor rather than amending
  `2026-07-31b`, and T031 does the same again. The only permitted edit is appending a verification
  record
- T017 may find a defect in an already-published revision. It is to be **reported**, not corrected —
  correcting it in place would break the guarantee that a report citing that revision stays
  interpretable
- Tasks marked ⟵ were added by the `/speckit-analyze` remediation. They exist because five
  requirements had no task at all (`FR-005`, `FR-010`, `FR-014`, `SC-003`, `SC-005`, `SC-007`) and a
  constitution principle had none (II)
- Every task names the `FR-`/`SC-` it serves. The first version named four of twenty-one, which is
  why the gaps went unnoticed until the analysis measured them
