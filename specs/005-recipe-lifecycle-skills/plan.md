# Implementation Plan: Recipe Lifecycle Skills

**Branch**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-recipe-lifecycle-skills/spec.md`

## Summary

Four Claude Code skills, one per phase of a Goose recipe's life, shipped from this repository as the
plugin `nolte-goose`: `recipe-requirements-elicit`, `recipe-plan`, `recipe-implement` and
`recipe-audit`. Each carries only what is specific to Goose recipes and delegates generic work to
the named claude-shared capability that owns it, failing closed when that capability is absent.

Two decisions shape everything else. First, the audit skill **invokes the Claude Code binding**
that feature 004 renders (`bindings/claude-code/run.sh`) and contributes nothing normative, because
a skill that performed the review from `process.md` would be a third, authored binding, the one
kind `invocation-contract.md` obligation 6 forbids (research `R2`). Second, the plugin is rooted at
the repository root so that `process/` and `baselines/` are inside the installed plugin and the audit
needs no copy of either tree (research `R1`).

The duplicate check spec `FR-007` requires was done against every skill and agent description in
claude-shared. One phase delegates to an existing skill (`requirements-elicit`), two have no
delegation target and own their format (planning, implementation), and one delegates to this
repository's own process (audit). The check surfaced a defect upstream: `requirements-elicit` cannot
run in a consumer today, because its methodology spec is neither inheritable nor shipped with a
plugin-root fallback (research `R5`). That blocks the dogfooding run of User Story 2 and is recorded
as a dependency, not worked around by copying the spec.

## Technical Context

**Language/Version**: Markdown skill definitions with YAML frontmatter; two JSON plugin manifests.
No executable code is added by this feature. The recipe produced during dogfooding is Goose YAML.

**Primary Dependencies**: Goose 1.45.0 (`goose run --explain` for the implementation phase; the
audit's subject domain); the Claude Code CLI, measured at 2.1.221 by feature 004, for the audit
binding; the `nolte-shared` plugin at `v0.1.11` for `requirements-elicit`; feature 004's rendered
Claude Code binding. The pinned `pre-commit` toolchain and Vale for the gate. **The plugin acquires
no runtime dependency beyond Goose, the Claude Code CLI and `nolte-shared`**; that set is the
distribution contract.

**Storage**: Files. Lifecycle artifacts under `project/recipes/<slug>/` in the consuming repository;
resume state under `.resume/` per `spec/claude/resumable-work/`.

**Testing**: `task ci` for the static gate, extended so the portability guard scans `skills/`; real
skill runs recorded in `tests/goose-implementation-review/RESULTS.md`; claude-shared's
`scripts/validate_skills.py` as a recorded manual step (research `R8`).

**Target Platform**: Linux and macOS workstations running Claude Code with the plugin installed;
GitHub Actions for the gate.

**Project Type**: Claude Code plugin (skills only, no agents), plus documentation.

**Performance Goals**: The audit adds no time of its own over the binding it invokes; the binding's
`SC-005` budget of feature 001 (15 minutes for the reference fixture) is inherited, not re-measured.

**Constraints**: No rule of the review process is restated in any skill (spec `FR-012`, `SC-004`).
No skill name collides with a claude-shared name (`FR-008`). No repository-specific value under
`skills/` (`FR-027`). `OMISSIONS.md` §Version-bearing files stays true: `plugin.json` has no
`version`. Published baselines remain immutable. Vendored `.specify/` and `.claude/` files are not
edited. All authored material is English.

**Scale/Scope**: Four skills, two manifests, one `skills/README.md` carrying the
delimitation record, one `skills/VERSION.md`, two artifact templates, one question-set reference, one comment convention
reference, one portability-guard extension, one `OMISSIONS.md` entry, and one real recipe through
all four phases.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates resolved from `.specify/memory/constitution.md` v1.0.0.

### Initial check — before Phase 0

| Principle | Verdict | Basis |
|---|---|---|
| **I. Reusable by Construction** | PASS | The skills ship as a plugin, the only distribution path `skill-management` sanctions, and resolve every path from `${CLAUDE_PLUGIN_ROOT}`. Consumer-specific values (slug, recipe path, baseline id) are inputs recorded in artifacts. The portability guard is extended to `skills/` |
| **II. Plans Are Versioned Artifacts** | PASS | Each skill declares its input, its output and its refusal conditions (`contracts/skill-interfaces.md`); the lifecycle has an explicit state machine (`data-model.md`). The lifecycle carries its own semver in `skills/VERSION.md`, independent of the repository tag, in the form the review process already uses (research R14). Per-skill version fields stay forbidden by `skill-management` §Distribution, and `plugin.json` carries no `version` |
| **III. Auditable Revisions** (NON-NEGOTIABLE) | PASS | This feature edits no released plan. The review process is invoked, not changed; `process/` and `baselines/` are untouched. The one repository record that moves — `OMISSIONS.md` — gains an entry rather than losing one |
| **IV. Host-Contract Fidelity** | PASS | The implementation phase validates through `goose run --explain`, the documented parser; the audit reaches Goose material only through the review process. Nothing patches or introspects Goose. The Goose version the plugin requires is stated in both manifests |
| **V. Dogfooding** | PASS | Spec `FR-025` and `FR-026` require one recorded real use per skill and one full lifecycle run before release; research `R11` names the recipe. Two of those runs are blocked on outside work and the plan says so rather than substituting a fixture |
| **VI. Evidence-Backed Claims** (NON-NEGOTIABLE) | PASS | Every delegation target was read, not assumed, and the one that cannot run today is reported as such (`R5`). The nested-invocation question in `R2` is labelled unverified and given a measuring scenario. Cross-host digest agreement is measured (`FR-014`), not asserted |

**No violations. Complexity Tracking is empty.**

One tension is stated rather than left implicit. Two skills (`recipe-plan`, `recipe-implement`) own
their format because no shared capability accepts their input. That is not a violation of the
delimitation: spec `FR-005` delegates work to "the named shared capability that already owns it",
and `FR-007` requires the search to be recorded, which research `R3` does. The upstream proposal
that would let planning delegate later is recorded in the same place, so the boundary can move
without a redesign.

### Post-design re-check — after Phase 1

| Principle | Verdict | What the design added |
|---|---|---|
| **I** | PASS | `contracts/plugin-manifest.md` fixes the plugin root at the repository root so the audit uses the shipped `process/` and `baselines/` trees in place; `quickstart.md` scenario 6 proves the guard covers `skills/` |
| **II** | PASS | `data-model.md` gives every artifact a state (`draft`/`confirmed`, `ready`/`blocked`, `validated`/`rejected`) and names which state is a valid input to the next skill, so a stage's completion is checkable by someone other than its author |
| **III** | PASS | Research `R1` chooses a `plugin.json` without `version` precisely to keep the feature-003 record in `OMISSIONS.md` true instead of silently contradicting it; research `R14` adds `skills/VERSION.md` as the same kind of file `process/` and `baselines/` already carry under that record, so the history of the lifecycle is append-only from its first release |
| **IV** | PASS | `contracts/skill-interfaces.md` binds `recipe-audit` to the invocation contract's five inputs verbatim, with no input of its own, and routes every binding failure through the binding's exit codes rather than around them |
| **V** | PASS | `quickstart.md` scenarios 1, 2, 4 and 5 are the dogfooding evidence, each with a pass condition; scenarios 1 and 2 carry their block conditions rather than a weakened pass |
| **VI** | PASS | `quickstart.md` scenario 8 repeats the second-reader measurement feature 001 used for its `SC-003`, because a delimitation the author judges clear is not evidence that it is. Research `R13` records that the plugin CLI commands the quickstart cites were verified against CLI 2.1.282 rather than assumed |

**Still no violations.** The re-check tightened one thing: `R9` pins the baseline once per lifecycle
in the requirement artifact, closing a gap the spec's assumption stated but no artifact enforced.

## Project Structure

### Documentation (this feature)

```text
specs/005-recipe-lifecycle-skills/
├── plan.md                       # This file
├── research.md                   # Phase 0 — R1..R12 and what stays open
├── data-model.md                 # Phase 1 — artifacts, states, relationships
├── quickstart.md                 # Phase 1 — eight validation scenarios
├── contracts/
│   ├── skill-interfaces.md       # Input, output, delegation and boundary sentence per skill
│   ├── plugin-manifest.md        # The two manifests and the distribution contract
│   └── recipe-artifacts.md       # On-disk form of requirements.md, plan.md, recipe comments
├── checklists/
│   └── requirements.md           # Spec quality checklist (complete)
└── tasks.md                      # Phase 2 — NOT created by /speckit-plan
```

### Source Code (repository root)

```text
.claude-plugin/
├── plugin.json                   # NEW — nolte-goose, no version field
└── marketplace.json              # NEW — one entry, source "."
skills/
├── README.md                     # NEW — distribution contract, delimitation record, prerequisites
├── VERSION.md                    # NEW — lifecycle semver and history (research R14)
├── recipe-requirements-elicit/
│   ├── SKILL.md                  # NEW — delegates to nolte-shared:requirements-elicit
│   ├── templates/recipe-requirements.template.md
│   └── references/recipe-question-set.md
├── recipe-plan/
│   ├── SKILL.md                  # NEW — owns the plan format (no delegation target)
│   └── templates/recipe-plan.template.md
├── recipe-implement/
│   ├── SKILL.md                  # NEW — writes the recipe, validates with goose --explain
│   └── references/traceability-comments.md
└── recipe-audit/
    └── SKILL.md                  # NEW — invokes bindings/claude-code/run.sh, adds nothing

scripts/
└── check-portability.sh          # CHANGED — trees: process, baselines, skills

OMISSIONS.md                      # CHANGED — frontmatter validation is a recorded manual step
README.md                         # CHANGED — Usage gains the plugin install and the four skills
CLAUDE.md                         # CHANGED — the plugin and the lifecycle, one paragraph
tests/goose-implementation-review/
└── RESULTS.md                    # CHANGED — skill runs, the lifecycle run, the SC-003 reading
project/recipes/baseline-drift-check/   # NEW — the dogfooding lifecycle artifacts
project/requirements/baseline-drift-check.md  # NEW — the generic artifact, hand-written or elicited
```

**Structure Decision**: `skills/` is a fourth top-level tree, beside `baselines/`, `process/` and
`tests/`. The existing three are split by rate of change; the skills change with the *phases of
recipe development*, which is a different axis from the process they audit against, so they neither
belong inside `process/` (they are not part of the review) nor inside `tests/`. The plugin manifests
sit where Claude Code requires them. `project/` is the consumer-side convention claude-shared already
uses for `project/requirements/`, and the dogfooding run uses it here for the same reason a
consumer would.

## Dependencies and order

| This feature | Depends on | State on 2026-09-24 |
|---|---|---|
| US1 (`recipe-audit`) | Feature 004 User Story 1: `bindings/claude-code/run.sh` rendered, run for real, recorded (`T016`–`T023`) | Rendered and committed (`T016`–`T018`); no run recorded (`T019`–`T023` open) |
| US2 (`recipe-requirements-elicit`) dogfooding | An upstream claude-shared release in which `requirements-elicit` runs in a consumer (research `R5`), pinned here | Not started |
| US3, US4 | US2's artifact, which may be hand-written for the first run (spec `FR-002`) | Unblocked |

Authoring all four skills is unblocked. The recorded runs that release them are not, for two of the
four, and `tasks.md` must carry the two blocks as explicit tasks with the outside condition named.

## Complexity Tracking

> No Constitution Check violations. This table is intentionally empty.
