# Feature Specification: CI/CD and Release Pipeline

**Feature Directory**: `specs/003-cicd-release-pipeline`

**Created**: 2026-07-31

**Status**: Draft

**Input**: User description: "Es soll eine umfangreiche cicd geben, dafür sollen die worfklows von gh-plumping verwendet werden, Du finedest ausführliche beschreibungen des release prozesses unter /home/nolte/repos/github/claude-shared/spec, dabei soll der release prozess unterstützt werden und die markdown und yaml files sollen statischen tests unterzogen werden."

## Context

`claude-goose` today has no automation of any kind: no remote, a single `main` branch, no `.github/`
directory, no static-check configuration, and no task runner. Every claim the repository makes about
its own deliverables — that a recipe parses, that a criterion file matches the published format, that
a cross-reference between `baselines/`, `process/` and `tests/` still resolves — is verified by hand
or not at all. Constitution Principle VI (Evidence-Backed Claims, NON-NEGOTIABLE) requires that a
claim name how it was determined; today nothing determines these claims mechanically.

The governing process descriptions for the target state already exist and are external to this
repository. They live under `spec/project/` in the portfolio hub and are authoritative here:
`branching-model` (which branches and workflows must exist), `continuous-integration` (pre-merge
stage design), `continuous-delivery` (post-merge delivery discipline), `release-automation` (the
Draft → Published transition and its gates), `github-actions-best-practices` (the platform binding),
`test-tier-static-analysis` (what the static tier contains), and `quality-gate` (how the gate is
invoked). The shared workflow implementations they mandate are published by `nolte/gh-plumbing`.

This feature brings `claude-goose` onto that governed path. It is deliberately a *consumer* feature:
the pipeline mechanics are inherited by pinned reference, and only what genuinely differs for this
repository — its toolchain, its own static checks, its stage set — is authored here.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A change to Markdown or YAML is statically verified before it can merge (Priority: P1)

A contributor changes a baseline criterion file, the review recipe, the report template, or any
documentation page, and opens a pull request. Without waiting for a human reviewer and without
spending an LLM call, they receive a verdict that names which class of problem occurred: a malformed
YAML document, a structural Markdown violation, a file that no longer matches its declared schema, a
cross-reference that no longer resolves, or prose that violates the project's style rules. A clean
verdict means the same thing on every pull request and on every machine.

**Why this priority**: This is the standalone MVP. It delivers value on the very first pull request,
independently of whether any release ever happens, and it is the slice the repository most acutely
lacks — the deliverables here *are* Markdown and YAML, so the static tier is not a supporting layer
but the primary verification surface.

**Independent Test**: Open a pull request that introduces one defect of each class (invalid YAML, a
Markdown structure violation, a recipe field that violates the recipe schema, a link to a moved
file, a prose-style violation). The pipeline reports failure, and each failing class is identifiable
from the check name without opening the log. Reverting each defect turns that check green.

**Acceptance Scenarios**:

1. **Given** a pull request whose YAML is not parsable, **When** the pipeline runs, **Then** the
   static-analysis stage fails and names the file and line.
2. **Given** a pull request that changes `process/goose-implementation-review/recipe.yaml` in a way
   the Goose recipe parser rejects, **When** the pipeline runs, **Then** the recipe parse check
   fails without any model being invoked.
3. **Given** a pull request that renames a file referenced from another tree, **When** the pipeline
   runs, **Then** the link-validation check fails and names the dangling reference.
4. **Given** a pull request with no defects, **When** the pipeline runs twice on the same commit —
   once with a cold cache and once with a warm cache — **Then** both runs reach the same verdict.
5. **Given** a contributor on a local workstation, **When** they invoke the repository's declared
   gate entry point, **Then** they run the identical set of checks the pipeline runs, with no
   environment branching that makes one stricter than the other.

---

### User Story 2 - Branch roles, protection, and merge behaviour are declared as code (Priority: P2)

A maintainer needs `develop` to be the integration branch that all work targets, `main` to be a
release-presentation branch nothing writes to by hand, and an approved, green pull request to merge
without a manual click. They configure none of this in a web UI: the branch roles, the required
status checks, and the merge automation are files in the repository, reviewable in a pull request
and reconstructible from the repository alone.

**Why this priority**: The static gate of US1 produces verdicts, but nothing yet *acts* on them.
This story turns those verdicts into merge gates and establishes the branch topology the release
chain in US3 depends on. It is independently valuable — a governed branch layout with automated
merges is worth having even before a release is ever cut.

**Independent Test**: Delete a branch-protection rule through the hosting platform's user interface
and re-trigger the settings synchronization; the rule is restored from the committed declaration.
Open a pull request against `develop` with a failing static check and confirm it cannot merge; fix
the check, approve the pull request, and confirm it merges without a manual merge action.

**Acceptance Scenarios**:

1. **Given** the committed branch-protection declaration, **When** it is synchronized, **Then**
   `develop` requires the static-gate checks to pass before merge and `main` rejects direct human
   pushes.
2. **Given** a pull request against `develop` that is approved and whose required checks are green,
   **When** the merge automation runs, **Then** the pull request is squash-merged without a
   maintainer performing the merge.
3. **Given** a pull request whose branch name does not carry one of the permitted prefixes, **When**
   a reviewer inspects it, **Then** the deviation is visible against the declared convention.
4. **Given** an attempt to push a commit directly to `main`, **When** the push is made by a human,
   **Then** it is rejected.

---

### User Story 3 - A release is cut, published, and propagated without hand-editing the release (Priority: P3)

A maintainer decides that the current state of `develop` is worth releasing. They do not create a
tag, do not edit a release in a web UI, and do not run a release-editing command against the tag.
They trigger the publish operation deliberately, it verifies its preconditions and refuses if any
fails, and once it succeeds the release-presentation branch is brought in line with the released
commit automatically. Afterwards it is possible to determine, from the repository and its run
history alone, which run published which release and who triggered it.

**Why this priority**: This is the release process the request names, and it is the slice with the
highest blast radius — a delivery defect ships, whereas a red pre-merge run blocks one pull request.
It is placed last because it presupposes the branch topology of US2, and because the repository can
operate usefully for some time without cutting a release.

**Independent Test**: With a draft release open, trigger the publish operation in its validation-only
mode and confirm every gate is evaluated and nothing is published. Then trigger it for real and
confirm the release is no longer a draft and that the presentation branch advanced to the released
commit.

**Acceptance Scenarios**:

1. **Given** pull requests have merged into the integration branch, **When** the drafting automation
   runs, **Then** an open draft release exists whose notes are derived from the merged pull-request
   titles.
2. **Given** an open draft release, **When** the publish operation is triggered in validation-only
   mode, **Then** every precondition is evaluated and reported and the release remains a draft.
3. **Given** no open draft release exists, **When** the publish operation is triggered, **Then** it
   fails with a message naming the missing precondition rather than creating anything.
4. **Given** more than one open draft release exists and no target is named, **When** the publish
   operation is triggered, **Then** it fails and lists every open draft rather than guessing.
5. **Given** a successful publish, **When** the propagation step completes, **Then** the
   release-presentation branch points at the released commit, and no human wrote to that branch.
6. **Given** a published release, **When** an auditor inspects the run history, **Then** the target
   tag, the triggering user, and the run reference are retrievable.

---

### Edge Cases

- **Two open drafts, no target named.** The publish operation must refuse and enumerate them; a
  "newest wins" heuristic is prohibited because it silently picks a release nobody chose.
- **A release event that does not cascade.** When the publishing identity is the workflow's own
  default token, the resulting release event does not start a downstream run. The propagation to the
  presentation branch then silently never happens, and the release looks complete while `main` is
  stale. The feature must make this outcome visible rather than silent, and must record which
  identity the repository uses.
- **The process version is not the repository version.** `process/goose-implementation-review/VERSION.md`
  carries the *process's* semantic version, which Constitution Principle II declares independent of
  the repository version. It must not be treated as a file the release automation aligns to the
  release tag. This repository has no version-bearing files at all.
- **A pull request that touches no Markdown or YAML.** The static gate must still run rather than be
  skipped by a path filter: a rename under a referenced directory breaks a cross-reference without
  touching the referencing file.
- **A check that cannot fail.** A check configured so that it always reports success — an empty file
  set, a tool that exits zero when it found nothing to do, an error suppressed to keep the run green
  — is indistinguishable from a check that is not running, and is a defect rather than a tolerable
  looseness.
- **The Goose toolchain is unavailable or drifts.** The recipe parse check depends on an external
  binary at a specific version. If that version is not pinned, the same commit can produce different
  verdicts on different days; if the binary cannot be installed, the check must fail loudly rather
  than be skipped.
- **The self-review cannot run unattended.** Constitution Principle V requires the process to review
  its own directory and produce no findings before release, but that run needs a model. It cannot be
  a pipeline stage, and its absence must be recorded as a deliberate, named out-of-pipeline practice
  rather than left as an apparent oversight.
- **A supply-chain obligation with nothing to scan.** This repository has no dependency manifest for
  its deliverables. An obligation that finds nothing must still have a declared position, cadence, or
  recorded practice, so that "no findings" is distinguishable from "never looked".
- **Warm versus cold cache.** A run that only passes because a cache was warm is not reproducible; a
  cache is an accelerator and must never change a verdict.

## Requirements *(mandatory)*

### Functional Requirements — Static verification (US1)

- **FR-001**: The pipeline MUST statically verify every YAML file in the repository for parsability
  and for conformance to a declared style ruleset, and MUST fail the run on any violation.
- **FR-002**: The pipeline MUST statically verify every Markdown file in the repository against a
  declared structural ruleset, and MUST fail the run on any violation. The active and the disabled
  rules MUST both be declared in a committed configuration rather than passed ad hoc.
- **FR-003**: The pipeline MUST validate `process/goose-implementation-review/recipe.yaml` against
  the recipe schema of the supported host version, and MUST validate baseline criterion files against
  the criterion format published under `baselines/goose/<revision>/`. A file that parses as YAML but
  violates its schema MUST fail.
- **FR-004**: The pipeline MUST validate the repository's internal links offline — relative file
  links, intra-page anchors, and cross-tree references between `baselines/`, `process/`, `tests/`,
  and `specs/` — and MUST fail on an unresolvable reference. External URLs MUST NOT be probed in the
  blocking gate, because network flakiness would make the verdict non-deterministic.
- **FR-005**: The pipeline MUST lint the prose of Markdown files against the project's declared
  style vocabulary and MUST fail on a violation. The style tool's version MUST be pinned so that the
  same source yields the same alerts locally and in the pipeline.
- **FR-006**: The pipeline MUST run `goose run --recipe <file> --explain` against the review recipe
  as a blocking check, with the Goose version pinned. This check MUST NOT invoke a model. If the
  toolchain cannot be provisioned, the check MUST fail rather than be skipped.
- **FR-007**: The pipeline MUST report the static-analysis classes as separately named units, so a
  red run names which class of problem occurred without the log being opened.
- **FR-008**: The pipeline MUST invoke each check through the repository's declared task entry point
  rather than re-implementing the invocation inline, so the local gate and the pipeline gate cannot
  diverge. The repository MUST provide that entry point.
- **FR-009**: The pipeline MUST run the static gate unconditionally on every pull request targeting
  the integration branch, without a path filter that could skip a run whose changes break a
  cross-reference indirectly.
- **FR-010**: No check in the required set may be configured so that it cannot fail the run. A check
  that is genuinely advisory MUST be declared as a non-required check rather than as a required check
  whose failure is suppressed.
- **FR-011**: A pipeline run MUST reach the same verdict on the same commit with a cold cache as with
  a warm cache. No cache may store a check result, and no cache key may omit content that determines
  the cached data.
- **FR-012**: Every external input the pipeline consumes — the toolchain versions, the check-tool
  versions, and every reusable pipeline component — MUST be resolved from a pinned reference. A
  moving branch, a bare `latest`, or an unbounded version range MUST NOT appear.

### Functional Requirements — Branch governance and merge automation (US2)

- **FR-013**: The repository MUST designate `develop` as the integration branch that all work targets
  by pull request, and `main` as a release-presentation branch that only the release automation
  writes to.
- **FR-014**: Branch-protection rules, required status checks, and repository merge settings MUST be
  declared as a committed file and synchronized from it. They MUST NOT be configured only through the
  hosting platform's user interface.
- **FR-015**: The static-gate checks of FR-001 through FR-006 MUST be declared as required status
  checks on the integration branch.
- **FR-016**: The repository MUST provide merge automation so that an approved pull request with all
  required checks green merges without a manual merge action, using the repository's declared merge
  strategy.
- **FR-017**: Feature branches MUST use the prefixes declared by the governing branching model, so
  that branch names and the conventional-commit types used in pull-request titles align without
  translation.

### Functional Requirements — Release chain (US3)

- **FR-018**: The repository MUST maintain a draft release on the integration branch that accumulates
  merged changes, with the notes derived from pull-request titles rather than hand-written.
- **FR-019**: The Draft → Published transition MUST be performed by a dedicated, deliberately
  triggered operation. It MUST NOT be reachable by a push, a pull request, or a schedule, and it MUST
  NOT be embedded in a workflow whose primary responsibility is a different release phase.
- **FR-020**: The publish operation MUST refuse to act when no draft produced by the drafting
  automation exists, and MUST refuse to guess when more than one draft is open and no target was
  named — it MUST instead list every open draft.
- **FR-021**: The publish operation MUST NOT create a tag, rewrite a tag, or accept a hand-crafted
  tag as a release source. The tag the draft carries is the tag that gets published.
- **FR-022**: The publish operation MUST offer a validation-only mode that evaluates every
  precondition and stops short of publishing.
- **FR-023**: The publish operation MUST surface the target tag, the triggering user, and the run
  reference so that a published release is attributable after the fact.
- **FR-024**: On publication, the release-presentation branch MUST be brought in line with the
  released commit mechanically. When the publishing identity is one whose events do not start the
  propagation run, that condition MUST be surfaced as an incomplete release rather than passing
  silently, and the repository MUST record which identity it uses.
- **FR-025**: The repository MUST declare that it has no version-bearing files, and MUST NOT treat
  `process/goose-implementation-review/VERSION.md` as one; the process version is independent of the
  repository version by Constitution Principle II.
- **FR-026**: Every workflow MUST declare an explicit permission set that is the minimum it needs,
  read-only at the top level with write scopes granted only on the job that requires them.
- **FR-027**: Release and delivery operations MUST NOT be configured to cancel an in-flight run,
  because cancelling mid-publication can leave a partially published release. Pre-merge runs SHOULD
  supersede stale runs.

### Functional Requirements — Reuse, coverage, and honesty of omissions

- **FR-028**: Pipeline mechanics that are identical across repositories MUST be consumed from the
  portfolio's shared workflow repository (`nolte/gh-plumbing`) by pinned reference, not copied into
  this repository. A defect in shared mechanics MUST NOT be fixed by patching a local copy; an
  interim local workaround MUST name the upstream change it waits for.
- **FR-029**: Each supply-chain obligation — dependency vulnerability scanning, license policy, and
  code-security review — MUST have either a declared position in the stage sequence, a declared
  cadence, or a recorded out-of-pipeline practice. An obligation with nothing to scan in this
  repository MUST still be recorded, so "no findings" is distinguishable from "never looked".
- **FR-030**: Every stage the governing pipeline design declares but that this repository omits —
  notably the package stage, since the repository ships no build artifact — MUST be visibly omitted
  with a recorded reason rather than silently absent.
- **FR-031**: The full review runs and the golden-file reconciliation under
  `tests/goose-implementation-review/` MUST be recorded as an out-of-pipeline practice, because they
  require a model and cannot run unattended. The same applies to the self-review that Constitution
  Principle V makes a release condition.
- **FR-032**: Every artifact this feature adds MUST satisfy Constitution Principle I: no absolute
  paths, no assumption about a directory layout that exists only here, and every context-specific
  value declared as an input with a stated default.
- **FR-033**: Files managed by the `specify` CLI and hashed in `.specify/integrations/*.json` MUST
  NOT be modified by this feature; any customization goes through the override mechanism.

### Key Entities

- **Static check class**: A named, independently reported unit of verification (YAML syntax, YAML
  style, Markdown structure, schema conformance, link resolution, prose style, recipe parse). Carries
  a pinned tool version and a committed configuration.
- **Gate entry point**: The single declared invocation that runs the static check classes. Consumed
  identically by a contributor locally and by the pipeline.
- **Branch role declaration**: The committed statement of which branch integrates work, which branch
  presents releases, what protects each, and which checks are required.
- **Draft release**: The accumulating, unpublished release on the integration branch, whose notes are
  derived from merged pull-request titles and whose tag is the only tag eligible for publication.
- **Publish operation**: The deliberately triggered transition from draft to published, with its
  precondition set, its validation-only mode, and its audit output.
- **Recorded omission**: A stage, obligation, or practice that this repository does not run in the
  pipeline, together with the reason and, where applicable, the cadence or out-of-pipeline practice
  that discharges it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every pull request receives a pass/fail verdict on all seven static check classes, and
  a contributor can name the failing class from the check names alone without opening a log.
- **SC-002**: A contributor who introduces one defect per check class sees exactly the corresponding
  check fail and every other check pass — seven of seven classes are individually falsifiable.
- **SC-003**: The same commit produces the same verdict on two consecutive runs, including one run
  with caching disabled.
- **SC-004**: A contributor running the repository's gate entry point on a fresh workstation obtains
  the same result the pipeline reports for the same commit, with no step that exists only in one of
  the two places.
- **SC-005**: The verdict for a pull request that changes only Markdown and YAML is available without
  any model being invoked and without any external network dependency beyond toolchain installation.
- **SC-006**: An approved pull request with green required checks merges into the integration branch
  without a maintainer performing a merge action.
- **SC-007**: Branch protection deleted through the hosting platform's user interface is restored
  from the committed declaration on the next synchronization, with no manual reconfiguration.
- **SC-008**: A direct human push to the release-presentation branch is rejected.
- **SC-009**: A release is published without any operator running a release-editing command against
  the tag, and the last released version is reproducible from the run history alone.
- **SC-010**: The publish operation refuses, with an actionable message, in each of its three refusal
  cases: no draft, several drafts with no target named, and a failed precondition.
- **SC-011**: After a successful publication, the release-presentation branch points at the released
  commit, or the run reports the release as incomplete — never neither.
- **SC-012**: For every stage and obligation the governing pipeline design names, this repository can
  point to either a running check or a recorded omission with a reason; there is no third case.
- **SC-013**: No pipeline definition in the repository contains a floating reference for a toolchain
  version, a check-tool version, or a shared workflow component.
- **SC-014**: The complete set of artifacts this feature adds can be copied into a second repository
  and works after changing only declared inputs, with no edit to any artifact body.

## Assumptions

- **A GitHub remote will exist for this repository.** The repository has no remote today. The
  branching model, the merge automation, and the entire release chain presuppose a hosted repository;
  creating it and pushing `develop` and `main` is part of this feature's scope per the scope decision
  recorded above, but the hosting account and its permissions are a precondition outside it.
- **`develop` becomes the default branch and `main` is derived from releases.** The current `main`
  content becomes the starting point of `develop`; `main` is thereafter written only by the release
  propagation.
- **The portfolio's shared workflow repository is reachable and tagged.** The pinned reference points
  at a release tag of `nolte/gh-plumbing`; the shared implementations named by the governing specs
  (drafting, publishing, propagation, merge automation, pre-commit, prose linting, dependency review)
  are assumed to exist there and to keep their declared input contracts.
- **No portfolio App identity is available initially.** The release event will therefore be emitted
  under the workflow's default token, which does not start the propagation run. This is a known
  platform constraint owned by the portfolio's workflow-health process, not a defect of this feature;
  FR-024 requires the resulting incompleteness to be visible, and the primary remedy is a
  portfolio-level change outside this repository.
- **The repository ships no build artifact and has no dependency manifest for its deliverables.** The
  package stage is therefore omitted (FR-030) and the supply-chain obligations are discharged by
  record rather than by a scan with findings (FR-029). A pinned requirements file may exist for the
  check toolchain itself; that is a pipeline input, not a shipped artifact.
- **The repository has no documentation site.** The documentation-delivery workflow that the
  branching model lists as conditional is therefore not applicable and is a recorded omission.
- **Runners are hosted, not self-hosted.** The repository is public, and the governing platform
  binding prohibits running public-repository workflows on self-hosted runners.
- **Vale style rules are consumed from the portfolio's published style repository** rather than
  authored here, consistent with the reuse-over-copying rule.
- **Goose 1.45.0 and `claude-agent-acp` are the supported host versions**, per `CLAUDE.md`. The
  recipe parse check pins to that version; a host upgrade is a reviewable change, and per
  Constitution Principle IV a breaking host change surfaces as a major version bump rather than a
  silent adaptation.
- **Full review runs and golden-file reconciliation stay out of the pipeline** because they require a
  model. Their status as an out-of-pipeline practice is recorded rather than implied (FR-031).

## Dependencies

- The portfolio spec corpus under `spec/project/` — `branching-model`, `continuous-integration`,
  `continuous-delivery`, `release-automation`, `github-actions-best-practices`,
  `test-tier-static-analysis`, `quality-gate`, `taskfile`, `link-validation`, `workflow-health` — is
  the governing authority for this feature. Where this specification and one of those specs differ,
  the spec wins and this document is amended.
- `nolte/gh-plumbing` supplies the shared workflow implementations consumed by pinned reference.
- `.specify/memory/constitution.md` v1.0.0 gates the plan; Principles I, III, V, and VI each bind
  requirements in this specification.
