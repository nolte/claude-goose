<!--
SYNC IMPACT REPORT
==================
Version change: TEMPLATE (unratified placeholders) → 1.0.0
Bump rationale: Initial ratification. The file previously contained only
  unfilled bracket tokens and had never defined governance, so this is an
  establishing version rather than an amendment.

Modified principles:
  [PRINCIPLE_1_NAME] → I. Reusable by Construction
  [PRINCIPLE_2_NAME] → II. Plans Are Versioned Artifacts
  [PRINCIPLE_3_NAME] → III. Auditable Revisions (NON-NEGOTIABLE)
  [PRINCIPLE_4_NAME] → IV. Host-Contract Fidelity
  [PRINCIPLE_5_NAME] → V. Dogfooding

Added sections:
  VI. Evidence-Backed Claims — added beyond the template's five principle slots
     at the operator's explicit instruction ("falsche und nicht nachvollziehbare
     Behauptungen und Vorgehensweisen sind ein Nogo"). Kept separate from
     III rather than folded in, because III governs plan revisions only,
     whereas VI governs every claim and procedure the project emits.
  [SECTION_2_NAME] → Authoring Constraints
  [SECTION_3_NAME] → Development Workflow
  Governance (amendment procedure, versioning policy, compliance review)

Removed sections: none

Templates requiring updates:
  ✅ .specify/templates/plan-template.md — no change needed; line 43 delegates
     gates to this file at runtime ("[Gates determined based on constitution
     file]"), so /speckit-plan resolves them dynamically.
  ⚠ .specify/templates/spec-template.md — mandatory sections (User Scenarios,
     Requirements, Success Criteria) are compatible as-is. However line 3 labels
     the identifier "Feature Branch", while feature state is resolved from
     .specify/feature.json and never from git (see common.sh get_current_branch).
     Cosmetic and upstream-owned; fix via an override if it causes confusion.
  ⚠ .specify/templates/tasks-template.md — line 12 declares tests OPTIONAL.
     Principle III requires a verification step per stage, which is narrower
     than "optional" but does not contradict it (the constitution tightens,
     the template permits). Revisit via an override if this proves too loose.
  ✅ .claude/skills/speckit-*/SKILL.md — verified by grep across all ten files:
     no agent-specific references (CLAUDE.md/AGENTS.md/GEMINI.md/copilot) and no
     dot-separated /speckit.* invocations that would contradict the "-" separator
     configured in .specify/integration.json.
  ✅ CLAUDE.md — updated to reflect a ratified constitution.

Deferred TODOs: none. All placeholders resolved.
-->

# claude-goose Constitution

## Core Principles

### I. Reusable by Construction

Every artifact this project ships — plan, skill, agent, or library module — MUST be usable in a
foreign repository without editing its body. Concretely: no hard-coded absolute paths, no
embedded project or author names, no assumptions about a specific directory layout, and no
implicit dependency on state that only exists in this repository. Anything context-specific MUST
be a declared, documented input with a stated default.

An artifact that cannot be dropped into a second project unchanged is not finished, regardless of
how well it works here.

Rationale: Missing reusability is the single failure mode this project exists to eliminate. Making
it a construction rule rather than a review checklist keeps it from being retrofitted, which
never works.

### II. Plans Are Versioned Artifacts

Multi-stage implementation plans are the product, not a byproduct of building something else. Each
plan MUST declare its stages explicitly, and each stage MUST state its preconditions, its outputs,
and the condition under which it is considered complete. A stage whose completion cannot be
checked by someone other than its author is underspecified and MUST be rewritten.

Plans carry their own semantic version, independent of the repository version.

Rationale: A plan that cannot be resumed, audited, or handed over is a transcript, not a plan.
Explicit stage boundaries are what make a plan reusable across contexts.

### III. Auditable Revisions (NON-NEGOTIABLE)

Plan history MUST be append-only and reconstructible. Every substantive change to a released plan
MUST record what changed, when, and why — silent rewrites are forbidden. Superseded stages are
marked as superseded and retained; they are never deleted or edited in place. Any consumer MUST be
able to determine, from the artifact alone, which revision they are running and what preceded it.

Each stage MUST carry at least one verification step that produces observable evidence of its
outcome.

Rationale: Revision safety is what allows a plan to be trusted after the fact. Without it,
reusability degrades into copying something that once appeared to work.

### IV. Host-Contract Fidelity

Integration with Goose MUST go exclusively through its documented provider interface. Forking
Goose, patching it at runtime, or depending on its internal, undocumented behavior is forbidden.
The supported provider-contract version MUST be stated explicitly, and a breaking change on the
host side MUST surface as a MAJOR version bump here, never as a silent adaptation.

Rationale: An integration that reaches behind the host's public contract breaks on the next
upstream release and takes every dependent plan down with it.

### V. Dogfooding

This project MUST develop itself using its own artifacts. A plan, skill, or agent is released only
after it has been used at least once to perform real work in this repository. Friction discovered
during that use is a defect against the artifact, not a workaround for the operator to absorb and
remember.

Rationale: The author is the first user. Problems that only surface in real use will not be found
by review.

### VI. Evidence-Backed Claims (NON-NEGOTIABLE)

Every factual claim this project makes — in documentation, plan text, status output, or agent
reasoning — MUST be traceable to something a reader can check. Specifically:

- A referenced file, command, API, option, or version MUST be verified to exist before it is
  cited. Plausibility is not evidence.
- A claim that something works MUST name how that was determined. If it was not verified, it MUST
  be labeled as an assumption.
- A procedure MUST be reproducible from its own text by a reader who cannot ask the author what
  was meant. "It works" is not a procedure.
- Failed, skipped, or partial steps MUST be reported as such. Silent omission is a violation even
  when the end result is correct.

Rationale: This project produces instructions that agents and people execute without re-deriving
them. A confident but unfounded claim propagates into every downstream reuse, where it is far
more expensive to detect than it was to avoid. Reusability is worthless if what is reused cannot
be trusted.

## Authoring Constraints

- **Language**: All documentation, skills, agents, plans, and code comments are written in
  English. This is independent of the language used for operator conversation.
- **Format**: Markdown is the authoring format for plans, skills, agents, and documentation.
  Machine-readable metadata belongs in YAML frontmatter, not in prose.
- **Distribution**: The project is public and open source. Every artifact MUST be intelligible to
  a reader who has no prior context on this repository and no access to its author.
- **Scaffolding**: Files managed by the `specify` CLI (hashed in `.specify/integrations/*.json`)
  MUST NOT be hand-edited. Customization goes through `.specify/templates/overrides/`.

## Development Workflow

Feature work follows the Spec Kit SDD pipeline: `/speckit-specify` → `/speckit-clarify` →
`/speckit-plan` → `/speckit-tasks` → `/speckit-implement`, with `/speckit-analyze` available as a
read-only consistency check before implementation.

- The Constitution Check gate in `plan.md` MUST pass before Phase 0 research and MUST be
  re-evaluated after Phase 1 design.
- A violation that cannot be removed MUST be recorded in the plan's Complexity Tracking table with
  a concrete justification and the rejected simpler alternative. An empty justification blocks the
  gate.
- Unresolved `[NEEDS CLARIFICATION]` markers in `spec.md` block `/speckit-plan`.

## Governance

This constitution takes precedence over convention, habit, and convenience. Where a principle and
an existing practice conflict, the principle wins until the constitution is amended.

**Amendment procedure**: Amendments are proposed as a change to this file, stating the affected
principles and the rationale. An amendment MUST update the Sync Impact Report at the top of this
file and reconcile the dependent artifacts listed there before it is considered complete.

**Versioning policy**: This document follows semantic versioning.

- **MAJOR**: A principle is removed or redefined in a way that invalidates prior compliance.
- **MINOR**: A principle or section is added, or existing guidance is materially expanded.
- **PATCH**: Clarification, rewording, or typo correction with no semantic change.

**Compliance review**: Compliance is verified at the Constitution Check gate of every plan. As
sole maintainer, the author reviews adherence at each amendment; once external contributors exist,
this section MUST be amended to define a review process that does not rely on a single person.

**Version**: 1.0.0 | **Ratified**: 2026-07-31 | **Last Amended**: 2026-07-31
