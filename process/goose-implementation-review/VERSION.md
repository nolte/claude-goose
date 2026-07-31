# Process Version

**0.1.0**

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
| 0.1.0 | 2026-07-31 | Initial. Pre-release: the process has not yet performed a real review |

**0.x means pre-release.** Per Constitution Principle V, this process is not released until it has
performed a genuine review in its home repository — its own recipe being the first subject. The
first release version is 1.0.0.
