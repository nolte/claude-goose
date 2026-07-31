# Verification Log — Revision 2026-08-01

**Append-only.** Adding a record is permitted inside this published revision; editing or removing one
is not. This is the single exception to revision immutability, and it exists because confirming that
nothing changed is not a change to the criteria.

Format: see `../../SOURCE-FORMAT.md`. Procedure: see `../../MAINTENANCE.md`.

## Records

| Date | Source | Rule | Observed | Result |
|---|---|---|---|---|
| 2026-07-31 | S-001 | A — source commit | `3254d442c90c` | `unchanged` |
| 2026-07-31 | S-002 | A — release metadata | v1.45.0, published 2026-07-29 | `unchanged` |
| 2026-07-31 | S-003 | B — host version | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-004 | A — source commit | `3254d442c90c` | `unchanged` |
| 2026-07-31 | S-005 | A — source commit | `ceb94b24dc69` | `unchanged` |
| 2026-07-31 | S-006 | B — host version | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-007 | B — host version | v1.45.0 = revision target | `unchanged` |
| 2026-07-31 | S-008 | B — host version | v1.45.0 = revision target | `unchanged` |

**Rule A** applies to authoritative records and compares the stored `source_commit` against the
current commit for `source_path`. **Rule B** applies to observed records, which have no document to
watch, and compares `host_version` against the revision's `goose_version`.

Two records (`S-002`, and any without a `source_path`) are checked by a variant of Rule A against
release metadata rather than a file commit; this is noted rather than glossed over, because it is a
weaker anchor.

## Completeness checks

| Date | Check | Result |
|---|---|---|
| 2026-07-31 | Criteria count vs. sourced criteria count | 10 = 10 — **pass** |
| 2026-07-31 | Every named source resolves to a record | 10/10 — **pass** |
| 2026-07-31 | Every criterion carries a `version_range` | 10/10 — **pass** |
| 2026-07-31 | Every `conflicts_with` carries a `resolution` | 1/1 — **pass** |

## Check of the superseded revisions (2026-07-31)

Required by the maintenance procedure before publishing a successor. Both were checked **against
their own `criterion-format.md`**, not against this revision's.

| Revision | Criteria | Sourced | Own-format fields present | Result |
|---|---|---|---|---|
| `2026-07-31` | 7 | 7 | yes | **pass** |
| `2026-07-31b` | 10 | 10 | yes | **pass** |

Both are byte-identical to their committed state — verified with `git diff --quiet`.

**A false defect was raised and withdrawn.** The first pass applied this revision's schema to both,
reporting `version_range` missing 0/7 and 0/10. That field became mandatory only here. The
revisions are complete under the schema they were published against; the check was applying the
wrong one.

This is exactly why `criterion-format.md` travels inside each revision rather than being shared. The
procedure now states that a revision is checked against its own format, and the mistake is recorded
rather than quietly fixed — the next person to write such a check will be tempted the same way.

## Wording check against evidence class (2026-07-31)

Required before publication: a criterion may not claim more than its source class supports.

| Criterion | Source class | Verdict |
|---|---|---|
| `R-002` | authoritative (`S-001`) with observed counter-evidence (`S-003`) | **pass** — states the documented rule and names the measurement that contradicts it |
| `R-010` | observed (`S-008`) | **pass** — worded as an observation of Goose 1.45.0; explicitly forbids claiming the documentation requires `prompt` |

**A false positive was raised and withdrawn.** An automated scan for the phrase "the documentation
requires" flagged `R-010`. The match was the criterion's own *prohibition* against making that
claim, not the claim itself.

This is the second time in one session that a check was too naive to distinguish a rule from its
negation — the first applied a newer schema to an older revision. Both were caught by reading the
hit rather than trusting the count. A grep is evidence of a string, not of a claim.

## Drift check — executed 2026-07-31

Rule A against the live repository; Rule B against the declared host version.

| Source | Rule | Stored | Current | Result |
|---|---|---|---|---|
| S-001 | A | `3254d442c90c` | `3254d442c90c` | `unchanged` |
| S-004 | A | `3254d442c90c` | `3254d442c90c` | `unchanged` |
| S-005 | A | `ceb94b24dc69` | `ceb94b24dc69` | `unchanged` |
| S-002 | A (release metadata) | v1.45.0 | v1.45.0 | `unchanged` |
| S-003, S-006, S-007, S-008 | B | host v1.45.0 | revision targets v1.45.0 | `unchanged` |

### The three failure paths were provoked, not assumed

A drift check that has only ever returned `unchanged` proves nothing. Each alternative outcome was
forced:

| Test | Method | Outcome |
|---|---|---|
| **`drifted`** | Stored commit set to `000000000000` against `developer-mcp.md` | Reported `drifted`. **Detected** |
| **`unreachable`** | Query issued against an unreachable API host | Query failed; result is `unreachable`, **never** `unchanged` |
| **Rule B fires alone** | `S-008` compared against a revision declaring `v1.46.0` | Reported `drifted` although its documentation had not moved |

The last one is the reason two rules exist. An observation has no document to watch: had Rule A been
applied to `S-008`, it would have reported `unchanged` for a statement that a version bump may have
silently falsified.

### SC-006 — flagged before use, not after

The cadence requires Stages 1–4 before a revision is published or used. The check above ran before
this revision was put to work, so no review has consumed it on unverified evidence.
