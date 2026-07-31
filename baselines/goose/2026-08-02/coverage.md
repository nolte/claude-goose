# Coverage — Revision 2026-08-02

**Goose version**: v1.45.0
**Revision published**: 2026-07-31
**Supersedes**: `2026-08-01` (retained, unmodified)

What this revision covers, and — more importantly — what it does not. The review turns every gap
below into an `undecided` finding rather than a silent pass.

## Covered

| Topic | Criteria | Backed by | Host-enforced? |
|---|---|---|---|
| Recipe required fields | `R-001` | S-001, S-003 | yes |
| Recipe has instructions or prompt | `R-002` | S-001, S-003 | **no** |
| Recipe parameter rules | `R-003`, `R-004`, `R-005` | S-001, S-003, S-006 | yes |
| Extension type validity | `R-006` | S-001, S-003 | yes |
| Extension execution surface | `R-007` | S-001 | n/a — not a violation |
| Extension required fields per type | `R-008`, `R-009` | S-004, S-003 | yes |
| Headless runnability | **`R-010`** | S-008 | **no** |

**Two criteria catch what the host lets through**: `R-002` and `R-010`. The rest offer earlier
detection and sourced explanation for defects that would never load anyway. See
`criterion-format.md`, "host_enforced changes what a criterion is worth".

## Declared gaps

Each entry was investigated and left uncovered on purpose. None is an oversight.

**Every gap carries an id.** A gap produces findings just as a criterion does, but has no criterion
to name — so it names its gap id. Without ids, two reviews can legitimately disagree about how to
label a gap finding, which was observed and broke reproducibility.

**A gap produces exactly one `undecided` finding when, and only when, the subject contains an
in-scope part the gap applies to.** Gaps whose subject matter is absent or out of review scope are
noted in the coverage statement as not applicable and produce no finding.

| Id | Gap | Why uncovered | Triggers a finding when |
|---|---|---|---|
| `GAP-CONFIG` | **Configuration file** (`config.yaml`) — path, format, keys | `https://goose-docs.ai/docs/guides/config-file/` returned no readable content when consulted. A page of that name exists on the dead `block.github.io` host; whether it survived the migration is unconfirmed | Never — out of review scope per `FR-001` |
| `GAP-RECIPE-FIELDS` | **Recipe `response`, `retry`, `settings`, `sub_recipes` fields** | Documented as existing, but their validation rules were not consulted in depth | The subject declares at least one of those four fields |
| `GAP-EXT-SEMANTICS` | **Semantic correctness of extension field values** | **Researched (S-009); the documentation is silent.** It specifies field *types* but no constraints on values: `cmd` has "no formal specification of required format or syntax", `timeout` no units or bounds, `bundled` no operational meaning. A rule here would have to invent its threshold | The subject declares at least one extension |
| `GAP-CONTEXT` | **Context artifacts** — `.goosehints`, persistent instructions, prompt templates, skills | Out of review scope per `FR-001`. Documentation located but not researched | Never — out of scope. Appears in `not_examined` if present |
| `GAP-AGENTS` | **Subagents, MCP apps, session recipes** | Out of review scope per `FR-001` | Never — out of scope |
| `GAP-TRANSFER` | **Reason for the `block` → `aaif-goose` transfer** | Observed, never explained. No transfer notice found | Never — no criterion depends on it |

### Change from 2026-08-01

`GAP-EXT-SEMANTICS` was **narrowed, not closed**. It is no longer "not yet researched" but
"researched, and nothing authoritative exists" — recorded as `S-009` so the search is not repeated
blindly. **No criterion was added**, because every candidate rule would have required inventing a
threshold the documentation does not state.

A comparison between a report against `2026-08-01` and one against this revision will show no delta
at all: the gap still fires under the same condition. That is correct. Narrowing what is *known
about* a gap does not change what a review can *decide*.

### Change carried forward from 2026-07-31b

No gap was opened or closed. What changed is that every authoritative source now carries a drift
anchor, so a gap can no longer be silently outdated: if the documentation behind a covered topic
moves, the check says so.

### Change carried forward from 2026-07-31

`GAP-EXT-INTERNALS` was **narrowed and renamed** to `GAP-EXT-SEMANTICS`. Its field-presence half is
now covered by `R-008` and `R-009`; only value semantics remain uncovered.

**Consequence for comparisons across revisions**: a report against `2026-07-31` carrying a
`GAP-EXT-INTERNALS` finding, compared against a report using this revision, will show that finding as
`resolved` with cause `baseline` — not `subject`. Nothing about the subject changed; the baseline
learned to check part of what it previously declared unknown. This is exactly the distinction
`FR-012` requires be made visible.

## What a clean report against this revision means

That the subject's **recipe structure, parameter rules, extension types, extension required fields,
and headless runnability** conform to the criteria above, as of Goose v1.45.0.

It does **not** mean the implementation is good, secure, or complete. This revision still covers a
narrow slice deliberately: every criterion is backed by a directly consulted source or a recorded
measurement. Growing the covered set is the work of `002-qa-documentation-base`.
