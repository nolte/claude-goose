# Ruleset — Revision 2026-07-31

**Goose version**: v1.45.0 | **Format**: see `criterion-format.md` in this directory

Every criterion below traces to a record in `sources.md`. Criteria are ordered by id, not by
importance.

## Which criteria actually carry weight

Each criterion records `host_enforced`, measured against Goose 1.45.0 (see S-003). It changes what a
finding is worth:

| Criterion | host_enforced | Consequence |
|---|---|---|
| R-001 | yes | A violating recipe does not load |
| **R-002** | **no** | **A violating recipe loads. Only this review catches it** |
| R-003 | yes | Does not load |
| R-004 | yes | Does not load |
| R-005 | yes | Does not load |
| R-006 | yes | Does not load |
| R-007 | no | Not a violation at all — a documented property, surfaced for a trust decision |

R-002 is the most valuable entry in this revision, and the least expected: the documentation states
the rule plainly, yet the parser accepts a recipe that breaks it.

## How host delegation actually behaves

Criteria marked `host_enforced: yes` delegate their decision to `goose run --recipe <file>
--explain`. **The host stops at the first defect.** One invocation therefore decides at most one
criterion, and which one depends on the parser's internal order — not on the ruleset's.

Deciding the remaining criteria requires **derived probes**: a copy of the subject with the
already-found defect neutralized, re-checked, and repeated until the parser accepts the file. This
was observed on the first real review run, which reached R-004, R-005 and R-006 only by that route.

Consequences a reviewer must respect:

1. **Probes are copies. The subject is never edited** — not even temporarily. Derived probes belong
   outside the subject tree, and Stage 4's checksum comparison is what proves the rule was kept.
2. **A finding decided against a probe must say so** in its rationale. It was decided against a
   near-copy, not the original, and a reader deserves to know which.
3. **Delegation is deterministic per invocation, not per review.** The parser's verdict on a given
   file is reproducible; the *sequence* of probes an agent constructs to get there is not
   necessarily identical between runs. Claims that host delegation makes findings "deterministic by
   construction" hold for a single check, not for a whole report.

---

## R-001 — Recipe declares its required fields

| | |
|---|---|
| **expectation** | The recipe declares `title` and `description`, both non-empty strings |
| **decision_procedure** | Delegate to the host: `goose run --recipe <file> --explain`. Rejection naming a missing required field is the finding. Falls back to parsing the file when the host is unavailable |
| **source** | S-001 — Recipe Reference Guide, "Required Fields", consulted 2026-07-31 |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured: rejected with "missing field `description`" (S-003) |

---

## R-002 — Recipe carries instructions or prompt

| | |
|---|---|
| **expectation** | At least one of `instructions` or `prompt` is present |
| **decision_procedure** | Read the recipe. Check for either key at the top level. Absence of both is a deviation; presence of both is not. **The host cannot decide this** |
| **source** | S-001, verbatim: "At least one of `instructions` or `prompt` must be present." |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `no` — measured: a recipe with neither key was **accepted** by `--explain` (S-003) |

**This is the criterion that justifies the review.** The rule is documented as a "must", but the
parser does not enforce it: a recipe with neither `instructions` nor `prompt` loads without
complaint. A violating recipe therefore reaches a running system, where it presumably does nothing
useful, and nothing but a review will say why.

**Measurement caveat**: acceptance was observed under `--explain`, which loads and validates a
recipe. Whether a full execution also tolerates the omission was not tested. The criterion holds
either way — this note records the limit of what was measured.

---

## R-003 — Optional parameters carry defaults

| | |
|---|---|
| **expectation** | Every parameter not marked required declares a default value |
| **decision_procedure** | Delegate to the host: `goose run --recipe <file> --explain`. Rejection naming the parameter is the finding |
| **source** | S-001, verbatim: "Optional parameters must have default values" |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured: rejected with "Optional parameters missing default values in the recipe: opt" (S-003) |

---

## R-004 — File parameters carry no defaults

| | |
|---|---|
| **expectation** | No parameter of file type declares a default value |
| **decision_procedure** | Delegate to the host: `goose run --recipe <file> --explain`. Rejection naming the parameter is the finding |
| **source** | S-001, verbatim: "File parameters cannot have default values to prevent importing sensitive files." |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured: rejected with "File parameters cannot have default values to avoid importing s…" (S-003) |

**Note**: the source states the rule *and* its reason. The host's own error message echoes it almost
verbatim, which is unusually strong corroboration that the documented intent matches the
implementation.

---

## R-005 — Template variables and parameters correspond exactly

| | |
|---|---|
| **expectation** | Every template variable used has a matching parameter definition, and every defined parameter is used |
| **decision_procedure** | Delegate to the host: `goose run --recipe <file> --explain`. Rejection in either direction is the finding |
| **source** | S-001, verbatim: "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured in both directions: an undefined variable and an unused parameter were each rejected (S-003) |

---

## R-006 — Declared extension types are documented types

| | |
|---|---|
| **expectation** | Every entry in `extensions` declares a type from the documented set: `stdio`, `builtin`, `platform`, `streamable_http`, `frontend`, `inline_python` |
| **decision_procedure** | Delegate to the host: `goose run --recipe <file> --explain`. Rejection naming an unknown variant is the finding |
| **source** | S-001 — Recipe Reference Guide, extension types listed verbatim, consulted 2026-07-31 |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | extension configuration |
| **host_enforced** | `yes` — measured: rejected with "unknown variant `nonsense_type`" (S-003) |

**Related, not yet a criterion**: each extension type also has required fields — `inline_python`
needs `code`, `timeout`, `description`; `stdio` needs `cmd`, `args`, `timeout` (S-004). These are
host-enforced too, and are candidates for a future revision.

---

## R-007 — Code-executing extensions are surfaced

| | |
|---|---|
| **expectation** | Where a recipe declares an extension of type `inline_python` or `stdio`, the review surfaces it so the operator makes the trust decision knowingly |
| **decision_procedure** | Read the recipe's `extensions`. Each entry of type `inline_python` or `stdio` produces one finding with outcome `judgment call` |
| **source** | S-001 — the documentation describes `inline_python` as "inline Python code executed using `uvx`" and `stdio` as a Standard I/O client |
| **evidence_class** | `authoritative` (for the fact that these types execute code) |
| **severity** | `advisory` |
| **applies_to** | extension configuration |
| **host_enforced** | `no` — measured: a well-formed `inline_python` extension is accepted, as it should be. Nothing here is a violation (S-003) |

**This criterion asserts no rule violation, and must not be worded as one.** No consulted source says
a recipe should avoid these types. What *is* documented is that they execute code and spawn
processes; that fact alone is reportable, because a reviewer deciding whether to trust a third-party
recipe needs to see it.

A finding from R-007 therefore reads "this recipe executes code, here" — never "this recipe should
not execute code". The moment it is phrased as a rule, it becomes an unsourced expectation, which
`criterion-format.md` forbids.

---

## Criteria deliberately not included

| Candidate | Why excluded |
|---|---|
| Recipe `version` should be set explicitly | The documentation states `version` defaults to `"1.0.0"` when omitted. That makes omission *documented behavior*, not a deviation. Requiring it would be a preference dressed as a rule |
| Naming, structure, or readability conventions | No consulted source establishes any. They belong upstream as proposed rules, not here |
| Validation rules for `response`, `retry`, `settings`, `sub_recipes` | Documented as existing; their rules were not consulted in depth. Declared as a gap in `coverage.md` so subjects using them report `undecided` rather than passing |
| Per-type required extension fields | Verified (S-004) and host-enforced, but arrived after this revision's criteria were fixed. Candidate for the next revision |
