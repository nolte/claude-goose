# Baselines

A baseline is a published, versioned set of criteria that reviews are measured against. Each
revision lives in its own directory under `goose/<revision>/`.

## The immutability rule

**A published revision directory is never edited in place.** Corrections and additions create a new
revision; the old one stays exactly as it was published.

### When a revision counts as published

The rule needs a start point, and "written to disk" is the wrong one — it would freeze a revision
before anyone had a chance to check it. A revision is **published** once either has happened:

1. it has been committed, or
2. any review has been run against it.

Before that it is a draft and may be corrected freely. After that it is frozen, because from that
moment a report may exist that names it, and such a report must remain interpretable.

This definition was added after the first draft revision needed correction: holding a
never-committed, never-used revision immutable would have forced a second revision purely to fix a
draft, which serves nobody.

This is not bookkeeping formality. A report names the revision it was measured against. If that
revision could change afterwards, every past report would silently come to mean something different
from what it meant when it was written — the report would still exist, but would no longer be
interpretable. Retaining revisions is what keeps old findings comparable to new ones.

The same reasoning is why each revision carries its **own copy** of `criterion-format.md`. A single
shared format file would re-interpret every earlier revision the moment the schema changed. The
duplication is deliberate and is the price of keeping old revisions readable.

## Structure of a revision

| File | Contents |
|---|---|
| `criterion-format.md` | The schema this revision's criteria conform to |
| `ruleset.md` | The criteria themselves |
| `sources.md` | Where each criterion came from: URL, version, consulted date, evidence class |
| `coverage.md` | What this revision covers — and what it declares as a gap |

## Gaps are load-bearing

`coverage.md` declares what the baseline does **not** cover. The review process turns those
declarations into `undecided` findings rather than silent passes. A thin baseline with honest gaps
is safe; a thin baseline with hidden gaps produces false confidence, which is worse than no review.

## Revisions

| Revision | Goose version | Notes |
|---|---|---|
| `2026-07-31` | v1.45.0 | Initial revision. Recipe structure and parameter rules only |
