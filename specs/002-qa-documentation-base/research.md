# Phase 0 Research: Documentation Base

**Feature**: `002-qa-documentation-base`
**Consulted**: 2026-07-31

Evidence classes are those `FR-011` fixes: **authoritative** (official documentation, upstream
repository), **observed** (a reproducible measurement, stated as such), **excluded** (community
sources).

---

## Finding 0: This feature does not start from zero

| | |
|---|---|
| **Decision** | Treat the two existing baseline revisions as this feature's starting inventory, not as foreign artifacts to be replaced. |
| **Evidence** | observed — present in this repository |

Feature `001-goose-implementation-review` shipped `baselines/goose/2026-07-31` and `2026-07-31b`
while building its review process. Together they hold **ten criteria across three source records**
and **six declared gaps**, and they have been exercised by 24 real reviews.

Consequences for this plan:

- The **method is already proven**, not hypothetical. What this feature adds is cadence, drift
  detection, and the discipline to grow the base without weakening it.
- `2026-07-31` is **published and immutable**. Anything this feature changes produces a new revision.
- The gap list is the work list (`FR-012`), and it already exists.

**Alternatives considered**: authoring a fresh base under this feature's own structure. Rejected —
it would orphan two revisions that reports already cite by id, breaking `FR-011` of feature 001
(published revisions stay interpretable).

---

## Finding 1: Drift detection must use the source commit, not HTTP caching headers

| | |
|---|---|
| **Decision** | Detect drift by the **git commit that last touched the documentation source file**, not by `ETag`, `Last-Modified`, or a hash of the rendered page. |
| **Evidence** | observed — measured 2026-07-31 |

The obvious mechanism fails. Measured against two documentation pages:

```
recipe-reference/   last-modified: Fri, 31 Jul 2026 17:00:40 GMT   etag: "6a6cd4b8-3a206"
developer-mcp/      last-modified: Fri, 31 Jul 2026 17:00:40 GMT   etag: "6a6cd4b8-11c09"
```

Both carry an **identical timestamp** and an ETag differing only in its second component, which
tracks `content-length`. The shape is `<deploy-id>-<size>`: it changes on every site rebuild,
regardless of whether any page's content changed.

The decisive check: the source of the recipe reference was last modified in **May**, while the page
was served in **July**.

| | |
|---|---|
| Source file | `documentation/docs/guides/recipes/recipe-reference.md` |
| Last commit | `3254d442c90c`, 2026-05-16 |
| Page served | 2026-07-31 |

Using `Last-Modified` would therefore have flagged every statement citing that page as needing
re-verification, on a day when its content had been stable for two and a half months. `FR-008` would
produce constant false alarms, and an alarm that always fires is quickly ignored — which is worse
than no drift detection, because it looks like coverage.

### The mechanism

Documentation URLs map to repository paths predictably:

```
https://goose-docs.ai/docs/<path>/   →   documentation/docs/<path>.md
```

The drift check is then:

```sh
gh api "repos/aaif-goose/goose/commits?path=<source path>&per_page=1" --jq '.[0].sha'
```

A source record stores that SHA. Drift is `stored != current`. Verified reproducible: two
consecutive queries returned `3254d442c90c` both times.

**Alternatives considered**:

- **`ETag` / `Last-Modified`** — rejected above; they report deploys, not content.
- **Hash of the rendered HTML** — rejected: the rendering changes with the site generator, its theme
  and its navigation, so unrelated edits elsewhere would move the hash.
- **Hash of the visible text** — rejected: it detects real changes but cannot say *what* changed,
  and it breaks when the source file moves. A commit SHA is comparable, attributable and cheap.

**Limit of this decision**: it works only for statements sourced from documentation whose source
lives in the upstream repository. A statement backed by an **observation** has no upstream commit to
watch — see Finding 2.

---

## Finding 2: Observed statements need a different staleness rule

| | |
|---|---|
| **Decision** | An observation is bound to the host version it was measured against, and goes stale when that version moves — not when any document changes. |
| **Evidence** | observed — derived from the shipped baseline's own records |

`FR-011` admits observation as a source class, and the shipped baseline depends on it: `R-002` and
`R-010` — the only two criteria that catch what the host parser lets through — both rest on
measurements, because they describe behaviour that **contradicts what the documentation implies**.

Such statements have no source commit. Watching a document for them would be meaningless: the
documentation could stay untouched for years while the behaviour changed in the next release.

Their staleness rule is therefore the **host version**. An observation recorded against Goose 1.45.0
must be re-measured when the baseline targets a different version, and the record must retain both
results (`FR-009`).

**Alternatives considered**: excluding observations to keep one uniform drift rule. Rejected — it
would delete the two most valuable criteria in the base. A second rule is a smaller cost than a base
that only repeats what the documentation already says.

---

## Finding 3: Gap priority follows demand, not tidiness

| | |
|---|---|
| **Decision** | Work the declared gaps in order of how often a review has been unable to decide something because of them. |
| **Evidence** | observed — the six gaps in `baselines/goose/2026-07-31b/coverage.md` |

`FR-012` makes the gap list the work list. It does not say in which order, and the gaps are not
equal:

| Gap | Triggers a finding when | Observed demand |
|---|---|---|
| `GAP-EXT-SEMANTICS` | The subject declares any extension | **High** — fired in almost every review |
| `GAP-RECIPE-FIELDS` | The subject uses `response`/`retry`/`settings`/`sub_recipes` | Moderate — fired on the reference and oversized fixtures |
| `GAP-CONFIG` | Never — out of review scope | None |
| `GAP-CONTEXT` | Never — out of review scope | None |
| `GAP-AGENTS` | Never — out of review scope | None |
| `GAP-TRANSFER` | Never — backs no criterion | None |

Three gaps can never produce a finding under feature 001's current scope. Researching them first
would produce material nothing consumes.

**Alternatives considered**: closing gaps in declaration order, or closing the cheapest first.
Rejected — both optimise for the author's convenience rather than the consumer's need. A gap that
never fires is not urgent, however easy it is to close.

---

## Open questions

| Question | Status |
|---|---|
| Does the URL→source-path mapping hold for every documentation section? | **Unverified.** Confirmed for two pages under `docs/`. Blog posts and tutorials may differ |
| Is there an upstream changelog for documentation specifically? | **Unverified.** Not searched for; would allow batch drift checks instead of per-file queries |
| What rate limits apply to the commit query at scale? | **Unverified.** Irrelevant at the current six-source scale; matters if the base grows to hundreds |

None blocks planning. All three are recorded so a later reader knows they were not silently assumed.

## Sources

- `https://goose-docs.ai/docs/guides/recipes/recipe-reference/` — HTTP headers, 2026-07-31 — observed
- `https://goose-docs.ai/docs/mcp/developer-mcp/` — HTTP headers, 2026-07-31 — observed
- `repos/aaif-goose/goose` — repository tree and commit history via API, 2026-07-31 — authoritative
- `baselines/goose/2026-07-31b/` — this repository's shipped baseline — authoritative for its own content
