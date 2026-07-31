# Sources — Revision 2026-08-02

Every criterion in `ruleset.md` traces to an entry here. A source that is not recorded in this file
cannot back a criterion.

## Evidence classes

- **A — direct**: the page was fetched and read while compiling this revision.
- **B — index**: content summarized from a search index, not fetched directly. Weaker, because a
  search index can serve stale content.
- **C — unverified**: encountered but not confirmed. Cannot back a criterion; belongs in
  `coverage.md` as a gap.

## Records

### S-001 — Recipe Reference Guide

| | |
|---|---|
| **URL** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ |
| **source_path** | `documentation/docs/guides/recipes/recipe-reference.md` |
| **source_commit** | `3254d442c90c` (2026-05-16) |
| **Applies to Goose version** | v1.45.0 |
| **Consulted** | 2026-07-31 |
| **Evidence class** | A — direct (`authoritative`) |
| **conflicts_with** | `S-003`, `S-008` — see "Recorded contradiction" below |
| **quote** | "At least one of `instructions` or `prompt` must be present." / "Optional parameters must have default values" / "File parameters cannot have default values to prevent importing sensitive files." / "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." |

Backs the recipe structure and parameter criteria. Statements taken verbatim:

- "At least one of `instructions` or `prompt` must be present."
- "Optional parameters must have default values"
- "File parameters cannot have default values to prevent importing sensitive files."
- "All template variables must have corresponding parameter definitions, and all defined parameters
  must be used (no unused parameters)."

Documented required fields: `title` (String), `description` (String), plus one of `instructions` or
`prompt`. Documented optional fields: `version` (defaults to `"1.0.0"`), `activities`, `extensions`,
`parameters`, `response`, `retry`, `settings`, `sub_recipes`.

Documented extension types, verbatim: `stdio`, `builtin`, `platform`, `streamable_http`, `frontend`,
`inline_python`.

### S-002 — Goose repository and release

| | |
|---|---|
| **URL** | https://github.com/aaif-goose/goose |
| **Release consulted** | v1.45.0, published 2026-07-29T20:11:39Z |
| **Consulted** | 2026-07-31 |
| **Evidence class** | A — direct (GitHub API) |

Establishes the host version this revision applies to. Also records that the project moved: a query
for `repos/block/goose` returns `full_name: aaif-goose/goose`. The repository is not archived and
was last pushed 2026-07-31.

### S-003 — Host enforcement, measured locally

| | |
|---|---|
| **Method** | `goose run --recipe <probe> --explain` against isolated single-violation probe recipes |
| **Goose version** | 1.45.0 |
| **Measured** | 2026-07-31 |
| **Evidence class** | **C — observed**. Not documented anywhere; this is behavior seen directly |

Backs the `host_enforced` field on every criterion. Results:

| Probe | Verdict | Message (truncated) |
|---|---|---|
| `description` absent | rejected | "missing field `description`" |
| Optional parameter without default | rejected | "Optional parameters missing default values in the recipe: opt" |
| File parameter with default | rejected | "File parameters cannot have default values to avoid importing s…" |
| Parameter defined but unused | rejected | *(message empty)* |
| Template variable undefined | rejected | "Missing definitions for parameters in the recipe file: …" |
| Unknown extension type | rejected | "unknown variant `nonsense_type`, expected o…" |
| **Neither `instructions` nor `prompt`** | **accepted** | — |
| Well-formed `inline_python` | accepted | — |

**Scope limit**: these are observations of `--explain`, which loads and validates a recipe. Whether
a full execution behaves identically was not tested. Per the evidence rules, nothing here may be
generalized beyond "observed in Goose 1.45.0 under `--explain`".

**Why this matters**: the one *accepted* violation is R-002, a rule the documentation states
plainly. Documented rule and implemented behavior disagree, and only a review catches the gap.

### S-004 — Extension entry required fields

| | |
|---|---|
| **URL** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ |
| **source_path** | `documentation/docs/guides/recipes/recipe-reference.md` |
| **source_commit** | `3254d442c90c` (2026-05-16) |
| **Applies to Goose version** | v1.45.0 |
| **Consulted** | 2026-07-31 |
| **Evidence class** | A — direct (`authoritative`) |

| Type | Required fields |
|---|---|
| `inline_python` | `type`, `name`, `code`, `timeout`, `description`; optional `dependencies` |
| `stdio` | `type`, `name`, `cmd`, `args`, `timeout` |
| `builtin` | No dedicated example given; `type` and `name` alone were accepted (S-003) |

Not yet promoted to criteria — see `ruleset.md`, "Criteria deliberately not included".

### S-005 — Developer extension capabilities

| | |
|---|---|
| **URL** | https://goose-docs.ai/docs/mcp/developer-mcp/ |
| **source_path** | `documentation/docs/mcp/developer-mcp.md` |
| **source_commit** | `ceb94b24dc69` (2026-07-17) |
| **Applies to Goose version** | v1.45.0 |
| **Consulted** | 2026-07-31 |
| **Evidence class** | A — direct (`authoritative`) |
| **quote** | "The Developer extension is already enabled by default when goose is installed." / goose "can run system commands with your user privileges and edit any accessible file" |

The Developer extension "is already enabled by default when goose is installed" and exposes `shell`,
`write`, `edit`, `tree`, `read_image`. Per the same page, goose "can run system commands with your
user privileges and edit any accessible file".

Backs no criterion. Recorded because it establishes that a reviewing agent holds write capability
over its subject by default, which is why the process verifies read-only behavior by checksum rather
than assuming it.


### S-006 — `input_type: file` substitutes content, not a path

| | |
|---|---|
| **Method** | `goose run --recipe <r> --params subject_path=<directory>` |
| **Goose version** | 1.45.0 |
| **Measured** | 2026-07-31 |
| **Evidence class** | **C — observed** |

Passing a directory to a `file` parameter fails with `Failed to read parameter file <dir>: Is a
directory (os error 21)`. The parameter is not a path handle: Goose reads the file and substitutes
its contents.

Backs the data-flow note on R-004. It explains the documented rationale ("to prevent importing
sensitive files") in mechanical terms: a default on a file parameter inlines the referenced file.

### S-007 — Template scanning includes YAML comments

| | |
|---|---|
| **Method** | Neutralizing R-005 defects in derived probes during a review run |
| **Goose version** | 1.45.0 |
| **Measured** | 2026-07-31 |
| **Evidence class** | **C — observed** |

The host continued to report a template variable as undefined when its only remaining occurrence was
inside a `#` comment. Template scanning appears to run over the raw text rather than the parsed
document.

Backs the location caveat on R-005. Backs no criterion of its own.

### S-008 — Headless execution requires `prompt`

| | |
|---|---|
| **Method** | `goose run --no-session --recipe <r>` on a recipe declaring `instructions` but no `prompt` |
| **Goose version** | 1.45.0 |
| **Measured** | 2026-07-31 |
| **Evidence class** | **C — observed** |

The recipe loaded and validated, then failed at execution with `Error: no text provided for prompt in
headless mode`.

Backs **R-010**. Note the disagreement with S-001, which states only that "at least one of
`instructions` or `prompt` must be present" — that holds for loading, not for headless execution. No
consulted document records the stricter runtime requirement, which is why R-010 carries
`evidence_class: observed` and must be worded as an observation.

### S-009 — Extension field value semantics: searched, nothing authoritative found

| | |
|---|---|
| **URL** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ |
| **source_path** | `documentation/docs/guides/recipes/recipe-reference.md` |
| **source_commit** | `3254d442c90c` (2026-05-16) |
| **Applies to Goose version** | v1.45.0 |
| **Consulted** | 2026-07-31 |
| **Evidence class** | A — direct (`authoritative`) for the *absence*, which is itself a finding |

**What was searched**: constraints on extension field *values*, as opposed to which fields are
required.

**What was found**: types only.

| Field | Documented | Constraint on values |
|---|---|---|
| `timeout` | Number | **None** — no units, minimum, maximum or default stated. Examples show `300` and `60` |
| `cmd` | String | **None** — "no formal specification of required format or syntax" |
| `args` | Array | **None** — examples show string elements; whether flags are permitted is unstated |
| `bundled` | Boolean | **None** operational — only "Whether the extension is bundled with goose" |

**Why no criterion follows.** A rule about acceptable values would have to invent the threshold. A
timeout ceiling, a required `cmd` shape, a convention for `args` — each is plausible and none is
sourced. `GAP-EXT-SEMANTICS` therefore stays open, but narrowed: it is no longer "not researched",
it is "researched, and the documentation is silent".

That distinction matters to a reader deciding whether to repeat the search.

## Recorded contradiction — S-001 versus S-003 and S-008

**The documentation and the measured behaviour disagree, and both are true within their scope.**
Recorded rather than resolved away, per `FR-005` and `SC-007`.

| | |
|---|---|
| **Records** | `S-001` (authoritative) contradicted by `S-003` and `S-008` (observed) |
| **The documented claim** | "At least one of `instructions` or `prompt` must be present." |
| **What was measured** | `S-003`: a recipe with **neither** key is accepted at load time. `S-008`: a headless run fails without `prompt`, even when `instructions` is present |

**Resolution — by scope, not by winner:**

- **`S-001` governs loading.** For the question "will this recipe validate?", the documentation
  understates the tolerance: the parser accepts what the text forbids.
- **`S-003` and `S-008` govern running.** For the question "will this recipe do anything?", the
  measurements are decisive and the documentation is silent.

Declaring one record the winner would discard information. `R-002` rests on `S-003`, `R-010` on
`S-008`, and both are marked `host_enforced: no` precisely because of this split — they are the only
two criteria in the base that catch what the host lets through.

**A reader must be able to see this contradiction from the revision alone.** If a future edit
smooths it into a single tidy rule, that edit has destroyed the most valuable thing recorded here.

## Sources deliberately excluded

| Source | Why excluded |
|---|---|
| `https://block.github.io/goose/…` | **Dead — HTTP 404 as of 2026-07-31.** Still surfaced prominently by search engines *with cached content summaries attached*. Anything sourced from it would cite a page that no longer exists |
| `block-goose.mintlify.app` | Encountered in search results; not confirmed as canonical. The repository links `goose-docs.ai` |

The dead host is recorded rather than merely dropped: a future compiler of this baseline will meet
the same search results and needs to know they were already checked and rejected.
