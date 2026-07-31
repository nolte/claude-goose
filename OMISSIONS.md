# Omissions

Every stage the governing pipeline design names, and every guarantee this repository does **not**
provide, with a reason and a condition under which the omission stops being correct (`FR-030`,
`SC-012`).

**Silence is not an answer.** A stage that appears nowhere is indistinguishable from one that was
forgotten, which is why this file lists things that do not happen rather than only things that do.

## Stages

| Stage | Status | Reason | Revisit when |
|---|---|---|---|
| Static verification | **runs** | — | — |
| Branch protection as code | **runs** | — | — |
| Release drafting | **runs** | — | — |
| Release publishing | **runs** | — | — |
| Merge automation | **runs** | — | — |
| Dependency review | **runs**, by record | No dependency manifest for shipped deliverables; the check toolchain is a pipeline input, not a product dependency (`FR-029`) | The repository ships something installable |
| Release propagation | **runs, expected not to complete** | See below | An App identity becomes available |
| Package / build | **omitted** | Nothing is compiled or packaged. The deliverables are Markdown and YAML | The repository ships a build artifact |
| Documentation delivery | **omitted** | No documentation site exists | A site is added |
| Container publishing | **omitted** | No container is produced | A container becomes a deliverable |

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

**Revisit when**: a provider makes full runs cheap enough to gate on.

### Version-bearing files

The repository declares that it has **none** (`FR-025`). No file in the working tree states a release
version, nothing needs bumping, and no file may be treated as authoritative for one. The tag is the
version.

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

**Next step**: the failure is at workflow level rather than inside a job, so the remaining candidates
are the caller's own syntax or a permissions/visibility condition on the reusable call. It needs the
run's raw annotation, which the API did not surface through the endpoints tried here.
