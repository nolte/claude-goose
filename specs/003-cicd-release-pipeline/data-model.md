# Data Model: CI/CD and Release Pipeline

**Feature**: `003-cicd-release-pipeline` | **Date**: 2026-07-31

The entities here are configuration objects and platform state, not records in a store. "Field"
means a declared key a reader or a check can locate.

## Check Class

One named unit of static verification. Seven exist (`FR-001` … `FR-006`, plus link checking).

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Reported separately so a failure names its cause (`FR-007`) |
| `entry_point` | yes | Invoked through the task runner, never by an inline script (`FR-008`) |
| `scope` | yes | Which files it examines |
| `can_fail` | yes | Must be `true`. **A check configured so it cannot fail is not a check** (`FR-010`) |

| Class | Scope | Fails when |
|---|---|---|
| YAML parse | every `*.yml`, `*.yaml` | A file does not parse |
| Markdown lint | every `*.md` | A rule in the declared style is violated |
| Recipe schema | `process/goose-implementation-review/recipe.yaml` | The recipe does not conform |
| Link check | all internal relative links and anchors | A target does not exist |
| Prose lint | Markdown prose | A Vale rule is violated |
| Recipe parse | the review recipe, via `goose run --explain` | Goose's own parser rejects it |
| Format | all files | Trailing whitespace, missing final newline, mixed line endings |

**Validation**: Every class is separately named in the run output. A class that only ever passes is
suspect until a deliberately introduced defect makes it fail (`SC-002`).

## Branch Role

A branch with a declared purpose, protection, and writer.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | |
| `role` | yes | `integration`, `release-presentation`, or `feature` |
| `written_by` | yes | Who or what may push |
| `required_checks` | conditional | Required for `integration` |

| Branch | Role | Written by | Protection |
|---|---|---|---|
| `develop` | integration | Pull requests only | All seven check classes required (`FR-015`) |
| `main` | release-presentation | Release propagation only | **Direct human push rejected** (`SC-008`) |
| `<prefix>/*` | feature | The contributor | None; targets `develop` (`FR-017`) |

**State transition**: `main` is written **only** by propagation after a publication (`FR-024`). Its
content is derived, never authored. This inverts the repository's current state, where `main` is the
only branch and holds the work directly.

**Validation**: Protection deleted through the platform UI is restored from the declared
configuration (`SC-007`). Declaring it as code is what makes deletion a temporary condition rather
than a silent permanent loss.

## Release

| Field | Required | Notes |
|---|---|---|
| `tag` | yes | Created by the drafting mechanism, never by the publish operation (`FR-021`) |
| `state` | yes | `draft` → `published`. One direction only |
| `notes` | yes | Accumulated by the drafter from merged pull requests (`FR-018`) |
| `triggered_by` | yes | Surfaced in the run (`FR-023`) |

**State transitions**: `absent → draft → published`. The publish operation performs exactly the
second transition and **refuses** in three cases (`SC-010`):

| Refusal | Condition |
|---|---|
| No draft | No draft produced by the drafting mechanism exists for the tag (`FR-020`) |
| Hand-crafted tag | The tag was not produced by the drafter (`FR-021`) |
| Failing checks | Required checks on the integration branch are not green |

**Validation**: A published release is never rewritten. The publish operation does not create tags,
which is what keeps the tag's provenance attributable to the drafter alone.

## Pinned Input

Every external thing the pipeline consumes (`FR-012`).

| Field | Required | Notes |
|---|---|---|
| `identifier` | yes | Repository, action, or package |
| `version` | yes | A tag or exact version, never a branch or `latest` |
| `scope_of_guarantee` | yes | What the pin does and does not cover |

| Input | Pinned to | Guarantee |
|---|---|---|
| `nolte/gh-plumbing` | `v1.1.26` | **This repository's references only.** The shared workflows call each other with `@develop`, which a consumer cannot override |
| `nolte/vale-style` | `v0.1.17` | Full — a package version |
| Goose | `1.45.0` | Full — an installed version |
| Check toolchain | exact versions in `requirements-ci.txt` | Full |

**Validation**: No definition in this repository contains a floating reference (`SC-013`). The
`scope_of_guarantee` field exists because one input's pin genuinely does not extend transitively, and
recording that is more honest than a table implying otherwise.

## Omission Record

A stage the governing design names that this repository does not run (`FR-030`).

| Field | Required | Notes |
|---|---|---|
| `stage` | yes | The named stage |
| `reason` | yes | Why it does not apply here |
| `revisit_when` | yes | The condition under which the omission stops being correct |

| Stage | Reason | Revisit when |
|---|---|---|
| Package | No build artifact and no dependency manifest for deliverables | The repository ships something installable |
| Documentation delivery | No documentation site | A site is added |
| Full review runs in the gate | Each consumes a subscription and takes minutes (`FR-031`) | A non-interactive provider makes them cheap |
| Transitive pinning | Not controllable by a consumer | `gh-plumbing` pins its internal references |
| Release propagation completing | No portfolio App identity; the default token does not start the run | An App identity becomes available |

**Validation**: For every stage the governing design names, this repository can answer "runs" or
"omitted, because" (`SC-012`). **Silence is not an answer** — an unlisted stage is indistinguishable
from one that was forgotten.

## Relationships

```text
Branch Role ──< required_checks ──> Check Class
     │
     └── integration ──> Release (draft) ──> Release (published) ──> propagation ──> release-presentation

Pinned Input ──> consumed by ──> Check Class and workflow
Omission Record ──> explains absence of ──> Check Class or stage
```

A Check Class never runs outside the task entry point. A Release never reaches `published` without
the integration branch being green. `main` never receives a write except from propagation.
