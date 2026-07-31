# Criterion Format — Revision 2026-07-31

The schema the criteria in this revision conform to. This copy belongs to this revision and is never
updated in place; a later revision carries its own copy, which may differ.

**This file is self-sufficient**: anyone holding this revision can interpret its criteria from it
alone. It was derived from the review process's baseline contract, which lives in that process's own
project documentation — but a consumer of this revision neither has nor needs that document, and
this revision must never depend on it.

## Fields

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Stable identifier, unique within the baseline and stable across revisions so findings stay comparable over time |
| `expectation` | yes | What must hold, stated so it can be decided rather than debated |
| `decision_procedure` | yes | How to decide it from the material alone, without running the subject |
| `source` | yes | The documented rule this derives from, with URL and consulted date |
| `evidence_class` | yes | `authoritative`, `second-hand`, or `observed` |
| `severity` | yes | `blocking` or `advisory` |
| `applies_to` | yes | Which in-scope artifact type it examines |
| `host_enforced` | yes | `yes` if the host itself rejects a violating artifact, `no` if a violation can survive into a working system |
| `version_range` | no | Host versions the expectation holds for. Absent means all versions this revision declares |

## host_enforced changes what a criterion is worth

A criterion marked `host_enforced: yes` describes something the host already refuses to load. A
violating artifact never runs, so the review is not preventing a production defect — it is finding
the problem earlier and explaining it, rather than leaving the author to a one-line parser error.

That value is real but limited, and stating it per criterion keeps the ruleset honest about which of
its entries carry weight:

| | `host_enforced: yes` | `host_enforced: no` |
|---|---|---|
| Can a violation reach a running system? | No | **Yes** |
| What the review adds | Earlier detection, all findings at once, sourced rationale | The only check there is |
| Preferred `decision_procedure` | Delegate to the host's own validation — deterministic | Read the material |

**Where the host can decide a criterion, the decision procedure should delegate to it.** A finding
produced by the host's parser is reproducible by construction, not by convention — which is the
difference between a review whose findings can be trusted to be stable and one whose stability rests
on fixtures.

**A ruleset consisting only of `host_enforced: yes` criteria adds little.** Growth should favour
`no`: semantics, security posture, and practice, where nothing else is checking.

## The source field is structural

A criterion without `source` is not a weak criterion — it is **not a criterion**. It cannot be
expressed in this format and must not be added to a ruleset.

This is the structural enforcement of Constitution Principle VI. An expectation that seems obviously
right but cannot be traced to documentation belongs in the coverage declaration as a gap, or
upstream as a proposed rule — never in the ruleset as if it were established.

## Evidence classes

| Class | Meaning | Permitted phrasing |
|---|---|---|
| `authoritative` | Official documentation, upstream source, or release notes | "must" / "must not" |
| `second-hand` | Blog posts, forum answers, third-party guides | "commonly" — never stated as a rule |
| `observed` | Behavior seen directly but not documented | "observed in version X" — never generalized |

The class constrains how a finding derived from the criterion may be worded. A `second-hand`
criterion cannot produce a finding that says the subject is wrong; it can only say it departs from
common practice.

## Severity

| Severity | Meaning |
|---|---|
| `blocking` | Violates a documented rule, or creates a security or correctness defect |
| `advisory` | Departs from recommended practice without breaking a rule |

Severity may be lowered when a finding is reported, but only with a stated reason. It is never
lowered silently.
