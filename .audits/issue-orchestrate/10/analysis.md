# Pre-analysis — nolte/claude-goose#10

**Issue**: https://github.com/nolte/claude-goose/issues/10 — "Recipe lifecycle: give recipe requirements an id prefix distinct from baseline criteria"
**Author**: nolte (repository owner — trusted)
**Classification**: `refactor` — renames an id scheme across artifacts without adding a capability; it breaks the artifact format, so the lifecycle version moves.
**Route**: implement directly — one outcome, one PR strand, no roadmap item.
**Branch / worktree**: `fix/recipe-requirement-id-prefix` in `../claude-goose-wt-10`, off `origin/develop` at `c349e34`. The repository has no `task worktree:add`; `git worktree add` was used directly.

## Requirements gate

Operator override, 2026-11-05: no artifact under `project/requirements/` is elicited for this issue. The issue states its own acceptance criteria ("Done when"), and the three open decisions were taken by the operator:

| Decision | Choice |
|---|---|
| Prefix for recipe requirements | `RR-<n>` |
| Existing artifact `baseline-drift-check` | Migrate to the new prefix |
| Lifecycle version | `0.3.0` — a pre-release break raises MINOR; `1.0.0` stays reserved for the first release |

## Measured state

- 50 lines use `R-<n>` / `R-{{n}}` / `R-<m>` for a recipe requirement (established: `grep -rnE '\bR-(\{\{n\}\}|<m>|<n>|[0-9]+\b)' skills/ recipes/ project/recipes/ specs/005-recipe-lifecycle-skills/ | grep -vE 'R-0[0-9]{2}'`).
- The asserted confusion is real (established): `recipes/baseline-drift-check/recipe.yaml:90` reads `# P-8 ← R-1, R-2, R-3, R4, R1, …` — recipe requirements, a generic requirement and a stray `R4` side by side.
- Baseline criteria use three digits, `R-001`…`R-010` (established: `baselines/goose/2026-08-02/ruleset.md`). Published baseline revisions are immutable and are not touched.

## Scope

In: the three skills' templates, bodies and references; the lifecycle contracts and data model under `specs/005-recipe-lifecycle-skills/`; the migrated `baseline-drift-check` artifacts and recipe; `skills/VERSION.md`; the review plan's finding.
Out: baseline revisions (immutable), the generic artifact's `R<n>` (owned by `nolte-shared`), `RESULTS.md` history (a record of past runs, not a format).

## Work packages

| Id | Problem | Acceptance | Files | Specialist | Depends on |
|---|---|---|---|---|---|
| WP-1 | Skills name recipe requirements `R-<n>` | `grep -nE '\bR-[0-9<{]' skills/` matches only baseline criteria (`R-0nn`, `R-xxx`); every recipe requirement is `RR-<n>` | `skills/recipe-*/**`, `skills/VERSION.md` | `nolte-claude-dev:claude-plugin-developer` | — |
| WP-2 | The lifecycle contract and data model define `R-<n>` | Same predicate over `specs/005-recipe-lifecycle-skills/` | `specs/005-…/{contracts/recipe-artifacts.md,data-model.md,quickstart.md,research.md,tasks.md}` | no matching specialised agent — generalist | WP-1 |
| WP-3 | `baseline-drift-check` is written under the old scheme | Artifacts and recipe use `RR-<n>`, carry `lifecycle_version 0.3.0`; `goose run --recipe … --explain` accepts the recipe; the stray `R4` is resolved against the plan | `project/recipes/baseline-drift-check/*`, `recipes/baseline-drift-check/recipe.yaml` | no matching specialised agent — generalist | WP-1 |
| WP-4 | Review plan finding open | `.audits/skill-review/recipe-requirements-elicit.md` finding closed with a `verified:` line | that plan | generalist (`nolte-claude-dev:skill-review` update operation, inline) | WP-1..3 |

## Risks and open questions

- Refuted in WP-3: `R4` in `recipe.yaml:90` is not a stray. The plan's coverage table lists the generic requirement `R4` against P-8 (established: `project/recipes/baseline-drift-check/plan.md:91`). The line mixes three schemes on purpose, which is the confusion this issue removes.
- A recipe requirement table row `RR-1` next to a criterion `R-001` is still two letters apart; the guard is the predicate, run in CI is not established (no hook exists for it).

## Results

- WP-2 (generalist): `RR-<n>` in `contracts/recipe-artifacts.md`, `data-model.md`, `quickstart.md`, `research.md:192`; the contract gains a table of the three id schemes. Research ids `R1`…`R14` and done-task texts in `tasks.md` are a different scheme or a historical record and stay.
- WP-3 (generalist): `R-[1-5]` → `RR-[1-5]` in requirements.md, plan.md and recipe.yaml; lifecycle version 0.1.0 → 0.3.0. `goose run --recipe recipes/baseline-drift-check/recipe.yaml --explain` exits 0 with no `Error:` line (established, run 2026-11-05). Open: the `Teach-back` header that 0.3.0's `validate` requires for a `confirmed` artifact.
