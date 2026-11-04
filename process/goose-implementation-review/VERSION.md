# Process Version

**1.1.0**

This is the semantic version of the review process itself, as required by Constitution Principle II
("Plans Are Versioned Artifacts").

## Three independent axes

This version is **not** the repository version and **not** the baseline revision. The three move for
different reasons and must never be conflated:

| Axis | Where | Increments when |
|---|---|---|
| **Process version** | this file | The review method changes |
| **Baseline revision** | `baselines/goose/<revision>/` | Upstream documentation changes, or criteria are added, corrected, retired |
| Repository version | the consuming repository | Irrelevant to a review; recorded nowhere in a report |

Every report names the process version **and** the baseline revision. With only one of them, a
reader cannot tell whether a changed finding came from a changed method or a changed yardstick —
the same distinction the delta rules require when comparing two reviews.

## Semantics

- **MAJOR** — the parameter contract or report format changes in a way that breaks existing
  consumers or invalidates existing golden files.
- **MINOR** — a stage or capability is added compatibly.
- **PATCH** — wording and clarification with no behavioral change.

## History

| Version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-07-31 | Initial. Pre-release: the process had not yet performed a real review |
| 0.2.0 | 2026-07-31 | Added the `DIGEST v1` block to the report format. Two real runs over an unchanged subject produced identical findings but differing prose, so byte-comparing whole reports was the wrong test for `FR-005`. The digest is the byte-stable core; prose is free |
| 1.0.0 | 2026-07-31 | **First release.** Added `max_bytes_per_pass`, Stage 3b (pinning, version mismatch, revision drift, offline) and Stage 6 (delta). Principle V's condition is met: 24 real reviews, a final self-review with no findings, and two foreign repositories |
| 1.0.1 | 2026-10-13 | Stage 0 builds the manifest with `find … -print0 \| xargs -r -0 sha256sum \| sort` instead of `find … -exec sha256sum {} \; \| sort`: the manifest and its hash are identical, and the `-exec` form is not permitted by every host. Stage 0 also says where the manifest is kept (in the run's notes, not in a file) and that a refusal of a combined call says nothing about its parts. The digest's `process=` field moves with this version, as it always does. Measured causes of the early stops are in `tests/goose-implementation-review/RESULTS.md`, "Feature 005 — Run 9" |
| 1.1.0 | 2026-10-13 | Five audits over the same file produced five different digests, from three causes now fixed in the text. A single-file subject has a defined manifest (`./<name>`, run from the parent directory), so two runs cannot hash the same bytes differently. A criterion delegated to the host is decided by the host and by nothing else, and is `undecided` when the host cannot be asked; reading the file is no substitute and never a pass. An `undecided` criterion finding is `advisory`, whatever the criterion declares. A criterion with no in-scope part is recorded as `pass` with that said. The process says how to work: file tools to look, the shell only for the manifest and the host invocation, the invocation made exactly as stated and without a preceding check, and a refusal of any other command is no reason to stop or to treat the host as unavailable. A derived probe is made by writing the complete subject, minus the one defect, to a new file; a shell copy and an in-place edit are not relied on. The claude-code binding gains the one host call the baseline needs, `goose run --recipe <file> --explain`, as a rule that names the whole invocation. Measurements are in `tests/goose-implementation-review/RESULTS.md`, "Feature 005 — Run 9" and "Run 10" |

**On reaching 1.0.0**: the format is now promised to consumers. From here, any change to the report
format or the parameter contract that breaks existing golden files is a genuine MAJOR bump, not a
minor one. The freedom to reshape the digest without ceremony ended with this release.

**What justified it**: Principle V requires an artifact to perform real work in this repository
before release. It has — 24 full reviews, including a final self-review that produced no findings at
all, and runs in two unrelated repositories with no edits to the process.
