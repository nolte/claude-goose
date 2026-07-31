# Verification Log — Revision 2026-08-02

**Append-only.** Format: see `../../SOURCE-FORMAT.md`. Procedure: see `../../MAINTENANCE.md`.

## Records

| Date | Source | Rule | Observed | Result |
|---|---|---|---|---|
| 2026-07-31 | S-001 | A | `3254d442c90c` | `unchanged` |
| 2026-07-31 | S-002 | A (release metadata) | v1.45.0 | `unchanged` |
| 2026-07-31 | S-003 | B | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-004 | A | `3254d442c90c` | `unchanged` |
| 2026-07-31 | S-005 | A | `ceb94b24dc69` | `unchanged` |
| 2026-07-31 | S-006 | B | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-007 | B | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-008 | B | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-009 | A | `3254d442c90c` | `unchanged` |

## Completeness check (against this revision's own criterion-format.md)

| Check | Result |
|---|---|
| Criteria count vs. sourced criteria count | 10 = 10 — **pass** |
| Every named source resolves | 10/10 — **pass** |
| Every criterion carries a `version_range` | 10/10 — **pass** |
| Every `conflicts_with` carries a `resolution` | 1/1 — **pass** |

## What this revision demonstrates

That **research producing no criterion is still progress**. `GAP-EXT-SEMANTICS` was investigated and
the documentation found silent on value semantics. The gap stays open; what changed is that it now
records what was searched.

A base that only grows when it finds rules would quietly reward inventing them.

## An immutability violation, caught and reverted

While preparing this revision, `quote` fields were added to `2026-08-01/sources.md` — **after that
revision had been committed, and therefore published**. Under the rule in `../../README.md` that is
forbidden: a published revision may only be appended to via `verification.md`.

| File | Change | Verdict |
|---|---|---|
| `2026-08-01/verification.md` | 32 lines appended, 0 removed | **Permitted** — the one allowed edit |
| `2026-08-01/sources.md` | 2 lines added | **Forbidden** — reverted to its committed state |

The quotes were not lost: this revision was derived from the edited copy, so they live on here,
where adding them is legitimate.

**Why this is recorded rather than quietly fixed.** The violation was additive and harmless-looking
— two quote fields that make citations easier to follow. That is exactly the kind of edit an
immutability rule exists to stop, because "it only improves things" is the argument that erodes
every such rule. A report citing `2026-08-01` must find it as it was when the report was written.

Detected by `git diff --quiet HEAD` against the predecessor directories, which is now the check that
belongs in the publication routine.

