# Expected Delta: recipe-with-deviations → recipe-with-deviations-fixed

**Prior**: a report of `fixtures/recipe-with-deviations`
**Current**: a report of `fixtures/recipe-with-deviations-fixed`
**Baseline**: identical in both runs
**Subject**: differs

Because the baseline is identical and the subject differs, every changed finding must carry
`delta_cause: subject`.

## Expected classification

| Identity | Location | delta_status | delta_cause |
|---|---|---|---|
| R-001 | top-level | unchanged | — |
| **R-004** | **parameters[config_file]** | **resolved** | **subject** |
| R-005 | instructions | unchanged | — |
| R-005 | parameters[unused_param] | unchanged | — |
| R-007 | extensions[0] | unchanged | — |
| GAP-EXT-SEMANTICS | extensions[0] | unchanged | — |
| R-010 | top-level | unchanged | — |

`R-004` is the only correction. Reporting any other finding as `resolved` means the delta matched on
something other than `(identity, location)`.

## The baseline-cause counterpart

Reviewing an **unchanged** subject against a **newer baseline revision** must show
`GAP-EXT-INTERNALS` (2026-07-31) as `resolved` with `delta_cause: baseline`, since revision
`2026-07-31b` narrowed that gap to `GAP-EXT-SEMANTICS`.

**That is not a fix.** Nothing about the subject improved; the baseline learned to check part of what
it had declared unknown. Attributing it to the subject would credit work nobody did.
