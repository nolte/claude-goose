# Contract: Review Report Format

**Feature**: `001-goose-implementation-review` | **Date**: 2026-07-31

Fixes the shape of a report so a third party — human or program — can read it without knowing how it
was produced. Plain-text and version-controllable per `FR-013`.

## Required structure

```markdown
# Review Report: <subject identity>

**Subject**: <location> (<revision, if any>)
**Process version**: <semver of the review process>
**Baseline**: <revision_id> for Goose <goose_version>
**Run date**: <YYYY-MM-DD>
**Compared to**: <prior report, or "none">

## Coverage

**Examined**: <in-scope parts reviewed>
**Not examined**: <parts skipped, each with reason — or "none">
**Baseline gaps**: <topics the baseline declares uncovered — or "none">

## Findings

### <severity>: <short title>

- **Criterion**: <criterion_id>
- **Location**: <file>:<position>
- **Outcome**: deviation | judgment call | undecided
- **Source**: <documented rule, with URL and consulted date>
- **Rationale**: <why>
- **Delta**: new | resolved | unchanged (cause: subject | baseline)   ← only when compared

## Criteria Applied

<list of criterion ids evaluated, including those that produced no finding>
```

## Rules

1. **Every finding carries `Criterion`, `Location`, and `Source`.** A report containing a finding
   missing any of the three is invalid and must not be published (`SC-001`, `FR-002`).
2. **`Coverage` is mandatory even when complete.** "Not examined: none" is an explicit claim; its
   absence is not (`SC-006`).
3. **`Criteria Applied` is mandatory even when no findings resulted.** This is what distinguishes a
   clean subject from an unexamined one (`US1` scenario 2).
4. **Undecided outcomes appear as findings**, not omissions. They are never counted as passes
   (`FR-007`).
5. **Severity may be lowered from the criterion's default only with a stated reason** in the
   rationale. Silent downgrading is forbidden (Principle VI).
6. **Delta fields appear only when `compared_to` is set**, and must name the cause — subject or
   baseline. A finding that vanished because the baseline changed is not a fix (`FR-012`).

## Ordering

Findings are sorted by severity, then by location. Ordering is fixed so that two runs over unchanged
inputs produce byte-identical reports, making `FR-005` mechanically checkable by comparing files
rather than by reading them.

## Not permitted

- Prose summaries that assert quality beyond what the findings support ("this recipe is well
  written"). The report states what was checked and what deviated — nothing more (Principle VI).
- Recommendations that alter the subject. The process is advisory and read-only (`FR-006`).
- Findings whose source is the reviewer's opinion. If no criterion covers it, it is not a finding;
  it belongs upstream as a proposed criterion in `002-qa-documentation-base`.
