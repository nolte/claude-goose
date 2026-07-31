# Test Results

Recorded outcomes of fixture and quickstart runs. **A scenario absent from this file has not been
run.** Nothing here is inferred from reading code; every entry records something that was executed.

**Status as of 2026-07-31: twenty-two full reviews executed. Quickstart scenarios 1, 2, 3, 4, 5, 6, 7 and 8 pass; scenario 9 untested (O-10), offline branch untested (T037).**

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

### O-10 — The oversized fixture is not oversized

The `recipe-oversized` run was meant to exercise the partial-coverage path. It did not. At 397 lines
and 10,897 bytes the file was read in one pass, in full; nothing was omitted for size. The reviewing
agent reported this plainly rather than claiming the scenario had been exercised.

**Quickstart Scenario 9 (a partial review says so) therefore remains untested**, and `T027` is not
complete despite all three of its runs having happened. The defect is in the test material, not in
the process.

The run was not wasted — it confirmed correct behavior for a different case. The subject references
60 sub-recipe files that do not exist, and the report classified them as `not examined` with the
reason "absent from the subject tree", explicitly declining to report them as passing. It also
produced one `undecided` finding for `sub_recipes` correctness, from the declared baseline gap.

**Options, none yet chosen:**

1. **Enlarge the fixture** until it genuinely exceeds a review pass. With current context windows
   that means megabytes of generated YAML committed to the repository — and it would need
   re-enlarging as models grow.
2. **Make coverage limits a declared input**, e.g. a maximum number of files or bytes per pass. The
   partial-coverage path then becomes testable with a small fixture and a small limit, and the
   behaviour stops depending on the reviewing model's capacity.
3. **Drop the scenario** and accept that partial coverage is unverified.

Option 2 looks right: it makes the criterion testable by construction rather than by out-sizing
whatever model runs the review, which is a race the fixture cannot win. It is an operator decision,
not one to take silently.

### O-11 — Reproducibility: four rounds of underspecification — RESOLVED 2026-07-31

`FR-005` and `SC-002` now hold, verified by two consecutive runs producing byte-identical digests
that also match the golden file exactly. Getting there exposed four separate defects **in the
specification**, not in the process. Each was found only by measuring, and each had been invisible
while reports were compared by reading.

| Round | Observation | Cause | Fix |
|---|---|---|---|
| 1 | Whole reports differed: 128 vs 164 lines, 242 differing lines. Findings were identical | Byte-comparing prose is the wrong test. An agent rephrases harmlessly ("are not covered by this baseline" vs "are outside the baseline's coverage") and may add sections | Introduced the `DIGEST v1` block. It is the byte-stable core; prose is free. `FR-005` asks for identical *findings*, not identical sentences |
| 2 | `subject=` hashes differed for an unchanged subject | "sha256 of the subject manifest" never defined how the manifest is built — absolute vs relative paths, sort order, enumeration order | Defined it exactly: `find . -type f -exec sha256sum {} \; \| sort`, then hash. Runs now reproduce the reference value computed independently |
| 3 | One run emitted a gap finding labelled `R-006`; the next omitted it entirely | Findings from declared baseline gaps have **no criterion**, yet the contract demanded a criterion id. Both behaviours were defensible under the text | Gaps carry ids (`GAP-…`). A gap finding names its gap id; naming the "nearest" criterion is forbidden. Each gap declares exactly when it triggers |
| 4 | Same finding located as `recipe.yaml:44` and `recipe.yaml:extensions[0]` | Location notation was never specified. Both were correct | Digest locations are **structural**, never line numbers. Prose may cite lines freely |

**Round 4's fix matters beyond reproducibility.** A positional digest would break `FR-012`: inserting
one line at the top of a subject shifts every line number, so the next comparison would report every
unchanged finding as `resolved` plus an identical `new` one. Structural addresses survive
reformatting.

**What this says about the deferral in the plan.** The absence of a deterministic checker is not
what threatened `FR-005`. Every failure came from the *specification* being ambiguous enough that two
correct executions could differ. Writing a scripted checker first would have hard-coded one arbitrary
answer to each of these four questions without anyone noticing the questions existed.

### O-12 — `prompt` outweighs `instructions` in practice — RESOLVED 2026-07-31

A run pinned to `2026-07-31` reported `baseline=2026-07-31b` and produced findings from criteria
that exist only in the newer revision. The pin was ignored.

**It was not a delivery problem.** `--render-recipe` confirmed the value arrived and that
`instructions` contained, verbatim: "USE EXACTLY THE BASELINE REVISION 2026-07-31." Strengthening
that wording changed nothing — a second run repeated the violation.

**The difference was placement.** The `prompt` said only "follow process.md stage by stage" and never
mentioned the baseline. `process.md` documents that `latest` resolves to the greatest revision, so an
agent working from the prompt reasonably resolved a baseline itself and picked the newest. Naming the
pin in the `prompt` fixed it on the first attempt: pin honoured, `BASELINE-DRIFT` reported, no
newer-revision criteria leaked.

**Generalizable, and it should become a criterion.** For this host and provider, a constraint that
must hold belongs in `prompt`, not only in `instructions`. `instructions` reads as background;
`prompt` reads as the task. This is the third finding in the same family:

| Finding | What it showed |
|---|---|
| `R-002` | The parser accepts a recipe with neither key |
| `R-010` (O-7) | A headless run fails without `prompt`, though validation passes |
| **O-12** | **Even with both present, a constraint only in `instructions` may be overridden** |

Together they say the two fields are not interchangeable in any practical sense, while the
documentation treats them as alternatives ("at least one of"). A candidate criterion for the next
revision: *constraints that must not be violated appear in `prompt`.* Its evidence class would be
`observed` — no consulted document states this.

**Also worth noting**: the agent's substitution was not careless. Applying the newest available
criteria is defensible if the goal is the best possible answer. It is not: the goal is a report that
means what its header says. That intent has to be stated, not assumed.

### O-9 — The fixture contradicted its own header comment

The first review reported that `recipe-with-deviations` declared an `R-006 nonsense_type` defect in
its header comment that the file did not contain — removed earlier when fixing O-2, without updating
the comment or the golden file.

The reviewing agent judged **the file, not the comment**, and said so. Both were corrected. Worth
recording because the review caught a defect in its own test material on its first outing.

## Verification log — parse-level checks

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

### Run 5 — `recipe-oversized` (2026-07-31)

| | |
|---|---|
| Result | Ran successfully; **did not** exercise the intended scenario. See O-10 |
| Findings | One `undecided` — `sub_recipes` correctness, from a declared baseline gap |
| Coverage | 60 referenced sub-recipe files reported as `not examined`, reason: absent from the subject tree |
| T024 read-only | **PASS** — sha256 before/after identical |

**Quickstart Scenario 9 remains untested.** T027 stays open for that reason, even though all three
of its runs were performed.

## Reproducibility procedure (T030)

To verify `FR-005` / `SC-002` for any subject:

```sh
SUBJ=<path to subject>
for i in 1 2; do
  GOOSE_PROVIDER=claude-acp GOOSE_MODEL=default \
    goose run --no-session --recipe process/goose-implementation-review/recipe.yaml \
      --params subject_path="$SUBJ" --params output_path="/tmp/run-$i.md"
  sed -n '/^DIGEST v1/,/^```/p' "/tmp/run-$i.md" | grep -v '^```' > "/tmp/d$i.txt"
done
diff /tmp/d1.txt /tmp/d2.txt && echo "reproducible"
```

**Compare digests, not whole reports.** Differing prose is expected and acceptable; a differing
digest is a real failure. Independently verify the subject hash with
`cd "$SUBJ" && find . -type f -exec sha256sum {} \; | sort | sha256sum`.

### Runs 6–11 — reproducibility (2026-07-31)

| Runs | Digest outcome |
|---|---|
| 1st pair | Whole reports differed by 242 lines; findings identical. Digest introduced |
| 2nd pair | Digests differed in `subject=` only. Manifest computation specified exactly |
| 3rd pair | Gap finding labelled `R-006` in one run, omitted in the other. Gap ids introduced |
| 4th pair | Location `recipe.yaml:44` vs `recipe.yaml:extensions[0]`. Structural notation mandated |
| **5th pair** | **Identical. Also matches `expected/recipe-clean.md` exactly** |

`FR-005` and `SC-002` are satisfied for this subject. Eleven full reviews were run in total; every
one left its subject byte-identical.

## Offline procedure (T032)

Verifies process.md Stage 3b's offline branch: a review that cannot check baseline currency must say
so, and must never report a drift check it did not perform.

```sh
# Deny network access for the run, e.g. with unshare, a firewall rule, or by
# pointing the drift check at an unreachable location.
unshare -rn env GOOSE_PROVIDER=claude-acp GOOSE_MODEL=default \
  goose run --no-session --recipe process/goose-implementation-review/recipe.yaml \
    --params subject_path="$SUBJ" --params output_path=/tmp/offline.md
```

**Caveat**: with the `claude-acp` provider the agent itself needs the network, so a fully offline run
cannot be performed this way — the provider fails before the review starts. Verifying the offline
branch in isolation requires either a local provider or a stubbed drift check. **Not yet performed**;
recorded so the gap is visible rather than assumed away.

**Two acceptable outcomes**, and no others:

1. Proceed against the pinned baseline and emit a `BASELINE-DRIFT-UNKNOWN` finding
   (`undecided`, `advisory`) stating currency could not be checked.
2. Refuse the run and write no report.

Reporting a clean drift check that never ran is a failure, as is omitting the subject silently. The
criteria themselves need no network — they come from the pinned revision on disk — so offline review
remains possible in principle.

### Runs 12–16 — baseline pinning, mismatch and drift (2026-07-31)

| Run | Result |
|---|---|
| version-mismatch fixture, attempt 1 | **Timed out.** "Upstream drift" was ambiguous: no upstream location is defined for baselines, so the agent explored instead of deciding. Scoped the check to the local filesystem |
| version-mismatch fixture, attempt 2 | **PASS.** `baseline=2026-07-31b` honoured; exactly one `BASELINE-VERSION-MISMATCH` finding, no per-criterion flood |
| drift, attempt 1 (pin `2026-07-31`) | **FAIL.** Reported `2026-07-31b`; `R-010` leaked |
| drift, attempt 2 (wording hardened in `instructions`) | **FAIL.** Identical violation |
| **drift, attempt 3 (pin named in `prompt`)** | **PASS.** Pin honoured, `BASELINE-DRIFT` reported, no newer-revision criteria leaked. See O-12 |

**Not verified**: the offline branch (T037). It is implemented in Stage 3b but cannot be exercised
with the `claude-acp` provider, which needs the network before the review starts. Verifying it in
isolation requires a local provider or a stubbed drift check.

### Runs 17–22 — US3 portability and US4 delta (2026-07-31)

| Run | Result |
|---|---|
| **Foreign repo 1** (`automation/nightly-sync.yaml`, conformant) | **PASS.** Ran from inside an unrelated git repo with `process/` and `baselines/` copied verbatim. Subject unchanged; both copied trees byte-identical to source afterwards |
| **Foreign repo 2** (`recipes/tag-release.yaml`, two planted defects) | **PASS.** Found `R-004` (file parameter default) and `R-010` (no `prompt`) plus `R-007` and the extension gap. `R-010` is the one the host does not catch |
| Delta, attempt 1 | **FAIL.** "No prior report. Stage 6 did not run" — `compare_to` was named only in `instructions` |
| **Delta, attempt 2** (`compare_to` named in `prompt`) | **PASS.** `R-004` classified `resolved` with cause `subject`; the other six `unchanged`. Matches `expected/delta-subject-change.md` |
| **Delta, baseline cause** (unchanged subject, newer revision) | **PASS.** `GAP-EXT-INTERNALS` and `BASELINE-DRIFT` both `resolved` with cause **`baseline`**, with the report stating "nothing below is a fix" |

**`SC-004` is satisfied**: the unmodified process produced valid reports in two different
repositories.

**O-12 confirmed independently.** The delta failure was the same defect as the pinning failure, in a
different parameter: `compare_to` was present in `instructions` and ignored; naming it in `prompt`
fixed it on the first attempt. Two independent reproductions of the same rule — for this host and
provider, a constraint that must hold belongs in `prompt`.

**Minor deviation, not corrected**: findings classified `unchanged` also carry a `cause`, though
Stage 6 specifies a cause only for changed findings. Harmless and redundant rather than wrong;
recorded so the next reader knows it was noticed.
