# SC-003 Sample — Do the citations hold up for someone else?

**For a reader who did not author the baseline.** `SC-003` requires that at least 90% of a sample of
20 findings can be confirmed or refuted **using only the report and the reviewed material** — without
asking the author.

This cannot be self-certified. The process wrote these citations; it is not a witness to whether they
carry.

## How to check one row

1. Open the **Source** URL. Does the quoted rule actually say what the finding claims?
2. Open the **Location** in the fixture. Is the deviation there?
3. Tick `resolved` only if both succeeded **without** consulting anything else.

Anything that sent you hunting counts as not resolved — that is the point of the criterion.

## The sample

Criteria live in `baselines/goose/2026-07-31b/ruleset.md`; every `source` there carries a URL and a
consulted date. Fixtures are under `tests/goose-implementation-review/fixtures/`.

| # | Finding | Location | Source to follow | Resolved? |
|---|---|---|---|---|
| 1 | R-001 — `description` absent | `recipe-with-deviations/recipe.yaml` top-level | Recipe Reference, "Required Fields" | ☐ |
| 2 | R-004 — file parameter has a default | same, `parameters[config_file]` | Recipe Reference, verbatim rule on file parameters | ☐ |
| 3 | R-005 — `undefined_var` undefined | same, `instructions` | Recipe Reference, template-variable rule | ☐ |
| 4 | R-005 — `unused_param` unused | same, `parameters[unused_param]` | same rule, other direction | ☐ |
| 5 | R-007 — code-executing extension | same, `extensions[0]` | Recipe Reference, `inline_python` description | ☐ |
| 6 | GAP-EXT-SEMANTICS — undecided | same, `extensions[0]` | `coverage.md`, declared gaps table | ☐ |
| 7 | R-010 — no `prompt` | same, top-level | S-008 in `sources.md` (an **observation**, not a document) | ☐ |
| 8 | R-001 pass | `recipe-clean/recipe.yaml` | Recipe Reference, "Required Fields" | ☐ |
| 9 | R-003 pass | same, optional parameters | Recipe Reference, optional-parameter rule | ☐ |
| 10 | R-006 pass | same, `extensions[0]` | Recipe Reference, extension types list | ☐ |
| 11 | R-004 — file parameter has a default | foreign repo 2, `parameters[notes_template]` | Recipe Reference, file-parameter rule | ☐ |
| 12 | R-010 — no `prompt` | foreign repo 2, top-level | S-008 | ☐ |
| 13 | R-008 — `inline_python` needs `code` | S-004 and the parser error | Recipe Reference, extension fields | ☐ |
| 14 | R-009 — `stdio` needs `cmd` | S-004 and the parser error | Recipe Reference, extension fields | ☐ |
| 15 | BASELINE-DRIFT | pinned `2026-07-31`, newer exists | `process.md` Stage 3b | ☐ |
| 16 | BASELINE-VERSION-MISMATCH | `recipe-version-mismatch` | `process.md` Stage 3b | ☐ |
| 17 | GAP-RECIPE-FIELDS — undecided | `reference-recipe`, `response` | `coverage.md`, declared gaps | ☐ |
| 18 | Delta: R-004 resolved / subject | fixed fixture vs prior report | `process.md` Stage 6, cause table | ☐ |
| 19 | Delta: GAP-EXT-INTERNALS resolved / baseline | unchanged subject, newer revision | `process.md` Stage 6, cause table | ☐ |
| 20 | Partial coverage — exceeds budget | oversized fixture, budget 5000 | `process.md` Stage 1, coverage budget | ☐ |

**Threshold**: 18 of 20. Below that, the citations need correcting before `SC-003` may be claimed.

## Rows worth extra scepticism

**Row 7 and row 12** cite `S-008`, which is an **observation**, not a document. No published source
says a headless run needs `prompt`; it was measured. If the finding reads as though the documentation
requires it, the wording is wrong and should be corrected — the evidence class is `observed` and the
claim must not exceed it.

**Rows 13 and 14** rest partly on parser error messages. Check that the cited documentation really
lists those fields, rather than the finding leaning on the error alone.

## Result

- Resolved: ___ / 20
- `SC-003` met: ☐ yes ☐ no
- Checked by: ______________  Date: __________
