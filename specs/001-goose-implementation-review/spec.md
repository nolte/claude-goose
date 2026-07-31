# Feature Specification: Review Process for Goose Implementations

**Feature Branch**: `001-goose-implementation-review`

**Created**: 2026-07-31

**Status**: Draft

**Input**: User description (verbatim, not corrected): `Es sollen hochwertige automatisierungen auf goose basis entstehen, dafür muss ein reviewprozess für bestehende Goose implementierungen geschaffen werden, welcher sich an den best prectices und an aktuellen Dokumentationen orientiert.`

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Evidence-Backed Review Report (Priority: P1)

An operator points the review process at an existing Goose implementation and receives a written
report listing what deviates from established practice. Every entry names the exact place in the
reviewed material it refers to and the specific rule or documented recommendation it is derived
from, so the operator can judge each entry without having to trust the reviewer.

**Why this priority**: This is the entire value proposition. Without a report a reader can check,
the process produces opinions rather than review results, and any quality claim about the resulting
automations would rest on nothing.

**Independent Test**: Run the process against one existing Goose implementation and confirm a report
is produced in which every entry traces to both a location in the reviewed material and a named
source. Delivers value on its own — the operator learns what to fix.

**Acceptance Scenarios**:

1. **Given** an existing Goose implementation and an available review baseline, **When** the
   operator requests a review, **Then** a report is produced in which each finding names the
   reviewed location, the source it is derived from, and a severity.
2. **Given** a reviewed implementation with no deviations, **When** the review completes, **Then**
   the report states explicitly that the material was checked and which criteria were applied,
   rather than being empty.
3. **Given** a criterion that cannot be decided from the material alone, **When** the review
   completes, **Then** that criterion is reported as undecided with its reason, and is not counted
   as passed.

---

### User Story 2 - Stated, Reproducible Baseline (Priority: P2)

An operator can see exactly which version of the practices and documentation a report was measured
against, and can re-run that review later to obtain the same result. When the baseline is updated,
the change appears as a distinct revision rather than silently altering what "correct" means.

**Why this priority**: A review whose yardstick is unknown or shifting cannot be revisited or
defended, and comparing two reports becomes meaningless. This is what makes the process
revision-safe rather than a one-time opinion.

**Independent Test**: Run the same review twice against an unchanged implementation and an unchanged
baseline; confirm both reports carry the same baseline identifier and list the same findings.

**Acceptance Scenarios**:

1. **Given** a completed review, **When** the operator reads the report, **Then** it identifies the
   baseline revision and the Goose version the criteria apply to.
2. **Given** an unchanged implementation and baseline, **When** the review is repeated, **Then** the
   findings are identical.
3. **Given** an updated baseline, **When** a review is run, **Then** the report carries the new
   baseline identifier and the previous revision remains retrievable.

---

### User Story 3 - Usable Against Foreign Implementations (Priority: P3)

An operator applies the review process to a Goose implementation in a repository that is not this
one, without editing the process itself. Anything specific to the reviewed subject is supplied as
input rather than embedded in the process.

**Why this priority**: Reusability is this project's reason for existing (Constitution Principle I).
A review process that only works on its author's own material fails the project's central
non-negotiable, however good its findings are.

**Independent Test**: Run the unmodified process against at least two implementations in different
repositories and confirm both produce valid reports with no edits to the process between runs.

**Acceptance Scenarios**:

1. **Given** an implementation outside this repository, **When** the operator runs the review,
   **Then** it completes without requiring any change to the process definition.
2. **Given** a subject requiring context the process cannot infer, **When** the review starts,
   **Then** that context is requested as a declared input with a documented default.

---

### User Story 4 - Change Between Reviews (Priority: P4)

An operator who reviewed an implementation before can see what changed since: which findings are
new, which were resolved, and which remain open.

**Why this priority**: Turns the review from a single verdict into a usable improvement loop.
Valuable, but only once single reviews are trustworthy and reproducible.

**Independent Test**: Review an implementation, change it, review again, and confirm the second
report classifies each finding as new, resolved, or still open relative to the first.

**Acceptance Scenarios**:

1. **Given** two reviews of the same subject, **When** the operator compares them, **Then** each
   finding is classified as new, resolved, or unchanged.
2. **Given** a finding that disappeared because the baseline changed rather than the subject,
   **When** the comparison is produced, **Then** that cause is distinguished from a real fix.

### Edge Cases

- What happens when the supplied subject contains no recognizable Goose material? The process must
  report that nothing reviewable was found, rather than returning a clean result.
- What happens when the reference documentation cannot be reached at review time? The process must
  either use its last known baseline and say so, or refuse — never silently review against nothing.
- How does the process handle a subject built against an older Goose version than the baseline
  describes? The version mismatch must surface as its own finding rather than producing a flood of
  misleading deviations.
- How does the process handle a criterion that is a matter of judgment rather than fact? It must be
  reported as a judgment call with its rationale, not asserted as a defect.
- What happens when the subject is too large to review in one pass? Coverage must be stated
  explicitly, so a partial review is never mistaken for a complete one.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The process MUST accept an existing Goose implementation as its review subject and
  identify which of its parts are in scope. In scope are **recipe definitions** and the **extension
  configurations they declare**. Out of scope for this feature, and to be revisited only after the
  in-scope types are covered: context-shaping artifacts (hints files, persistent instructions,
  prompt templates, skills), subagents, MCP apps, and session recipes.
- **FR-002**: Every finding MUST name the location in the reviewed subject it refers to and the
  specific rule or documented recommendation it derives from. A finding lacking either is invalid.
- **FR-003**: The process MUST assign each finding a severity distinguishing "must fix" from
  "should consider", so an operator can triage without reading every entry.
- **FR-004**: Each report MUST state the baseline revision and the Goose version its criteria apply
  to.
- **FR-005**: Repeating a review with an unchanged subject and unchanged baseline MUST produce
  identical findings.
- **FR-006**: The process MUST NOT modify the reviewed subject. Its output is a report; applying
  fixes is a separate, operator-initiated act.
- **FR-007**: A criterion that cannot be decided from the available material MUST be reported as
  undecided with its reason, and MUST NOT be counted as passed.
- **FR-008**: The process MUST state its coverage: which in-scope parts were examined and which were
  not.
- **FR-009**: The process MUST run against subjects in other repositories without editing the
  process definition; subject-specific values MUST be declared inputs with documented defaults.
- **FR-010**: The baseline MUST derive from current official Goose documentation and established
  practice, held as a pinned, curated ruleset inside this repository — the documentation base
  specified in `002-qa-documentation-base` — and MUST be accompanied by a drift check against
  upstream that reports an available baseline update as its own finding, rather than silently
  changing the yardstick between reviews.
- **FR-011**: Baseline revisions MUST be retained rather than overwritten, so any past report stays
  interpretable after the baseline moves on.
- **FR-012**: The process MUST compare a review against a previous review of the same subject and
  classify each finding as new, resolved, or unchanged, distinguishing changes caused by the subject
  from changes caused by the baseline.
- **FR-013**: The report MUST be a plain-text, version-controllable document readable without
  special tooling.

### Key Entities

- **Review Subject**: The existing Goose implementation under review, identified precisely enough
  that a later review can be shown to address the same thing.
- **Review Baseline**: The versioned set of criteria a review is measured against, derived from
  official documentation and established practice, carrying a revision identifier and the Goose
  version it applies to.
- **Review Criterion**: A single checkable expectation, stating what is expected, how it is decided,
  and which documented source it comes from.
- **Finding**: One deviation or judgment call, carrying its location in the subject, its source
  criterion, a severity, and a rationale.
- **Review Report**: The complete result of one review run — subject, baseline revision, coverage
  statement, and findings.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of findings in any report cite both a location in the subject and a named source;
  a report containing an unsourced finding is rejected.
- **SC-002**: Two reviews of an unchanged subject against an unchanged baseline produce identical
  findings in 100% of trials.
- **SC-003**: A reviewer other than the report's author can confirm or refute at least 90% of a
  report's findings using only the report and the reviewed subject, without asking the author.
- **SC-004**: The unmodified process produces valid reports for at least two implementations from
  different repositories.
- **SC-005**: An operator reviewing a single implementation of representative size reaches a triaged
  list of actionable findings within 15 minutes of starting. "Representative size" is fixed by a
  named reference fixture rather than left to judgment, so the criterion stays measurable.
- **SC-006**: Every report states its coverage, so no reader can mistake a partial review for a
  complete one.

## Assumptions

- The review is read-only and advisory. Automatically applying fixes is out of scope for this
  feature; the operator decides what to act on.
- The output is a findings report rather than a pass/fail verdict, because "high quality" is not a
  single threshold and different operators weigh findings differently.
- Severity uses a small, ordered scale separating blocking from advisory findings. The exact labels
  are an implementation concern.
- Reports and baselines are written in English Markdown and kept under version control, per the
  project's Authoring Constraints. FR-013 states the underlying requirement in format-agnostic terms
  so the criterion stays testable independently of that house rule.
- The primary user is the project author and, subsequently, anyone who adopts the process. No access
  control, multi-tenancy, or user management is implied.
- Reviewing an implementation does not require executing it. Findings derive from the material
  itself, which keeps reviews safe to run against untrusted third-party subjects.
- The process depends on Goose's published documentation being publicly available. Where upstream
  documentation for a checked area is missing, the affected criteria are reported as undecided
  (FR-007) rather than guessed at.
- The scope in FR-001 was chosen against the artifact taxonomy established in `research.md`, not
  assumed. Recipes were included because their reference documentation already states directly
  checkable rules; extensions because they carry the executing surface (`inline_python`, `stdio`).
- The canonical documentation source is `goose-docs.ai`; the previously published
  `block.github.io/goose` host is dead (HTTP 404 as of 2026-07-31). The upstream project is owned by
  `aaif-goose` under the Agentic AI Foundation. Any baseline research must start from the canonical
  host, since search engines still surface the dead one with cached content.
- This feature's baseline is produced by `002-qa-documentation-base`. Feature 001 can be planned and
  built against a baseline containing a single covered topic; it does not require the baseline to be
  complete, only for its gaps to be declared.
