# Feature Specification: Researched Documentation Base for Goose QA

**Feature Branch**: `002-qa-documentation-base`

**Created**: 2026-07-31

**Status**: Draft

**Input**: User description (verbatim, not corrected): `Es soll eine Dokumenten basis entstehen auf welchem der qs prozess für die goose implementierungen beruht. Die Dokumente müssen gründlich recherchiert sein. es dürfen keine Infromationen erfunden werden !`

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every Statement Carries Its Source (Priority: P1)

An author adds material to the documentation base. Each statement about how Goose behaves or how it
should be used is recorded together with the source it came from, precise enough that a reader can
open that source and find the statement. A statement the author cannot source does not enter the
base — it is recorded as an open question instead.

**Why this priority**: This is the feature's entire premise. A documentation base whose statements
cannot be traced is indistinguishable from invention, and everything the QA process concludes from
it would inherit that defect.

**Independent Test**: Add material covering one topic, then check every statement in it resolves to
a named source. Delivers value alone — that topic becomes usable as a QA reference.

**Acceptance Scenarios**:

1. **Given** an author writes a statement about Goose behavior, **When** the material is submitted,
   **Then** it carries a source reference identifying the document or artifact, its version or
   revision, and the date it was consulted.
2. **Given** an author cannot find a source for a statement they believe to be true, **When** they
   submit the material, **Then** the statement is recorded as an open question rather than as fact.
3. **Given** material containing a statement with no source reference, **When** it is checked,
   **Then** it is rejected and named as the offending statement.

---

### User Story 2 - A Third Party Can Verify Without Asking the Author (Priority: P2)

Someone who did not write the material — a reviewer, a future maintainer, or the QA process
consuming it — takes any statement and confirms or refutes it from the cited source alone, without
contacting the author and without re-doing the research.

**Why this priority**: Verifiability is what turns sourced material into a trustworthy basis. A
citation nobody can follow is decoration. This is also what makes the base survive its author.

**Independent Test**: Hand the material to a person who did not write it and have them check a
sample of statements using only the citations; measure how many they can resolve unaided.

**Acceptance Scenarios**:

1. **Given** any statement in the base, **When** a third party follows its citation, **Then** they
   reach material that either supports or contradicts the statement, with no further lookup needed.
2. **Given** a citation whose target has moved or disappeared, **When** verification is attempted,
   **Then** the failure is recorded against that statement rather than silently tolerated.
3. **Given** a statement derived from several sources that disagree, **When** a third party reads
   it, **Then** the disagreement and how it was resolved are visible.

---

### User Story 3 - Gaps Are Visible as Gaps (Priority: P3)

A reader can see what the documentation base does *not* cover. Topics where research found nothing
authoritative are listed as such, so neither a human nor the QA process mistakes absence of a rule
for absence of a problem.

**Why this priority**: Silent gaps are the failure mode that turns a partial base into false
confidence — QA would report a clean result for an area it never examined.

**Independent Test**: Compare the base's stated coverage against the topics the QA process needs and
confirm every uncovered topic appears in the gap list.

**Acceptance Scenarios**:

1. **Given** a topic where research found no authoritative source, **When** the base is published,
   **Then** that topic appears as a declared gap with what was searched.
2. **Given** a declared gap, **When** the QA process encounters it, **Then** the affected checks are
   reported as undecidable rather than passing.

---

### User Story 4 - Drift Against Upstream Is Detected (Priority: P4)

When an upstream source changes after material was written, the statements resting on it are flagged
for re-verification, so the base ages visibly rather than silently.

**Why this priority**: Documentation about a moving target decays. Valuable only once the base
exists and is verifiable, but without it the base becomes quietly wrong over time.

**Independent Test**: Record material against a source, simulate a change to that source, and confirm
the dependent statements are flagged.

**Acceptance Scenarios**:

1. **Given** a source that changed since it was consulted, **When** drift is checked, **Then** every
   statement citing it is flagged as needing re-verification.
2. **Given** a flagged statement, **When** it is re-verified and still holds, **Then** the record
   shows the new confirmation date without losing the previous one.

### Edge Cases

- What happens when the official documentation and the actual observable behavior disagree? Both
  observations must be recorded with their sources, and the conflict stated — not silently resolved
  in favor of one.
- What happens when a widely followed practice has no authoritative source? It does not enter the
  base. Per `FR-011` community practice is an excluded source class; the topic is recorded as a
  declared gap instead, so the QA process reports it undecidable rather than passing.
- What happens when the only available source is second-hand (a blog post, a forum answer)? It cannot
  back a statement. Where the behavior can be reproduced, record it as an **observation** with the
  method, host version and date — that is an admissible class, provided the statement is worded as an
  observation and never as a documented requirement.
- What happens when observation contradicts the documentation? Record both, state the conflict, and
  let the observation stand as an observation. This is not hypothetical: the shipped baseline's two
  most valuable criteria exist precisely because measured behavior departs from what the
  documentation implies.
- What happens when a source is version-specific? The statement must carry the version it holds for;
  an unversioned claim about versioned behavior is not acceptable.
- What happens when a cited source becomes unreachable? The statement must not silently remain as
  established fact.
- What happens when an author is confident but unsourced? The material is an open question,
  regardless of the author's confidence.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every statement of fact in the documentation base MUST carry a source reference
  identifying the source, its version or revision, and the date it was consulted.
- **FR-002**: A statement that cannot be attributed to a source MUST NOT be recorded as fact. It is
  recorded as an open question or omitted.
- **FR-003**: Each source reference MUST be precise enough for a third party to locate the supporting
  passage without further searching.
- **FR-004**: Each statement MUST carry the evidential strength of its source, distinguishing at
  minimum authoritative sources from second-hand and observational ones.
- **FR-005**: Where sources disagree, the base MUST record the disagreement and the reasoning applied,
  rather than presenting one reading as undisputed.
- **FR-006**: The base MUST declare its coverage: which topics are covered and which were
  investigated without an authoritative result.
- **FR-007**: Declared gaps MUST be consumable by the QA process so affected checks report as
  undecidable rather than passing.
- **FR-008**: The base MUST detect when a cited source has changed or become unreachable since it was
  consulted, and flag the dependent statements for re-verification.
- **FR-009**: Verification history MUST be retained. Re-verifying a statement adds a confirmation
  without erasing earlier ones.
- **FR-010**: Statements about version-specific behavior MUST record the version range they hold for.
- **FR-011**: Admissible source classes and their ranking are fixed to the four the review process
  already uses in production, in descending strength:
  1. **Official documentation** — the canonical documentation site.
  2. **Upstream repository and releases** — source, release notes, published version metadata.
  3. **Observation** — a reproducible measurement of actual behavior, recorded with the method, the
     host version, and the date. Statements derived from it MUST be worded as observations and MUST
     NOT be phrased as documented requirements.
  4. **Excluded** — community practice, blog posts and forum answers may not back a statement.

  Classes 1 and 2 are authoritative; class 3 is not, and the distinction MUST be visible to a reader
  (`FR-004`). Class 3 is nonetheless indispensable: the two most valuable criteria in the shipped
  baseline rest on it, because they describe behavior that contradicts what the documentation
  implies. Class 4 is excluded because search results have already been observed to surface stale
  content from a dead documentation host with confident summaries attached.
- **FR-012**: The base MUST cover the topics the QA process declares as gaps. The consuming baseline's
  coverage declaration is the work list: each declared gap names a topic that is deliberately
  uncovered, and closing one converts it into a criterion. This makes the scope evidence-derived
  rather than invented, and inherently prioritized — a gap only exists because a review needed it and
  found nothing.

  The base MUST NOT be considered complete when the gap list empties; new host versions produce new
  gaps. Completeness is not a release condition (see Assumptions); honesty about incompleteness is.
- **FR-013**: Material MUST be reviewable as a change: what was added or altered, and on which
  sources it rests, MUST be apparent without reading the whole base.
- **FR-014**: The base MUST be a plain-text, version-controllable set of documents readable without
  special tooling.

### Key Entities

- **Statement**: A single claim about Goose behavior or recommended practice — the smallest unit that
  is sourced, verified, and can be flagged.
- **Source Reference**: The pointer from a statement to its evidence, carrying identity, version or
  revision, consultation date, and the location of the supporting passage.
- **Source Class**: The category of a source and its evidential strength (for example authoritative,
  second-hand, observed), governing how a statement may be phrased.
- **Open Question**: A topic where research found no sufficient basis, recorded with what was
  searched so the effort is not repeated blindly.
- **Coverage Statement**: The declared map of what the base does and does not address.
- **Verification Record**: The history of when a statement was confirmed against its source and by
  whom.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero statements in the published base lack a source reference. This is a release
  condition, not a target — a single unsourced statement blocks publication.
- **SC-002**: A reviewer who did not author the material resolves at least 95% of a sampled set of
  statements to their sources unaided; any statement they cannot resolve is corrected before release.
- **SC-003**: 100% of statements about version-specific behavior name the version range they apply to.
- **SC-004**: Every topic the QA process requires is either covered or listed as a declared gap; no
  topic is silently absent.
- **SC-005**: A reader locates the source of an arbitrary statement in under one minute.
- **SC-006**: After an upstream source changes, every dependent statement is flagged before the base
  is used for a QA run.
- **SC-007**: Where sources conflict, 100% of the conflicts are visible to the reader rather than
  resolved silently.

## Assumptions

- The base is a research and reference artifact, not a tutorial. It records what is true and where
  that is established, not how to get started with Goose.
- Research is manual or tool-assisted but always author-attributed; a statement is someone's recorded
  finding, not an anonymous assertion.
- Reviewing is read-only with respect to upstream. Nothing in this feature changes Goose or its
  documentation.
- Documents are English Markdown under version control, per the project's Authoring Constraints.
  FR-014 states the underlying requirement in format-agnostic terms so it stays testable
  independently of that house rule.
- The base is consumed primarily by the review process specified in
  `001-goose-implementation-review`, which supplies its "Review Baseline". A second consumer is any
  human wanting to know why a rule exists.
- Completeness is not a release condition; honesty about incompleteness is. A small base with
  declared gaps is acceptable, a large base with hidden gaps is not.
- No claim is made that the base reflects Goose behavior beyond what its cited sources support at
  their recorded versions.
