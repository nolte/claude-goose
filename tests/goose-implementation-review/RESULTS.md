# Test Results

Recorded outcomes of fixture and quickstart runs. **A scenario absent from this file has not been
run.** Nothing here is inferred from reading code; every entry records something that was executed.

**Status as of 2026-07-31: four full reviews executed. Quickstart scenarios 1, 2, 6 and 8 pass.**

## Environment

Goose **1.45.0**, `claude-agent-acp` **0.64.0** on the PATH. Provider is supplied per invocation
(`GOOSE_PROVIDER=claude-acp`, `GOOSE_MODEL=default`); `~/.config/goose/config.yaml` carries no
provider entry.

Two levels of checking are recorded below and must not be confused:

- **Parse-level** — `goose run --explain`. Exercises Goose's real parser, costs no LLM call.
- **Full review** — the process running end to end against a subject. Consumes the subscription.

A golden file that has never been reconciled against an actual run is an expectation, not a verified
result, and is not presented as one. The reconciliation that has happened is recorded in the
verification log; what has not run is listed at the end of this file.

## Reference fixture for SC-005

`fixtures/reference-recipe/recipe.yaml` **is** the definition of "representative size" for `SC-005`
("a triaged findings list within 15 minutes"). The criterion is measured against that file and no
other, so the measurement is repeatable. It carries six parameters across four input types, two
extensions, a sub-recipe reference and a structured response — enough surface for every criterion in
the 2026-07-31 revision to be exercised at least once — and is deliberately conformant, so a timing
run measures the process rather than the effort of writing up defects.

## Open items found during implementation

### O-1 — Extension declaration for file access — RESOLVED 2026-07-31

**Outcome: no declaration is needed, and none was added.** The Developer extension supplies the file
tools this process requires and "is already enabled by default when goose is installed" (S-005).
Declaring it would add nothing.

A second reason to leave `extensions` absent: whether an explicit list *replaces* the defaults rather
than adding to them was not verified. If it replaces them, an incomplete list would silently strip
the very tools the process depends on. Under that uncertainty, not declaring is the safe option.

**Security consequence, now documented in `recipe.yaml` and `process.md` Stage 4.** The same
extension exposes `shell`, `write` and `edit`; goose "can run system commands with your user
privileges and edit any accessible file" (S-005). **The read-only promise of `FR-006` is therefore
enforced by detection, not prevention.** Nothing stops a write to the subject; the checksum
comparison in Stage 4 catches it afterwards. That makes Stage 4 the only real safeguard, which is
why a mismatch discards the report rather than annotating it.

**Open follow-up**: Goose documents per-tool permissions ("Always Allow" / "Ask Before" / "Never
Allow") and `.gooseignore`. Whether either can be set from a recipe — which would turn detection
into prevention for `write`, `edit` and `shell` — has **not** been verified. Worth investigating
before this process is pointed at anything valuable.

### O-2 — Extension entry structure — RESOLVED 2026-07-31

**The concern was justified: the assumed structure was wrong, and it broke two fixtures.**

Declaring extensions as `- type: <type>` with only a `name` is insufficient. Verified against the
parser and the documentation:

| Type | Required fields |
|---|---|
| `inline_python` | `type`, `name`, `code`, `timeout`, `description` (optional `dependencies`) |
| `stdio` | `type`, `name`, `cmd`, `args`, `timeout` |
| `builtin` | `type`, `name` are accepted; the reference gives no dedicated example |

Both affected fixtures were corrected and now parse. This is exactly why the assumption was recorded
as an open item rather than treated as known.

### O-4 — Most, but not all, baseline criteria are enforced by the host parser — RESOLVED 2026-07-31

**Correction to the first version of this entry.** It was headed "Every baseline criterion is
already enforced by the host parser" and claimed R-001 through R-006 were all host-enforced. That
was written having probed only four of them; R-002 and R-003 were assumed, not measured. Measuring
them disproved the claim.

Full results, probing each rule violation in isolation against `goose run --recipe … --explain`
(Goose 1.45.0):

| Criterion | Violation probed | Parser verdict |
|---|---|---|
| R-001 | `description` absent | **rejected** — "missing field `description`" |
| **R-002** | **neither `instructions` nor `prompt`** | **ACCEPTED** |
| R-003 | optional parameter without a default | **rejected** — "Optional parameters missing default values…" |
| R-004 | file parameter with a default | **rejected** — "File parameters cannot have default values to avoid importing s…" |
| R-005 | parameter defined but unused | **rejected** |
| R-005 | template variable undefined | **rejected** — "Missing definitions for parameters in the recipe file: …" |
| R-006 | undocumented extension type | **rejected** — "unknown variant `nonsense_type`, expected o…" |
| R-007 | well-formed `inline_python` | accepted — correctly, it is no violation |

**R-002 is the exception that justifies the whole feature.** The documentation states the rule
plainly — "At least one of `instructions` or `prompt` must be present." — and the parser accepts a
recipe that breaks it. A violating recipe reaches a running system, and nothing but a review reports
why it does nothing useful. Documented rule and implemented behavior disagree.

**Consequence for the feature.** A recipe violating R-001, R-003, R-004, R-005 or R-006 does not
load. For those, the review is not preventing a production defect — it finds the problem earlier and
explains it, where the host emits one terse error and stops.

What the review still adds for these criteria is real but narrower than assumed:

- It inspects material **statically**, without attempting to load or run it — usable against
  repositories one does not want to execute.
- It covers **every** recipe in a subject in one report, rather than one invocation per file.
- It states **why** a rule exists, with its source. The parser emits `Error: …` and stops at the
  first problem; the review reports all findings with rationale.
- It covers `R-007`, which the parser says nothing about: `inline_python` and `stdio` execute code,
  and that is a trust decision, not a schema error.

**Two consequences worth acting on:**

1. **`goose run --recipe … --explain` is a deterministic checker for R-001 through R-006.** Adopting
   it as the `decision_procedure` for host-enforced criteria would make those findings reproducible
   by construction rather than by fixture — directly addressing the deferral recorded in the plan's
   Complexity Tracking.
2. **Future baseline growth should favour criteria the parser does not enforce** — semantics,
   security posture, and practice — since host-enforced ones duplicate a check that already exists.

This finding does not invalidate the feature, but it does narrow what the current baseline is worth.
It is recorded here rather than quietly absorbed, and is the operator's call to act on.

### O-3 — An optional file parameter is unconstructible

Discovered by holding the review recipe to the criteria it enforces on others. Two documented rules
conflict for a single case:

- R-003 — "Optional parameters must have default values"
- R-004 — "File parameters cannot have default values to prevent importing sensitive files"

A parameter that is both optional and of `input_type: file` must therefore both carry and not carry
a default. It cannot be expressed.

**How it was handled here**: `compare_to` names a file but is typed `string`, satisfying both rules.
This is documented inline in `recipe.yaml` rather than silently worked around.

**Why it is recorded**: this is an observation about Goose's rule set, not about any subject, and it
is exactly the kind of finding the dogfooding principle is supposed to produce. Whether upstream
considers it a defect is unknown and is not asserted here.

### O-6 — `input_type: file` imports content; it is not a path

Found on the first real run, which failed with:

```
Failed to read parameter file tests/…/recipe-with-deviations: Is a directory (os error 21)
```

`file` does not mean "a path to a file". Goose **reads the file and substitutes its contents**.
A directory therefore fails outright, and a single file would be inlined — hiding every other file
in the subject from the review.

`subject_path` was changed to `input_type: string`. No default is needed because it is required;
the R-003 default obligation applies only to optional parameters.

**This deepens R-004 beyond what the documentation states.** "File parameters cannot have default
values to prevent importing sensitive files" is not schema tidiness — file parameters *import
content*, so a default path silently inlines whatever it points at. The rule is about data flow.

### O-7 — A headless run needs `prompt`, not just `instructions`

The second attempt failed with `Error: no text provided for prompt in headless mode`. The recipe
declared `instructions` but no `prompt`.

`instructions` describes *how* to work; `prompt` is the starting impulse. Without it a
non-interactive run has nothing to begin, even though the parser accepts the recipe.

**This closes the measurement caveat recorded against R-002.** That criterion noted the parser
accepts a recipe with neither key, but that "whether a full execution also tolerates the omission was
not tested". It does not: such a recipe loads and then fails at run time. R-002's `host_enforced: no`
is therefore correct *and* consequential — the defect survives validation and surfaces only when
someone tries to run the thing.

The review recipe hit this failure itself, which is exactly the class of defect R-002 exists to
catch.

### O-8 — Host delegation stops at the first defect

The host aborts on the first problem, so one `--explain` invocation decides at most one criterion.
The first review reached R-004, R-005 and R-006 only by building **derived probes** — copies of the
subject with earlier defects neutralized.

Now documented in `ruleset.md` ("How host delegation actually behaves") and `process.md` (Stage 2,
"Derived probes"), with three rules: probes are copies, the subject is never edited, and a finding
decided against a probe says so.

**It also qualifies O-4.** "Deterministic by construction" holds per check, not per report: the
parser's verdict on a given file is reproducible, but the sequence of probes an agent constructs to
get there is not guaranteed to be. `plan.md` Complexity Tracking was corrected accordingly.

### O-9 — The fixture contradicted its own header comment

The first review reported that `recipe-with-deviations` declared an `R-006 nonsense_type` defect in
its header comment that the file did not contain — removed earlier when fixing O-2, without updating
the comment or the golden file.

The reviewing agent judged **the file, not the comment**, and said so. Both were corrected. Worth
recording because the review caught a defect in its own test material on its first outing.

## Verification log

| Date | What was run | Outcome |
|---|---|---|
| 2026-07-31 | `goose run --recipe process/…/recipe.yaml --explain` | **PASS** — the review recipe parses; all four parameters accepted with the intended types and defaults |
| 2026-07-31 | `--explain` on fixture `recipe-clean` | **PASS** — parses; conformant as designed |
| 2026-07-31 | `--explain` on fixture `reference-recipe` | **PASS** after correcting the stdio entry (missing `cmd`) |
| 2026-07-31 | `--explain` on fixture `recipe-oversized` | **PASS** — parses |
| 2026-07-31 | `--explain` on fixture `recipe-with-deviations` | Rejected at `missing field description` — the planted R-001 defect, confirmed by the host |
| 2026-07-31 | Isolated probes of R-004, R-005 ×2, R-006 | All rejected by the parser — see O-4 |

**Not yet run**: any actual review (T024, T026–T029). Those require the process to execute against a
subject and consume the Claude subscription; the checks above are parse-only and cost nothing.

**Incidental finding**: `recipe_dir` is a built-in parameter supplied by Goose to every recipe. It
appeared in the `--explain` output and was not present in the consulted documentation. Not currently
used by this process.

## Verification log — full review runs

Provider: `GOOSE_PROVIDER=claude-acp GOOSE_MODEL=default`, Goose 1.45.0, claude-agent-acp 0.64.0.

| Date | Run | Result |
|---|---|---|
| 2026-07-31 | T026 — `recipe-with-deviations`, attempt 1 | Failed: `subject_path` was `input_type: file` and rejected a directory. See O-6 |
| 2026-07-31 | T026 — attempt 2 | Failed: `no text provided for prompt in headless mode`. See O-7 |
| 2026-07-31 | **T026 — attempt 3** | **PASS.** Report written. 6 findings: R-001, R-004, R-005 ×2 as deviations; R-007 judgment call; one undecided from a declared gap |
| 2026-07-31 | **T024 — read-only check, deviations fixture** | **PASS.** sha256 before/after identical |
| 2026-07-31 | **T027 — `recipe-clean`** | **PASS.** No deviations; one undecided from a declared gap. Coverage and Criteria Applied present, so a clean subject is distinguishable from an unexamined one |
| 2026-07-31 | **T024 — read-only check, clean fixture** | **PASS.** sha256 before/after identical |
| 2026-07-31 | **T027 — `no-goose-material`** | **PASS.** "No recognizable recipe was found. Nothing was reviewed, and this is not a clean result." Findings section reads "None — because no criterion was ever applied, not because the criteria were satisfied" |
| 2026-07-31 | **T028 — self-review** (Principle V) | **PASS.** Subject `process/goose-implementation-review/`. No findings: the process violates no criterion it enforces on others |
| 2026-07-31 | **T024 — read-only check, self-review** | **PASS.** sha256 before/after identical |

### Golden file reconciliation (T026)

Five of six findings matched `expected/recipe-with-deviations.md` exactly. The single divergence was
the golden file's `R-006 nonsense_type` finding, which was stale — see O-9. The golden file was
corrected to match reality, not the reverse: the divergence was caused by an earlier edit to the
fixture, not by the process misbehaving.

### Not yet run

| Scenario | Task | Needs |
|---|---|---|
| 3 — Reproducibility | T030, T040 | Two runs of the same subject, byte-compared |
| 9 — Partial coverage | T027 (oversized) | A run against `recipe-oversized` |
| 12 — Citations hold for a stranger | T029 | A second reader; cannot be self-certified |
| 13 — Time to triaged findings | T054 | A timed run against `reference-recipe` |
