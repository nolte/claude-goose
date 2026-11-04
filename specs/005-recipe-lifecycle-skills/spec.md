# Feature Specification: Recipe Lifecycle Skills

**Feature Directory**: `specs/005-recipe-lifecycle-skills`

**Created**: 2026-09-24

**Status**: Draft

**Input**: User description (verbatim, not corrected):

```text
Skills, die den Entwicklungsprozess von Goose-Rezepten abbilden, getrennt in vier Phasen:
Anforderungserfassung, Planung der Umsetzung, Implementierung und Audit auf Best Practices. Klare
Abgrenzung zu den generischen Skills in nolte/claude-shared: die Goose-spezifischen Skills
delegieren generische Arbeit dorthin und tragen nur das, was Goose-Rezepte betrifft. Das Audit darf
keine Kriterien neu erfinden, sondern bindet den bestehenden Review-Prozess mit gepinnter Baseline
ein.
```

## User Scenarios & Testing *(mandatory)*

Today this repository can *judge* a Goose recipe but cannot help anyone *make* one. The review
process reports what deviates from the documentation after the fact. Nothing guides an author from
"I need a recipe that does X" to a recipe that passes that review on the first attempt. This feature
adds that guidance as four phase-scoped skills, one per phase of a recipe's life: capturing what the
recipe must do, planning how the recipe realises it, writing the recipe, and auditing the result.

The four skills are one workflow, but each is usable alone. An author who already has a written
requirement starts at planning; an author who already has a recipe starts at the audit.

### User Story 1 - Audit a recipe against the pinned baseline (Priority: P1)

An author has a Goose recipe, written by hand or by any tool, and wants to know how it measures
against the documented rules before shipping it. They invoke the audit skill on the recipe. The
skill runs the existing review process against a pinned baseline revision and hands back the
review report. Every finding in that report names its criterion, its location and its documented
source, exactly as a report produced through the Goose binding would.

**Why this priority**: The audit is the phase that already has a working core. It is the smallest
slice that delivers value on its own, it is the gate every other phase must satisfy, and it is the
proof that the skills reuse the review process rather than re-implement it.

**Independent Test**: Audit a fixture recipe through the skill and through the existing Goose
binding over the same baseline revision. Compare the two reports on their reproducible digest
content. They must match, and every difference must be explained.

**Acceptance Scenarios**:

1. **Given** a recipe and a pinned baseline revision, **When** the audit skill runs, **Then** it
   produces a review report that names the baseline revision, the process version and the host that
   executed it, and contains every mandatory report section.
2. **Given** the same recipe and baseline, **When** it is audited once through the skill and once
   through the Goose binding, **Then** the reproducible digest content of the two reports is
   identical.
3. **Given** a recipe that violates a criterion, **When** the audit skill runs, **Then** the
   finding carries the same criterion id, location and cited source the Goose binding would
   produce.
4. **Given** a recipe that touches a topic the baseline declares as a gap, **When** the audit skill
   runs, **Then** the gap appears as an `undecided` finding and never as a pass.
5. **Given** the audit skill's own description, **When** a reader looks for a rule of the review
   process in it, **Then** they find none; the skill states where the rules live and which baseline
   revision it applied.

---

### User Story 2 - Capture what a recipe must do (Priority: P2)

An author knows roughly what they want a recipe to accomplish but has not written it down in a
form anyone could build from. They invoke the requirements skill. It runs the portfolio's generic
elicitation method and adds only the questions that are specific to a Goose recipe: what the
recipe takes as input, what capabilities it needs from the host, whether it runs unattended, what
it must hand back, and what it must never do. The result is a recipe requirement artifact that
another person can read and build from without asking the author.

**Why this priority**: A recipe built from an unstated requirement fails the audit for reasons
nobody can trace to a decision. Capturing the requirement first is what makes the later phases
checkable. It ranks below the audit only because the audit is usable without it.

**Independent Test**: Run the requirements skill for a recipe of representative size. Hand the
resulting artifact to a reader who did not take part in the interview. They must be able to name
every input the recipe takes, every host capability it needs, and its execution mode without
consulting the author.

**Acceptance Scenarios**:

1. **Given** an author with an informally stated need, **When** the requirements skill completes,
   **Then** a requirement artifact exists that states the recipe's purpose, inputs and whether each is
   required, needed host capabilities, execution mode, expected output and prohibited
   behaviour.
2. **Given** a requirement that would violate a baseline criterion by construction, for example an
   optional input that must import a file, **When** the requirements skill captures it, **Then**
   the conflict is named in the artifact together with the criterion it would violate, before any
   recipe is planned.
3. **Given** a question that is not specific to Goose recipes, **When** the requirements skill
   asks it, **Then** it asks it through the portfolio's generic elicitation capability, not through
   a question of its own.
4. **Given** a requirement the author cannot answer, **When** the artifact is written, **Then** the
   open point is recorded as such rather than filled with a guess.

---

### User Story 3 - Plan the recipe before writing it (Priority: P3)

An author has a recipe requirement artifact and wants a plan for the recipe itself: which recipe
elements realise which requirement, which inputs become parameters and with what defaults, which
host capabilities become declared extensions, and which baseline criteria the design must satisfy
by construction. They invoke the planning skill. The result is a recipe plan in which every
requirement maps to a recipe element and every recipe element traces back to a requirement.

**Why this priority**: The plan is where most audit findings are avoided, because it is where an
optional file input, a missing headless prompt or an undeclared capability becomes visible before
it is written. It depends on a requirement artifact, so it ranks after the phase that produces one.

**Independent Test**: Plan a recipe from an existing requirement artifact. Check that every
requirement appears in the plan, that every planned element names its requirement, and that every
baseline criterion applicable to the planned recipe is either marked satisfied by construction or
named as a risk.

**Acceptance Scenarios**:

1. **Given** a recipe requirement artifact, **When** the planning skill completes, **Then** a
   recipe plan exists in which each requirement maps to at least one recipe element and each
   element names the requirement it serves.
2. **Given** a requirement that cannot be realised within the documented recipe rules, **When**
   the plan is written, **Then** the plan names the requirement, the rule it collides with, and
   returns the decision to the author rather than choosing silently.
3. **Given** a planned recipe intended to run unattended, **When** the plan is checked, **Then**
   it names the element that makes unattended execution possible and the criterion that requires it.
4. **Given** the generic structure of a plan, **When** the planning skill produces one, **Then**
   the structure comes from the portfolio's generic planning capability and the skill adds only the
   recipe-specific mapping.

---

### User Story 4 - Write the recipe from the plan (Priority: P4)

An author has a recipe plan and wants the recipe written. They invoke the implementation skill. It
produces the recipe and its declared extension configuration from the plan, checks the result with
the host's own validation at no model cost, and records which plan element each part of the recipe
realises. The output is ready for the audit.

**Why this priority**: This is the phase that produces the deliverable, but it is worth little
without a plan to build from and an audit to prove it. It closes the workflow rather than opening
it.

**Independent Test**: Implement a recipe from an existing plan, then audit it. The audit must
report no `deviation` findings. Every element in the recipe must be traceable to a plan element.

**Acceptance Scenarios**:

1. **Given** a recipe plan, **When** the implementation skill completes, **Then** a recipe exists
   that the host's own validation accepts.
2. **Given** the produced recipe, **When** it is audited against the baseline revision the plan
   named, **Then** the report contains no `deviation` finding.
3. **Given** the produced recipe, **When** a reader asks why an element exists, **Then** the
   element traces to a plan element and through it to a requirement.
4. **Given** the host's validation rejects the produced recipe, **When** the implementation skill
   reports, **Then** it reports the rejection verbatim and does not present the recipe as done.

---

### Edge Cases

- **The generic capability the skill delegates to is not available.** A consumer may have installed
  the recipe skills without the portfolio's shared skills. The skill must stop and name the missing
  capability. It must not perform the generic work itself, because that is exactly the duplicate
  the delimitation forbids.
- **The delegated capability changes upstream.** A rename or a changed output shape in the shared
  skills must surface as a named failure in the recipe skill, not as silently different behaviour.
- **The audit skill is invoked with no baseline revision.** It resolves `latest` the way the review
  process does and reports the resolved id, never the word `latest`.
- **The audit skill is pointed at a directory containing no recipe.** The report states that
  nothing reviewable was found. A clean report over nothing is forbidden, as it is in the process.
- **A requirement is captured for a recipe the baseline cannot fully judge.** The declared gaps of
  the pinned baseline are named in the requirement artifact so the author knows which properties
  the audit will report as `undecided` rather than decide.
- **An author starts mid-workflow with a hand-written input artifact.** Each skill must accept the
  artifact of its predecessor whether the predecessor skill produced it or a person did, and must
  say what is missing if the artifact is incomplete.
- **The planning phase discovers the requirement cannot be built.** The plan returns the conflict to
  the author instead of quietly narrowing the requirement.
- **Two skills could both plausibly own a step.** Ownership is decided once, recorded in the
  delimitation, and never left to whichever skill happens to run first.
- **The review process moves to a new version while the skills are in use.** The audit skill
  reports the process version it ran, so a changed finding can be attributed to a changed method
  rather than a changed recipe.

## Requirements *(mandatory)*

### Functional Requirements

**Phase structure**

- **FR-001**: The feature MUST ship exactly four skills, one per phase: requirements capture,
  implementation planning, implementation, and audit. No skill covers more than one phase.
- **FR-002**: Each skill MUST be invocable on its own, taking the artifact of the preceding phase
  as input regardless of whether that artifact was produced by the preceding skill or written by a
  person.
- **FR-003**: Each skill MUST produce exactly one named output artifact, and MUST state which
  input it consumed, so the chain of requirement, plan, recipe and report is reconstructible from
  the artifacts alone.
- **FR-004**: A skill that receives an incomplete input artifact MUST name what is missing and stop.
  It MUST NOT fill the gap with an assumption presented as the author's decision.

**Delimitation from the shared portfolio skills**

- **FR-005**: Each skill MUST carry only what is specific to Goose recipes. Work that is generic to
  any development phase — the elicitation method, the structure of a plan, the pull-request flow,
  the quality gate — MUST be delegated to the named shared capability that already owns it.
- **FR-006**: Each skill MUST declare, in its own description, which shared capability it delegates
  to and what it adds beyond that capability. A reader MUST be able to draw the boundary from the
  two descriptions alone.
- **FR-007**: Before a skill is authored, the existing shared skills and agents MUST be checked for
  an equivalent capability, and the result of that check MUST be recorded. A near-equivalent found
  there is extended or referenced, never duplicated here.
- **FR-008**: No skill name MAY collide with a name owned by the shared portfolio plugins.
- **FR-009**: When a delegated shared capability is unavailable, the skill MUST fail with the name
  of the missing capability. It MUST NOT substitute its own implementation of the generic work.
- **FR-010**: The four skills MUST ship as one installable unit with a distribution contract
  distinct from the shared portfolio plugins: they are for consumers who develop Goose recipes and
  require Goose to be present. That difference, not their topic, is the justification for shipping
  them separately, and it MUST be recorded where the unit is described.

**Audit phase**

- **FR-011**: The audit skill MUST invoke the existing review process against a pinned baseline
  revision and return its report. It MUST NOT evaluate any criterion itself.
- **FR-012**: The audit skill MUST NOT introduce, restate or narrow a criterion or constraint of
  the review process. Every normative statement it relies on lives in the process, and the skill
  points there.
- **FR-013**: The audit skill MUST honour the review process's invocation contract: the same input
  names, the same required-or-optional status and the same defaults, and no input of its own.
- **FR-014**: A report produced through the audit skill MUST be comparable on its reproducible
  digest content with a report produced through the Goose binding over the same subject and
  baseline, and MUST record the host that executed it.

**Requirements phase**

- **FR-015**: The requirement artifact MUST state, for the recipe: its purpose, each input, whether it is
  required, and whether it carries a default, the host capabilities it needs, whether it runs
  unattended, the shape of what it hands back, and what it must never do.
- **FR-016**: The requirements skill MUST check each captured requirement against the criteria and
  declared gaps of the pinned baseline revision and MUST record, in the artifact, every requirement
  that would violate a criterion by construction and every property the baseline cannot decide.
- **FR-017**: Anything the author cannot answer MUST be recorded as an open point, never as a
  guessed value.

**Planning phase**

- **FR-018**: The recipe plan MUST map every requirement to at least one recipe element and every
  planned element to the requirement it serves. An element with no requirement and a requirement
  with no element are both defects of the plan.
- **FR-019**: The plan MUST name every baseline criterion applicable to the planned recipe and
  state, for each, whether the design satisfies it by construction or carries it as a risk.
- **FR-020**: A requirement that cannot be realised within the documented recipe rules MUST be
  returned to the author as a named conflict. The plan MUST NOT resolve it by narrowing the
  requirement.

**Implementation phase**

- **FR-021**: The implementation skill MUST produce the recipe and its declared extension
  configuration from the plan and nothing else. An element that has no plan element is a defect.
- **FR-022**: The produced recipe MUST be checked with the host's own validation before it is
  reported as done. A rejection MUST be reported verbatim and blocks completion.
- **FR-023**: The implementation skill MUST record, for each part of the recipe, the plan element it
  realises, so the audit's findings can be traced back to a decision.

**Evidence and release**

- **FR-024**: Every skill MUST record, in its output artifact, which baseline revision, which
  version of the review process, and which version of the lifecycle itself were in force when it
  ran. The two process versions are distinct fields; a reader must never have to guess which one a
  number refers to.
- **FR-025**: Before release, each skill MUST have been used at least once for real work in this
  repository, and each use MUST be recorded with its input, its output and its outcome. A skill
  with no recorded use is not released.
- **FR-026**: Before release, one recipe MUST have passed through all four phases in order, and its
  final audit MUST have been recorded together with the digest comparison required by FR-014.
- **FR-027**: The skills MUST be free of repository-specific content and MUST pass the existing
  portability guard, so a consumer can install them without editing them.

### Key Entities

- **Recipe requirement artifact**: What a recipe must do, stated so a stranger can build from it:
  purpose, inputs, needed host capabilities, execution mode, output shape, prohibited behaviour,
  open points, and the baseline criteria and gaps it was checked against.
- **Recipe plan**: The mapping from requirements to recipe elements and back, with each applicable
  baseline criterion marked satisfied-by-construction or risk, and every requirement that cannot be built
  returned as a named conflict.
- **Recipe**: The deliverable: the recipe definition and its declared extension configuration, each
  part traceable to a plan element.
- **Review report**: The audit's output, produced by the existing review process; unchanged in
  shape by this feature, now additionally reachable through a skill.
- **Delimitation record**: For each skill, the shared capability it delegates to, what it adds, and
  the result of the duplicate check against the shared skills and agents.
- **Phase skill**: One of the four skills. Owns exactly one phase, consumes one input artifact,
  produces one output artifact, and carries nothing generic.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A recipe developed through all four phases in order passes its first audit with zero
  `deviation` findings.
- **SC-002**: The report produced by the audit skill and the report produced by the Goose binding
  over the same subject and baseline revision have identical reproducible digest content, measured
  on at least two fixtures.
- **SC-003**: For every skill, a reader can name from its description alone which shared capability
  it delegates to and what it adds; measured by having a reader who has not seen the skills do so
  for all four, with zero wrong attributions.
- **SC-004**: Zero normative statements of the review process appear in the audit skill; measured
  by searching the skill for the process's reserved modal verbs applied to a review rule.
- **SC-005**: Every artifact in a completed lifecycle run is traceable end to end: each recipe
  element to a plan element, each plan element to a requirement, with zero unmapped elements in
  either direction.
- **SC-006**: A consumer who installs the skills without the shared portfolio skills gets a failure
  naming the missing capability on the first invocation of each skill that delegates.
- **SC-007**: The run record contains, before release, at least four entries that each name a
  different one of the four skills as the skill that ran, plus one entry for a full lifecycle run;
  measured by counting entries, not by reading intent.
- **SC-008**: An author with an informally stated need reaches a requirement artifact that a second
  reader can build from, in a single session, without the second reader consulting the author.

## Assumptions

- **The audit skill is the skill-shaped entry to the host binding that feature 004 introduces.** It
  does not carry review logic of its own; it starts the review under the host the skills run on.
  This feature therefore depends on feature `004-portable-process-logic` shipping a binding for
  that host. If 004 has not shipped when this feature is planned, the audit skill's plan must
  name that dependency explicitly rather than work around it.
- **The shared portfolio skills are a declared prerequisite, not an optional enhancement.** Failing
  closed when they are absent was chosen over falling back to a local implementation, because the
  fallback would be the duplicate the delimitation exists to prevent. A consumer who does not want
  the shared skills does not get the recipe skills.
- **The scope of "recipe" is the scope of the review process**: the recipe definition and the
  extension configurations it declares. Context artifacts, subagents and session recipes stay out
  of scope, as they do for the review.
- **The implementation phase validates with the host's parser only.** A live run with a model is
  not part of the phase, because it costs a subscription and its outcome depends on the model. An
  author who wants one runs it deliberately after the audit.
- **Skills, not agents.** The user asked for skills, and every phase gates on the author's
  decisions mid-flow, which is the pattern the portfolio's artifact-type rule assigns to skills.
  The plan records the choice per skill in the form that rule requires.
- **The skills live in this repository and ship from it.** Their distribution contract differs
  from the shared portfolio plugins in requiring Goose, which is the one justification the
  portfolio's plugin-scoping rule accepts for a separate unit. Where exactly the unit is declared
  is a planning decision.
- **The baseline revision applied by all four phases is pinned once per lifecycle run**, in the
  requirement artifact, and carried forward. A later phase may not silently move to a newer
  revision, for the same reason the review may not.
- **A change in a delegated shared capability is caught by the release pin, not by the skill.**
  The edge case "the delegated capability changes upstream" is covered by pinning the shared
  plugin's release and moving that pin only with a recorded re-verification. The skill does not
  inspect the shared capability's version at run time; a consumer who installs a newer shared
  release than the pin is outside the verified set, and the pin record says so.
- **Dogfooding target**: the first recipe to pass through all four phases is a real recipe this
  repository needs, not a fixture written for the purpose. Which one is decided at planning.
