# Lifecycle Version

**0.1.0**

The semantic version of the four-phase recipe lifecycle — requirements, plan, implementation, audit
— as a multi-stage plan, required by Constitution Principle II ("Plans Are Versioned Artifacts").
It is independent of the repository's release tag and of the review process version.

## Three independent axes

| Axis | Where | Increments when |
|---|---|---|
| **Lifecycle version** | this file | A phase's input, output, refusal conditions or delegation changes |
| **Review process version** | `process/goose-implementation-review/VERSION.md` | The review method changes |
| **Baseline revision** | `baselines/goose/<revision>/` | Criteria or sources change |

Every lifecycle artifact records the first two under distinct names, `lifecycle_version` and
`review_process_version`, and pins the third as `baseline_revision`. With only one of them a reader
cannot tell whether a changed outcome came from a changed phase, a changed review method or a
changed yardstick.

## Semantics

- **MAJOR** — a phase's input or output artifact changes shape so that an artifact written under the
  previous version is no longer accepted by the next phase, or a delegation target changes.
- **MINOR** — a phase gains a capability compatibly: a new operation, a new optional section, a new
  refusal that only rejects input the previous version would have mishandled.
- **PATCH** — wording and clarification with no behavioural change.

## History

| Version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-09-24 | Initial. Four skills authored; pre-release |

**0.x means pre-release.** Per Constitution Principle V the lifecycle is not released until every
skill has performed real work in this repository and one recipe has passed through all four phases.
The first release is 1.0.0.
