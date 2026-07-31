# Source, Statement and Verification Record Formats

Applies across all revisions. Unlike `criterion-format.md`, which travels **inside** each revision
because criteria are interpreted against the schema in force when they were published, this file
describes how records are written and is shared.

Governed by `specs/002-qa-documentation-base/data-model.md`, which is normative where the two differ.

## Source Record

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Stable (`S-001`, …). Referenced by statements |
| `class` | yes | `authoritative` or `observed`. Nothing else is admissible |
| `url` | conditional | Required for `authoritative` |
| `source_path` | conditional | Repository path of the documentation source, when one exists |
| `source_commit` | conditional | Commit SHA that last touched `source_path` when consulted |
| `method` | conditional | Required for `observed`: how it was measured, reproducibly |
| `host_version` | yes | The Goose version this record applies to |
| `consulted` | yes | Date |
| `quote` | recommended | The passage relied upon, verbatim |
| `conflicts_with` | conditional | Other record ids this one contradicts |
| `resolution` | conditional | Required whenever `conflicts_with` is set |

### The two admissible classes

| Class | What it is | Permitted wording |
|---|---|---|
| `authoritative` | Official documentation; the upstream repository and its releases | "must", "is required" |
| `observed` | A reproducible measurement of actual behaviour | "observed to … in version X" — never "the documentation requires" |

**Community sources are inadmissible.** Blog posts and forum answers cannot back a statement. Where
behaviour can be reproduced, record it as an observation instead; where it cannot, the topic becomes
a declared gap. Search results have been seen serving stale content from a dead documentation host
with confident summaries attached, which is why this is a hard exclusion rather than a weak class.

### Invalid records

- `authoritative` without `url` — unverifiable by a third party.
- `observed` without `method` — unreproducible, therefore unfalsifiable.
- `conflicts_with` without `resolution` — naming a contradiction without saying how it was handled
  leaves the reader worse off than not naming it.

## Contradictions

`conflicts_with` and `resolution` exist because documentation and behaviour genuinely disagree, and
the disagreement is often the most valuable thing recorded.

**A resolution states which record governs *for which purpose*, not which one wins.** Declaring a
winner discards information; scoping preserves both.

The shipped example: `S-001` states "At least one of `instructions` or `prompt` must be present".
`S-003` measured that a recipe with neither is accepted at load time. `S-008` measured that a
headless run fails without `prompt` regardless. All three are true within their scope — the
documentation governs **loading**, the measurements govern **running**. Suppressing either side
would hide exactly what a reviewer needs to know.

## Statement fields

| Field | Required | Meaning |
|---|---|---|
| `text` | yes | The assertion, worded within the limits of its source's class |
| `source_ref` | yes | Which record backs it. **Structurally mandatory** |
| `version_range` | conditional | Required when the behaviour is version-specific |

**`version_range` is not optional politeness.** An unversioned claim about versioned behaviour is
invalid, not merely imprecise: a reader cannot tell whether it still applies, and a drift check
cannot tell whether it needs re-measuring.

## Verification Record

| Field | Required | Meaning |
|---|---|---|
| `source_id` | yes | Which record was checked |
| `checked` | yes | Date |
| `observed_commit` | conditional | The commit found at check time, for `authoritative` records |
| `result` | yes | `unchanged`, `drifted`, or `unreachable` |

**`verification.md` is append-only inside a published revision.** Adding a record is permitted;
editing or removing one is not. This is the single exception to revision immutability, and it exists
because confirming that nothing changed is not a change to the criteria.

`unreachable` is never recorded as `unchanged`. A check that could not run is not a check that
passed.
