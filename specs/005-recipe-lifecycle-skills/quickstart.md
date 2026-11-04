# Quickstart: Recipe Lifecycle Skills

**Feature**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24

How to prove this feature works, end to end. Each scenario names what it validates and what a pass
looks like. Two scenarios are blocked on work outside this feature and say so; a blocked scenario is
not a passed one.

## Prerequisites

| Need | For | Notes |
|---|---|---|
| `task`, `pre-commit` | Scenario 6 | `task ci:install` installs the pinned toolchain |
| `goose` 1.45.0 | Scenarios 4, 5 | Also needed by the `recipe-parse` gate class |
| Claude Code CLI | Every skill scenario | The plugin is installed into it |
| `nolte-shared` plugin | Scenarios 2, 3 | At the release named in `skills/README.md` |
| Feature 004 US1 shipped | Scenario 1 | `bindings/claude-code/run.sh` rendered and recorded in `RESULTS.md` |
| A claude-shared checkout at the pinned release | Scenario 7 | For `scripts/validate_skills.py` |

Install the plugin from this working copy for every skill scenario. The commands were verified
against Claude Code CLI 2.1.282 (research R13); a consumer uses the GitHub form in
`contracts/plugin-manifest.md` instead of the local path:

```sh
claude plugin marketplace add /home/nolte/repos/github/claude-goose
claude plugin install nolte-goose@nolte-goose
```

## Scenario 1 — The audit skill returns the binding's report (US1, FR-011..FR-014)

In a Claude Code session in a scratch directory holding a copy of
`tests/goose-implementation-review/fixtures/recipe-with-deviations/`:

```text
/nolte-goose:recipe-audit --subject_path ./recipe-with-deviations --baseline_revision 2026-07-31b --output_path ./review-skill.md
```

Then, outside the session, the same subject through the binding directly:

```sh
process/goose-implementation-review/bindings/claude-code/run.sh \
  --subject_path ./recipe-with-deviations --baseline_revision 2026-07-31b --output_path ./review-direct.md
diff <(sed -n '/^DIGEST v1/,/^```/p' review-skill.md) <(sed -n '/^DIGEST v1/,/^```/p' review-direct.md)
```

**Pass**: both reports carry `Host: claude-code`, `baseline=2026-07-31b` in the digest, the coverage
statement and the `Criteria Applied` table; the `diff` is empty. The skill's transcript contains no
sentence in normative voice about a review rule (`SC-004`: search it for `NEVER`, `MUST`, `USE
EXACTLY`).

**Fail**: the nested `claude --print` does not complete, or the digests differ. The first is the
unverified item in research `R2` and triggers its fallback; the second is a finding against feature
004's binding, not against this skill, and is recorded in `RESULTS.md` either way.

**Blocked until**: 004 `T016`–`T023` are done. Running this scenario earlier measures a binding
that has not been rendered yet.

## Scenario 2 — Requirements capture delegates and adds (US2, FR-005, FR-015..FR-017)

```text
/nolte-goose:recipe-requirements-elicit
```

Answer the interview for the research `R11` recipe: a baseline drift check that takes a revision
id, compares each recorded source commit with the current one, and prints rows for `verification.md`.

**Pass**: `project/requirements/baseline-drift-check.md` exists and was written by
`requirements-elicit` (its template header is present); `project/recipes/baseline-drift-check/requirements.md`
exists, names the generic artifact, carries a concrete `baseline_revision`, both version fields,
all five recipe sections, and a baseline check that names `R-007` and `GAP-EXT-SEMANTICS` against
the shell capability (the drift-check recipe has no file-importing optional input, so `R-004` does
not fire here). The interview asked no generic question through
the recipe skill's own text.

**Blocked until**: the `requirements-elicit` precondition is satisfiable in a consumer (research
`R5`). Record the block; do not copy the spec locally.

## Scenario 3 — Missing shared capability fails closed (FR-009, SC-006)

Make `nolte-shared` absent with `claude plugin disable nolte-shared` (verified subcommand, research
R13), then:

```text
/nolte-goose:recipe-requirements-elicit
```

**Pass**: the skill stops with the fail-closed message naming `nolte-shared:requirements-elicit`, the
minimum release and the marketplace; `project/` is untouched.

**Fail**: the skill conducts an interview of its own.

## Scenario 4 — Plan then implement, traceable both ways (US3, US4, FR-018..FR-023)

With a confirmed `project/recipes/baseline-drift-check/requirements.md`:

```text
/nolte-goose:recipe-plan
/nolte-goose:recipe-implement
```

**Pass**: `plan.md` is `ready`, its coverage table lists every `R-<n>` and every `P-<n>`, and its
criteria table lists every criterion of the pinned `ruleset.md` exactly once. The recipe at the
plan's path carries the provenance block and a `P-<n> ← R-<m>` comment on every element; and

```sh
goose run --recipe <recipe path> --explain
```

prints no line beginning `Error:`.

## Scenario 5 — First audit of the lifecycle recipe is clean (SC-001, FR-026)

```text
/nolte-goose:recipe-audit --subject_path <recipe dir> --baseline_revision <pinned id> --output_path project/recipes/baseline-drift-check/review-report.md
```

**Pass**: zero findings with outcome `deviation`. Findings with `undecided` for `GAP-EXT-SEMANTICS`
and `judgment call` for `R-007` are expected: the recipe declares a code-executing extension, and
the baseline says so rather than deciding. Record the run in `RESULTS.md` with the digest and the
comparison against a Goose-binding run over the same subject (`FR-014`, `FR-026`).

## Scenario 6 — The gate is green and the guard covers `skills/` (FR-027)

```sh
task ci
grep -rn 'claude-goose' skills/ && echo "portability: repository name in skills/" || true
```

**Pass**: every class passes, and the portability class now scans `skills/` (its output names the
tree). The second command prints nothing.

## Scenario 7 — Frontmatter conforms (research R8)

```sh
git -C /home/nolte/repos/github/claude-shared checkout v0.1.11
python3 /home/nolte/repos/github/claude-shared/scripts/validate_skills.py skills/
```

**Pass**: no line prefixed `Critical`, and none of the four skill names appears in any `skills/`
listing of that checkout or its `plugins/*/skills/` (spec `FR-008`). Record the validator version
the script prints with `--version`, and the claude-shared tag, in `skills/README.md`. This step is manual until
claude-shared exposes the validator as a pre-commit hook; `OMISSIONS.md` says so.

## Scenario 8 — A second reader draws the boundary (SC-003)

Hand a reader who has not seen the skills the four `description` lines and the `description` lines
of `requirements-elicit`, `implementation-plan-author`, `fullstack-developer` and
`pull-request-create`. Ask, per recipe skill: which shared capability does it delegate to, and what
does it add?

**Pass**: four correct answers, zero wrong attributions. The reader's answers are recorded in
`RESULTS.md` the way `SC-003` of feature 001 was.

## Scenario 9 — Refusals stop and name the cause (FR-004, FR-016, FR-020, FR-022)

Four negative runs, each over a deliberately defective input, each expected to stop without
writing the phase's output artifact:

1. `recipe-plan` over a requirement artifact whose `State` is `draft` with one open point.
   **Pass**: stops, names the open point, writes no `plan.md` (FR-004).
2. `recipe-requirements-elicit` (or its `validate` operation over a hand-written artifact) with an
   optional input marked `Imports a file: yes`. **Pass**: the baseline check names `R-004` with
   consequence "violates by construction" (FR-016).
3. `recipe-plan` over a confirmed artifact that keeps that input. **Pass**: `plan.md` is written
   with `State: blocked`, the conflicts table names the input and `R-004`, and the requirement is
   not narrowed (FR-020).
4. `recipe-implement` over a ready plan after one element is edited to an undocumented extension
   type in a scratch copy. **Pass**: the parser's `Error:` line is reported verbatim and the recipe
   is not presented as done (FR-022).

Record all four in `RESULTS`; a refusal that was never provoked is a refusal that was never tested.

## What each scenario proves

| Scenario | Story | Requirement or criterion |
|---|---|---|
| 1 | US1 | FR-011, FR-012, FR-013, FR-014, SC-002, SC-004 |
| 2 | US2 | FR-005, FR-006, FR-015, FR-016, FR-017, SC-008 |
| 3 | — | FR-009, SC-006 |
| 4 | US3, US4 | FR-018 to FR-023, SC-005 |
| 5 | all | FR-024, FR-025, FR-026, SC-001, SC-007 |
| 6 | — | FR-027 |
| 7 | — | frontmatter rules of `skill-management`; FR-008 |
| 8 | — | FR-006, FR-007, SC-003 |
| 9 | — | FR-004, FR-016, FR-020, FR-022 |
