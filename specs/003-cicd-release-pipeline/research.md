# Phase 0 Research: CI/CD and Release Pipeline

**Feature**: `003-cicd-release-pipeline`
**Consulted**: 2026-07-31

Every external dependency the spec's Assumptions section names was checked for existence rather than
assumed. Two assumptions turned out to be stale, and one shared workflow cannot be used as-is.

---

## Finding 0: The remote now exists — one assumption is already overtaken

| | |
|---|---|
| **Decision** | Treat the remote as present. Creating it is no longer in scope; creating `develop` still is. |
| **Evidence** | observed 2026-07-31 |

The spec states "The repository has no remote today". It does now:
`git@github.com:nolte/claude-goose.git`.

Remote branch state:

| Branch | Present | Note |
|---|---|---|
| `main` | yes, at `784c1e1` | Currently the default and the only branch |
| `develop` | **no** | The spec makes it the integration branch that all work targets |

**Consequence**: the branch-role work of US2 begins by creating `develop` from the current `main` and
switching the default, not by creating a repository. One local commit is also unpushed.

---

## Finding 1: The shared workflow repository exists and is tagged

| | |
|---|---|
| **Decision** | Pin every consumed workflow to `nolte/gh-plumbing@v1.1.26`. |
| **Evidence** | authoritative — GitHub API, 2026-07-31 |

| | |
|---|---|
| Repository | `nolte/gh-plumbing`, public, default branch `develop` |
| Latest release | **`v1.1.26`** |
| Last pushed | 2026-07-22 |

Reusable workflows relevant here, all present:

| Workflow | Serves |
|---|---|
| `reusable-pre-commit.yaml` | The static gate (FR-001 … FR-006) |
| `release-drafter.yml` | Draft accumulation (FR-018) |
| `release-publish.yml` | Draft → Published (FR-019 … FR-023) |
| `release-cd-refresh-master.yml` | Release propagation (FR-024) |
| `automerge.yaml`, `reusable-automerge.yaml` | Merge automation (FR-016) |
| `reusable-dependency-review.yaml` | Supply chain (FR-029) |

`nolte/vale-style` also exists (public, latest `v0.1.17`), satisfying the assumption that prose rules
are consumed rather than authored here.

---

## Finding 2: `build-static-tests.yaml` must not be consumed as a whole

| | |
|---|---|
| **Decision** | Consume the individual `reusable-*` workflows, not the aggregate `build-static-tests.yaml`. |
| **Evidence** | authoritative — the workflow's own definition, read 2026-07-31 |

The aggregate calls four children:

```yaml
static:      reusable-pre-commit.yaml
docs:        reusable-mkdocs-build.yaml
security:    reusable-trivy.yaml
chain-bench: reusable-chain-bench.yaml
```

**Two of these do not apply to this repository.** The spec's own Assumptions record that there is no
documentation site and no shipped build artifact, so `reusable-mkdocs-build.yaml` would run against
a `mkdocs.yml` that does not exist.

Consuming the aggregate would therefore either fail on an inapplicable job or force this repository
to grow a documentation site it does not want — the tail wagging the dog. Calling the children
directly keeps `FR-028` (consume shared mechanics) satisfied while `FR-030` (declare omitted stages)
records why two are absent.

**Alternatives considered**: consuming the aggregate and adding a stub `mkdocs.yml`. Rejected —
inventing an artifact to satisfy a check inverts the relationship between the repository and its
pipeline.

---

## Finding 3: A pinned reference does not pin the transitive graph

| | |
|---|---|
| **Decision** | Pin what this repository controls, and record the limit rather than claiming full pinning. |
| **Evidence** | authoritative — the shared workflows' own definitions |

`SC-013` requires that no pipeline definition contain a floating reference. This repository can
satisfy that for **its own** references:

```yaml
uses: nolte/gh-plumbing/.github/workflows/reusable-pre-commit.yaml@v1.1.26
```

But the shared workflows call each other with `@develop`:

```yaml
jobs:
  static:
    uses: nolte/gh-plumbing/.github/workflows/reusable-pre-commit.yaml@develop
  publish:
    uses: nolte/gh-plumbing/.github/workflows/reusable-release-publish.yml@develop
```

**A consumer cannot pin what a shared workflow calls internally.** Pinning the outer reference to a
tag freezes *that file* as of the tag; whether GitHub then resolves its inner `@develop` at the
tagged state or at the branch tip is a property of the platform and the shared repository, not of
this one.

Consequences to accept:

1. `SC-013` is satisfiable **for this repository's definitions**, which is what it can control.
2. Reproducibility (`FR-011`, `SC-003`) holds against a fixed shared-repository state, not
   unconditionally.
3. The honest response is to state this in the omissions record (`FR-030`) rather than assert a
   pinning guarantee the setup cannot deliver. Fixing it properly is a change to `gh-plumbing`,
   outside this feature.

**Alternatives considered**: vendoring the shared workflows into this repository to control the whole
graph. Rejected — it directly contradicts `FR-028` and the project's reuse-over-copying rule, and
would fork mechanics that exist to be shared.

---

## Finding 4: The publish workflow already provides the refusal and dry-run behaviour

| | |
|---|---|
| **Decision** | Consume `release-publish.yml` rather than implementing publication here. |
| **Evidence** | authoritative — the workflow's inputs, read 2026-07-31 |

```yaml
on:
  workflow_dispatch:
    inputs:
      tag:      { required: true,  type: string }
      dry_run:  { required: false, type: boolean, default: false }
```

It is `workflow_dispatch`-only, which satisfies `FR-019` (a deliberately triggered transition), and
its `dry_run` input satisfies `FR-022` (validation-only mode) without new work here.

It passes `app-id: ${{ vars.PORTFOLIO_APP_ID }}` and `auto-align: true`. The spec's Assumptions
already record that no portfolio App identity is available, so the release event will be emitted
under the default token and will **not** start the propagation run. `FR-024` requires that resulting
incompleteness to be visible — the omissions record is where it becomes visible.

---

## Open questions

| Question | Status |
|---|---|
| Does `reusable-pre-commit.yaml` accept inputs for which hooks to run, or is it driven entirely by `.pre-commit-config.yaml`? | **Unverified.** Its input contract was not read in full; the repository will supply a pre-commit config either way |
| Which Vale package name does `nolte/vale-style@v0.1.17` publish, and how is it referenced? | **Unverified.** Needed when the Vale config is written, not for planning |
| Does the platform resolve a tagged workflow's inner `@develop` at the tag or at the branch tip? | **Unverified**, and the answer changes only how strongly Finding 3 must be worded, not the decision |

None blocks planning; all three are recorded so a later reader knows they were not silently assumed.

## Sources

- `repos/nolte/gh-plumbing` — API metadata, release list, workflow contents, 2026-07-31 — authoritative
- `repos/nolte/vale-style` — API metadata, latest release, 2026-07-31 — authoritative
- `git ls-remote origin` — remote branch state, 2026-07-31 — observed
