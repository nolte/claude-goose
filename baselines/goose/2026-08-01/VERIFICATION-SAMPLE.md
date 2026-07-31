# Verification Sample — Revision 2026-08-01

**For a reader who did not author this material.** `SC-002` requires at least 95% of a sample to be
resolved **using only this document and the cited sources** — without asking the author and without
hunting.

This cannot be self-certified. The base wrote these citations; it is no witness to whether they
carry.

## How to check one row

1. Open the **URL**. Does the quoted text appear there and say what the row claims?
2. Where a row names a file, open it and confirm the thing described is there.
3. Tick ✓ only if both succeeded **without** consulting anything else.

Anything that sent you searching counts as unresolved — that is the point of the criterion.

**Time**: roughly 25–35 minutes. Rows 1–14 share two URLs.

## Sources

| Tag | Where |
|---|---|
| **REF** | https://goose-docs.ai/docs/guides/recipes/recipe-reference/ — source `documentation/docs/guides/recipes/recipe-reference.md` @ `3254d442c90c` |
| **DEV** | https://goose-docs.ai/docs/mcp/developer-mcp/ — source `documentation/docs/mcp/developer-mcp.md` @ `ceb94b24dc69` |
| **REPO** | https://github.com/aaif-goose/goose — release v1.45.0, published 2026-07-29 |
| **OBS** | A measurement recorded in this revision's `sources.md`. **No document states it.** |

## The sample

| # | Claim | Source | Quoted / reproducible evidence | ✓ |
|---|---|---|---|---|
| 1 | `title` and `description` are required recipe fields | REF | Listed under Required Fields | ☐ |
| 2 | At least one of `instructions` or `prompt` must be present | REF | "At least one of `instructions` or `prompt` must be present." | ☐ |
| 3 | Optional parameters must carry defaults | REF | "Optional parameters must have default values" | ☐ |
| 4 | File parameters may not carry defaults | REF | "File parameters cannot have default values to prevent importing sensitive files." | ☐ |
| 5 | Template variables and parameters must correspond exactly | REF | "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." | ☐ |
| 6 | Six extension types are documented | REF | `stdio`, `builtin`, `platform`, `streamable_http`, `frontend`, `inline_python` | ☐ |
| 7 | `inline_python` executes code | REF | "inline Python code executed using `uvx`" | ☐ |
| 8 | `inline_python` requires `code`, `timeout`, `description` | REF | Extension field table for that type | ☐ |
| 9 | `stdio` requires `cmd`, `args`, `timeout` | REF | Extension field table for that type | ☐ |
| 10 | `version` defaults to `"1.0.0"` when omitted | REF | Optional-field table. **This is why no criterion requires it** | ☐ |
| 11 | The Developer extension is enabled by default | DEV | "The Developer extension is already enabled by default when goose is installed." | ☐ |
| 12 | The reviewing agent can write to any accessible file | DEV | goose "can run system commands with your user privileges and edit any accessible file" | ☐ |
| 13 | This revision applies to Goose v1.45.0 | REPO | Latest release v1.45.0, published 2026-07-29 | ☐ |
| 14 | The documentation source is commit-addressable | REPO | `documentation/docs/guides/recipes/recipe-reference.md` exists; its last commit is `3254d442c90c` | ☐ |
| 15 | A recipe with neither `instructions` nor `prompt` is **accepted** | OBS | Reproduce: write such a recipe, run `goose run --recipe <f> --explain`. It loads | ☐ |
| 16 | A file parameter with a default **is** rejected | OBS | Reproduce: `goose run --recipe <f> --explain` on such a recipe | ☐ |
| 17 | A headless run fails without `prompt` | OBS | Reproduce: `goose run --no-session --recipe <f>` on a recipe with only `instructions` | ☐ |
| 18 | **Rows 2, 15 and 17 contradict each other, and all three are recorded** | this revision | `sources.md`, "Recorded contradiction". The resolution scopes rather than picks a winner | ☐ |
| 19 | `ETag`/`Last-Modified` are unusable as drift signals | OBS | Reproduce: `curl -I` both doc URLs. Identical `last-modified`; ETags differ only in a length component | ☐ |
| 20 | Community sources cannot back a statement | this revision | `SOURCE-FORMAT.md`, admissible classes. `sources.md` lists the dead `block.github.io` host as excluded | ☐ |

**Threshold**: 19 of 20 (95%).

## Rows built to be doubted

**Rows 15, 16, 17 and 19 cite OBS** — measurements, not documents. Each must read as an observation
of Goose 1.45.0. **If any reads as though the documentation required the behaviour, mark it
unresolved**: the claim would exceed its evidence class. All four are reproducible in under a minute
with the commands given.

**Row 18 is the most important in the sample.** It asks whether a contradiction was recorded rather
than smoothed away. Row 2 states a documented rule; rows 15 and 17 measured behaviour that departs
from it. If the revision presents a single tidy rule instead of the conflict, the base has destroyed
the most valuable thing it knows — mark it unresolved.

**Row 10** checks the opposite discipline: a plausible rule that was *rejected*. Requiring `version`
would be a preference dressed as a rule, since omitting it is documented behaviour.

## Result

- Resolved: ___ / 20
- `SC-002` met: ☐ yes ☐ no
- Checked by: ______________  Date: __________

Record the outcome in `verification.md`. Below threshold, the failing rows name exactly which
citations to fix.
