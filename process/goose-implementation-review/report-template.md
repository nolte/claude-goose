# Review Report: <subject identity>

**Subject**: <location> (<revision, if any>)
**Process version**: <semver from VERSION.md>
**Baseline**: <revision_id> for Goose <goose_version>
**Host**: <host identifier from the binding that ran>
**Run date**: <YYYY-MM-DD>
**Compared to**: <prior report, or "none">

```text
DIGEST v1
baseline=<revision_id> process=<semver> subject=<sha256 of subject manifest>
<criterion_id>|<location>|<outcome>|<severity>
```

<!--
  The digest is the machine-comparable core of the report and the ONLY part that
  must be byte-identical between two runs over unchanged inputs. One line per
  finding, sorted by severity (blocking first), then criterion id, then location.
  No prose, no extra spacing. With no findings, emit the two header lines only.

  Everything below is explanatory and may be worded freely. What must hold is
  identical findings over identical inputs, not identical sentences.

  The Host field is deliberately NOT in the digest. It belongs to the header.
  Putting it in the digest would make any comparison of two reports from
  different hosts report a reproducibility failure by construction, which is
  exactly the comparison the field exists to make possible.

  The digest's process= field DOES move when the process version moves. That is
  what a MAJOR bump means here, and golden files are re-pinned when it happens.
-->

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
  Rules this template enforces:

  1. Every finding carries Criterion, Location and Source. Missing any one makes the report
     invalid and it must not be published. This is C-5 in constraints.md.
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
