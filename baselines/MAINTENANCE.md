# Baseline Maintenance

**Procedure version**: see `VERSION.md`. Record formats: see `SOURCE-FORMAT.md`.

How a baseline is kept current and grown without weakening its evidence. A review measures against a
pinned revision; keeping that revision honest is this document's job.

---

## Stage 1 — Completeness check

**Precondition**: A revision directory exists.

**Action**: Check the revision **against its own `criterion-format.md`**, never against a later
schema. That file travels inside each revision precisely so this is possible.

1. Every criterion names a `source`.
2. Every named source exists in that revision's `sources.md`.
3. Every field that revision's own format marks required is present.
4. Every record with `conflicts_with` also carries a `resolution`.

**Applying a newer schema to an older revision produces false defects.** This happened on the first
run: checking `2026-07-31` and `2026-07-31b` for `version_range` reported 0/7 and 0/10, although
both are complete — the field became mandatory only in `2026-08-01`. The revisions are not
defective; the check was wrong.

```sh
REV=baselines/goose/<revision>
grep -c '^## R-' $REV/ruleset.md            # criteria
grep -c '\*\*source\*\*' $REV/ruleset.md     # ...must be equal
```

**Complete when**: All four hold, or each failure is named.

**Verification**: Counts are equal and every referenced id resolves. **A single unsourced statement
blocks publication** — this is a release condition, not a quality target.

**On a failure in an already-published revision**: report it, do not correct it. Correcting a
published revision in place would break the guarantee that reports citing it stay interpretable. The
fix is a new revision.

---

## Stage 2 — Drift check, Rule A (authoritative sources)

**Precondition**: Records carry `source_path` and `source_commit`.

**Action**: For each authoritative record with a `source_path`:

```sh
gh api "repos/aaif-goose/goose/commits?path=<source_path>&per_page=1" --jq '.[0].sha'
```

| Stored vs. current | Result |
|---|---|
| Equal | `unchanged` |
| Different | `drifted` — every statement citing this record needs re-verification |
| Query fails | `unreachable` — recorded as such, **never** as `unchanged` |

**URL to source path**: `https://goose-docs.ai/docs/<path>/` → `documentation/docs/<path>.md`.
Confirmed for the `docs/` tree; **unverified** for blog posts and tutorials. Where the mapping is
unknown the record carries no `source_path` and falls back to manual re-reading, stated as such.

**Complete when**: Every authoritative record has a result.

**Verification**: The number of results equals the number of authoritative records. A record with no
result was skipped, not passed.

### HTTP caching headers must not be used

`ETag` and `Last-Modified` are **forbidden** as drift signals.

Measured 2026-07-31: two unrelated documentation pages carried an identical `last-modified` and
ETags differing only in a length component — the shape is `<deploy-id>-<size>`, so both move on every
site rebuild. Decisively, the recipe reference's source was last committed **2026-05-16** while the
page was served **2026-07-31**.

Using `Last-Modified` would have flagged every statement citing that page on a day its content had
been stable for ten weeks. **A drift signal that always fires is worse than none**: it looks like
coverage while being ignored.

---

## Stage 3 — Drift check, Rule B (observed sources)

**Precondition**: Records carry `method` and `host_version`.

**Action**: Compare the record's `host_version` against the revision's `goose_version`.

| Comparison | Result |
|---|---|
| Equal | `unchanged` |
| Different | `drifted` — repeat the measurement using the record's `method` |
| No `method` | **Invalid record**, not a drift result |

**Complete when**: Every observed record has a result.

**Verification**: No observed record was checked by Rule A. Watching a document for an observation
would report `unchanged` for a statement that had silently become false — the documentation can sit
untouched for years while the behaviour changes in the next release. This is the failure mode the
whole feature exists to prevent.

---

## Stage 4 — Record the outcome

**Action**: Append one verification record per source to the revision's `verification.md`.

**Complete when**: Every source checked in Stages 2 and 3 has a record.

**Verification**: Earlier records are untouched and the criteria are unchanged. **A drift check
never edits criteria.** It reports that re-verification is needed; acting on it produces a new
revision.

---

## Stage 5 — Third-party sampling

**Precondition**: Stage 1 passed.

**Action**: Draw at least 20 statements into a `VERIFICATION-SAMPLE.md` in the revision. Each row
carries the claim, where to check it, the URL, and the quoted passage — **self-contained, so the
checker never has to look anything up**. Mark rows whose source class is `observed` as requiring
extra scepticism, and include at least one row covering a recorded contradiction.

**Complete when**: A reader who did not author the material has completed the sample.

**Verification**: At least 95% resolved unaided. **This cannot be self-certified** — the base wrote
the citations and is no witness to whether they carry.

A sample that forces the checker to look sources up is itself a failure of the criterion under test.
That happened once and was caught before the check ran.

---

## Stage 6 — Growing the base

**Action**: Close declared gaps, in order of observed demand.

| Priority | Gap | Why |
|---|---|---|
| 1 | `GAP-EXT-SEMANTICS` | Fires in almost every review |
| 2 | `GAP-RECIPE-FIELDS` | Fires on subjects using those fields |
| 3+ | `GAP-CONFIG`, `GAP-CONTEXT`, `GAP-AGENTS`, `GAP-TRANSFER` | Can never fire under the review's current scope |

**Prefer criteria the host does not enforce.** Five of the ten shipped criteria describe conditions
under which a recipe will not load at all; for those the review offers earlier detection and a
sourced explanation, but catches nothing new. The two that matter — `R-002` and `R-010` — describe
behaviour the host accepts and the documentation misstates.

**Complete when**: The gap is either converted into criteria or narrowed, with what was searched
recorded either way.

**Verification**: The new material passes Stage 1, and the outcome is published as a **new
revision**. A comparison against the old revision must show any narrowed gap as `resolved` with
cause `baseline` — it is not a fix to the subject.

**Before publishing, prove the predecessors were not touched:**

```sh
git diff --quiet HEAD -- baselines/goose/<each earlier revision>/ || echo "IMMUTABILITY VIOLATION"
```

Only `verification.md` may differ, and only by added lines. This check exists because the rule was
broken once, additively and with good intentions: `quote` fields were added to a published revision
to make its citations easier to follow. "It only improves things" is precisely the argument that
erodes an immutability rule, and the check is cheaper than the argument.

---

## Cadence

| When | What |
|---|---|
| Before publishing a revision | Stages 1–4 across every source. A revision must not be published on stale evidence |
| When the baseline targets a new host version | Stage 3 for all observed records at once |
| After any gap is closed | Stages 1 and 6 |
| Otherwise | Operator's discretion; `verification.md` shows when each source was last confirmed |

**No automatic schedule is specified.** An unattended check nobody reads produces verification
records nobody acts on — a stronger claim of currency than the truth supports.

---

## Invariants

- A drift check never modifies criteria, sources or coverage — it only appends verification records.
- `unreachable` is never recorded as `unchanged`.
- A published revision is never edited except by appending verification records.
- Community sources never back a statement.
- A contradiction is scoped, never resolved away.
