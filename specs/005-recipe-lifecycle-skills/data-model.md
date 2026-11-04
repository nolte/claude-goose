# Data Model: Recipe Lifecycle Skills

**Feature**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24

No database. The entities are files, the relationships are which file names which, and the one
invariant that matters is that the chain requirement → plan → recipe → report can be walked in
both directions from the files alone (spec `FR-003`, `SC-005`).

## Target layout

```text
.claude-plugin/
├── plugin.json                      # NEW — name nolte-goose, no version field (research R1)
└── marketplace.json                 # NEW — one entry, source "."
skills/
├── README.md                        # NEW — distribution contract, delimitation record
├── VERSION.md                       # NEW — lifecycle semver and history (research R14)
├── recipe-requirements-elicit/
│   ├── SKILL.md                     # NEW
│   ├── templates/
│   │   └── recipe-requirements.template.md
│   └── references/
│       └── recipe-question-set.md   # the five recipe dimensions and their probes
├── recipe-plan/
│   ├── SKILL.md                     # NEW
│   └── templates/
│       └── recipe-plan.template.md
├── recipe-implement/
│   ├── SKILL.md                     # NEW
│   └── references/
│       └── traceability-comments.md # the comment convention (research R10)
└── recipe-audit/
    └── SKILL.md                     # NEW — invokes the binding, nothing else
project/recipes/<slug>/              # per lifecycle run, in the consuming repository
├── requirements.md                  # recipe requirement artifact
├── plan.md                          # recipe plan
└── review-report.md                 # the audit's output (output_path passed explicitly)
project/requirements/<slug>.md       # written by nolte-shared:requirements-elicit, referenced
<recipe path>/recipe.yaml            # the deliverable; path chosen at planning
```

Everything under `skills/` ships in the plugin. Everything under `project/` is produced in the
consuming repository and never ships. `process/` and `baselines/` are untouched by this feature;
the audit reaches them through the installed plugin's root.

## Entities

### Lifecycle version

`skills/VERSION.md`. The semver of the four-phase lifecycle as a plan, independent of the repository
tag and of the review process version (Constitution II, research `R14`).

| Attribute | Rule |
|---|---|
| Value | `0.1.0` until every skill has a recorded real run; `1.0.0` when spec `FR-025` and `FR-026` hold |
| History | Append-only table of version, date, change |
| Recorded in | Every lifecycle artifact, as `lifecycle_version` |

### Phase skill

One of the four. Owns one phase, consumes one input artifact, produces one output artifact.

| Attribute | Rule |
|---|---|
| `name` | `recipe-<action>`; folder name, frontmatter `name` and slash command identical |
| `description` | Third person; names the trigger, the delegated shared capability and what this skill adds (spec `FR-006`); ≤1024 characters |
| `phase` | `plan` for requirements and planning, `build` for implementation, `review` for audit |
| `tags` | From the starter vocabulary: `requirements`, `planning`, `implementation`, `review` respectively, plus `goose` as the cluster tag |
| Delegates to | Zero or one shared capability, named by namespaced skill name |
| Rationale section | `## Why this is a skill, not an agent`, exact heading |
| `resumable` | `true` for the requirements skill (it spans the delegated interview plus its own); the others complete in one approval span |

**Validation**: `scripts/validate_skills.py` at the pinned claude-shared release reports no
`Critical` finding (research `R8`). The portability guard finds nothing under `skills/`.

### Recipe requirement artifact

`project/recipes/<slug>/requirements.md`. What the recipe must do, stated so a stranger can build
from it.

| Section | Content | Source |
|---|---|---|
| Header | `slug`, `baseline_revision` (a concrete id, never `latest`), `lifecycle_version`, `review_process_version`, date | Resolved once here (research `R9`, `R14`) |
| Generic artifact | Path of `project/requirements/<slug>.md` | Written by `requirements-elicit` |
| Recipe profile | Purpose; inputs (name, required or optional, carries a default, imports a file); host capabilities needed; execution mode (`interactive`, `headless`, `both`); output shape; prohibited behaviour | The recipe question set |
| Baseline check | For each captured input or property: the criterion it would violate by construction, if any; every declared gap of the pinned revision that applies | `ruleset.md` and `coverage.md` of the pinned revision |
| Open points | Everything the author could not answer | Never a guessed value (spec `FR-017`) |

**Validation**: the generic artifact exists at the named path; `baseline_revision` names an
existing directory under `baselines/goose/`; every input has all four attributes; the baseline check
section is present even when empty ("none" is a claim, silence is not).

**State**: `draft` while open points exist and the author has not confirmed; `confirmed` once the
author has confirmed the recipe profile in a teach-back. Only a `confirmed` artifact is a valid
input to `recipe-plan`; a `draft` one makes `recipe-plan` stop and name the open points.

### Recipe plan

`project/recipes/<slug>/plan.md`. The mapping from requirements to recipe elements and back.

| Section | Content |
|---|---|
| Header | `slug`, `baseline_revision`, `lifecycle_version` and `review_process_version` carried from the requirement artifact, the recipe's target path |
| Elements | One row per planned recipe element: `id` (`P-<n>`), the recipe field or entry it becomes, the requirement ids it serves, its decided value or shape |
| Coverage | Every requirement id from the requirement artifact with the element ids that serve it; a requirement with none, or an element with none, is a defect (spec `FR-018`) |
| Criteria | Every criterion of the pinned revision that applies to the planned recipe, each marked `by construction` with the element that satisfies it, or `risk` with the reason (spec `FR-019`) |
| Conflicts | Requirements that cannot be realised within the documented rules, each with the rule it collides with, returned to the author (spec `FR-020`) |

**Validation**: coverage is total in both directions; every criterion in the pinned `ruleset.md`
appears in the criteria table exactly once; a plan with a non-empty conflicts section is `blocked`,
not an input to `recipe-implement`.

**State**: `blocked` while conflicts are open; `ready` when coverage is total and conflicts are
empty.

### Recipe

The deliverable: the recipe definition and the extension configurations it declares, at the path
the plan names.

| Attribute | Rule |
|---|---|
| Elements | Only what the plan lists; an element without a `P-<n>` comment is a defect (spec `FR-021`) |
| Traceability | A YAML comment on each top-level element, parameter and extension entry: `# P-<n> ← R-<m>` (research `R10`) |
| Host validation | `goose run --recipe <file> --explain` accepts it before it is reported done (spec `FR-022`) |
| Provenance | A leading comment block naming `slug`, `baseline_revision`, `lifecycle_version` and `review_process_version` (spec `FR-024`) |

**State**: `rejected` (parser error, reported verbatim) or `validated`. Only `validated` is an input
to `recipe-audit` within a lifecycle.

### Review report

Unchanged by this feature. Produced by the review process through the Claude Code binding; carries
`Host: claude-code`. Within a lifecycle its `output_path` is `project/recipes/<slug>/review-report.md`
and its `baseline_revision` is the pinned id; standalone, both are the contract defaults.

### Delimitation record

One table, in `skills/README.md`, with one row per skill: the shared capability delegated to,
what the skill adds, and the result of the duplicate check (research `R3`). This is the record
spec `FR-007` requires and the reader test `SC-003` is run against.

## Relationships

```text
project/requirements/<slug>.md  ◄── referenced by ── requirements.md
requirements.md  ── R-<m> ids ──►  plan.md  ── P-<n> ids ──►  recipe.yaml
recipe.yaml  ── subject_path ──►  review-report.md
requirements.md.baseline_revision == plan.md.baseline_revision == recipe.yaml provenance
                                  == review-report.md digest baseline=
requirements.md.lifecycle_version == plan.md.lifecycle_version == recipe.yaml provenance
                                  == skills/VERSION.md at the time of the run
```

No arrow points from a skill into `process/` or `baselines/` except the audit's invocation of the
binding, and none points from any of those trees back into a skill.

## Lifecycle state machine

```text
(none) ──recipe-requirements-elicit──► requirements.md[draft]
requirements.md[draft] ──author confirms──► requirements.md[confirmed]
requirements.md[confirmed] ──recipe-plan──► plan.md[ready] | plan.md[blocked]
plan.md[blocked] ──author decides──► requirements.md[draft]   (a conflict reopens the requirement)
plan.md[ready] ──recipe-implement──► recipe.yaml[validated] | recipe.yaml[rejected]
recipe.yaml[rejected] ──fix──► recipe-implement again
recipe.yaml[validated] ──recipe-audit──► review-report.md
review-report.md with a deviation ──author decides──► plan.md or requirements.md, never recipe.yaml alone
```

The last transition is the one that keeps `SC-005` true after a finding: a deviation is repaired
at the level whose decision caused it, so the traceability chain is not silently broken by editing
the recipe in place.
