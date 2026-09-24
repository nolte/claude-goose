# Quickstart: Portable Process Logic

**Feature**: `004-portable-process-logic` | **Date**: 2026-08-02

How to prove this feature works, end to end. Each scenario names what it validates and what a pass
looks like. Nothing here is implementation; see `contracts/` for the interfaces and `data-model.md`
for the layout.

## Prerequisites

| Need | For | Notes |
|---|---|---|
| `task`, `pre-commit` | Every static scenario | `task ci:install` installs the pinned toolchain |
| POSIX `sh`, `awk` | The renderer | Already present; the renderer takes no other dependency |
| `goose` 1.45.0 | Scenarios 4, 6 | Also needed by the `recipe-parse` gate class |
| Claude Code CLI | Scenarios 5, 6 | The second host binding |

## Scenario 1 — The gate is green (all stories)

```sh
task ci
```

**Pass**: every hook passes, including the new `binding-render` class and the newly wired portability
guard. This is the same command CI runs, so a green run here and a green run there mean the same
thing.

## Scenario 2 — Drift is caught (US2, `FR-006`, `SC-008`)

Edit a generated binding by hand — change one word inside a `BEGIN GENERATED` region:

```sh
sed -i 's/NEVER modify/never modify/' process/goose-implementation-review/bindings/goose/recipe.yaml
task ci
```

**Pass**: the gate fails, names `bindings/goose/recipe.yaml`, names the source it disagrees with, and
tells the reader to run the renderer rather than to edit the file. Restore with:

```sh
process/goose-implementation-review/tools/render-bindings.sh
git diff --exit-code process/goose-implementation-review/bindings/
```

**Fail**: the gate passes, or it repairs the file silently. A check that fixes what it is measuring
reports nothing.

### 2b — The region checks fire (`FR-018`, `FR-019`)

Drift detection only covers generated regions. These two cover the template itself, which is where a
hand-written rule would otherwise survive forever:

```sh
# an unmarked line
printf '\n# a stray note\n' >> process/goose-implementation-review/bindings/goose/recipe.yaml.tmpl
task ci
```

**Pass**: the gate fails naming the line and saying it belongs to no declared region.

```sh
# normative voice inside a HOST-SPECIFIC region
task ci   # after writing "the recipe MUST NOT declare inline_python" into that region
```

**Pass**: the gate fails naming the region and the offending line, and points at `constraints.md` as
where a rule belongs. Revert both edits afterwards.

## Scenario 3 — A rule changes in exactly one place (US2, `FR-001`)

Change the wording of a constraint in `constraints.md`, then:

```sh
process/goose-implementation-review/tools/render-bindings.sh
git status --short process/goose-implementation-review/
```

**Pass**: every binding shows as modified, and no other host-neutral artifact does. One edit, no
manual propagation.

## Scenario 4 — The Goose binding still runs (US1, `FR-009`)

```sh
GOOSE_PROVIDER=claude-acp GOOSE_MODEL=default \
  goose run --no-session --recipe process/goose-implementation-review/bindings/goose/recipe.yaml \
    --params subject_path=tests/goose-implementation-review/fixtures/recipe-with-deviations \
    --params baseline_revision=2026-07-31b \
    --params output_path=./review-goose.md
```

**Pass**: the report is written, its header carries `Host: goose`, its `DIGEST v1` block matches
`tests/goose-implementation-review/expected/recipe-with-deviations.md` on the digest, and the pinned
baseline is honoured — the digest says `baseline=2026-07-31b`, not a newer revision.

**The golden file must already be re-pinned** to `process=2.0.0` before this scenario can pass. The
digest carries the process version, so the release bump moves it; every other digest field is required
to be byte-identical. Comparing against a golden still reading `process=0.2.0` reports a difference
that is an artifact of the release, not of the run.

That last clause is the regression test for `O-12`. A run that reports a revision other than the one
pinned is a failure even if every finding is otherwise correct.

**Note the path**: the recipe has moved into `bindings/goose/`. The old path is gone, which is what
makes this release `2.0.0`.

## Scenario 5 — The process runs without Goose (US1, `FR-015`, `FR-016`)

```sh
process/goose-implementation-review/bindings/claude-code/run.sh \
  --subject_path tests/goose-implementation-review/fixtures/recipe-with-deviations \
  --baseline_revision 2026-07-31b \
  --output_path ./review-claude.md
```

**Pass**: a conformant report at `./review-claude.md` carrying `Host: claude-code`, with the coverage
statement and the `Criteria Applied` table present, every finding carrying criterion, location and
source, and `baseline=2026-07-31b` in the digest.

**This is the scenario the feature exists for.** No Goose process was involved.

### 5b — The host-neutral artifacts are sufficient on their own (US1, `FR-002`)

Scenario 5 proves a *second host* works. It does not prove `FR-002`, which asks something stronger:
that the host-neutral artifacts alone are enough to carry out a review. A binding could quietly be
carrying part of the method and nobody would notice, because both bindings are rendered from the same
sources.

Give an operator only these four files and a subject:

```text
process/goose-implementation-review/process.md
process/goose-implementation-review/constraints.md
process/goose-implementation-review/invocation-contract.md
process/goose-implementation-review/report-template.md
```

They supply the contract's inputs by hand and work through the stages. No binding file is opened, and
no `bindings/` directory is present.

**Pass**: a report with every mandatory section — the coverage statement, the `Criteria Applied` table,
and each finding carrying criterion, location and cited source — and `Host` filled in with how the run
was actually performed. It need not match a golden file: prose is free and only the digest is
byte-compared, and this run has a different reader.

**Fail**: any point at which the operator has to open a binding to learn what to do. That is a rule
living in a binding, which is what `FR-001` and `FR-004` forbid — record which rule and move it.

This is `US1` acceptance scenario 3 made executable. It needs a reasoning operator, so it stays outside
the automated gate, like every other verification of this kind here.

## Scenario 6 — Cross-host comparison (`FR-017`, `SC-001`)

With both reports from scenarios 4 and 5:

```sh
sed -n '/^DIGEST v1$/,/^```$/p' review-goose.md  > digest-goose.txt
sed -n '/^DIGEST v1$/,/^```$/p' review-claude.md > digest-claude.txt
diff digest-goose.txt digest-claude.txt
```

**Pass**: either the digests are identical, **or** every differing line is recorded in
`tests/goose-implementation-review/RESULTS.md` with a cause. A difference is a finding to report, not
a release blocker — see `contracts/report-host-field.md`.

**Fail**: a difference that is observed and left unexplained.

## Scenario 7 — Adding a host costs one file (US3, `SC-004`)

Create `bindings/<newhost>/<file>.tmpl` with the marker pairs, then render. There is nothing to
register — the directory name is the host, and the template path minus `.tmpl` is where it renders:

```sh
process/goose-implementation-review/tools/render-bindings.sh
git status --short process/goose-implementation-review/
```

**Pass**: the only additions are inside `bindings/<newhost>/`, and no file above `bindings/` is
modified. If a host-neutral artifact had to change, the separation does not hold and the design is
wrong, not the host.

## Scenario 8 — Portability is intact (US1, `FR-011`, `FR-013`)

```sh
./scripts/check-portability.sh
```

**Pass**: no repository name, no absolute path, no reference to `specs/` anywhere in `process/` or
`baselines/` — including in the newly added shell files, which are the likeliest place for an absolute
path to be hard-coded during debugging.

**Expect one pre-existing failure the first time this runs.** `baselines/SOURCE-FORMAT.md` references
`specs/002-qa-documentation-base/data-model.md`, which check 3 rejects. That is the guard working, not
the guard being wrong — it is the defect wiring it up exists to surface. Fix the file, do not narrow
the check.

Then the copy test:

```sh
tmp=$(mktemp -d) && cp -r process baselines "$tmp"/ && cd "$tmp"
```

Run scenario 5 from there against a subject outside this repository, **and then scenario 4** against
the same subject. `FR-013` says "under any supported host", so exercising one binding in the copy
leaves the claim half-tested — and the Goose binding is the one whose path just moved.

**Pass**: both run with zero edits to the copied files, and the copies are byte-identical afterwards.

## Scenario 9 — The process still passes its own review (`FR-012`, `SC-005`, Principle V)

Point the review at its own directory using either binding.

**Pass**: no findings. This is a release condition from Constitution Principle V, not a nicety. A
restructuring that leaves the process unable to approve itself is not finished.
