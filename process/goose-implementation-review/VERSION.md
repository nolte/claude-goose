# Process Version

**1.0.0**

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

**On reaching 1.0.0**: the format is now promised to consumers. From here, any change to the report
format or the parameter contract that breaks existing golden files is a genuine MAJOR bump, not a
minor one. The freedom to reshape the digest without ceremony ended with this release.

**What justified it**: Principle V requires an artifact to perform real work in this repository
before release. It has — 24 full reviews, including a final self-review that produced no findings at
all, and runs in two unrelated repositories with no edits to the process.
