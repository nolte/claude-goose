# Review Report: <subject identity>

**Subject**: <location> (<revision, if any>)
**Process version**: <semver from VERSION.md>
**Baseline**: <revision_id> for Goose <goose_version>
**Run date**: <YYYY-MM-DD>
**Compared to**: <prior report, or "none">

## Coverage

**Examined**: <in-scope parts reviewed>
**Not examined**: <parts skipped, each with a reason — or "none">
**Baseline gaps**: <topics the baseline declares uncovered — or "none">

## Findings

<!--
  One block per finding, sorted by severity (blocking before advisory), then by location.
  The ordering is fixed so two runs over unchanged inputs produce byte-identical reports.
  Omit the Delta line entirely when no comparison was requested.
  If there are no findings, write "None." and keep every other section.
-->

### <severity>: <short title>

- **Criterion**: <criterion_id>
- **Location**: <file>:<position>
- **Outcome**: deviation | judgment call | undecided
- **Source**: <documented rule, with URL and consulted date>
- **Rationale**: <why this outcome follows from the material>
- **Delta**: new | resolved | unchanged (cause: subject | baseline)

## Criteria Applied

<!--
  Every criterion evaluated, including those that produced no finding.
  This section is what distinguishes a clean subject from an unexamined one.
-->

| Criterion | Result |
|---|---|
| <criterion_id> | pass / finding / undecided |

---

<!--
  Rules this template enforces, from contracts/review-report.md:

  1. Every finding carries Criterion, Location and Source. Missing any one makes the report
     invalid and it must not be published.
  2. Coverage is mandatory even when complete. "Not examined: none" is a claim; silence is not.
  3. Criteria Applied is mandatory even when no findings resulted.
  4. Undecided outcomes appear as findings, never as omissions, and never count as passes.
  5. Severity may be lowered from the criterion default only with a stated reason.
  6. Delta lines appear only when a comparison was requested, and must name the cause.

  Not permitted:
  - Prose asserting quality beyond what the findings support.
  - Recommendations that alter the subject; this process is advisory and read-only.
  - Findings whose source is the reviewer's opinion. If no criterion covers it, it is not a
    finding — it belongs upstream as a proposed criterion.
-->
