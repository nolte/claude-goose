# Recipe Plan — Baseline Drift Check

**Slug**: baseline-drift-check
**Baseline revision**: 2026-08-02
**Lifecycle version**: 0.1.0
**Review process version**: 1.0.0
**Recipe path**: recipes/baseline-drift-check/recipe.yaml
**State**: ready
**Date**: 2026-09-24

<!--
Produced via the nolte-goose `recipe-plan` skill from
project/recipes/baseline-drift-check/requirements.md. Every header value except the recipe
path and the date is carried from that artifact unchanged.

Second plan for this slug. The first plan followed the artifact's original result vocabulary
(`changed` / `unknown`) literally and flagged that it did not match `SOURCE-FORMAT.md`; the
artifact was revised on 2026-09-24 to `unchanged` / `drifted` / `unreachable` and to state that
R-007 is not triggered by a `builtin` extension. This plan replaces the first one entirely.

Requirement ids: `R-1` … `R-5` are the input and capability ids of requirements.md; `R1` … `R8`
are the functional requirements of the generic artifact it names
(project/requirements/baseline-drift-check.md). Both sets are covered below.
-->

## Elements

| Id | Recipe element | Serves | Decided value or shape |
|---|---|---|---|
| P-1 | `title` | R4 | `"Baseline Drift Check"` |
| P-2 | `description` | R4 | One sentence: read-only check of one published baseline revision for source drift, comparing each recorded `source_commit` with the current upstream commit and printing the `verification.md` rows for the maintainer to append |
| P-3 | `parameters[revision]` | R-1, R1, R7 | `input_type: string`, `requirement: required`, no default; description "Baseline revision directory name under `<baselines_dir>/goose/`, e.g. 2026-08-02" |
| P-4 | `parameters[baselines_dir]` | R-2, R1, R8 | `input_type: string`, `requirement: optional`, `default: "./baselines"`; description "Directory holding `goose/<revision>/`. A path the recipe reads under, deliberately not `input_type: file`" |
| P-5 | `parameters[repo]` | R-3, R2, R8 | `input_type: string`, `requirement: optional`, `default: "aaif-goose/goose"`; description "Upstream repository queried for the current commit of each source path" |
| P-6 | `extensions[developer]` | R-4, R-5 | `type: builtin`, `name: developer`. Supplies file reading (R-4) and `shell` for `gh api` and `date` (R-5). Declared explicitly so the code-executing capability is visible in the recipe rather than inherited silently from the host's defaults. The declared list equals the needed set, so the unverified question whether an explicit list replaces the defaults (RESULTS O-1) cannot strip a needed tool. Documented fields only: `type` and `name` (S-001, S-004); no `timeout`, `bundled` or other value is set because the pinned revision documents no constraint on them (S-009) |
| P-7 | `instructions` | R-4, R-5, R1, R2, R3, R5, R6, R7 | The method, see "Element details" below: locate and parse `sources.md`, query one commit per `source_path` with `gh api`, classify with the `verification.md` vocabulary, print rows, and the four prohibitions verbatim |
| P-8 | `prompt` | R-1, R-2, R-3, R4, R1, R2, R3, R5, R6, R7, R8 | The headless starting impulse. Names all three parameters by template variable and restates every constraint that must hold: the file to read, the exact `gh api` command with `{{ repo }}`, the missing-revision behaviour, the row format, the three result words and the summary line, and all four prohibitions (RESULTS O-12: a constraint stated only in `instructions` was ignored twice) |

Not planned, on purpose: `version` (documented to default to `"1.0.0"`), `activities`, `response`,
`retry`, `settings`, `sub_recipes`. No requirement calls for them; leaving the last four absent keeps
`GAP-RECIPE-FIELDS` not triggered, as the requirement artifact's baseline check expects.

### Element details

**P-7 `instructions`** must state, in this order:

1. Role: a read-only drift check that prints and never writes. Stage 2 of `baselines/MAINTENANCE.md`
   for one revision, producing rows in the shape of that revision's `verification.md`.
2. Locate `{{ baselines_dir }}/goose/{{ revision }}/sources.md`. If the directory or the file does
   not exist: print one sentence naming the missing path, print no rows, stop (R7).
3. Parse every record heading `### S-<nnn>` and, from its table, `source_path`, `source_commit`
   (the commit token only, without the date in parentheses) and the evidence class (R1).
4. For each record with a `source_path`, run exactly
   `gh api "repos/{{ repo }}/commits?path=<source_path>&per_page=1" --jq '.[0].sha'` (R2).
   The recorded commit is abbreviated; compare it as a prefix of the observed SHA.
   Equal: result `unchanged`. Different: result `drifted`. The command fails, prints nothing, prints
   `null` or prints no SHA: result `unreachable` with the first line of the error (or "empty
   response") as reason, then continue with the next record (R6). Never retry with any other
   mechanism.
5. A record without `source_path`: result `unreachable`, reason `no source_path` (generic artifact,
   surviving assumption). Its rule column is `A` when its evidence class is A/direct, `B` when it is
   observed, matching the `Rule` column of the existing `verification.md` rows.
6. Print one row per record in the column order of `verification.md`:
   `| <date> | <source id> | <rule> | <observed commit> | <result> |`, date from `date -u +%F`,
   observed commit abbreviated to twelve characters in backticks, `—` when unreachable, result in
   backticks, the reason appended to the result cell after a colon so the row still pastes as one
   line. Then one summary line `unchanged: n, drifted: n, unreachable: n` (R3). `unreachable` is
   never counted or printed as `unchanged` (`SOURCE-FORMAT.md`).
7. The four prohibitions from the requirement artifact, verbatim: never write to `verification.md` or
   any file; never modify anything under `{{ baselines_dir }}`; never decide drift from HTTP `ETag`
   or `Last-Modified`; never fetch or read documentation page content, only commit metadata (R5).

**P-8 `prompt`** must repeat items 2, 4, 6 and 7 of P-7 with the concrete values substituted
(`{{ revision }}`, `{{ baselines_dir }}`, `{{ repo }}`), including the three result words verbatim,
so that the run has a starting text in headless mode (R4) and every constraint is present where the
host is observed to honour it. Every parameter appears in the prompt, which is what satisfies R-005
for P-3, P-4 and P-5.

## Coverage

| Requirement | Elements |
|---|---|
| R-1 | P-3, P-8 |
| R-2 | P-4, P-8 |
| R-3 | P-5, P-8 |
| R-4 | P-6, P-7 |
| R-5 | P-6, P-7 |
| R1 | P-3, P-4, P-7, P-8 |
| R2 | P-5, P-7, P-8 |
| R3 | P-7, P-8 |
| R4 | P-1, P-2, P-8 |
| R5 | P-7, P-8 |
| R6 | P-7, P-8 |
| R7 | P-3, P-7, P-8 |
| R8 | P-4, P-5, P-8 |

<!-- Every requirement id from requirements.md appears; every P-<n> appears in at least one row. -->

## Criteria

| Criterion | Verdict | Element or reason |
|---|---|---|
| R-001 | by construction | P-1, P-2 |
| R-002 | by construction | P-7, P-8 |
| R-003 | by construction | P-4, P-5 carry defaults; P-3 is required and needs none |
| R-004 | by construction | no element of kind `input_type: file` is planned; P-3, P-4, P-5 are strings |
| R-005 | by construction | P-8 uses `{{ revision }}`, `{{ baselines_dir }}`, `{{ repo }}`, one per parameter P-3, P-4, P-5, and no other variable. Implementation note (S-007): the host also scans YAML comments, so no comment may contain a `{{ … }}` of an undefined name |
| R-006 | by construction | P-6 declares `builtin`, one of the six documented types |
| R-007 | by construction | no element of kind `inline_python` or `stdio` is planned. P-6 is the element that supplies the shell capability; it is `builtin`, outside this criterion's decision procedure, so the audit produces no judgment-call finding for it — as the requirement artifact's baseline check now expects. The trust decision is made visible in P-6 instead |
| R-008 | by construction | no element of kind `inline_python` is planned |
| R-009 | by construction | no element of kind `stdio` is planned |
| R-010 | by construction | P-8 |
| GAP-EXT-SEMANTICS | risk | P-6 declares an extension, which triggers this gap; the audit reports one `undecided` finding under this id. Expected by the requirement artifact's baseline check |

<!-- Every criterion of the pinned revision's ruleset.md appears exactly once. -->
<!-- GAP-RECIPE-FIELDS is not triggered: none of response, retry, settings, sub_recipes is planned. -->

## Conflicts

| Requirement | Collides with | Returned to author |
|---|---|---|

none

<!-- "none" when empty. A non-empty table sets State to blocked. -->
