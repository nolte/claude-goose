# Contract: Review Report Format

**Feature**: `001-goose-implementation-review` | **Date**: 2026-07-31

Fixes the shape of a report so a third party — human or program — can read it without knowing how it
was produced. Plain-text and version-controllable per `FR-013`.

## Required structure

```markdown
# Review Report: <subject identity>

**Subject**: <location> (<revision, if any>)
**Process version**: <semver of the review process>
**Baseline**: <revision_id> for Goose <goose_version>
**Run date**: <YYYY-MM-DD>
**Compared to**: <prior report, or "none">

## Coverage

**Examined**: <in-scope parts reviewed>
**Not examined**: <parts skipped, each with reason — or "none">
**Baseline gaps**: <topics the baseline declares uncovered — or "none">

## Findings

### <severity>: <short title>

- **Criterion**: <criterion_id>
- **Location**: <file>:<position>
- **Outcome**: deviation | judgment call | undecided
- **Source**: <documented rule, with URL and consulted date>
- **Rationale**: <why>
- **Delta**: new | resolved | unchanged (cause: subject | baseline)   ← only when compared

## Criteria Applied

<list of criterion ids evaluated, including those that produced no finding>
```

## Rules

1. **Every finding carries an identity, a `Location`, and a `Source`.** The identity is a criterion
   id for criterion-derived findings, or a **gap id** (`GAP-…`) for findings derived from a declared
   baseline gap. A report containing a finding missing any of the three is invalid and must not be
   published (`SC-001`, `FR-002`).

   Gap findings have no criterion — that is what makes them gaps. Naming the "nearest" criterion is
   guesswork and is forbidden: two runs guessed differently, one labelling a gap finding `R-006` and
   another omitting it, which broke digest reproducibility.
2. **`Coverage` is mandatory even when complete.** "Not examined: none" is an explicit claim; its
   absence is not (`SC-006`).
3. **`Criteria Applied` is mandatory even when no findings resulted.** This is what distinguishes a
   clean subject from an unexamined one (`US1` scenario 2).
4. **Undecided outcomes appear as findings**, not omissions. They are never counted as passes
   (`FR-007`).
5. **Severity may be lowered from the criterion's default only with a stated reason** in the
   rationale. Silent downgrading is forbidden (Principle VI).
6. **Delta fields appear only when `compared_to` is set**, and must name the cause — subject or
   baseline. A finding that vanished because the baseline changed is not a fix (`FR-012`).

## The findings digest

Immediately after the header, every report carries a fenced block in exactly this form:

```text
DIGEST v1
baseline=<revision_id> process=<semver> subject=<sha256 of the subject manifest>
<criterion_id>|<location>|<outcome>|<severity>
<criterion_id>|<location>|<outcome>|<severity>
```

One line per finding, sorted by severity (blocking before advisory), then by criterion id, then by
location. No prose, no formatting, no trailing whitespace. A report with no findings carries the
header lines and nothing else.

### Location notation in the digest is structural, never positional

A digest location is `<path relative to subject_path>:<structural address>`, where the structural
address is:

| Address | Meaning |
|---|---|
| `top-level` | The document root — used when the finding concerns a missing or malformed top-level key |
| `<key>` | A top-level mapping key, e.g. `instructions` |
| `<key>[<name>]` | An entry in a keyed collection, addressed by its own name, e.g. `parameters[config_file]` |
| `<key>[<index>]` | An entry in an ordered collection with no name, e.g. `extensions[0]` |

**Line numbers must not appear in the digest.** Prose may cite them freely and should, because they
help a human find the spot.

The reason is `FR-012`. A finding must stay comparable across reviews; inserting one line at the top
of a subject shifts every line number, and a positional digest would then report every unchanged
finding as `resolved` plus an identical `new` one. Structural addresses survive reformatting.

This too was measured: two runs described the same finding as `recipe.yaml:44` and
`recipe.yaml:extensions[0]`. Both were correct and the digests still diverged.

### The subject manifest hash is defined exactly

`subject=` is the SHA-256 of a manifest built precisely as follows. Anything less specific produces
different hashes for identical input, which was observed in practice:

1. Take every regular file under `subject_path`, recursively.
2. For each, emit `<sha256 of the file's bytes><two spaces><path relative to subject_path>\n`.
3. Sort those lines by byte value, ascending.
4. The manifest is their concatenation; `subject=` is its SHA-256.

Equivalent to, from within `subject_path`:

```sh
find . -type f -exec sha256sum {} \; | sort | sha256sum
```

**Why this is spelled out.** Two runs over a byte-identical subject produced different `subject=`
values while agreeing exactly on the findings. The subject had not changed; the manifest had been
constructed two different ways — absolute versus relative paths, different sort order, or files
enumerated in filesystem order. An underspecified hash is worse than no hash: it reports a change
that did not happen.

**The digest is what `FR-005` is checked against.** Two runs over an unchanged subject and an
unchanged baseline must produce byte-identical digests. The surrounding prose need not match.

### Why the digest exists

The original contract required whole reports to be byte-identical. Measured against two real runs,
that failed: the findings were the same — one `undecided` for the same criterion at the same
location — while the wording differed ("are not covered by this baseline" versus "are outside the
baseline's coverage") and one run added an explanatory section.

Requiring byte-identical prose from an agent-driven process is the wrong demand: it fails on
harmless rephrasing and would push toward templated, less useful explanations. `FR-005` asks for
identical *findings*, not identical sentences. The digest separates the part that must be stable
from the part that should be free to explain well.

## Ordering

Findings in the prose section are sorted by severity, then by location, matching the digest.

## Not permitted

- Prose summaries that assert quality beyond what the findings support ("this recipe is well
  written"). The report states what was checked and what deviated — nothing more (Principle VI).
- Recommendations that alter the subject. The process is advisory and read-only (`FR-006`).
- Findings whose source is the reviewer's opinion. If no criterion covers it, it is not a finding;
  it belongs upstream as a proposed criterion in `002-qa-documentation-base`.
