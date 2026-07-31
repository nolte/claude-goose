# Quickstart: Validating the Documentation Base

**Feature**: `002-qa-documentation-base` | **Date**: 2026-07-31

How to confirm the base works. Each scenario maps to acceptance criteria in [spec.md](./spec.md).
This is a validation guide, not an authoring guide.

## Prerequisites

- `gh` authenticated against GitHub; network access for drift checks.
- A baseline revision under `baselines/goose/<revision>/`.
- For scenario 6: a reader who did not author the material.

## Scenario 1 — Every statement carries a resolvable source (US1, SC-001)

Take any revision's `ruleset.md`. For each criterion, check it names a `source`, and that the source
appears in that revision's `sources.md`.

```sh
REV=baselines/goose/2026-07-31b
grep -c '^## R-' $REV/ruleset.md          # criteria
grep -c '\*\*source\*\*' $REV/ruleset.md   # ...each must carry one
```

**Expected**: Equal counts. Every `source` resolves to a record.

**Fails if**: any criterion lacks a source, or names one that does not exist. **This blocks
publication** — it is not a warning.

## Scenario 2 — Unsourced material became a gap, not a fact (US1, FR-002)

Read the "deliberately not included" section of `ruleset.md`.

**Expected**: Candidate rules that were rejected for lacking a source are listed there with the
reason.

**Fails if**: the section is absent or empty while the base covers a mature topic. Research that
never rejects anything has probably not been strict.

## Scenario 3 — Evidence class bounds the wording (FR-004)

Find every criterion whose source has `class: observed`.

**Expected**: Each is worded as an observation naming the host version, never as a documented
requirement.

**Fails if**: an observed criterion reads as though the documentation requires it. That claim
exceeds its evidence, which the criterion format forbids. In the shipped base this applies to
`R-002` and `R-010`.

## Scenario 4 — Drift is detected against the source commit (US4, FR-008)

```sh
gh api "repos/aaif-goose/goose/commits?path=documentation/docs/guides/recipes/recipe-reference.md&per_page=1" --jq '.[0].sha'
```

Compare against the `source_commit` stored in `sources.md`.

**Expected**: Equal ⇒ `unchanged`. Different ⇒ `drifted`, and every statement citing that record is
flagged.

**Fails if**: the check uses `ETag` or `Last-Modified`. Those track site deploys, not content —
measured 2026-07-31, two unrelated pages shared a `last-modified` while one had been unchanged for
two and a half months. See [drift-detection.md](./contracts/drift-detection.md).

## Scenario 5 — Observed statements go stale by version, not by document (FR-008)

Take an `observed` record and compare its `host_version` against the revision's `goose_version`.

**Expected**: Different versions ⇒ `drifted`, with the record's `method` naming how to re-measure.

**Fails if**: an observed record is reported `unchanged` because its documentation did not move. The
documentation was never what backed it.

## Scenario 6 — Citations hold up for a stranger (US2, SC-002)

Hand a sample of at least 20 statements to someone who did not author them. They resolve each using
only the sample and the cited sources.

**Expected**: At least 95% resolved unaided.

**Fails if**: below 95%. **Cannot be self-certified** — the base wrote the citations and is no
witness to whether they carry. Feature 001's `SC-003-SAMPLE.md` is the working template.

## Scenario 7 — Gaps are visible and consumable (US3, FR-006, FR-007)

Read `coverage.md`, then run a review whose subject triggers a declared gap.

**Expected**: Every gap carries an id and a trigger condition, and the triggered one appears in the
report as `undecided` — never as a pass.

**Fails if**: a gap has no trigger, or a triggered gap produces no finding. This is the single check
that stops an incomplete base from producing false confidence.

## Scenario 8 — Verification history is retained (FR-009)

Append a verification record, then re-read the earlier ones.

**Expected**: Earlier records intact; the revision's criteria unchanged.

**Fails if**: a verification overwrote an earlier one, or a drift check modified criteria. Appending
is the one edit a published revision permits.

## Scenario 9 — Published revisions stay interpretable (FR-011 of feature 001)

Publish a new revision, then re-read the previous one and a report citing it.

**Expected**: The earlier revision byte-identical apart from appended verifications, and still
interpretable — including its own copy of the criterion format.

**Fails if**: the earlier revision changed, or depends on a format that has since moved.

## Release gate

Scenarios 1–5 and 7–9 must pass. Scenario 6 requires a second reader and may trail, but **must not be
claimed as passing on the author's own assessment**.

Scenario 1 is non-negotiable: a single unsourced statement blocks publication. Everything else in
this feature rests on that one holding.
