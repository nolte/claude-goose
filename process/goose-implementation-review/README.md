# Goose Implementation Review

A read-only review process for Goose recipe definitions and the extension configurations they
declare. It produces a findings report in which every finding names both its location in the
reviewed material and the documented rule it derives from.

## What this directory is

**This directory is copied wholesale into a consuming repository.** It contains nothing specific to
the repository it currently lives in — no absolute paths, no project names, no author-specific
values. Everything subject-specific arrives as a declared parameter.

If you find yourself editing a file here to make a review run somewhere, that is a defect in this
process, not a configuration step.

## What you need

- Goose **v1.45.0** or compatible
- A baseline revision directory (see `baselines/` in this repository, or supply your own)

## Running a review

The process is invoked as a Goose recipe with these parameters:

| Parameter | Required | Default | Purpose |
|---|---|---|---|
| `subject_path` | **yes** | *none permitted* | The implementation to review |
| `baseline_revision` | no | `latest` | Which baseline revision to apply |
| `output_path` | no | `./review-report.md` | Where the report is written |
| `compare_to` | no | *(empty)* | A prior report, to compute a delta |

`subject_path` has no default by design. Goose's recipe reference states that file parameters cannot
have defaults, to prevent importing sensitive files — supplying one would be both a schema violation
and a security defect.

## What it does not do

- It does not modify the subject. Checksums are taken before and after; a changed subject fails the
  run.
- It does not execute the subject. Findings come from reading the material, which is what makes it
  safe to point at untrusted third-party code.
- It does not decide whether the subject is "good". It reports what deviates from documented rules
  and what could not be decided.

## Files

| File | Purpose |
|---|---|
| `VERSION.md` | Semantic version of this process |
| `process.md` | The multi-stage review process: stages, preconditions, outputs, verification |
| `recipe.yaml` | The Goose recipe shell |
| `report-template.md` | The shape of a review report |
