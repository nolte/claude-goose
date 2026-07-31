# Ruleset — Revision 2026-08-01

**Goose version**: v1.45.0 | **Format**: see `criterion-format.md` in this directory
**Supersedes**: `2026-07-31b` (retained, unmodified)

Every criterion below traces to a record in `sources.md`. Criteria are ordered by id.

## What changed from 2026-07-31b

| Change | Detail |
|---|---|
| **Drift anchors** | Every authoritative source record now carries `source_path` and `source_commit`, so staleness is detectable at all. Previously it was not |
| **`version_range` mandatory** | Every criterion states the host versions it holds for. An unversioned claim about versioned behaviour is invalid, not merely imprecise |
| **Contradiction recorded** | `S-001` versus `S-003`/`S-008` is documented with a scoped resolution — see `sources.md` |
| Criteria R-001 … R-010 | **Unchanged in substance.** No expectation, decision procedure or severity was altered |

**No criterion changed meaning.** A report produced against `2026-07-31b` remains valid; this
revision adds the ability to tell when its sources go stale.

## Which criteria actually carry weight

| Criterion | host_enforced | Consequence |
|---|---|---|
| R-001 | yes | Does not load |
| **R-002** | **no** | **Loads, then does nothing useful** |
| R-003 | yes | Does not load |
| R-004 | yes | Does not load |
| R-005 | yes | Does not load |
| R-006 | yes | Does not load |
| R-007 | n/a | Not a violation — a documented property surfaced for a trust decision |
| R-008 | yes | Does not load |
| R-009 | yes | Does not load |
| **R-010** | **no** | **Loads, passes validation, fails at run time in headless mode** |

Two of ten catch something the host lets through. Those two are the reason this review exists; the
rest offer earlier detection and sourced explanation.

## How host delegation actually behaves

Criteria marked `host_enforced: yes` delegate to `goose run --recipe <file> --explain`. **The host
stops at the first defect**, so one invocation decides at most one criterion, in the parser's order
rather than the ruleset's.

Reaching the rest requires **derived probes**: a copy of the subject with the found defect
neutralized, re-checked, repeated until the parser accepts. Three rules govern this:

1. **Probes are copies. The subject is never edited** — Stage 4's checksum comparison proves it.
2. **A finding decided against a probe says so** in its rationale, naming what was neutralized.
3. **Delegation is deterministic per invocation, not per review.** The parser's verdict on a given
   file reproduces; the sequence of probes an agent builds to get there need not.

---

## R-001 — Recipe declares its required fields

| | |
|---|---|
| **expectation** | The recipe declares `title` and `description`, both non-empty strings |
| **decision_procedure** | Delegate to the host: `goose run --recipe <file> --explain`. Rejection naming a missing required field is the finding |
| **source** | S-001 — Recipe Reference Guide, "Required Fields", consulted 2026-07-31 |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

---

## R-002 — Recipe carries instructions or prompt

| | |
|---|---|
| **expectation** | At least one of `instructions` or `prompt` is present |
| **decision_procedure** | Read the recipe. Check for either key at the top level. **The host cannot decide this** |
| **source** | S-001, verbatim: "At least one of `instructions` or `prompt` must be present." |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `no` — measured: a recipe with neither key was **accepted** (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

See also `R-010`, which is stricter and covers the headless case specifically.

---

## R-003 — Optional parameters carry defaults

| | |
|---|---|
| **expectation** | Every parameter not marked required declares a default value |
| **decision_procedure** | Delegate to the host. Rejection naming the parameter is the finding |
| **source** | S-001, verbatim: "Optional parameters must have default values" |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

---

## R-004 — File parameters carry no defaults

| | |
|---|---|
| **expectation** | No parameter of `input_type: file` declares a default value |
| **decision_procedure** | Delegate to the host. Rejection naming the parameter is the finding |
| **source** | S-001, verbatim: "File parameters cannot have default values to prevent importing sensitive files." |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

**Why this rule is about data flow, not schema tidiness** (S-006): `input_type: file` does not pass a
path — Goose **reads the file and substitutes its contents**. A default therefore inlines whatever it
points at, which is precisely the "importing sensitive files" the rule names. A reviewer should treat
a violation as a potential data leak, not a style error.

---

## R-005 — Template variables and parameters correspond exactly

| | |
|---|---|
| **expectation** | Every template variable used has a matching parameter definition, and every defined parameter is used |
| **decision_procedure** | Delegate to the host. Rejection in either direction is the finding |
| **source** | S-001, verbatim: "All template variables must have corresponding parameter definitions, and all defined parameters must be used (no unused parameters)." |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `yes` — measured in both directions (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

**Known host behaviour** (S-007): the host matches `{{ … }}` in YAML comments as well as in live
values, so a variable mentioned only in a comment still counts as used. A location derived from the
host's message alone may therefore point at a comment.

---

## R-006 — Declared extension types are documented types

| | |
|---|---|
| **expectation** | Every entry in `extensions` declares a type from the documented set: `stdio`, `builtin`, `platform`, `streamable_http`, `frontend`, `inline_python` |
| **decision_procedure** | Delegate to the host. Rejection naming an unknown variant is the finding |
| **source** | S-001 — extension types listed verbatim, consulted 2026-07-31 |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | extension configuration |
| **host_enforced** | `yes` — measured (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

---

## R-007 — Code-executing extensions are surfaced

| | |
|---|---|
| **expectation** | Where a recipe declares an extension of type `inline_python` or `stdio`, the review surfaces it so the operator makes the trust decision knowingly |
| **decision_procedure** | Read `extensions`. Each entry of type `inline_python` or `stdio` produces one finding with outcome `judgment call` |
| **source** | S-001 — `inline_python` is "inline Python code executed using `uvx`"; `stdio` is a Standard I/O client |
| **evidence_class** | `authoritative` (for the fact that these types execute code) |
| **severity** | `advisory` |
| **applies_to** | extension configuration |
| **host_enforced** | `no` — a well-formed such extension is accepted, correctly (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

**This criterion asserts no rule violation and must not be worded as one.** A finding reads "this
recipe executes code, here" — never "this recipe should not execute code". Phrased as a rule it
becomes an unsourced expectation, which `criterion-format.md` forbids.

---

## R-008 — inline_python extensions are complete

| | |
|---|---|
| **expectation** | Every `inline_python` extension declares `code`, `timeout` and `description` |
| **decision_procedure** | Delegate to the host. Rejection naming a missing extension field is the finding |
| **source** | S-004 — Recipe Reference Guide, extension fields, consulted 2026-07-31 |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | extension configuration |
| **host_enforced** | `yes` — measured: `Error: extensions: missing field 'code'` (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

---

## R-009 — stdio extensions are complete

| | |
|---|---|
| **expectation** | Every `stdio` extension declares `cmd`, `args` and `timeout` |
| **decision_procedure** | Delegate to the host. Rejection naming a missing extension field is the finding |
| **source** | S-004 — Recipe Reference Guide, extension fields, consulted 2026-07-31 |
| **evidence_class** | `authoritative` |
| **severity** | `blocking` |
| **applies_to** | extension configuration |
| **host_enforced** | `yes` — measured: `Error: extensions: missing field 'cmd'` (S-003) |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

---

## R-010 — A recipe intended for headless use declares `prompt`

| | |
|---|---|
| **expectation** | The recipe declares a non-empty `prompt`. `instructions` alone is insufficient for non-interactive execution |
| **decision_procedure** | Read the recipe. Check for a non-empty top-level `prompt`. **The host cannot decide this** — validation passes and the failure occurs only at run time |
| **source** | S-008 — observed: `goose run --no-session` fails with "no text provided for prompt in headless mode" when a recipe declares `instructions` but no `prompt`, Goose 1.45.0, 2026-07-31 |
| **evidence_class** | `observed` |
| **severity** | `blocking` |
| **applies_to** | recipe definition |
| **host_enforced** | `no` — the recipe loads; the failure is at execution |
| **version_range** | `v1.45.0` — the only host version this revision was measured against |

**Wording constraint.** The evidence class is `observed`, not `authoritative`: no consulted document
states this requirement. A finding must therefore say what was seen — "observed to fail headless
execution in Goose 1.45.0" — and must not claim the documentation requires `prompt`. It does not; it
requires only one of the two, which is exactly why this gap exists.

**Scope**: applies to recipes meant to run non-interactively. An interactive-only recipe supplying
its prompt at the keyboard does not violate this, so a finding here is `blocking` only where headless
use is intended. Where intent is unknown, report it and say the intent could not be determined.

---

## Criteria deliberately not included

| Candidate | Why excluded |
|---|---|
| Recipe `version` should be set explicitly | Documented to default to `"1.0.0"` when omitted, making omission documented behaviour, not a deviation |
| Naming, structure, readability conventions | No consulted source establishes any |
| Validation rules for `response`, `retry`, `settings`, `sub_recipes` | Documented as existing; rules not consulted in depth. Remains a declared gap |
| Semantic correctness of extension field *values* | R-008/R-009 cover presence only. Whether a `cmd` is sensible or a `timeout` adequate is unresearched — remains the narrowed `GAP-EXT-INTERNALS` |
