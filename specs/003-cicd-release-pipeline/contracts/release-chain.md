# Contract: The Release Chain

**Feature**: `003-cicd-release-pipeline` | **Date**: 2026-07-31

Fixes how a release is accumulated, published, and propagated. Every mechanism is consumed from
`nolte/gh-plumbing@v1.1.26`; none is implemented here.

## The chain

```text
merged PR ──> release-drafter ──> draft release (tag created here)
                                        │
                            workflow_dispatch, deliberate
                                        ▼
                              release-publish ──> published
                                        │
                                        ▼
                           propagation ──> release-presentation branch
```

## Stage 1 — Drafting

**Mechanism**: `release-drafter.yml@v1.1.26`, triggered by merges to the integration branch.

**Produces**: A draft release accumulating notes from merged pull requests (`FR-018`), **and the
tag**. The tag's provenance is the drafter and only the drafter.

## Stage 2 — Publishing

**Mechanism**: `release-publish.yml@v1.1.26`, `workflow_dispatch` only.

| Input | Required | Purpose |
|---|---|---|
| `tag` | yes | Must match an open drafter-produced draft |
| `dry_run` | no, default `false` | Validate without flipping `draft=false` (`FR-022`) |

**Deliberate by construction.** `workflow_dispatch` means a release cannot happen as a side effect of
a merge (`FR-019`).

### The three refusals

The operation refuses, with an actionable message, when (`SC-010`):

| # | Condition | Why it matters |
|---|---|---|
| 1 | No open draft produced by the drafter exists for the tag (`FR-020`) | Publishing something the drafter did not produce means publishing notes nobody accumulated |
| 2 | The tag was hand-crafted (`FR-021`) | The publish operation must **never** create or rewrite a tag. A tag that appears without the drafter has unattributable provenance |
| 3 | Required checks on the integration branch are not green | Publishing over a red gate makes the gate advisory |

**No operator ever runs a release-editing command against the release directly** (`SC-009`). The
existence of `dry_run` removes the last excuse for doing so.

## Stage 3 — Propagation

**Mechanism**: `release-cd-refresh-master.yml@v1.1.26`, triggered by the release event.

**Effect**: The release-presentation branch is brought in line with the published release (`FR-024`).
It is written by this mechanism and by nothing else; a direct human push is rejected (`SC-008`).

### A known incompleteness, stated rather than hidden

**Propagation will not start.** The release event is emitted under the workflow's default token,
which by platform design does not trigger further workflow runs. Starting it requires a portfolio App
identity, which is not available.

`FR-024` requires this incompleteness to be **visible**. It is therefore recorded in `OMISSIONS.md`
with its revisit condition, not left for someone to discover when `main` silently fails to move. The
remedy is a portfolio-level change outside this feature.

## Versioning

The repository declares that it has **no version-bearing files** (`FR-025`). Nothing in the working
tree states a release version, so nothing needs bumping and no file may be treated as authoritative
for one. The tag is the version.

## Concurrency

Release and delivery operations are **never cancelled in flight** (`FR-027`). A cancelled publish can
leave a release half-transitioned, and the recovery is manual — exactly the hand-editing the chain
exists to avoid.

## What this contract does not cover

- How the drafter categorises notes — configuration, not contract.
- The shared workflows' internals; they are consumed, not owned.
- Whether the propagation *completes* — see the incompleteness above.
