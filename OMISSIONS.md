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
