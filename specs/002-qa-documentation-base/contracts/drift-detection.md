# Contract: Drift Detection

**Feature**: `002-qa-documentation-base` | **Date**: 2026-07-31

Fixes how a source record is checked for staleness. Two classes, two rules — using one rule for both
would either miss real drift or invent it.

## Rule A — authoritative sources: compare the source commit

**Applies to**: records with `class: authoritative` and a `source_path`.

```sh
gh api "repos/aaif-goose/goose/commits?path=<source_path>&per_page=1" --jq '.[0].sha'
```

| Stored `source_commit` vs. current | Result |
|---|---|
| Equal | `unchanged` |
| Different | `drifted` — every statement citing this record needs re-verification |
| Query fails | `unreachable` — recorded as such, never as `unchanged` |

**URL to source path**: `https://goose-docs.ai/docs/<path>/` → `documentation/docs/<path>.md`.
Verified for two pages; **not verified** for blog posts or tutorials, which may differ. Where the
mapping is unknown, the record carries no `source_path` and falls back to manual re-reading, stated
as such.

### HTTP caching headers must not be used

`ETag` and `Last-Modified` are **forbidden** as drift signals. Measured 2026-07-31: two unrelated
documentation pages carried an identical `last-modified` and ETags differing only in a length
component — the shape is `<deploy-id>-<size>`, so both move on every site rebuild.

Decisively, the recipe reference's source was last committed on **2026-05-16** while the page was
served on **2026-07-31**. Using `Last-Modified` would have flagged every statement citing it, on a
day when its content had been stable for two and a half months.

**A drift signal that always fires is worse than none**, because it looks like coverage while being
ignored.

## Rule B — observed sources: compare the host version

**Applies to**: records with `class: observed`. These have no document to watch.

| Baseline's `goose_version` vs. record's `host_version` | Result |
|---|---|
| Equal | `unchanged` |
| Different | `drifted` — the measurement must be repeated using the record's `method` |
| Record has no `method` | **Invalid record**, not a drift result |

The documentation could remain untouched for years while the behaviour changes in the next release.
Watching a document for an observation would report `unchanged` for a statement that had silently
become false — the failure mode this whole feature exists to prevent.

## What a drift check produces

A Verification Record appended to the revision's `verification.md`, per source, carrying the date,
the result, and the observed commit where applicable.

**A drift check never edits criteria.** It reports that re-verification is needed; acting on it
produces a new revision. Conflating the two would let a published revision change meaning
underneath reports that cite it.

## Cadence

| When | What |
|---|---|
| Before publishing a new revision | Every source, both rules. A revision must not be published on stale evidence |
| When the baseline targets a new host version | Every `observed` record — Rule B fires for all of them at once |
| Otherwise | Operator's discretion; the record shows when each source was last confirmed |

**No automatic schedule is specified.** An unattended check that nobody reads produces verification
records nobody acts on, which is a stronger claim of currency than the truth supports.

## Invariants

- A drift check never modifies criteria, sources or coverage — only appends verification records.
- `unreachable` is never recorded as `unchanged`.
- A record whose class rule cannot be applied is reported as invalid, not skipped.
