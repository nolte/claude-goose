# claude-goose

[![Static Gate](https://github.com/nolte/claude-goose/actions/workflows/static-gate.yml/badge.svg)](https://github.com/nolte/claude-goose/actions/workflows/static-gate.yml)

A read-only review process for [Goose](https://github.com/aaif-goose/goose) recipe definitions and
the extension configurations they declare, measured against a pinned, source-backed baseline of
documented rules. For teams that ship Goose recipes and want to know what deviates from the
documentation before it fails at run time.

## Purpose

Goose validates most of a recipe when it loads it. What it does not validate still breaks:
a recipe with neither `instructions` nor `prompt` loads and then does nothing useful, and a recipe
without `prompt` passes validation and fails in headless mode. This process exists to catch those
gaps, and to give every other structural defect an earlier detection point and a cited source.

Its rules are deliberately narrow:

- **Every finding names three things**: the criterion it violates, the location in the subject, and
  the upstream documentation the criterion was taken from, with the commit it was consulted at.
- **No criterion is invented.** Only rules present in the pinned baseline revision may produce
  findings. What the documentation does not state is recorded as a declared gap and reported as
  `undecided`, never as a pass.
- **The subject is never modified or executed.** A checksum of every file is taken before and after the
  review; any difference discards the report.
- **Two runs over unchanged inputs produce the same findings.** The report carries a machine-comparable
  digest that must be byte-identical; prose around it may vary.

The governing principles live in [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
Reusability outside this repository and evidence-backed claims are the two that shape everything
below.

## Usage

Requires Goose 1.45.0 and, for the provider used here, `claude-agent-acp`. Copy `process/` and
`baselines/` side by side into the consuming repository; neither contains anything specific to
this one.

```sh
GOOSE_PROVIDER=claude-acp GOOSE_MODEL=default \
  goose run --no-session --recipe process/goose-implementation-review/recipe.yaml \
    --params subject_path=<path to recipe or directory> \
    --params baseline_revision=2026-08-02 \
    --params output_path=./review-report.md
```

Five inputs, and no others:

| Input | Required | Default | Meaning |
|---|---|---|---|
| `subject_path` | yes | none permitted | The recipe file or directory to review |
| `baseline_revision` | no | `latest` | Revision under `baselines/goose/`; `latest` resolves to the greatest id |
| `output_path` | no | `./review-report.md` | Where the report is written |
| `compare_to` | no | empty | A prior report; findings are classified as new, resolved or unchanged |
| `max_bytes_per_pass` | no | `0` | Coverage budget per pass; `0` means unlimited |

`subject_path` has no default on purpose. A default would review material the caller never chose,
and on Goose a file-typed parameter is read and inlined rather than passed as a path.

### What a report contains

| Section | Content |
|---|---|
| Header | Subject, process version, baseline revision and Goose version, host, run date |
| `DIGEST v1` | One line per finding: criterion, location, outcome, severity. The reproducibility core |
| Coverage | What was examined, what was not and why, which baseline gaps apply |
| Findings | Per finding: criterion, location, outcome, source, rationale, optional delta |
| Criteria Applied | Every criterion evaluated, including those that passed |

Outcomes are `deviation`, `judgment call` or `undecided`; severities are `blocking` or `advisory`.
A finding's wording is bounded by its criterion's evidence class: only a criterion backed by
directly read documentation may state that something is wrong. The full stage description is in
[`process/goose-implementation-review/process.md`](process/goose-implementation-review/process.md).

### Validate a recipe without a model call

`goose run --recipe <file> --explain` runs the host's real parser. Five of the ten baseline
criteria are decided by it, so this is the cheapest first check on any recipe. The parser stops at
the first defect, which is why the review builds neutralized copies of the subject to reach the
remaining criteria.

### Develop a recipe with the plugin

The repository is also a Claude Code plugin, `nolte-goose`, with one skill per phase of a recipe's
life. It requires Goose, the Claude Code CLI and the `nolte-shared` plugin.

```sh
claude plugin marketplace add nolte/claude-goose
claude plugin install nolte-goose@nolte-goose
```

- `/nolte-goose:recipe-requirements-elicit` captures what the recipe must do, delegating the
  interview to `nolte-shared:requirements-elicit` and adding the recipe-specific questions.
- `/nolte-goose:recipe-plan` maps every requirement to a recipe element and decides every baseline
  criterion before anything is written.
- `/nolte-goose:recipe-implement` writes the recipe from the plan and validates it with Goose's
  parser.
- `/nolte-goose:recipe-audit` runs the review above through its Claude Code binding and returns
  the report; it adds no rule of its own.

`skills/README.md` records what each skill delegates and what it adds.

### Work on the process itself (dogfooding)

```sh
task ci
```

That is the entire static gate: format, YAML, Markdown, prose, recipe schema, recipe parse,
internal links, portability of the reusable trees, and manifest integrity. CI runs the same
command. A change to the process is released only after the process has reviewed its own directory
and produced no findings; the runs that happened are recorded in
[`tests/goose-implementation-review/RESULTS.md`](tests/goose-implementation-review/RESULTS.md),
and a scenario absent from that file has not been run.

## The baseline

A baseline revision is a directory under `baselines/goose/` named by publication date. It is the
yardstick a review measures against, and it is built so that a report citing it stays interpretable
indefinitely:

| File | Role |
|---|---|
| `ruleset.md` | The criteria (`R-001` to `R-010` in the current revision), each with a decision procedure, source, evidence class and version range |
| `sources.md` | Every source a criterion cites, with URL, upstream file path, commit consulted, and verbatim quote |
| `coverage.md` | What the revision covers, and the declared gaps (`GAP-*`) with the condition under which each becomes a finding |
| `criterion-format.md` | The schema this revision is checked against, so a later schema never reports false defects in an older revision |
| `verification.md` | Append-only drift log: the only file in a published revision that may change |

**Published revisions are immutable.** A correction creates a successor; the predecessors stay
byte-identical because reports cite them. Drift against upstream is checked by comparing the
recorded source commit with the current commit of the same documentation file, never by HTTP
headers, which track site deploys rather than content. The procedure is in
[`baselines/MAINTENANCE.md`](baselines/MAINTENANCE.md).

Three version axes move independently and are never conflated: the process version
(`process/.../VERSION.md`), the baseline revision, and the maintenance procedure version
(`baselines/VERSION.md`). A report names the first two so a reader can tell a changed method from a
changed yardstick.

## Structure

```text
baselines/
  MAINTENANCE.md, SOURCE-FORMAT.md, VERSION.md   # how a revision is kept current and grown
  goose/<revision>/                              # immutable, source-backed criteria per Goose version
.claude-plugin/                                  # plugin and marketplace manifests
skills/                                          # the four lifecycle skills, README and VERSION.md
process/goose-implementation-review/
  process.md                                     # the stages, with preconditions and verification
  recipe.yaml                                    # the Goose entry point
  report-template.md                             # the report shape, including the digest block
  VERSION.md                                     # semantic version of the process
tests/goose-implementation-review/
  fixtures/, expected/                           # subjects and golden files for real review runs
  RESULTS.md, PORTABILITY.md                     # what was actually run, and the reuse guard
specs/NNN-*/                                     # feature specifications driving the work above
OMISSIONS.md                                     # what the pipeline deliberately does not do, and why
```

## Related repositories

- [nolte/gh-plumbing](https://github.com/nolte/gh-plumbing) — the shared GitHub workflows every
  workflow here wraps, and the commons repository settings that `.github/settings.yml` extends.
- [nolte/vale-style](https://github.com/nolte/vale-style) — the prose vocabulary the `prose` gate
  class consumes.
- [nolte/claude-shared](https://github.com/nolte/claude-shared) — the Claude Code skills and agents
  this repository is maintained with, and the portfolio specs its branching model, pipeline design
  and README structure follow.

## Status

Early stage, in use by its author. The review process is released at 1.0.0 after 24 real reviews,
including a self-review with no findings and runs in two unrelated repositories. Four baseline
revisions exist; `2026-08-02` is the latest and targets Goose v1.45.0. Work in progress is the
split of the process into host-neutral artifacts plus generated host bindings, so a review can run
without Goose. The Claude Code binding and the `recipe-audit` skill that invokes it are authored
but have no recorded run yet; until they do, the Goose recipe above is the released entry point.
