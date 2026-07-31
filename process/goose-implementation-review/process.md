# Review Process

**Version of record**: `VERSION.md` in this directory. This file describes the stages; that file
carries the semantic version they are released under.

A multi-stage, read-only review. Each stage below declares its preconditions, its output, the
condition under which it is complete, and how that completion is verified — a stage whose completion
only its author can judge is underspecified.

Stages run in order. A stage that fails its precondition aborts the run; no partial report is ever
written, because a partial report understates coverage without saying so.

---

## Stage 0 — Preflight

**Preconditions**

1. `subject_path` exists and is readable.
2. The requested `baseline_revision` exists and contains `ruleset.md`, `sources.md`,
   `coverage.md`, and `criterion-format.md`.
3. When `compare_to` is set, that report exists and names a baseline revision.

**Action**: Build the subject manifest and read the baseline revision and process version.

The manifest is built **exactly** this way — an underspecified manifest yields different hashes for
identical input, which has been observed:

```sh
# from within subject_path
find . -type f -exec sha256sum {} \; | sort
```

That is: one line per regular file, `<sha256><two spaces><path relative to subject_path>`, sorted by
byte value. The manifest hash reported in the digest is the SHA-256 of that output.

**Output**: The subject manifest and its hash; the resolved baseline revision id and Goose version.

**Complete when**: All preconditions hold and the manifest is recorded.

**Verification**: The manifest is non-empty and lists every file the subject discovery stage will
later examine. An empty manifest means the subject path resolved to nothing — abort rather than
report a clean review of nothing.

---

## Stage 1 — Subject discovery

**Precondition**: Stage 0 complete.

**Action**: Identify the in-scope parts of the subject: recipe definitions and the extension
configurations they declare. Everything else is out of scope by definition and is recorded as such,
not silently dropped.

**Output**: The list of in-scope parts, and the coverage statement's `examined` and `not_examined`
fields.

**Complete when**: Every file in the manifest is classified as either in-scope-and-examined,
in-scope-but-not-examined (with a reason), or out-of-scope.

**Verification**: The three classifications together account for every file in the Stage 0
manifest. A file that appears in none of them is an unreported gap in coverage.

**When nothing reviewable is found**: Produce a report stating that no recognizable recipe was
found. Do not produce a clean report — "nothing to review" and "nothing wrong" are different claims,
and conflating them is the failure this stage exists to prevent.

**When the subject is too large for one pass**: Review what fits, list the remainder in
`not_examined` with the reason, and continue. A partial review is acceptable; a partial review that
reads as complete is not.

---

## Stage 2 — Criterion evaluation

**Precondition**: Stage 1 complete; the in-scope list is non-empty.

**Action**: For each criterion in the baseline's `ruleset.md`, apply its `decision_procedure` to
each in-scope part it `applies_to`. Record the outcome.

**Outcomes**

| Outcome | When |
|---|---|
| `deviation` | The decision procedure establishes the expectation does not hold |
| `judgment call` | The criterion surfaces a documented property rather than a rule violation |
| `undecided` | The material does not permit a decision, or the topic is a declared baseline gap |
| *(no finding)* | The expectation holds |

**Output**: One finding per non-passing outcome, carrying `criterion_id`, `location`, `outcome`,
`severity`, and `rationale`.

**Complete when**: Every criterion has been evaluated against every part it applies to, and every
evaluation has produced either a finding or a recorded pass.

**Verification**: The count of evaluations equals criteria × applicable parts. Any criterion with no
recorded result was skipped, which would let an unevaluated criterion appear as a pass in the
`Criteria Applied` table.

**Wording constraint**: A finding's phrasing is bounded by its criterion's `evidence_class`. An
`authoritative` criterion may state that something is wrong; a `second-hand` one may only state that
something departs from common practice. Findings never exceed what their source supports.

**Derived probes**: where a criterion delegates to the host, the host stops at the first defect, so a
single invocation decides at most one criterion. To reach the rest, copy the subject to a scratch
location, neutralize the defect already found, and re-check. Repeat until the parser accepts.

Three rules govern this:

- **Never edit the subject**, not even temporarily. Probes live outside the subject tree; Stage 4
  proves it.
- **A finding decided against a probe says so** in its rationale, naming what was neutralized to
  reach it.
- **Probes are discarded** with the run. They are not part of the report and never overwrite
  anything under `subject_path`.

---

## Stage 3 — Undecided and gap handling

**Precondition**: Stage 2 complete.

**Action**: Two distinct sources of `undecided`, handled separately:

1. **Declared baseline gaps.** Walk `coverage.md`'s gap table in id order. For each gap, apply its
   stated "triggers a finding when" condition to the subject. If it holds, emit **exactly one**
   finding: outcome `undecided`, identified by the **gap id** (`GAP-…`), located at the in-scope part
   that triggered it, severity `advisory`, sourced to the gap entry. If it does not hold, record it
   in the coverage statement as not applicable and emit nothing.
2. **Criteria that could not be decided.** A criterion whose decision procedure could not be applied
   emits an `undecided` finding identified by its criterion id, stating what was missing.

**A gap finding names a gap id, never a criterion id.** Gaps have no criterion — substituting the
nearest one is guesswork, and two runs will guess differently. That was observed: one run labelled a
gap finding `R-006`, another omitted it entirely, and the digests diverged.

**Output**: The undecided findings, and the coverage statement's `baseline_gaps` field.

**Complete when**: Every gap in `coverage.md` has been evaluated against its trigger condition, and
each has produced either exactly one finding or a not-applicable note.

**Verification**: The count of gap findings plus not-applicable notes equals the number of gaps in
the baseline. Any gap appearing in neither list was skipped.

**Verification**: No criterion is recorded as passing whose topic is a declared gap. This is the
single check that prevents an incomplete baseline from producing false confidence — a gap silently
treated as a pass is worse than no review at all.

---

## Stage 4 — Read-only verification

**Precondition**: Stages 1–3 complete.

**Action**: Re-checksum every file under `subject_path` and compare against the Stage 0 manifest.

**Output**: Pass, or a hard failure naming every changed file.

**Complete when**: The comparison has run.

**Verification**: Checksums are identical. **Any difference fails the run and the report is
discarded**, even if the findings are correct. This process is pointed at repositories it does not
own; a review that modifies its subject has done something worse than being wrong.

**Why this stage carries the whole read-only promise**: the host's Developer extension — enabled by
default — exposes `shell`, `write` and `edit`, and can "run system commands with your user
privileges and edit any accessible file". Nothing technically prevents a write to the subject. This
stage is detection after the fact, not prevention. It is the only mechanism that can catch a
violation, which is why a checksum mismatch is a hard failure rather than a warning, and why the
report is discarded rather than annotated.

---

## Stage 5 — Report rendering

**Precondition**: Stage 4 passed.

**Action**: Render the report per `report-template.md`, sorted by severity then location. Emit the
`DIGEST v1` block immediately after the header, before any prose.

**Output**: A report at `output_path`.

**Complete when**: The report is written and contains a header, the digest, a coverage statement,
the findings, and the `Criteria Applied` table.

**On the digest**: it is the only part required to be byte-stable across runs. Emit it mechanically —
one line per finding, sorted by severity, then identity, then location, with no prose and no
trailing whitespace. Two runs over an unchanged subject and baseline that produce differing digests
are a real reproducibility failure; differing prose is not.

**Digest locations are structural, never line numbers**: `top-level`, `<key>`, `<key>[<name>]`, or
`<key>[<index>]` — for example `parameters[config_file]` or `extensions[0]`. Prose may and should
cite line numbers; the digest may not. A line number shifts when anything above it is edited, which
would make every unchanged finding look resolved-and-new on the next comparison.

**Verification**: Every finding carries `Criterion`, `Location` and `Source`. **A report containing
a finding missing any of the three is invalid and must not be written.** Publication is blocked, not
merely warned about.

---

## Invariants across all stages

- The subject is never written to.
- The subject is never executed. Findings come from reading the material.
- No stage consults upstream documentation live; criteria come from the pinned baseline revision.
- Identical subject content plus identical baseline revision yields identical findings.
- Nothing in this process refers to the repository it happens to live in.

## Stages not yet implemented

Declared here so their absence is visible rather than discovered later:

| Stage | Covers | Status |
|---|---|---|
| Baseline pinning and drift check | `FR-010` — reporting an available newer revision as its own finding | Planned, US2 |
| Version-mismatch handling | Subject built against a Goose version outside the baseline range | Planned, US2 |
| Offline behaviour | Upstream unreachable: proceed against the pinned baseline and say so, or refuse | Planned, US2 |
| Delta comparison | `FR-012` — classifying findings as new, resolved, unchanged, with cause | Planned, US4 |

Until these exist, a report produced by this process states its baseline revision but makes no claim
that the revision is current.
