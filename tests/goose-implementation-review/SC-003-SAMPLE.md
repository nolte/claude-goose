# SC-003 Sample — Do the citations hold up for someone else?

**For a reader who did not author the baseline.** `SC-003` requires that at least 90% of a sample of
20 findings can be confirmed or refuted **using only this document and the reviewed material** —
without asking the author and without hunting for sources.

This cannot be self-certified. The process wrote these citations; it is not a witness to whether they
carry.

> **Note on an earlier version.** The first draft of this sample named sources only descriptively
> ("Recipe Reference, Required Fields") and forced the checker to look each one up in `sources.md`.
> That contradicted the very criterion under test, which forbids further searching. Every row now
> carries its URL and the quoted rule. Fixing it was itself an `SC-003` failure, caught before the
> check ran.

## How to check one row

1. Open the **URL**. Does the quoted text actually appear there and say what the row claims?
2. Open the **file** at the stated **location**. Is the thing described actually there?
3. Tick ✓ only if both succeeded **without** consulting anything else.

Anything that sent you searching counts as not resolved — that is the point of the criterion.

**Time**: roughly 20–30 minutes. Rows 1–10 share three URLs, so most of it is reading fixtures.

## Sources used — three documents, plus measurements

| Tag | Where |
|---|---|
| **REF** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ — consulted 2026-07-31 |
| **DEV** | https://goose-docs.ai/docs/mcp/developer-mcp/ — consulted 2026-07-31 |
| **REPO** | https://github.com/aaif-goose/goose — release v1.45.0, consulted 2026-07-31 |
| **OBS** | A measurement recorded in `baselines/goose/2026-07-31b/sources.md`. **No document states it.** |

## The sample

Fixture paths are relative to `tests/goose-implementation-review/fixtures/`.

| # | Claim | Check it here | Against this source | ✓ |
|---|---|---|---|---|
| 1 | `description` is missing, and it is required | `recipe-with-deviations/recipe.yaml`, top level | **REF**: `title` and `description` listed as Required Fields | ☐ |
| 2 | A file parameter carrying a default is forbidden | `recipe-with-deviations/recipe.yaml`, `config_file` | **REF**, verbatim: "File parameters cannot have default values to prevent importing sensitive files." | ☐ |
| 3 | `{{ undefined_var }}` is used but never defined | `recipe-with-deviations/recipe.yaml`, `instructions` | **REF**, verbatim: "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." | ☐ |
| 4 | `unused_param` is defined but never used | `recipe-with-deviations/recipe.yaml`, `parameters` | **REF**, same sentence as row 3, other direction | ☐ |
| 5 | `inline_python` executes code | `recipe-with-deviations/recipe.yaml`, `extensions[0]` | **REF**: `inline_python` described as "inline Python code executed using `uvx`" | ☐ |
| 6 | The baseline declares extension internals uncovered | `baselines/goose/2026-07-31b/coverage.md`, gap table | The gap `GAP-EXT-SEMANTICS` and its stated trigger condition | ☐ |
| 7 | A headless run needs `prompt`; the docs do **not** say so | `recipe-with-deviations/recipe.yaml`, top level | **OBS** (S-008). *Refute this row if the finding claims documentation requires it* | ☐ |
| 8 | `recipe-clean` satisfies the required-fields rule | `recipe-clean/recipe.yaml`, top level | **REF**, Required Fields | ☐ |
| 9 | Its optional parameters all carry defaults | `recipe-clean/recipe.yaml`, `parameters` | **REF**, verbatim: "Optional parameters must have default values" | ☐ |
| 10 | `builtin` is a documented extension type | `recipe-clean/recipe.yaml`, `extensions[0]` | **REF**: types are `stdio`, `builtin`, `platform`, `streamable_http`, `frontend`, `inline_python` | ☐ |
| 11 | `inline_python` requires a `code` field | `baselines/goose/2026-07-31b/ruleset.md`, R-008 | **REF**, extension fields for `inline_python` | ☐ |
| 12 | `stdio` requires `cmd`, `args`, `timeout` | `baselines/goose/2026-07-31b/ruleset.md`, R-009 | **REF**, extension fields for `stdio` | ☐ |
| 13 | The baseline applies to Goose v1.45.0 | `baselines/goose/2026-07-31b/coverage.md`, header | **REPO**: latest release v1.45.0, published 2026-07-29 | ☐ |
| 14 | The reviewing agent can write to any accessible file | `process/goose-implementation-review/recipe.yaml`, security note | **DEV**: exposes `shell`, `write`, `edit`; "can run system commands with your user privileges and edit any accessible file" | ☐ |
| 15 | `R-002` is **not** enforced by the parser | `baselines/goose/2026-07-31b/ruleset.md`, R-002 | **OBS** (S-003). Reproduce: a recipe with neither `instructions` nor `prompt` passes `goose run --explain` | ☐ |
| 16 | `R-004` **is** enforced by the parser | `baselines/goose/2026-07-31b/ruleset.md`, R-004 | **OBS** (S-003). Reproduce: `goose run --recipe recipe-with-deviations/recipe.yaml --explain` | ☐ |
| 17 | A superseded revision was retained unmodified | `baselines/goose/2026-07-31/` versus its commit | `git diff <commit> -- baselines/goose/2026-07-31/` returns nothing | ☐ |
| 18 | The criterion format travels inside each revision | `baselines/goose/2026-07-31/criterion-format.md` and `…/2026-07-31b/…` | `baselines/README.md`, the stated reason for duplicating it | ☐ |
| 19 | A gap resolved by a newer baseline is not a fix | `process/goose-implementation-review/process.md`, Stage 6 cause table | The rule: baseline differs, subject identical ⇒ cause `baseline` | ☐ |
| 20 | `version` may be omitted; it defaults | `baselines/goose/2026-07-31b/ruleset.md`, "deliberately not included" | **REF**: `version` defaults to `"1.0.0"` when omitted | ☐ |

**Threshold**: 18 of 20. Below that, the citations need correcting before `SC-003` may be claimed.

## Rows built to be doubted

**Rows 7, 15 and 16** cite **OBS** — measurements, not documents. No published source states them.
Each must read as an observation of Goose 1.45.0. **If any of them reads as though the documentation
requires it, mark the row unresolved**: the claim would exceed its evidence class, which
`criterion-format.md` forbids. Rows 15 and 16 are reproducible in seconds with the commands given.

**Row 20** is a criterion deliberately *not* adopted. It checks that the ruleset resists inventing
plausible rules: omitting `version` is documented behaviour, so requiring it would be a preference
dressed as a rule.

## Result

- Resolved: ___ / 20
- `SC-003` met: ☐ yes ☐ no
- Checked by: ______________  Date: __________

Record the outcome in `RESULTS.md` and tick `T029` in
`specs/001-goose-implementation-review/tasks.md`. Below threshold, the failing rows name exactly
which citations to fix.
