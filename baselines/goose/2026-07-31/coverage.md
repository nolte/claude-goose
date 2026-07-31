# Coverage — Revision 2026-07-31

**Goose version**: v1.45.0
**Revision published**: 2026-07-31

What this revision covers, and — more importantly — what it does not. The review process turns every
gap below into an `undecided` finding rather than a silent pass.

## Covered

| Topic | Criteria | Backed by | Host-enforced? |
|---|---|---|---|
| Recipe required fields | `R-001` | S-001, S-003 | yes |
| Recipe has instructions or prompt | `R-002` | S-001, S-003 | **no** |
| Recipe parameter rules | `R-003`, `R-004`, `R-005` | S-001, S-003 | yes |
| Extension type validity | `R-006` | S-001, S-003 | yes |
| Extension execution surface | `R-007` | S-001 | n/a — not a violation |

**Only `R-002` catches something the host lets through.** The other rule-checking criteria describe
conditions under which a recipe does not load at all; for those, this revision offers earlier
detection and sourced explanation rather than protection. See `criterion-format.md`, section
"host_enforced changes what a criterion is worth".

## Declared gaps

Each entry was investigated and left uncovered on purpose. None is an oversight.

**Every gap carries an id.** A gap produces findings just as a criterion does, but it has no
criterion to name — so it names its gap id instead. Without ids, two reviews of the same subject can
legitimately disagree about how to label a gap finding, which was observed and broke reproducibility.

**A gap produces exactly one `undecided` finding when, and only when, the subject contains an
in-scope part the gap applies to.** Gaps whose subject matter is absent, or out of review scope, are
noted in the coverage statement as not applicable and produce no finding.

| Id | Gap | Why uncovered | Triggers a finding when |
|---|---|---|---|
| `GAP-CONFIG` | **Configuration file** (`config.yaml`) — path, format, keys | `https://goose-docs.ai/docs/guides/config-file/` returned no readable content when consulted. A page of that name exists on the dead `block.github.io` host; whether it survived the migration is unconfirmed | Never — configuration files are out of review scope per `FR-001`. Recorded so a later revision does not mistake absence for irrelevance |
| `GAP-RECIPE-FIELDS` | **Recipe `response`, `retry`, `settings`, `sub_recipes` fields** | Documented as existing, but their validation rules were not consulted in depth | The subject declares at least one of those four fields |
| `GAP-EXT-INTERNALS` | **Extension configuration internals** | Extension *types* are documented and covered; what constitutes a well-formed configuration per type is not yet researched | The subject declares at least one extension |
| `GAP-CONTEXT` | **Context artifacts** — `.goosehints`, persistent instructions, prompt templates, skills | Out of review scope per `FR-001`. Their documentation was located but not researched | Never — out of review scope. Appears in `not_examined` if present |
| `GAP-AGENTS` | **Subagents, MCP apps, session recipes** | Out of review scope per `FR-001` | Never — out of review scope |
| `GAP-TRANSFER` | **Reason for the `block` → `aaif-goose` transfer** | Observed, never explained. No transfer notice found | Never — no criterion depends on it. Recorded because an unexplained ownership change is worth knowing |

## What a clean report against this revision means

That the subject's **recipe structure, parameter rules, and extension types** conform to the four
documented rules in S-001, as of Goose v1.45.0.

It does **not** mean the implementation is good, secure, or complete. This revision covers a narrow
slice deliberately: every criterion in it is backed by a directly consulted source. Growing the
covered set is the work of `002-qa-documentation-base`.
