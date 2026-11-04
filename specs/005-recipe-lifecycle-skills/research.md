# Research: Recipe Lifecycle Skills

**Feature**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24

Phase 0 output. Every decision below was taken against material read in this repository or in the
`nolte/claude-shared` working copy at `/home/nolte/repos/github/claude-shared` (plugin release
`v0.1.11`). Where something was not verified, it says so.

---

## R1 — Where the skills live and how they ship

**Decision**: This repository becomes a Claude Code plugin named `nolte-goose`, declared by
`.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` at the repository root, with the
four skills under `skills/<name>/`. The plugin source is the repository root, not a subdirectory.

**Rationale**: Three facts decide it.

1. `spec/claude/skill-management/` §Distribution (claude-shared) forbids distributing a skill by
   copying it into a consumer's `.claude/skills/`; the plugin mechanism is the only sanctioned path.
   Constitution Principle I demands reuse in a foreign repository, so the plugin is the mechanism
   here too.
2. `spec/claude/plugin-scoping/` accepts exactly one justification for a separate plugin: a different
   distribution contract. These skills require Goose and serve only consumers who write Goose
   recipes. That is the enumerated case "a different runtime or dependency requirement that not all
   consumers can satisfy". Topic alone would not justify it, and the spec says so.
3. The audit skill needs `process/` and `baselines/` at run time. With the plugin rooted at the
   repository root, both trees sit inside the installed plugin at `${CLAUDE_PLUGIN_ROOT}/process/`
   and `${CLAUDE_PLUGIN_ROOT}/baselines/`, exactly the side-by-side layout
   `bindings/claude-code/run.sh` already derives its tree root from. A plugin rooted in a
   subdirectory would have to copy those trees, and a copy is what feature 004 spent its release
   removing.

**Name**: `nolte-goose`, following `nolte-shared`, `nolte-engineering`, `nolte-planning`,
`nolte-media`, `nolte-claude-dev`. The reserved-token rule in `skill-management` bans `claude` and
`anthropic` in a *skill* `name` only; it does not reach the plugin name, but `claude-goose` as a
namespace would read as a first-party artifact and is avoided for that reason.

**Alternatives considered**:

- *Project-local skills under `.claude/skills/`* — rejected: not installable elsewhere, and the
  manifest-integrity class treats that directory as vendored territory.
- *Contribute the skills to `claude-shared` as `plugins/nolte-goose/`* — rejected: that plugin
  would not contain `process/` and `baselines/`, and the review process would then have to be
  released twice, once here and once there. The distribution contract also differs from every plugin
  claude-shared ships: none of them requires a third-party agent host.

**Consequence for feature 003**: `OMISSIONS.md` §Version-bearing files records that the repository
has none. `plugin.json` is written **without** a `version` field so that record stays true; the
`version` field is optional in the plugin manifest (claude-shared's own manifests carry one because
its release workflow aligns it, a mechanism this repository has deliberately not adopted). A consumer
pins the plugin by git tag when adding the marketplace. If that proves insufficient, the fix is to
adopt version-bearing-file alignment as a change to feature 003, not to hand-edit a version.

## R2 — The audit skill is a thin invoker of the Claude Code binding

**Decision**: `recipe-audit` invokes `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/bindings/claude-code/run.sh`
with the five contract inputs passed through as its long options, waits for it, and returns the
report path. It carries no review logic, no constraint text, and no prompt of its own.

**Rationale**: `invocation-contract.md` obligation 6 says a binding "is generated, not authored", and
`render-bindings.sh --check` is what makes obligation 5 ("states no rule of its own") mechanical. A
skill that loaded `process.md` and performed the review in-session would be a *third* binding, and an
authored one: its `SKILL.md` would have to carry the constraints at the point of invocation (the
`O-12` measurement in `RESULTS.md` says presence in background material is not enough), and nothing
would re-render and compare it. Invoking the generated binding keeps the skill on the right side of
`FR-011` and `FR-012` by construction, and makes `FR-014` (digest comparable with the Goose binding)
a property of the binding, already owed by feature 004, rather than a new promise.

**What is not verified**: whether `claude --print` started from inside a Claude Code session, via the
Bash tool, completes under this repository's permission mode. `run.sh` sets `--permission-mode
dontAsk` and a narrow `--allowedTools` list, so the inner run asks nothing, but a nested invocation
has not been measured. Quickstart scenario 1 measures it. If it fails, the fallback is to render a
skill-shaped binding through the same renderer, which stays conformant because it is generated; that
fallback is designed only if the measurement forces it.

**Alternatives considered**:

- *Perform the review in-session from `process.md`* — rejected above: an authored binding.
- *Re-implement the criteria in the skill* — rejected: `C-4` in `constraints.md` and spec `FR-011`.

## R3 — What each phase delegates, and what it found in claude-shared

`FR-007` requires the duplicate check to be recorded. Every `description` line of the skills and
agents under `skills/`, `agents/` and `plugins/*/` in claude-shared was read. Result per phase:

| Phase | Equivalent or near-equivalent found | Decision |
|---|---|---|
| Requirements | `nolte-shared:requirements-elicit` — the interview method, the eight-dimension gap matrix, the KPI gate, the artifact at `project/requirements/<slug>.md` | **Delegate.** The recipe skill adds a recipe question set and a recipe requirement artifact that references the generic one (`R4`) |
| Planning | `nolte-engineering:implementation-plan-author` accepts only a GitHub issue plus its elicited artifact, or an audit or review report; `nolte-planning:feature-decompose` takes a roadmap item. Neither accepts a bare requirement artifact | **No delegation target exists.** The recipe plan skill owns its plan format. The *shape* of a work package (id, statement, acceptance, dependencies) is borrowed from `implementation-plan-author`'s output contract so a future delegation is a drop-in. An upstream proposal is recorded: let `implementation-plan-author` accept a requirement artifact without an issue |
| Implementation | `nolte-engineering:fullstack-developer` implements code against a detected stack; nothing authors a Goose recipe. `nolte-shared:pull-request-create` owns the PR flow | **No authoring delegation.** Validation delegates to the host's own parser (`goose run --recipe <file> --explain`, the mechanism `scripts/check-recipe-parse.sh` uses). PR creation, when the operator wants it, is `pull-request-create` and is outside the phase |
| Audit | The review process in this repository, through its Claude Code binding | **Delegate to the binding** (`R2`). No claude-shared artifact reviews Goose material |

The boundary sentence each skill carries in its `description` (spec `FR-006`) is fixed in
`contracts/skill-interfaces.md`.

## R4 — The recipe requirement artifact is a second file, not an edit of the first

**Decision**: `recipe-requirements-elicit` first invokes `requirements-elicit`, which writes
`project/requirements/<slug>.md` as it always does. The recipe skill then runs its own interactive
question set for the five recipe dimensions and writes `project/recipes/<slug>/requirements.md`,
which names the generic artifact by path and adds the recipe profile and the baseline check.

**Rationale**: Editing another skill's artifact would blur ownership: `requirements-elicit`'s
`validate` operation checks its own template, and a foreign section would either fail that check or
have to be special-cased upstream. Two files with one reference keep every artifact checkable by
the skill that wrote it, which is also what makes `FR-002` hold — an author who hand-writes the
generic artifact can still run the recipe skill on it.

**Alternatives considered**: *one merged artifact* — rejected for the ownership reason above;
*no generic artifact, recipe questions only* — rejected: it would re-implement the interview, the
duplicate `FR-005` forbids.

## R5 — `requirements-elicit` cannot run in a consumer today, and the fix is upstream

**Finding**: `requirements-elicit` §Precondition stops unless
`spec/project/requirements-elicitation/<canonical_language>.md` is "reachable in the current
project". Unlike `github-issue-templates-apply`, `docs-dry-refactor`, `mermaid-diagrams-apply` and
`docs-audience-tracks-apply`, it has no `${CLAUDE_PLUGIN_ROOT}/spec/...` fallback. And the spec's
canonical file carries no `Portfolio-Scope: portfolio` header, so under
`spec/project/portfolio-inherited-spec-layer/` it is `local` and **not inheritable**. That layer also
forbids copying a hub spec into a consumer's tree.

This repository has no `spec/` tree at all. So today, User Story 2 cannot be dogfooded here, or in
any consumer, through the sanctioned path.

**Decision**: Treat it as an upstream defect with two candidate fixes, either sufficient: add the
plugin-root fallback to `requirements-elicit`'s precondition, as its four sibling skills already have;
or mark the spec `Portfolio-Scope: portfolio`. The recipe skill is written against the fixed
behaviour. Its dogfooding run (spec `FR-025`, US2) is **blocked** until one fix ships in a
claude-shared release and this repository pins that release. The block is recorded in the plan and
in `tasks.md`, not worked around by a local copy.

**Alternatives considered**: *vendor the spec locally* — rejected: forbidden by the inherited-spec
layer and precisely the drift it exists to prevent; *have the recipe skill improvise the method* —
rejected: `requirements-elicit` itself says "do not improvise a replacement", and `FR-009` here
says the same.

## R6 — Fail-closed detection of a missing shared capability

**Decision**: Each delegating skill invokes the shared capability by its namespaced name
(`Skill(skill="nolte-shared:requirements-elicit")`). If the invocation is refused because the name is
unknown, the skill stops and reports: the missing plugin, its minimum release, and the marketplace to
install it from. It does not proceed, and it does not try an un-namespaced name.

**Rationale**: `FR-009` and `SC-006`. Claude Code exposes installed skills by namespaced name, so an
unknown name is the reliable signal. Probing the filesystem for the plugin would couple the skill to
the host's install layout, which `skill-management` §Runtime discovery forbids assuming.

## R7 — Names

**Decision**: `recipe-requirements-elicit`, `recipe-plan`, `recipe-implement`, `recipe-audit`.

**Rationale**: `spec/claude/skill-agent-naming/` requires `<object-noun>-<action>` with the trailing
token a finite verb or verb-derived action noun. The object is the recipe in every case. None of the
four names exists in any claude-shared plugin (checked against every `skills/` listing; the nearest
neighbours are `roadmap-plan` and `sprint-plan`, different objects). None contains a reserved token.
`recipe-requirements-elicit` mirrors the shared skill it delegates to, which is deliberate: a reader
sees the delegation in the name.

## R8 — Frontmatter validation without a new dependency

**Finding**: claude-shared's `scripts/validate_skills.py` checks the frontmatter rules the skills must
satisfy (name form, description length and person, `phase` vocabulary, tags). It takes a target
path, depends only on the standard library, but claude-shared exposes no `.pre-commit-hooks.yaml`,
so it cannot be pinned as a pre-commit hook the way every other class here is.

**Decision**: Do not vendor the script and do not write a second validator. Run it as a recorded
release step from a claude-shared checkout at the pinned release (quickstart scenario 7), and record
the absence of a gate class in `OMISSIONS.md` with the revisit condition "claude-shared publishes a
pre-commit hook for its validator". An upstream proposal to add `.pre-commit-hooks.yaml` is recorded
alongside the `R5` one.

**Alternatives considered**: *vendor the script* — rejected: drift, the same defect class the
manifest-integrity class exists to catch; *a local minimal validator* — rejected: a duplicate of a
capability claude-shared owns.

## R9 — Baseline pinning across the lifecycle

**Decision**: The baseline revision is resolved once, when the recipe requirement artifact is
written, and recorded there as a concrete id. `recipe-plan` and `recipe-implement` read it from
their input artifact and carry it forward; `recipe-audit`, when invoked as the last step of a
lifecycle, is passed that id explicitly. Only an operator invoking `recipe-audit` standalone gets
the contract default `latest`.

**Rationale**: `C-1` for the review; `SC-001` for the lifecycle — a recipe planned against one
revision and audited against a newer one would fail its first audit for reasons the plan never saw.

## R10 — Traceability inside the recipe

**Decision**: Each top-level recipe element and each parameter or extension entry carries a YAML
comment naming the plan element it realises (`# P-3 ← R-2`). The plan is the index from element id
to requirement id.

**Rationale**: `FR-023` without a second file. Goose ignores comments, so no criterion is affected;
the reference fixture in `tests/goose-implementation-review/fixtures/reference-recipe/recipe.yaml`
already carries explanatory comments and parses.

## R11 — Dogfooding target

**Decision**: The first recipe through all four phases is a **baseline drift check**: given a
revision id, compare each `source_commit` in that revision's `sources.md` with the current commit of
the same upstream file, and print the rows to append to `verification.md`. It is Stage 2 of
`baselines/MAINTENANCE.md`, today a procedure performed by hand, and it is the kind of headless,
parameterised, shell-using recipe the baseline criteria were written for.

**Rationale**: Constitution V asks for real work, not a fixture. The recipe must not write to
`verification.md` itself (append-only, operator-reviewed); it prints, the operator appends. Whether it
ships as a maintenance tool afterwards is feature 002's decision.

## R12 — Dependency on feature 004

**Finding**: `specs/004-portable-process-logic/tasks.md` shows Phases 1–2 complete and User Story 1
(`T016`–`T023`: the Claude Code binding rendered, run for real, recorded) open. `run.sh` and
`run.sh.tmpl` exist in the working tree, uncommitted, and `RESULTS.md` records no run through them.

**Decision**: 005's User Story 1 is blocked on 004's User Story 1. The order is 004 US1 → 005 US1;
nothing in 005 works around it. Phases 2 and 3 of 005 (requirements, planning) do not depend on 004
and may proceed in parallel, subject to `R5`.

## What stays open

| Item | Blocks | Resolved by |
|---|---|---|
| Nested `claude --print` from a Claude Code session | US1 dogfooding | Quickstart scenario 1 |
| `requirements-elicit` reachable in a consumer | US2 dogfooding | Upstream fix per `R5`, then a pinned bump |
| 004 US1 shipped | US1 | Feature 004 |
| Skill validator as a gate | Release hygiene, not a story | Upstream `.pre-commit-hooks.yaml`, or the recorded manual step |

---

## Revision 2026-09-24b — after `/speckit-analyze`

Two constitution findings (C1, C2) and the related ambiguity A1 were resolved by the two entries
below. The earlier entries are unchanged.

## R13 — The plugin CLI commands, verified

**Finding**: Quickstart and tasks cited `claude plugin marketplace add`, `claude plugin install`,
`claude plugin list` and `claude plugin uninstall` without verification, which Principle VI forbids.

**Verified on 2026-09-24** against Claude Code CLI **2.1.282** (`claude --version`), by reading
`claude plugin --help`, `claude plugin marketplace --help` and `claude plugin install --help`:

| Command | Exists | Form |
|---|---|---|
| `claude plugin marketplace add <source>` | yes | "Add a marketplace from a URL, path, or GitHub repo" |
| `claude plugin install <plugin>` | yes | "use plugin@marketplace for specific marketplace" |
| `claude plugin list` | yes | "List installed plugins" |
| `claude plugin uninstall <plugin>` | yes | alias `remove`; "Uninstall an installed plugin" |
| `claude plugin disable <plugin>` | yes | the cheaper way to make a plugin absent for the fail-closed scenario |

A local path and a GitHub repository are both accepted by `marketplace add`, which is why the
quickstart may use the working copy while `skills/README.md` must name the GitHub repository (U1).

## R14 — The lifecycle carries its own version

**Finding**: Constitution Principle II says plans "carry their own semantic version, independent of
the repository version". The four-phase lifecycle is a multi-stage plan by that definition, and the
first plan draft justified Principle II with the git tag — which is the repository version.

**Decision**: `skills/VERSION.md`, in the form of `process/goose-implementation-review/VERSION.md`:
the lifecycle semver, the three-axis table (lifecycle version, review process version, baseline
revision), MAJOR/MINOR/PATCH semantics, and a history table. Initial version `0.1.0`, pre-release
until every skill has a recorded real run; `1.0.0` when `FR-025` and `FR-026` are met.

**Field names**: every lifecycle artifact records both versions under distinct names —
`lifecycle_version` (from `skills/VERSION.md`) and `review_process_version` (from the review
process's `VERSION.md`). The earlier single field `process_version` was ambiguous once two
processes existed (analysis A1) and is retired before any artifact is written.

**Why this is not a version-bearing file**: `OMISSIONS.md` §Version-bearing files says no file in the
working tree states a *release* version. `process/.../VERSION.md` and `baselines/VERSION.md` already
exist under that record; they state a process version, not the repository's release. `skills/VERSION.md`
is the same kind of file. `plugin.json` still has no `version`.

**Alternatives considered**: *`version` in `plugin.json`* — rejected: it would be a release version
and would need the alignment mechanism feature 003 declined; *no version, git tag only* — rejected:
that is the repository version Principle II explicitly excludes.
