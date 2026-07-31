# Quickstart: Validating the Review Process

**Feature**: `001-goose-implementation-review` | **Date**: 2026-07-31

How to confirm the feature works end to end. Each scenario maps to acceptance criteria in
[spec.md](./spec.md). This is a validation guide, not an implementation guide.

## Prerequisites

- Goose installed, **v1.45.0** or compatible (`goose --version`).
- One published baseline revision under `baselines/goose/<revision>/` with at least one topic
  covered and its gaps declared.
- The review recipe at `process/goose-implementation-review/recipe.yaml`.
- Fixtures under `tests/goose-implementation-review/`.

## Scenario 1 — A finding is traceable (US1, SC-001)

Run the review against the fixture that contains a known deviation.

**Expected**: A report is written. Every finding names a criterion id, a location in the fixture, and
a source with URL and consulted date.

**How to check**: Pick any finding, open its source URL, and confirm the quoted rule says what the
finding claims. Then open the named location and confirm the deviation is there. If either step
requires asking the author, `SC-003` has failed.

**Fails if**: any finding lacks criterion, location, or source — publication must be blocked.

## Scenario 2 — A clean subject is distinguishable from an unexamined one (US1 scenario 2)

Run against the fixture with no known deviations.

**Expected**: A report with zero findings that still lists the criteria applied and a coverage
statement.

**Fails if**: the report is empty, or omits `Criteria Applied`. An empty report cannot be told apart
from a review that never ran.

## Scenario 3 — Reproducibility (US2, SC-002, FR-005)

Run the review twice against an unchanged fixture with the same `baseline_revision`. Compare the two
reports byte for byte.

**Expected**: Identical files. Ordering is fixed by the report contract precisely so this comparison
is meaningful.

**Fails if**: the files differ in anything but a timestamp. Any other difference means findings are
not reproducible, and the deferral recorded in the plan's Complexity Tracking must be revisited —
a deterministic checker becomes necessary.

## Scenario 4 — Undecidable criteria are visible (FR-007)

Run against a fixture touching a topic the baseline declares as a gap.

**Expected**: The affected criteria appear as findings with outcome `undecided`, naming what was
missing. They are not counted as passes.

**Fails if**: the report is clean. This is the false-confidence failure mode the baseline contract
exists to prevent.

## Scenario 5 — Reuse against a foreign repository (US3, SC-004)

Copy `process/goose-implementation-review/` and `baselines/` into an unrelated repository containing
a Goose recipe. Run the review there with no edits to either directory.

**Expected**: A valid report.

**Fails if**: anything must be edited to make it run. That is a Principle I violation, not a
configuration inconvenience.

## Scenario 6 — Self-review (Principle V)

Run the review with `subject_path` pointing at `process/goose-implementation-review/recipe.yaml` —
the process reviewing its own recipe.

**Expected**: A report. In particular the recipe must satisfy the host schema rules quoted in the
[recipe interface contract](./contracts/recipe-interface.md): required fields present, every optional
parameter carrying a default, `subject_path` carrying none, and no unused parameters.

**Fails if**: the process cannot review itself, or passes itself while violating a rule it enforces
on others.

## Scenario 7 — Delta between reviews (US4, FR-012)

Review a fixture, fix one deviation, review again with `compare_to` set to the first report.

**Expected**: The fixed finding is `resolved` with cause `subject`; untouched findings are
`unchanged`.

Then repeat with the subject untouched but a newer baseline revision. A finding that disappears must
be reported with cause `baseline` — not as a fix.

**Fails if**: cause is absent or wrong. Attributing a baseline change to the subject would credit
work nobody did.

## Scenario 8 — The subject is not modified (FR-006)

Checksum every file under `subject_path`, run the review, checksum again.

**Expected**: Identical checksums.

**Fails if**: anything under the subject changed. The process promises to be read-only; against a
foreign repository that promise is the difference between a review and an intervention.

## Scenario 9 — A partial review says so (SC-006, FR-008)

Run against the oversized fixture, which cannot be reviewed in one pass.

**Expected**: A report whose `not_examined` lists the unreviewed parts with a reason.

**Fails if**: `not_examined` reads "none" while parts went unexamined. That is the difference
between an honest partial result and a false claim of completeness.

## Scenario 10 — Offline behaviour (Edge Case)

Run with upstream unreachable.

**Expected**: Either the review proceeds against the pinned baseline and states that drift could not
be checked, or it refuses outright.

**Fails if**: it reviews silently against nothing, or reports a clean drift check it never performed.

## Scenario 11 — Published revisions survive (FR-011)

Publish a second baseline revision, then re-read the first.

**Expected**: The first revision is byte-identical to its published state, and a report naming it
remains interpretable — including its criterion format, which travels inside the revision.

**Fails if**: the earlier revision changed, or can no longer be interpreted because the schema moved
out from under it.

## Scenario 12 — Citations hold up for a stranger (SC-003)

Have someone who did not author the baseline resolve a sample of at least 20 findings to their
sources, using only the report.

**Expected**: At least 90% resolved unaided.

**Fails if**: below 90%. Correct the citations — this is the only scenario that tests whether the
evidence actually *carries*, rather than merely being present.

## Scenario 13 — Time to triaged findings (SC-005)

Time a full review of the reference fixture, from invocation to a triaged list.

**Expected**: Under 15 minutes.

**Fails if**: over. Record what dominated the time before adjusting scope — a slow review is a
symptom, and the cause decides the fix.

## Release gate

Releasable when Scenarios 1–6 and 8–12 pass. Scenario 7 covers US4 (P4) and may trail; Scenario 13
is a measurement whose result is recorded rather than a pass/fail gate.

Two are non-negotiable. **Scenario 6**: per Constitution Principle V, the process is not released
until it has performed a real review in this repository, and its own recipe is the first genuine
subject. **Scenario 8**: an unverified read-only promise is the one defect that could damage a
consumer's repository rather than merely misinform them.
