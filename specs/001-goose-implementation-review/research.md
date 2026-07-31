# Phase 0 Research: Goose Artifact Taxonomy

**Feature**: `001-goose-implementation-review`
**Consulted**: 2026-07-31
**Purpose**: Establish, from sources, which artifact types a Goose implementation consists of, so
`FR-001` (review scope) can be decided on evidence rather than assumption.

**Evidence classes used** (per `002-qa-documentation-base` FR-004):

- **A — direct**: page fetched and read during this research.
- **B — index**: content summarized from a search index, not fetched directly. Weaker: a search
  index can serve stale content (demonstrated below).
- **C — unverified**: encountered but not confirmed.

---

## Finding 0: Project ownership and canonical documentation moved

| | |
|---|---|
| **Decision** | Treat `goose-docs.ai` as the canonical documentation source. Treat `block.github.io/goose` as dead. |
| **Evidence** | A — direct |

- `github.com/block/goose` resolves to a repository owned by **`aaif-goose`**, described as "part of
  the Agentic AI Foundation (AAIF) at the Linux Foundation". The README links
  **https://goose-docs.ai/** as the documentation site.
- **https://block.github.io/goose/docs/guides/recipes/recipe-reference/ returned HTTP 404.**

**Why this matters beyond this feature**: Two independent web searches returned the dead
`block.github.io` URL as a top result *with confident content summaries attached*. Had that been
accepted at face value, this research would have cited a non-existent page as "official
documentation". This is the exact failure mode `002-qa-documentation-base` exists to prevent, and it
occurred on the very first lookup — evidence that its `FR-008` (detect unreachable or changed
sources) is a real requirement rather than a theoretical one.

**Open**: The rename from `block` to `aaif-goose` is observed, not explained. No transfer notice was
found. Recorded as an open question rather than narrated as a story.

---

## Finding 1: Recipes

| | |
|---|---|
| **Source** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ |
| **Evidence** | A — direct |

Recipes are YAML documents. Documented top-level fields:

- **Required**: `title` (String), `description` (String), and at least one of `instructions` or
  `prompt` — "At least one of `instructions` or `prompt` must be present."
- **Optional**: `version` (defaults to `"1.0.0"` when omitted), `activities`, `extensions`,
  `parameters`, `response`, `retry`, `settings`, `sub_recipes`.

Documented validation rules, quoted:

- "Optional parameters must have default values"
- "File parameters cannot have default values to prevent importing sensitive files."
- "All template variables must have corresponding parameter definitions, and all defined parameters
  must be used (no unused parameters)."

**Relevance**: These are directly checkable rules with a named source — exactly the shape a review
criterion needs (`FR-002`). The file-parameter rule is security-relevant.

---

## Finding 2: Extension types

| | |
|---|---|
| **Source** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ |
| **Evidence** | A — direct |

Six documented extension types, verbatim: `stdio`, `builtin`, `platform`, `streamable_http`,
`frontend`, `inline_python`.

**Relevance**: `inline_python` and `stdio` execute code or spawn processes; a review scope excluding
extensions would be blind to the highest-risk surface.

---

## Finding 3: Further user-authored artifact types

| | |
|---|---|
| **Source** | https://goose-docs.ai/ navigation and search restricted to that domain |
| **Evidence** | A — direct (that these documentation paths exist); B — index (their described content) |

| Artifact | Documented at |
| --- | --- |
| Skills | `/docs/guides/context-engineering/using-skills/` |
| Subagents | `/docs/guides/context-engineering/subagents` |
| MCP Apps | `/docs/tutorials/building-mcp-apps` |
| Session recipes | `/docs/guides/recipes/session-recipes` |
| Custom extensions | `/docs/tutorials/custom-extensions` |
| `.goosehints` | `/docs/guides/context-engineering/using-goosehints/` |
| Persistent instructions | `/docs/guides/context-engineering/using-persistent-instructions/` |
| Prompt templates | `/docs/guides/context-engineering/prompt-templates/` |

`.goosehints` details, evidence class **B** (search index, not fetched directly — treat as
provisional): a global file at `~/.config/goose/.goosehints` and local per-directory files;
hierarchical loading from working directory up to the repository root in git repos; local hints take
precedence over global on conflict.

---

## Finding 4: Not verified

| Item | Status |
| --- | --- |
| Configuration file (`config.yaml`) path, format, keys | **C — unverified.** `https://goose-docs.ai/docs/guides/config-file/` returned no readable content. A page of that name exists on the dead `block.github.io` host. Whether it survived the migration is unconfirmed. Not blocking: configuration files are out of scope per `FR-001`. |
| Reason for the `block` → `aaif-goose` transfer | **C — unverified.** Observed, not explained. No transfer notice found. |

### Resolved after initial write

**Current Goose release version — now A (direct).** Queried via the GitHub API on 2026-07-31:
latest release **`v1.45.0`**, published 2026-07-29T20:11:39Z, at
`https://github.com/aaif-goose/goose/releases/tag/v1.45.0`.

The same query independently confirms Finding 0: requesting `repos/block/goose` returns
`full_name: aaif-goose/goose`, i.e. the old path resolves to the new owner. The repository is not
archived and was last pushed 2026-07-31, so the project is active under the new owner.

This satisfies `FR-004` (a baseline states the Goose version its criteria apply to) and closes the
Principle IV gate, which requires the supported host-contract version to be stated explicitly.

These are recorded as gaps rather than filled by inference, per Constitution Principle VI.

---

## Decision pending

The artifact taxonomy is now established well enough to decide `FR-001`. The scope decision itself
is the operator's and is not derivable from research — see the options put to the operator alongside
this document. `FR-010` is already resolved: the baseline is the pinned, curated ruleset of
`002-qa-documentation-base` plus an upstream drift check.

## Sources

- [goose (repository)](https://github.com/block/goose) — A
- [Recipe Reference Guide](https://goose-docs.ai/docs/guides/recipes/recipe-reference/) — A
- [goose documentation home](https://goose-docs.ai/) — A
- [Providing Hints to goose](https://goose-docs.ai/docs/guides/context-engineering/using-goosehints/) — B
- [Context Engineering](https://goose-docs.ai/docs/guides/context-engineering/) — B
- [Agent Skills](https://goose-docs.ai/docs/guides/context-engineering/using-skills/) — B
- `https://block.github.io/goose/docs/guides/recipes/recipe-reference/` — **dead, HTTP 404**
