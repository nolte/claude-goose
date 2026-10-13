# Feature Specification: Portable Process Logic

**Feature Branch**: `004-portable-process-logic`

**Created**: 2026-08-02

**Status**: Draft

**Input**: User description (verbatim, not corrected):

```text
ich möchte das die goose receipt dokumente nur einen minnimalen aufruf beinhalten, die logik soll
in wiederverwendbaren allgemeingültigen elementen abgelegt werden um diese auch ohne goose zu nutzen
```

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run the process without Goose (Priority: P1)

An operator who does not have Goose — a person working by hand, or someone driving a different
agent host — wants to run the review process. They read the shipped process artifacts, supply the
same named inputs the contract declares, follow the stages, and produce a report that another
reader can recognise as a conformant report of this process. Nothing they needed was locked inside
a file that only Goose can read.

**Why this priority**: This is the outcome the operator asked for. Every other part of the feature
exists to make it possible. Without it, the process remains bound to one host, and the project's
own reusability principle is satisfied only for repositories that have adopted that host.

**Independent Test**: Take a subject and a baseline revision. Execute the process using only the
host-neutral artifacts, with no Goose installation and no reference to any host binding file.
Compare the resulting report against a report produced through the Goose binding over the same
subject and baseline.

**Acceptance Scenarios**:

1. **Given** a subject directory and a pinned baseline revision, **When** an operator executes the
   process from the host-neutral artifacts alone, **Then** they produce a report containing every
   mandatory section, including the coverage statement and the criteria table.
2. **Given** the same subject and baseline revision, **When** the process is executed once without
   Goose and once through the Goose binding, **Then** each report records which host executed it,
   and the two are compared on their reproducible digest content with every difference explained.
3. **Given** an operator who has never used Goose, **When** they read the host-neutral artifacts,
   **Then** they can name every required input, every optional input, and each optional input's
   default without consulting a host binding.
4. **Given** a subject that violates a criterion, **When** the process is run without Goose,
   **Then** the finding carries the same criterion id, location and cited source that the Goose
   binding would have produced.

---

### User Story 2 - One source of truth for every constraint (Priority: P2)

A maintainer changes a rule of the process — a constraint, a stage's completion condition, how the
coverage budget is spent, how a delta is classified. They edit exactly one artifact. No host
binding needs a matching edit, and no host binding can silently disagree with what they wrote.

**Why this priority**: Today the same constraints are written twice inside a single host binding
and a third time in the process description. Every duplicate is a place where the executed rule and
the documented rule can part company without anyone noticing — the exact failure the project's
evidence principle exists to prevent. Fixing this is what makes the host binding minimal.

**Independent Test**: Change one rule in the host-neutral definition. Verify that no host binding
required an edit, and that the automated gate fails if a host binding is made to contradict the
changed rule.

**Acceptance Scenarios**:

1. **Given** the restructured artifacts, **When** a reader searches for a normative statement of the
   process, **Then** they find it in exactly one artifact.
2. **Given** a host binding, **When** it is inspected, **Then** it contains input declarations, the
   mapping onto the invocation contract, and an entry pointer, and no rule that governs a review's
   outcome.
3. **Given** a host binding edited to state a rule that contradicts the host-neutral definition,
   **When** the repository gate runs, **Then** the gate fails and names the contradicting artifact.
4. **Given** a rule that is genuinely a property of one host and not of the process, **When** it is
   recorded in that host's binding, **Then** it is marked as host-specific so it cannot be mistaken
   for a rule of the process.

---

### User Story 3 - Bind a new host without re-authoring the process (Priority: P3)

Someone wants to run this process under a host that has no binding yet. They read the invocation
contract, write one binding artifact for their host, and run. They do not read, copy, or edit any
process logic, and they do not need to ask the author what a parameter means.

**Why this priority**: It is the proof that the separation actually holds. It also lowers the cost
of every future host, but it delivers value only once the first two stories are in place.

**Independent Test**: Have a reader who has not seen the internals produce a binding for a second
host, working only from the invocation contract, and record which host-neutral files they had to
change. The expected number is zero.

**Acceptance Scenarios**:

1. **Given** the invocation contract, **When** a new host binding is written, **Then** no
   host-neutral artifact is modified.
2. **Given** a host that cannot express part of the contract, **When** the binding is written,
   **Then** the limitation is recorded in that binding, and the host-neutral definition is left
   unchanged.
3. **Given** two host bindings for the same process version, **When** both are inspected, **Then**
   they declare the same input names, requiredness and defaults.

---

### Edge Cases

- **A host ignores a rule that is not present at the moment of invocation.** This has been measured,
  not assumed: a constraint stated only in the recipe's background field was overridden twice, and
  naming it at the point of invocation fixed it on the first attempt. A binding reduced to a bare
  pointer would risk reproducing that defect, which is why FR-005 requires the constraints to be
  carried into the invocation — derived, never authored there. "Minimal" therefore means the binding
  contributes nothing of its own, not that it is empty.
- **The derived constraint material and its source fall out of step.** Someone edits the binding to
  make a run work. The gate must reject it, and the rejection must say which artifact was edited and
  what it should have contained.
- **A rule is host-specific rather than process-specific.** The decision not to declare extensions,
  and the reasoning about which fields a host requires, describe one host. If they migrate into the
  neutral definition they mislead every other host; if they vanish, hard-won findings are lost.
- **A consumer copies only the host binding.** With the logic elsewhere, a partial copy now produces
  a run that cannot proceed rather than one that proceeds incorrectly.
- **A host cannot express an optional input with a default.** The contract must still be satisfiable,
  and the gap must be visible to whoever runs it.
- **Two hosts produce different reports for the same subject and baseline.** The report must make it
  possible to attribute the difference, which requires recording the host without letting host
  identity leak into the content that reproducibility is checked on.
- **An existing consumer has copied the current layout.** They must be able to tell from the
  artifacts alone whether their copy still matches the process version they believe they are running.
- **The process is run offline.** Host independence must not introduce a step that requires network
  access where the current process does not.
- **A maintainer edits a host binding to fix a run.** The gate must catch it, because that edit is
  precisely how the single source of truth is lost.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every normative rule that can change a review's outcome — constraints, stage
  definitions, coverage-budget behaviour, delta classification, and reporting obligations — MUST be
  stated exactly once, in an artifact that names no execution host.
- **FR-002**: The host-neutral artifacts MUST be sufficient on their own to carry out a complete
  review and produce a conformant report. No rule may exist only inside a host binding.
- **FR-003**: The project MUST publish an invocation contract that names every input, its
  requiredness, its default, and its meaning, expressed independently of any host's parameter
  syntax.
- **FR-004**: A host binding MUST contain only material that binds its host to that contract: input
  declarations, the mapping onto contract inputs, and the entry pointer. It MUST NOT introduce,
  restate, or narrow a rule of the process.
- **FR-005**: A host binding MUST carry the process's must-not-violate constraints at the point of
  invocation, in a form derived mechanically from the host-neutral definition rather than authored
  in the binding. The derived material MUST NOT be an independently editable copy. `FR-006` states the
  gate obligation that makes this hold; it is deliberately not restated here.
- **FR-006**: An automated check MUST fail when a generated region of a host binding no longer
  matches the host-neutral definition it derives from.
- **FR-007**: Every report MUST record which host executed the run, alongside the process version and
  baseline revision it already records.
- **FR-008**: The content on which reproducibility is checked MUST NOT vary with the executing host.
  Host identity is recorded in the report but excluded from that content.
- **FR-009**: The existing invocation MUST continue to accept the same input names, defaults and
  meanings; if any of them changes, the process version MUST record it as a breaking change and
  state what a consumer has to do.
- **FR-010**: The restructuring MUST be released as a versioned revision of the process that states
  what changed and why, with the superseded arrangement recorded rather than silently replaced.
- **FR-011**: Host-neutral artifacts MUST remain free of repository-specific content, and the
  existing portability guard MUST cover every artifact this feature introduces.
- **FR-012**: The process MUST be reviewed by itself after the restructuring and MUST produce no
  findings before the change is released.
- **FR-013**: A consumer MUST be able to copy the process directory into a foreign repository and run
  it under any supported host without editing any file in it.
- **FR-014**: Where a host cannot express part of the invocation contract, the limitation MUST be
  recorded in that host's binding, and MUST NOT be resolved by changing the host-neutral definition.
- **FR-015**: The feature MUST ship a second, executable host binding alongside the Goose one, built
  from the invocation contract and nothing else.
- **FR-016**: Before release, a real review MUST be run through each shipped host binding, and each
  run MUST be recorded with its subject, its baseline revision, its outcome, and the resulting
  report.
- **FR-017**: The reports from those runs MUST be compared field by field on their reproducible
  digest content. Any divergence MUST be recorded together with its cause. A divergence is a
  finding to be reported, not a condition that blocks the release.
- **FR-018**: Every line of a binding template MUST fall inside exactly one declared region. Only two
  region kinds are permitted: generated regions, and a host-specific-notes region. A line belonging
  to no declared region is a gate failure, not a tolerated remainder.
- **FR-019**: A host-specific-notes region MUST NOT be written in normative voice. The modal verbs
  the process reserves for its rules do not appear there. A rule written into a template is a gate
  failure that names the region and the offending line.
- **FR-020**: A host MUST be discoverable from where its template sits, with no list of hosts to
  maintain. Its identity, the file it renders to, and the name its reports carry MUST all follow from
  that location rather than from a separate declaration.
- **FR-021**: A host MUST have exactly one authored template. None, or more than one, is a gate
  failure naming what was found. This makes SC-004 enforced rather than merely measured.

### Key Entities

- **Process definition**: The host-neutral statement of the review — its stages, their preconditions,
  outputs, completion conditions and verification steps. Carries its own version.
- **Constraint**: A single normative statement that can change a review's outcome. Belongs to the
  process definition; never to a host binding. Named for what it is rather than "binding rule",
  which reads as "a rule belonging to a host binding" — the opposite of where it lives.
- **Invocation contract**: The named inputs of a run — requiredness, default, meaning — plus the
  obligations a host binding must satisfy to be considered conformant.
- **Host binding**: The artifact that lets one specific host start a run. Declares that host's inputs,
  maps them onto the contract, points at the entry, and records limitations of that host. Generated
  from the host-neutral sources and its own template; never authored directly.
- **Binding template**: The one artifact a person writes when adding a host. Every line of it belongs
  to a declared region — either one generated from the host-neutral sources, or one holding facts
  about the host. It is what the "exactly one artifact" in SC-004 counts.
- **Review report**: The output of a run. Carries the coverage statement, the findings, the applied
  criteria, the executing host, the process version, and the reproducible digest content.
- **Host-specific note**: A recorded fact about one host that is not a rule of the process, marked so
  that it is not read as one.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A review has been run through every shipped host binding over the same subject and the
  same baseline revision, and each run is recorded. Their reproducible digest content is compared
  field by field, and 100% of differing fields carry a recorded cause.
- **SC-002**: Zero normative statements of the process appear in more than one artifact. The standard
  repository gate verifies this in two parts: a generated region that no longer matches its source
  fails, and a template region written in normative voice fails. What neither part detects — the same
  rule restated in different words inside a host-neutral artifact — is recorded in `OMISSIONS.md`
  rather than counted as covered.
- **SC-003**: A reader can name every input of a run — required, optional, and each optional input's
  default — from a single artifact, in under 5 minutes, without opening a host binding.
- **SC-004**: Adding a binding for a new host requires **authoring** exactly one artifact — the
  host's template — and modifying zero host-neutral artifacts. The rendered output is generated
  rather than authored and is not counted.
- **SC-005**: The process reviewing its own directory after the restructuring produces no findings.
- **SC-006**: From a report alone, a reader can determine the executing host, the process version and
  the baseline revision in 100% of reports produced by any supported host.
- **SC-007**: Copying the process directory into a foreign repository and running it there requires
  zero edits to the copied files.
- **SC-008**: A host binding altered to contradict the host-neutral definition is rejected by the
  repository gate in 100% of attempts, and the failure names the offending artifact.
- **SC-009**: At least two host bindings exist, each has completed a recorded real review, and
  neither required an edit to a host-neutral artifact to come into being.

## Assumptions

- The scope is the existing review process and the pattern it establishes. The baseline revisions are
  data consumed by the process, are already free of host references, and are not restructured by this
  feature; their immutability rule continues to apply.
- Goose remains a supported host. This feature removes the dependency on Goose, it does not remove
  Goose.
- "Without Goose" means an operator — a person or a different agent host — following the shipped
  artifacts. It does not mean a deterministic program that produces findings without a reasoning
  agent; criterion evaluation remains a judgement task.
- The current invocation's input names, requiredness and defaults are treated as the contract worth
  preserving, because consumers may already depend on them.
- The findings recorded from real runs remain valid evidence and are carried forward rather than
  re-derived; where one of them describes a host rather than the process, it becomes a host-specific
  note.
- Verification that needs a reasoning agent stays outside the automated gate, as it does today. The
  gate covers what can be decided statically: duplication, contradiction, and portability.
- No new external dependency is introduced. A run that works offline today continues to work offline.
- Identical reproducible digests across two different hosts are treated as an open question, not as
  a given. Reasoning agents differ, and the project has already measured how much specification it
  took to make the digest stable across runs on one host. The obligation is therefore to compare and
  explain, not to assume agreement.
- The second host binding is chosen so that it can actually be exercised in this repository, since a
  binding that is never run proves nothing.
