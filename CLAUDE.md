# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

`claude-goose` integrates Claude Code as a provider into [Goose](https://github.com/block/goose),
and on top of that ships **reusable, revision-safe multi-stage implementation plans**. It is part
library, part agent integration, developed in the open and used by its own author first.

The governing rules live in `.specify/memory/constitution.md` (v1.0.0, ratified 2026-07-31). Its
six principles are the gate every `plan.md` is checked against, so read it before planning work:
reusability by construction, plans as versioned artifacts, auditable revisions, host-contract
fidelity toward Goose's documented provider interface, dogfooding, and evidence-backed claims.
Principles III and VI are marked NON-NEGOTIABLE.

## The review process (shipped, v1.0.0)

The first feature is built and running. Three top-level trees, split by rate of change:

```
baselines/                    MAINTENANCE.md, VERSION.md, SOURCE-FORMAT.md — the upkeep procedure
baselines/goose/<revision>/   criteria, sources, coverage, criterion format, verification log
process/goose-implementation-review/   the method: process.md, recipe.yaml, report-template.md, VERSION.md
tests/goose-implementation-review/     fixtures, golden files, RESULTS.md, PORTABILITY.md
```

Current revisions: `2026-07-31`, `2026-07-31b`, `2026-08-01`, `2026-08-02` (latest). **Published
revisions are immutable** — the only permitted edit is appending to `verification.md`. Corrections
create a successor. Before publishing one, prove the predecessors are untouched:

```sh
git diff --quiet HEAD -- baselines/goose/<earlier revision>/ || echo "IMMUTABILITY VIOLATION"
```

**Check a source for drift** (`baselines/MAINTENANCE.md` has the full procedure):

```sh
gh api "repos/aaif-goose/goose/commits?path=documentation/docs/<path>.md&per_page=1" --jq '.[0].sha'
```

Compare against the record's `source_commit`. **Never use `ETag` or `Last-Modified`** — they track
site deploys, not content, and would flag every statement on every rebuild.

**Run a review:**

```sh
GOOSE_PROVIDER=claude-acp GOOSE_MODEL=default \
  goose run --no-session --recipe process/goose-implementation-review/recipe.yaml \
    --params subject_path=<path> \
    --params baseline_revision=2026-07-31b \
    --params output_path=./review-report.md
```

Optional: `compare_to=<prior report>` for a delta, `max_bytes_per_pass=<n>` to force partial
coverage. Requires Goose 1.45.0 and `claude-agent-acp`.

**Validate without an LLM call**: `goose run --recipe <file> --explain` runs Goose's real parser.
This is how five of the ten baseline criteria are decided, and it costs nothing.

**Before changing anything here, read `tests/goose-implementation-review/RESULTS.md`.** It records
twelve findings from real runs, several of which contradict what the documentation implies. Three
recur often enough to state up front:

- **A constraint belongs in the recipe's `prompt`, not only in `instructions`** (O-12). Two separate
  parameters were silently ignored when specified only in `instructions`, verbatim and correctly
  rendered. Naming them in `prompt` fixed both on the first attempt.
- **`input_type: file` reads the file and substitutes its contents** (O-6). It is not a path handle.
  That is why file parameters may not carry defaults — a default inlines whatever it points at.
- **Reproducibility is checked on the `DIGEST v1` block, never on whole reports** (O-11). Prose
  varies harmlessly between runs; the digest must not.
- **A revision is checked against its own `criterion-format.md`**, never a later one. That file
  travels inside each revision precisely so old revisions stay interpretable; applying a newer schema
  reports false defects.

## Repository state

Feature 002 (`qa-documentation-base`) is specified but not implemented — it is what grows the
baseline beyond its current ten criteria. Beyond the three trees above there is no other product
code: no README, no dependency manifest, no compiled language. The Spec Kit scaffold
(`.claude/skills/`, `.specify/`) drives the workflow described below.

Consequences for any work here:

- **There is no build or lint step.** The deliverables are Markdown and YAML. Verification is: `goose run --explain` for parse-level checks, and full review runs reconciled against golden files under `tests/goose-implementation-review/expected/`.
- **Verify a change to the process by re-running the self-review** — the process reviewing its own directory. It must produce no findings. This is a release condition from Constitution Principle V, not a nicety.
- The constitution **is** ratified (v1.0.0), so the *Constitution Check* gate in every `plan.md` is live rather than vacuous. `plan-template.md:43` resolves its gates from that file at runtime; do not hard-code them into the template.
- Two known template inconsistencies are recorded in the constitution's Sync Impact Report: `spec-template.md:3` says "Feature Branch" although state is not branch-derived, and `tasks-template.md:12` calls tests OPTIONAL where Principle III requires a verification step per stage. Both are upstream-owned — fix via `.specify/templates/overrides/` if they bite.

## The SDD workflow

Work here flows through Spec Kit's spec-driven development pipeline, driven by the ten skills in `.claude/skills/speckit-*`. Because `.specify/integration.json` sets `invoke_separator: "-"`, commands are invoked as `/speckit-plan`, **not** `/speckit.plan`.

```
/speckit-constitution   → .specify/memory/constitution.md   (project principles; do this first)
/speckit-specify        → specs/NNN-slug/spec.md            (creates the feature directory)
/speckit-clarify        → resolves [NEEDS CLARIFICATION] markers in spec.md
/speckit-plan           → plan.md (+ research.md, data-model.md, quickstart.md, contracts/)
/speckit-tasks          → tasks.md
/speckit-analyze        → read-only consistency check across spec/plan/tasks
/speckit-implement      → executes tasks.md
```

Supporting commands: `/speckit-checklist` (domain-specific quality checklist), `/speckit-converge` (diff codebase against spec/plan/tasks, append the unbuilt remainder to `tasks.md`), `/speckit-taskstoissues` (tasks → GitHub issues).

`.specify/workflows/speckit/workflow.yml` bundles specify → plan → tasks → implement with `type: gate` approval steps after spec and after plan; rejecting a gate aborts the run.

Feature artifacts live in `specs/<NNN>-<short-name>/` (three-digit sequential prefix, per `init-options.json: feature_numbering: sequential`). Two exist: `001-goose-implementation-review` (built) and `002-qa-documentation-base` (specified only).

## Feature state is not derived from the git branch

This is the single most surprising part of the setup, and it differs from older Spec Kit versions. `.specify/scripts/bash/common.sh` resolves the "current feature" from explicit state only:

1. `SPECIFY_FEATURE_DIRECTORY` (env var, wins over everything)
2. `.specify/feature.json` → `feature_directory` key, written by `create-new-feature.sh` and by `get_feature_paths()`
3. Otherwise: **hard error**, not a fallback

`get_current_branch()` returns `$SPECIFY_FEATURE` or the empty string — it never shells out to git. With no branch context, `CURRENT_BRANCH` falls back to the feature directory's basename. Likewise, the repo root comes from `SPECIFY_INIT_DIR` or an upward search for `.specify/`, never from `git rev-parse`.

Practical upshot: switching git branches does **not** switch the active feature. `.specify/feature.json` does. Note that `get_feature_paths()` *writes* that file as a side effect unless called with `--no-persist` (which `check-prerequisites.sh --paths-only` does).

## Script contract

The skills never touch `specs/` paths directly — they shell out to `.specify/scripts/bash/` and parse the JSON. Keep that indirection when editing skills; run these from the repo root:

| Script | Used by | Notes |
| --- | --- | --- |
| `create-new-feature.sh [--json] <description>` | `/speckit-specify` | Allocates the next number, creates `specs/NNN-slug/spec.md` from the template, persists `feature.json`. Flags: `--short-name`, `--number` (a *preference* — auto-bumped on collision), `--timestamp`, `--dry-run`, `--allow-existing-branch`. |
| `setup-plan.sh --json` | `/speckit-plan` | Seeds `plan.md`; idempotent (skips if present). |
| `setup-tasks.sh --json` | `/speckit-tasks` | Hard-fails if `plan.md` or `spec.md` is missing. Returns the resolved `TASKS_TEMPLATE` path. |
| `check-prerequisites.sh --json [--require-tasks] [--include-tasks] [--paths-only]` | analyze, implement, clarify, checklist, taskstoissues | `--paths-only` is pure resolution with no validation and no write. |

All emit `AVAILABLE_DOCS` — the subset of `research.md`, `data-model.md`, `contracts/`, `quickstart.md` that actually exists. Path variables are `printf '%q'`-quoted for safe `eval`.

## Template override stack

`resolve_template()` / `resolve_template_content()` in `common.sh` search four layers, highest priority first:

1. `.specify/templates/overrides/<name>.md`
2. `.specify/presets/<preset-id>/templates/` (ordered by `priority` in `.specify/presets/.registry`)
3. `.specify/extensions/<ext-id>/templates/`
4. `.specify/templates/<name>.md` (core)

**To customize a template, add an override — never edit the core file** (see below). Presets may declare a composition `strategy` in `preset.yml` (`replace` | `prepend` | `append` | `wrap` with a `{CORE_TEMPLATE}` placeholder); everything else composes as `replace`. Only `presets/` and `extensions/` exist as concepts here — neither directory is present yet.

## Managed files — do not hand-edit

`.specify/integrations/claude.manifest.json` and `speckit.manifest.json` hold SHA256 hashes of every file under `.claude/skills/speckit-*/SKILL.md`, `.specify/scripts/bash/`, and `.specify/templates/`. Those files are vendored by the `specify` CLI; local edits drift from the manifest and are overwritten on upgrade. Customize through `.specify/templates/overrides/` instead, or through project-local skills that do not carry the `speckit-` prefix.

## Conventions carried by the templates

- **spec.md** is written for non-technical stakeholders: no stack, no APIs, no code. Unknowns are marked inline as `[NEEDS CLARIFICATION: ...]` and resolved by `/speckit-clarify` before planning. Mandatory sections: User Scenarios & Testing, Requirements (`FR-NNN`), Success Criteria (technology-agnostic and measurable).
- **tasks.md** is organized by **user story**, not by layer: Setup → Foundational (blocking) → one phase per user story in priority order (`P1` is the MVP) → Polish. Task IDs are `T001…`, `[P]` marks tasks that are parallelizable because they touch different files, `[US1]` tags story membership. Each user-story phase must be independently completable and testable.
- **plan.md** has a Constitution Check gate; violations that cannot be removed go in the Complexity Tracking table with a justification.
