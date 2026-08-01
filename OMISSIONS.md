# Omissions

Every stage the governing pipeline design names, and every guarantee this repository does **not**
provide, with a reason and a condition under which the omission stops being correct (`FR-030`,
`SC-012`).

**Silence is not an answer.** A stage that appears nowhere is indistinguishable from one that was
forgotten, which is why this file lists things that do not happen rather than only things that do.

## Stages

The pre-merge sequence the governing design names is checkout → provision → static analysis → test
→ package → supply-chain scan. Every one of those appears below, including the ones that do not run.

| Stage | Status | Reason | Revisit when |
|---|---|---|---|
| Checkout | **runs** | — | — |
| Provision | **runs** | The pinned toolchain, installed per job from `requirements-ci.txt` | — |
| Static verification | **runs** | — | — |
| Test (executing tiers) | **omitted** | Nothing here executes. The deliverables are Markdown and YAML, and the static tier is not the foundation *under* a test suite — it is the whole suite. An executing tier would need a program to run | The repository ships code that runs |
| Branch protection as code | **runs** | — | — |
| Release drafting | **runs** | — | — |
| Release publishing | **runs** | — | — |
| Merge automation | **runs** | — | — |
| Dependency review | **runs**, by record | No dependency manifest for shipped deliverables; the check toolchain is a pipeline input, not a product dependency (`FR-029`) | The repository ships something installable |
| License policy | **omitted**, by record | See "Supply-chain obligations" below | The repository ships something installable |
| Code-security review | **out-of-pipeline practice** | See "Supply-chain obligations" below | — |
| Release propagation | **runs, expected not to complete** | See below | An App identity becomes available |
| Package / build | **omitted** | Nothing is compiled or packaged. The deliverables are Markdown and YAML | The repository ships a build artifact |
| Provenance / attestation | **omitted** | No artifact is produced, so there is nothing to attest. See "Delivery guarantees that do not apply" | The repository ships a build artifact |
| Documentation delivery | **omitted** | No documentation site exists | A site is added |
| Container publishing | **omitted** | No container is produced | A container becomes a deliverable |

## Supply-chain obligations (`FR-029`)

The governing design names **three** obligations and requires each to have either a position in the
stage sequence, a declared cadence, or a recorded out-of-pipeline practice. Only the first was
recorded until now; the other two were neither run nor declared, which is the exact gap this file
exists to close.

| Obligation | How it is discharged | Why not a scan |
|---|---|---|
| Dependency vulnerabilities | Stage position — `dependency-review.yml` runs on every pull request | It runs, but has nothing to find: no manifest declares a shipped dependency |
| License policy | **By record, here** | Nothing is distributed as a package, so no license compatibility question arises. The only third-party inputs are CI tools, which are never redistributed |
| Code-security review | **Out-of-pipeline practice** | The owning design frames it as an operator-invoked pass over the whole codebase and declares neither a stage nor a cadence. The governing pipeline spec explicitly says a stage must not be demanded where the owning spec declares none |

**The distinction that matters**: "runs and finds nothing" and "never looked" produce the same empty
output. Dependency review is the first; license and code-security are the second, and saying so is
the point.

**Revisit when**: the repository ships something installable. All three answers change at once —
a manifest appears, licenses start propagating to consumers, and the code-security pass acquires
code to review.

## Delivery guarantees that do not apply

The delivery design requires a mapping from every shipped artifact class to a stage that secures it,
plus provenance, immutability, and a rollback path over artifact versions.

**This repository ships no artifact class.** The mapping is therefore empty rather than incomplete,
and the following are not applicable rather than missing:

| Guarantee | Status |
|---|---|
| Artifact-to-securing-stage mapping | Empty — no artifact class exists to map |
| Provenance / signed attestation | Not applicable — nothing is built to attest |
| Immutability of a version reference | Satisfied trivially — the tag is the only version reference, and `FR-021` forbids rewriting it |
| Rollback by selecting an earlier version | Not applicable — nothing is consumed that could be rolled back to |
| Environment promotion | Deliberately absent; the governing design marks it optional |

**An empty mapping is a finding, not an oversight.** The design treats an artifact class with no
securing stage as a defect; it does not treat a project with no artifact classes as one. The
distinction is worth stating because the two look identical in a table.

**Revisit when**: anything here becomes installable, downloadable, or deployable. At that moment the
mapping stops being empty and every row above needs a real answer.

## Guarantees this pipeline does not make

### Transitive pinning

This repository pins every reference it owns to `nolte/gh-plumbing@v1.1.26`. **It cannot pin what
those workflows call internally**, and they call each other with `@develop`:

```yaml
uses: nolte/gh-plumbing/.github/workflows/reusable-pre-commit.yaml@develop
```

Consequently `SC-013` is satisfied for this repository's definitions, and the determinism of
`FR-011`/`SC-003` holds **against a fixed state of the shared repository**, not unconditionally.

Claiming "fully pinned" would be an unsourced assertion of exactly the kind this project forbids.

**Revisit when**: `gh-plumbing` pins its internal references. The fix belongs there, not here —
vendoring the workflows to control the graph would fork mechanics that exist to be shared.

### Release propagation completing

The release event is emitted under the workflow's default token, which by platform design does not
trigger further workflow runs. The propagation that aligns the release-presentation branch therefore
**will not start**.

This is a known platform constraint, not a defect to debug. `FR-024` requires the resulting
incompleteness to be visible, which is what this entry is for.

**Revisit when**: a portfolio App identity is available and configured as `PORTFOLIO_APP_ID`.

### The publish does not read CI status

**`SC-010`'s third refusal does not exist.** The spec, and until now a comment in
`.github/workflows/release-publish.yml`, said a publish is refused when required checks on the
integration branch are red. `reusable-release-publish.yml@v1.1.26` does not check this.

Established by enumerating the workflow, not by inference. It emits fifteen `::error::` guards; the
four that can stop a run before publication all sit in the `Resolve draft` step and all concern the
draft:

| Line | Guard |
|---|---|
| 129 | no open draft exists |
| 137 | no open draft carries the requested tag |
| 143 | several drafts carry it — state is corrupt |
| 155 | the draft's target SHA is unreachable from `origin/develop` |

The remaining eleven concern version-bearing files, the HACS asset, and a post-publish sanity check.
Every `gh api`, `gh release`, and `gh run` call in the file was listed as well: none reads
`check-runs`, `commits/{sha}/status`, or any equivalent.

**What still protects a release.** Branch protection requires both contexts before a merge into
`develop`, so red code does not normally reach the branch a draft targets. That guard is real but
weaker in two ways: it is enforced at merge time rather than publish time, and it is bypassable by an
administrator — this repository's own history contains four such bypasses, each reported by the
remote as `Bypassed rule violations for refs/heads/develop`.

Note also that the draft targets `refs/heads/develop`, a moving ref, not a fixed SHA. What gets
published is whatever the branch points at when the publish runs.

**Not verified experimentally.** Doing so requires making a required check red on `develop` on
purpose. The attempt was made and stopped, correctly, as an action that should be agreed rather than
performed unannounced. The code evidence above is complete on its own: a guard that is absent from
the file cannot fire.

**Revisit when**: `gh-plumbing` adds a status check to the publish, or this repository stops relying
on merge-time protection alone. The fix belongs upstream — a consumer cannot add a guard to a
workflow it only calls.

### Branch-prefix conformance

The five prefixes the governing branching model requires — `feat/`, `fix/`, `docs/`, `chore/`,
`exp/` — are **declared** in `CLAUDE.md` and satisfy `FR-017`, which asks for a declaration.

**Nothing enforces them.** No hook checks a branch name and no required context inspects one, so a
branch named anything at all can open a pull request. `.github/settings.yml` has no field for this,
and a pre-commit hook would guard only the machine that happens to run it.

Recorded because a declared convention with no enforcement reads, from the outside, exactly like an
enforced one. `FR-017` is met; the stronger property nobody promised is not.

**Revisit when**: a shared pull-request linter enters `gh-plumbing`. The rule belongs there — every
consumer needs the same check, and `FR-028` forbids solving it locally.

### External link reachability

The internal link class checks relative paths and intra-document anchors. **External URLs are not
checked.** Their reachability depends on the network, and a gate whose verdict changes with someone
else's outage is not deterministic (`FR-011`).

**Revisit when**: link rot becomes an observed problem rather than a hypothetical one, and can be
checked out-of-band rather than in the gate.

### The review's findings

The gate runs `goose run --explain`, which exercises the host's real parser at no LLM cost. It does
**not** run the full reviews of feature `001`: each consumes a subscription and takes minutes
(`FR-031`).

The gate therefore proves the review recipe still *parses*. It does not prove the review's *findings*
are still correct.

Two further practices sit outside the gate for the same reason, and are named here rather than left
to be inferred from the one above (`FR-031`):

| Practice | Why it cannot be a stage | Who runs it |
|---|---|---|
| Golden-file reconciliation against `tests/goose-implementation-review/expected/` | Needs a full review run to produce a report to reconcile | An operator, before changing the process |
| The self-review that Principle V makes a release condition — the process reviewing its own directory, which must produce no findings | Needs a model. A workflow cannot decide it | An operator, before a release |

**The self-review is a release condition that nothing enforces.** No gate can check it, and the
publish workflow does not read it. It holds because an operator runs it, which is a weaker guarantee
than a check and is recorded as such.

**Revisit when**: a provider makes full runs cheap enough to gate on. All three change status at the
same moment.

### Version-bearing files

The repository declares that it has **none** (`FR-025`). No file in the working tree states a release
version, nothing needs bumping, and no file may be treated as authoritative for one. The tag is the
version.

## Portability: measured in a second repository (2026-08-01)

`SC-014` asks that the artifacts work in another repository after changing only declared inputs.
Tested by doing it: a fresh `git init`, a different layout (`docs/`, `config/`, no `process/` tree,
no Goose recipe), and the artifact set copied in unedited.

| Class | Verdict in the foreign repository |
|---|---|
| Format (3 hooks) | pass |
| YAML parse + lint | pass |
| Markdown lint | pass |
| Internal links | pass |
| Prose | pass |
| Recipe schema | **skipped** — no files matched |
| Recipe parse | **skipped** — no files matched |

**No artifact body was edited.** `SC-014` holds.

**The two recipe classes hard-code a path and it does not matter.** Their `entry:` names
`process/goose-implementation-review/recipe.yaml` directly. In a repository without that file the
`files:` pattern matches nothing and the hook *skips* rather than failing — the path degrades into a
no-op instead of an error. Worth recording because reading the config suggests otherwise: a
hard-coded path looks like a portability defect and measurement showed it is not.

### The one thing that does break

Copying `.vale.ini` without `.vale/config/vocabularies/project/accept.txt` fails with:

```text
E100 [vocab] Runtime error
'project' vocabulary not found; searched: …/.vale/config/vocabularies/project
```

That file is **part of the artifact set**, not incidental repository content — it is the one thing
under `.vale/` that `.gitignore` deliberately keeps tracked while everything else there is synced
from the pinned package. An adopter who copies the config but not the vocabulary gets a runtime error
naming a path rather than a missing file, which is a poor signal for a simple omission.

**Revisit when**: someone adopts these artifacts. The mitigation is documentation, not code — the
error is Vale's and a wrapper that pre-checks the directory would duplicate what the error already
says, less accurately.

## Pre-sync baseline (`FR-014`)

Recorded **before** `.github/settings.yml` was applied, so the settings mechanism's effect is
measurable rather than assumed (quickstart Scenario 4b).

| Setting | Value on 2026-07-31, before first sync | Expected after |
|---|---|---|
| `default_branch` | `main` | `develop` |
| `allow_merge_commit` | `true` | `false` |
| `allow_rebase_merge` | `true` | `false` |
| `allow_squash_merge` | `true` | `true` |
| `delete_branch_on_merge` | `false` | `true` |
| `main` branch protection (classic) | absent | present |
| `main` protection (**ruleset**) | **already active** — see correction below | unchanged |
| `develop` branch | **does not exist** | exists, protected, required checks declared |

### Correction to this baseline (2026-07-31)

The row "`main` branch protection: absent" was **measured wrongly**. It came from
`GET /repos/…/branches/main/protection`, which returns 404 here — but that endpoint reports only
*classic* branch protection. This repository uses a **repository ruleset**, a separate mechanism the
protection endpoint does not see:

| | |
|---|---|
| Ruleset | `default-branch-protection`, enforcement `active` |
| Applies to | `refs/heads/main` |
| Rules | `pull_request`, `deletion`, `non_fast_forward`, `required_linear_history` |

**`SC-008` is therefore already satisfied, and was verified by accident**: an attempt to push six
commits directly to `main` was rejected with "push declined due to repository rule violations". That
is the acceptance criterion demonstrated on live infrastructure rather than by inspection.

**Consequence for the settings work**: `.github/settings.yml` configures *classic* protection, which
coexists with the ruleset rather than replacing it. Both are evaluated and the stricter wins. The
settings file must therefore not be written on the assumption that it is the only thing guarding
`main` — and a future check for "is `main` protected?" must query **both** mechanisms, or it will
report a repository as unprotected while a ruleset is actively rejecting pushes.

**If these values do not change after the file lands, the Settings App is not acting on this
repository** — whatever its installation page shows. The App is demonstrably working in this account
(`gh-plumbing/develop` is protected with a required context), so a failure here would mean the
installation does not cover this repository.

**A caveat worth knowing**: the App reacts to pushes touching *this repository's* settings file. An
upstream change to the portfolio commons propagates to nobody until each consumer touches its own
copy — tracked upstream as `gh-plumbing#331`.

## Gate status at introduction (2026-07-31)

All seven check classes are implemented and **every one has been demonstrated to fail** on a
deliberately introduced defect (`FR-010`, `SC-002`). That is the property that distinguishes a gate
from decoration, and it is verified rather than assumed.

Four classes pass against the existing corpus. Three report findings in material written before the
gate existed:

| Class | Verdict on the corpus | Nature of the findings |
|---|---|---|
| Format | **pass** | — |
| Recipe schema | **pass** | — |
| Recipe parse | **pass** | — |
| Internal links | **pass** | 13 links checked |
| YAML lint | 2 findings | Long lines in generated fixtures |
| Markdown lint | ~214 findings | Line length, bare URLs, inline HTML |
| Prose lint | 43 findings | Vocabulary gaps, not misspellings |

**These are not defects the gate caught; they are the cost of introducing a gate to an existing
corpus.** The distinction matters, because the remedy differs.

**Why the corpus was not simply reformatted.** Part of it lives in published, immutable baseline
revisions. Editing those to satisfy a linter would break the guarantee that a report citing a
revision finds it unchanged — the same rule that forced a revert earlier in this project's history.
Configuration was tuned to the corpus's actual conventions instead, and the residue is recorded here
rather than hidden by loosening rules until nothing reports.

**Consequence for `FR-015`.** The three classes above must **not** be declared as required status
contexts until their findings are resolved. A required check that fails on every pull request from
day one teaches contributors to ignore checks, which costs more than the rule saves.

**Revisit when**: the corpus findings are worked down. The four passing classes can be declared
required immediately; the other three follow.

## Bootstrap: the settings file cannot enable itself (2026-07-31)

The Probot Settings App reacts to pushes on the repository's **default branch**. That branch is
currently `main`, while `.github/settings.yml` lands on `develop` — and the setting the file most
needs to apply is `default_branch: develop`, inherited from the commons.

**The file therefore cannot bring itself into effect.** Nothing is wrong with it; the sequence is
simply circular:

| Step | Blocked by |
|---|---|
| Sync `settings.yml` from `develop` | App watches `main` |
| Make `develop` the default | That is what the sync would do |
| Push `settings.yml` to `main` directly | Ruleset rejects direct pushes |

Three ways out, in descending order of preference:

1. **Switch the default branch to `develop` once, by hand.** A single bootstrap action; every
   subsequent change flows through the file. This is the intended end state anyway.
2. **Merge `develop` into `main` through a pull request.** The ruleset permits this. It also
   contradicts the target model, in which `main` is written only by release propagation.
3. **Wait for the first release to propagate to `main`.** Correct in the long run, but propagation
   is itself blocked (see above), so this does not resolve today.

**Recorded rather than worked around**, because the circularity is a property of the mechanism and
will recur in any repository adopting these settings from a non-default branch. The first option is
a deliberate operator action, not something this feature should perform silently.

**Revisit when**: the default branch is `develop`. At that point the pre-sync baseline above becomes
measurable exactly as quickstart Scenario 4b describes.

## Scenario 4b: measured and passed (2026-07-31)

The default branch was switched to `develop` by hand, breaking the bootstrap circularity recorded
above. Touching `.github/settings.yml` then triggered the sync, which completed within ten seconds.

| Setting | Before | Expected | Measured | |
|---|---|---|---|---|
| `default_branch` | `main` | `develop` | `develop` | ✓ |
| `allow_merge_commit` | `true` | `false` | `false` | ✓ |
| `allow_rebase_merge` | `true` | `false` | `false` | ✓ |
| `allow_squash_merge` | `true` | `true` | `true` | ✓ |
| `delete_branch_on_merge` | `false` | `true` | `true` | ✓ |

26 labels also arrived from the commons. **The Settings App demonstrably acts on this repository** —
established by effect, not by reading an installation page. That distinction was the whole point of
writing the scenario this way.

### A protection block of no-ops is not applied

The first sync did everything above **and left `develop` unprotected**. Both mechanisms agreed:
classic protection returned 404, and the only ruleset covers `refs/heads/main`.

The cause was the block itself. `contexts: []` together with `required_approving_review_count: 0`
amounts to requiring nothing, and GitHub does not create a protection consisting entirely of no-ops.

The empty `contexts` list was correct and **stays**: a required context that no workflow produces
blocks every pull request forever. What was added are rules that bite without inventing a phantom
check — `required_linear_history`, `allow_force_pushes: false`, `allow_deletions: false`. Measured
after the second sync: all three active.

**The trap generalises.** A settings file can report success, apply most of itself, and silently skip
a branch entry that reduces to nothing. Verifying "the sync ran" is not the same as verifying "the
protection exists" — only the second question was worth asking, and asking the first would have
produced a confident, wrong answer.

Review and status-check requirements follow in `T027`, once the workflow that emits those checks
exists.

### Protection state after both syncs

| Branch | Mechanism | Rules |
|---|---|---|
| `main` | Repository ruleset `default-branch-protection` | `pull_request`, `deletion`, `non_fast_forward`, `required_linear_history` |
| `develop` | Classic protection, from `.github/settings.yml` | `required_linear_history`, no force pushes, no deletions |

Two branches, two different mechanisms, deliberately. A check for "is this branch protected?" must
query both, or it will report `main` as unprotected while a ruleset actively rejects pushes to it.

## Gate in CI: status after the first four runs (2026-07-31)

The gate now runs on every push and pull request to `develop`, in two jobs.

| Class | CI verdict | Note |
|---|---|---|
| Format (3 hooks) | **pass** | |
| YAML parse + lint | **pass** | |
| Recipe schema | **pass** | |
| Internal links | **pass** | |
| **Recipe parse** | **pass** | goose installs on the runner and validates against the host's own parser |
| Markdown lint | fail | The documented corpus backlog: 172 line-length, 12 inline HTML, 10 bare URLs |
| Prose lint | fail | Environment defect, see below |

**Five of seven classes pass in CI.** The recipe parse class passing matters most: it proves the
host's real parser runs on a runner at no LLM cost, which is the strongest check in the set.

### Four runs, three defects, all mine

Each failure was in the pipeline rather than in the code it checks, and each was found by running it:

1. **`errata-ai/vale-action` cannot be used to place a binary.** It lints as its primary function and
   exited 2 before the style package was synced; `fail_on_error: false` did not prevent it. Vale is
   now installed by downloading the pinned release.
2. **A pre-commit hook with no `stages:` key runs in every stage.** `--hook-stage manual` therefore
   re-ran the six classes the shared job already covered and failed the tooled job for their
   findings. The two tool-dependent hooks are now named explicitly.
3. **Linting immutable revisions.** The shared job failed on `MD034` inside
   `baselines/goose/2026-07-31/`, a published revision that must not be edited. `baselines/goose/` is
   now excluded for the same reason `.specify/` and `.claude/` are: what must not be changed must not
   be linted.

### Resolved: the vale vocabulary path

**Cause: committed sync artefacts, not a path bug.** An earlier sync had been committed before
`.gitignore` covered it. Those copies sat under `.vale/.vale-config/styles/`, a path the current
config does not search, while `.vale-config/0-nolte-styles.ini` re-declared `StylesPath` relatively.
Vale searched the right place, found nothing, and a stale copy sat nearby doing nothing.

Only this project's own vocabulary is tracked now. A clean-checkout simulation confirmed sync
populates the path the config searches.

Twelve terms were then flagged, and each was read before acceptance —
`automations`, `headlessly`, `parsable`, `unconstructible` and similar. **None was a misspelling.**

`Vale.Terms` is disabled for the same structural reason as several markdown rules: it enforces
vocabulary casing and flags `# Ruleset — Revision 2026-07-31`, a heading inside a published,
immutable revision. Spelling is enforced; casing is not.

### Superseded: the original vocabulary-path entry

`vale sync` writes the package to `<StylesPath>/.vale-config/styles`, while `Vocab = technical`
searches `<StylesPath>/config/vocabularies`. The two disagree, so the vocabulary is never found in a
clean checkout.

**It passes locally only because an earlier sync left the directory behind**, and that directory is
gitignored — so the local pass proves nothing about a fresh environment. This is precisely the class
of defect a cold CI run exists to expose, and it stayed hidden until the sync output stopped being
discarded.

**Revisit**: set `Vocab` to the path the package actually populates, or point `StylesPath` at it.
Requires one more measurement against a clean checkout, not a guess.

### Both contexts are now required

`shared / Static CI Tests` and `Tooled Checks` are declared as required status contexts on `develop`
and confirmed applied. **Both were verified green in CI before being required** — a context that no
workflow produces blocks every pull request forever, and one that always fails teaches contributors
to ignore checks.

**All ten hooks pass, in both stages, locally and in CI.**

## Release chain: built, partly verified (2026-07-31)

Five workflows are in place, each a thin wrapper around a pinned shared workflow.

| Piece | Status |
|---|---|
| Release drafter | **verified** — ran on push to `develop` and produced draft `v0.1.0` |
| Draft notes | Empty ("No changes"), correctly: nothing has been merged via pull request yet |
| Publish, refusal on unknown tag | **verified** — dispatch for `v99.99.99` failed as required |
| Publish, dry run on a valid draft | **fails, cause not yet established** |
| Propagation | Expected not to start under the default token; escape hatch present |

### The unresolved publish failure

A dry run against the real draft `v0.1.0` fails with **zero jobs started**, so no log exists to read.
The release correctly remains a draft, so nothing was published in error.

Ruled out by measurement:

- All six `reusable-*` workflows exist at the pinned tag `v1.1.26`.
- The secrets contract matches: `token` required, `app-private-key` optional.
- `auto-align` **is** a valid input — see the correction below.

**A wrong diagnosis is recorded here on purpose.** I concluded `auto-align` was not an input because
a `grep` over the workflow returned nothing, removed it, and pushed the "fix". Reading the contract
properly — parsing the YAML instead of grepping it — shows the inputs are
`tag, dry_run, app-id, asset-filename, auto-align`. The empty output was a failure of my command,
not evidence of absence, and I treated it as evidence. The input has been restored.

**Superseded (2026-08-01)**: the guess in this paragraph was also wrong. It named the caller's syntax
or a permissions condition as the remaining candidates; the cause was a duplicated concurrency group.
The first half of the sentence was right and load-bearing — the failure *is* at workflow level rather
than inside a job — which is exactly why a concurrency deadlock fits and a permissions error does
not. See "The publish dry run: resolved".

## Correction: the portfolio App identity does exist (2026-07-31)

Two entries above rest on a premise that is **wrong**. The spec's Assumptions state "No portfolio App
identity is available initially", and this file repeated it as the reason release propagation cannot
cascade.

Measured instead:

| | |
|---|---|
| `PORTFOLIO_APP_ID` | present, as a repository variable |
| `PORTFOLIO_APP_PRIVATE_KEY` | present, as a repository secret |

I discovered this while testing the opposite hypothesis — that the publish workflow failed *because*
the secret was missing. It was not, and the credentials had been there the whole time. The
assumption was inherited from the spec and never checked, which is the failure this project's
evidence rules exist to prevent.

**What follows**: the propagation entry needs re-testing rather than rewriting from another
assumption. With an App identity available, the `release: published` cascade may well fire, and the
"expected not to complete" note may be obsolete. That is a measurement to take, not a conclusion to
draw here.

## The publish dry run: resolved (2026-08-01)

**Cause: this caller declared the same concurrency group as the workflow it calls.**

`reusable-release-publish.yml` sets `concurrency: group: release-publish` itself. Concurrency groups
are scoped to the repository, not to a single workflow, so a caller that declares the same group
holds it while the job it spawns queues for it. The run cannot make progress and is terminated before
any job exists.

That explains every symptom exactly: zero jobs, no annotation, no log, and a `failure` conclusion
reached in seconds. The fix is one deletion — `.github/workflows/release-publish.yml` no longer
declares concurrency, and carries a comment saying why it must not.

`FR-027` (a publish is never cancelled in flight) still holds. It is satisfied by the called
workflow, which sets `cancel-in-progress: false`, not by the caller.

**Verified after the fix**: dispatch of `v0.1.0` with `dry_run: true` completed `success` with one
job. The log shows `Draft 'v0.1.0' resolved at 786af6c (reachable from origin/develop)`, and the
release remained `isDraft: true`.

**How it was found.** Not by reasoning about my own file — six measurements against it had already
come back clean. By diffing against `claude-home-assistant`, the portfolio repository whose last
publish run succeeded. Its caller has no concurrency block. The general lesson is in the table below:
every one of my hypotheses was about something being *absent* (a missing secret, a missing input, a
missing workflow), while the defect was something *present* that should not have been. A comparison
against a working instance finds that class of defect; inspecting the broken one does not.

### What was ruled out first

Four dispatches, all failing with **zero jobs started and no annotation**. The release correctly
stays a draft each time, so nothing has been published in error.

Ruled out by measurement:

| Hypothesis | Result |
|---|---|
| The reusable workflow is missing at the pinned tag | All six exist at `v1.1.26` |
| The input signature differs between `v1.1.26` and `develop` | Identical: `tag, dry_run, app-id, asset-filename, auto-align` |
| `auto-align` is not a valid input | It **is** valid — I removed it wrongly and restored it |
| Cross-repository calls are blocked | `reusable-pre-commit` succeeds cross-repository in the same run set |
| The App secret is missing | It exists |
| The caller differs structurally from the working original | Identical apart from the ref |

Every entry above is a correct measurement and a useless one: each confirmed that a thing which
*could* have been missing was in fact present. Three of the hypotheses were wrong outright, and two
of them led me to change working files, which had to be reverted. The cost of that approach is
recorded here so the next comparable failure starts with a diff against something that works.
