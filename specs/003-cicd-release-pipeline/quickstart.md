# Quickstart: Validating the Pipeline

**Feature**: `003-cicd-release-pipeline` | **Date**: 2026-07-31

How to confirm the pipeline works. Each scenario maps to acceptance criteria in [spec.md](./spec.md).
This is a validation guide, not a setup guide.

## Prerequisites

- The remote exists (`git@github.com:nolte/claude-goose.git`) and `develop` is the default branch.
- `task`, `pre-commit`, `vale`, and Goose 1.45.0 installed locally.
- Permission to edit branch protection, for scenarios 5 and 6.

## Scenario 1 — The gate runs on every pull request (US1, FR-009, SC-001)

Open a pull request against `develop` changing one Markdown file.

**Expected**: All seven check classes report, each separately named, with a pass/fail verdict.

**Fails if**: any class is missing, or the run was skipped by a path filter. A path filter is a
decision that some changes need no verification.

## Scenario 2 — Each check can actually fail (FR-010, SC-002) 🎯 the important one

Introduce exactly one defect per class, one at a time:

| Class | Defect to introduce |
|---|---|
| YAML parse | Unbalanced quote in any `*.yml` |
| Markdown lint | A violation of the declared style |
| Recipe schema | Remove a required field from the review recipe |
| Link check | A relative link to a file that does not exist |
| Prose lint | A word the Vale style rejects |
| Recipe parse | Break the recipe so `goose run --explain` rejects it |
| Format | Trailing whitespace |

**Expected**: Exactly the corresponding check fails, and the others pass.

**Fails if**: a check passes despite its defect. **That check is not wired**, whatever the green tick
suggests — this is the single scenario that distinguishes a gate from decoration.

## Scenario 3 — Determinism (FR-011, SC-003)

Re-run the gate on the same commit, once with a cold cache.

**Expected**: Identical verdict.

**Note the stated limit**: this holds against a fixed state of the shared workflow repository, whose
workflows call each other with `@develop`. See `OMISSIONS.md`.

## Scenario 4 — Same checks locally (SC-004)

On a fresh workstation:

```sh
task ci
```

**Expected**: The same seven classes, the same verdict as CI.

**Fails if**: a check exists only in a workflow file. A contributor cannot then verify before
pushing, which turns CI into the first place defects surface.

## Scenario 5 — Protection is restored after UI deletion (US2, SC-007)

Delete a branch-protection rule through the platform UI, then let the settings mechanism run.

**Expected**: The rule returns.

**Fails if**: it stays deleted. Protection that only exists in the UI is one click from gone, with no
record that it ever existed.

## Scenario 6 — The release-presentation branch rejects direct pushes (SC-008)

Attempt `git push origin main` with a hand-made commit.

**Expected**: Rejected.

**Fails if**: accepted. `main` is derived from releases; a direct push makes its content
unattributable.

## Scenario 7 — Merge automation (FR-016, SC-006)

Approve a pull request with all required checks green.

**Expected**: It merges into `develop` without a manual click.

## Scenario 8 — Publication refuses in all three cases (US3, SC-010)

Run the publish workflow three times, provoking each refusal:

1. A tag with no drafter-produced draft.
2. A hand-crafted tag.
3. A tag while required checks on `develop` are red.

**Expected**: Each refuses with an actionable message.

**Fails if**: any succeeds. Publishing over a red gate makes the gate advisory; publishing a
hand-crafted tag makes provenance unattributable.

## Scenario 9 — Dry run validates without publishing (FR-022)

Run publish with `dry_run: true` against a valid draft.

**Expected**: Every condition is evaluated; the release stays a draft.

**Fails if**: the release is published. The dry run exists so nobody needs to "just try it" against a
real release.

## Scenario 10 — Publication without hand-editing (SC-009)

Publish a real release.

**Expected**: No operator ran any release-editing command against the release. No tag was created or
rewritten by the publish operation.

## Scenario 11 — Every omission is answerable (FR-030, SC-012)

For each stage the governing pipeline design names, look it up in `OMISSIONS.md`.

**Expected**: Every stage answers "runs" or "omitted, because …, revisit when …".

**Fails if**: a stage appears nowhere. Silence is indistinguishable from having forgotten it.

## Scenario 12 — No floating references in this repository (SC-013)

```sh
grep -rn 'uses:.*@\(develop\|main\|master\)$' .github/
```

**Expected**: No matches.

**Note**: this checks **this repository's** definitions. The shared workflows' internal references
are outside a consumer's control and are recorded as a stated limit, not claimed as pinned.

## Scenario 13 — Portability (FR-032, SC-014)

Copy the added artifacts into a second repository and run `task ci`.

**Expected**: It runs without editing any of them.

**Fails if**: anything must be changed. That is a Principle I violation, not a configuration step.

## Release gate

Scenarios 1–4 and 8–13 must pass before the pipeline is relied upon.

**Scenario 2 is non-negotiable.** Everything else assumes the checks can fail; if they cannot, every
other green result is meaningless.

Scenarios 5–7 depend on platform permissions and may trail. Propagation completing is **expected to
fail** for a known, recorded reason — see `OMISSIONS.md`.
