# Implementation Plan: CI/CD and Release Pipeline

**Branch**: `003-cicd-release-pipeline` | **Date**: 2026-07-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-cicd-release-pipeline/spec.md`

## Summary

Give this repository a verification gate, declared branch roles, and a release chain — assembled
from the portfolio's shared workflows rather than authored here.

The deliverables are Markdown and YAML, so the gate is static: parse, lint, link-check, prose-check,
and validate the review recipe against Goose's own parser. Nothing is compiled and nothing is
packaged.

Two decisions shape everything below, both from measurement rather than assumption. The shared
aggregate workflow **cannot** be consumed whole, because two of its four jobs target artifacts this
repository deliberately does not have. And a pinned reference **does not** pin the transitive graph,
so the pinning guarantee has a stated limit rather than an implied one.

## Technical Context

**Language/Version**: None. Markdown and YAML only. The check toolchain is pinned as a pipeline
input, not as a project dependency.

**Primary Dependencies**: `nolte/gh-plumbing@v1.1.26` for pipeline mechanics; `nolte/vale-style@v0.1.17`
for prose rules; Goose **1.45.0** with `claude-agent-acp` for the recipe parse check. All four exist
and were verified via the API on 2026-07-31.

**Storage**: Workflow definitions under `.github/`, a task entry point at the repository root,
pinned tool versions in a requirements file.

**Testing**: The gate tests the repository. The gate itself is tested by introducing one defect per
check class and confirming exactly the corresponding check fails (`SC-002`) — a check that cannot
fail is not a check (`FR-010`).

**Target Platform**: GitHub-hosted runners. Self-hosted is prohibited for public repositories by the
governing platform binding.

**Project Type**: Repository infrastructure. It produces no artifact; it gates and releases the
artifacts of features `001` and `002`.

**Performance Goals**: `SC-005` — a verdict for a Markdown/YAML-only pull request without waiting on
anything that needs a Goose run.

**Constraints**: No floating references in this repository's own definitions (`SC-013`). Every
workflow declares a minimum permission set (`FR-026`). Release and delivery runs are never cancelled
in flight (`FR-027`). Files hashed in `.specify/integrations/*.json` are never hand-edited
(`FR-033`).

**Scale/Scope**: One repository, three workflows plus configuration. The full review runs of feature
`001` stay out of the gate (`FR-031`) — they consume a subscription and take minutes each.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Reusable by Construction | Added artifacts carry no absolute path, no author-specific value, and can be copied into another repository (`FR-032`, `SC-014`) | **PASS** — enforced by consuming shared workflows and by the existing portability guard |
| II. Plans Are Versioned Artifacts | The pipeline's stages are declared; its shared dependency is pinned to a version | **PASS** — `v1.1.26` pinned; the pipeline itself is configuration, not a multi-stage plan needing its own semver |
| III. Auditable Revisions | Release history is append-only; a published release is never rewritten | **PASS** — `FR-021` forbids tag creation or rewriting by the publish operation |
| IV. Host-Contract Fidelity | The Goose version the recipe check pins is stated explicitly; no forking of the host or of the shared workflows | **PASS** — 1.45.0 pinned; Finding 2 rejects vendoring precisely to avoid forking shared mechanics |
| V. Dogfooding | The pipeline runs against this repository before it is relied upon | **PASS** — its first subject is the pull request that introduces it |
| VI. Evidence-Backed Claims | Claims about the pipeline's guarantees are verified, and limits are stated rather than implied | **PASS** — see below |

**On Principle VI, and the one claim this feature must not make.** `SC-013` asks for no floating
references. This repository can pin its own; it cannot pin what the shared workflows call internally,
and they call each other with `@develop` (research Finding 3). Asserting "fully pinned" would be an
unsourced claim of exactly the kind this project forbids. The omissions record states the limit.

**Post-Phase-1 re-evaluation**: Re-checked after the design artifacts below. No gate changed status.
The design adds no repository-specific value to any consumed workflow, so Principle I is unaffected.

## Project Structure

### Documentation (this feature)

```text
specs/003-cicd-release-pipeline/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
.github/
├── workflows/
│   ├── static-gate.yml        # FR-001…FR-010: the required checks, on every PR to develop
│   ├── release-drafter.yml    # FR-018: draft accumulation on develop
│   ├── release-publish.yml    # FR-019…FR-023: deliberate Draft → Published
│   ├── release-propagate.yml  # FR-024: align the release-presentation branch
│   ├── automerge.yml          # FR-016: merge when approved and green
│   └── dependency-review.yml  # FR-029: supply-chain obligation
├── settings.yml               # FR-013…FR-015, FR-017: extends the portfolio commons; declares
│                              #   THIS repository's required-check contexts (the commons leaves
│                              #   them empty by policy). Synced by the Probot Settings App
└── release-drafter.yml        # drafting categories

Taskfile.yml                   # FR-008: the single entry point the pipeline invokes
.pre-commit-config.yaml        # the static checks, runnable locally and in CI
.vale.ini                      # FR-005: prose rules, consumed from nolte/vale-style
requirements-ci.txt            # FR-012: pinned check-tool versions
OMISSIONS.md                   # FR-030: every declared stage this repository does not run, and why
```

**Structure Decision**: Workflows are thin wrappers that call pinned shared workflows; the checks
themselves live in `.pre-commit-config.yaml` so the identical set runs locally and in CI (`SC-004`).
`Taskfile.yml` is the one entry point (`FR-008`), which is what makes "run the gate on a fresh
workstation" a single command rather than a list.

`OMISSIONS.md` is a first-class artifact rather than a comment, because `FR-030` and `SC-012` require
every omitted stage to be answerable — and because this feature has real omissions to declare, not
zero.

**On `settings.yml`.** `FR-014` requires a committed, synchronized file but names no mechanism. The
portfolio has settled it: the Probot Settings App, with consumers extending
`nolte/gh-plumbing:.github/commons-settings.yml`. Three properties of that arrangement shape the
work (research Finding 5):

- `default_branch: develop` and squash-only merging are **inherited**, so this repository does not
  restate them.
- Required-check contexts are **not** inherited — the commons leaves them empty by explicit policy.
  `FR-015` is satisfied by declaring them here.
- Branch entries merge by `name`, so declaring only `develop` locally leaves inherited entries alone.

**The App's installation is a precondition this feature cannot satisfy.** Whether it is installed
could not be verified (the endpoint needs App authentication), and `main` currently has no protection
at all. If the App is absent, every branch-protection requirement silently does nothing — which is
why it belongs in `OMISSIONS.md` rather than being assumed.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations. Three tensions are recorded because they shape the design and each has a
cost that must be accepted knowingly:

| Tension | Why it exists | Resolution |
|---|---|---|
| Pin everything vs. pinning is not transitive | `SC-013` asks for no floating references; the shared workflows call each other with `@develop`, which a consumer cannot override | Pin this repository's own references to `v1.1.26`; record in `OMISSIONS.md` that the guarantee stops at the boundary. Claiming full pinning would be the unsourced assertion Principle VI forbids |
| Reuse shared mechanics vs. the aggregate does not fit | `FR-028` says consume shared mechanics; `build-static-tests.yaml` runs mkdocs and chain-bench jobs against artifacts this repository does not have | Consume the individual `reusable-*` workflows. Reuse is satisfied without inventing a documentation site to keep a job happy |
| Verify the review works vs. keep the gate fast and cheap | Feature `001`'s real value is its full review runs, but each consumes a subscription and takes minutes | The gate runs `goose run --explain` only — a real parser check at no LLM cost (`FR-006`). Full runs stay manual (`FR-031`), so the gate cannot prove the review's *findings* are still correct, only that its recipe still parses |
