# Contract: Report Host Field

**Feature**: `004-portable-process-logic` | **Date**: 2026-08-02

The only change this feature makes to the report format. It is small, and the reasoning about where
*not* to put it is the substance.

## The change

`report-template.md` gains one header field:

```markdown
**Subject**: <location> (<revision, if any>)
**Process version**: <semver from VERSION.md>
**Baseline**: <revision_id> for Goose <goose_version>
**Host**: <host identifier from the binding that ran>
**Run date**: <YYYY-MM-DD>
**Compared to**: <prior report, or "none">
```

`Host` is mandatory in every report (`FR-007`). A report that cannot say what produced it makes an
unattributable claim, and it travels alone once written.

## The host stays out of `DIGEST v1`

```text
DIGEST v1
baseline=<revision_id> process=<semver> subject=<sha256 of subject manifest>
<criterion_id>|<location>|<outcome>|<severity>
```

**The host is deliberately absent from the digest.** `report-template.md` states the digest is the
only part required to be byte-identical across runs over unchanged inputs, and Stage 6 of `process.md`
treats a delta over an identical `baseline=` and `subject=` as a reproducibility failure rather than a
change. A host field inside the digest would make every cross-host comparison self-report as a
reproducibility failure — breaking precisely the comparison this feature exists to enable
(`FR-008`, research `R5`).

## One digest field does change, and it is not the host

The digest's first line carries `process=<semver>`. The bump to `2.0.0` therefore rewrites that field
in every report this process produces from now on, and in the golden files it is reconciled against.
`VERSION.md` defines MAJOR as the bump that "invalidates existing golden files"; this is what that
means in practice.

An earlier draft of this contract stated that the digest lines were unchanged. That is refuted by the
files themselves — `tests/goose-implementation-review/expected/recipe-clean.md:11` and
`recipe-with-deviations.md:11` both read `process=0.2.0` inside the digest block. The claim is
corrected rather than the field moved: `process=` belongs in the digest, because a finding set is only
comparable against another produced by the same method.

What `FR-008` requires is unaffected. `process=` is a property of the process, not of the executing
host: two hosts running the same process version write the same value. The digest still does not vary
with the host.

**Consequence for reconciliation**: the golden files are re-pinned to the new process version once, as
part of this release. Every other digest field — `baseline=`, `subject=`, and each finding line — must
remain byte-identical, and that is what the comparison checks.

## Consequences

| Artifact | Effect |
|---|---|
| Golden files in `tests/goose-implementation-review/expected/` | Headers gain `Host`; the digest's `process=` field is re-pinned to `2.0.0`. Every other digest field is unchanged, so reconciliation — which `O-11` records as digest-only — still holds |
| Stage 6 delta comparison | Unchanged. It reads `baseline=`, `subject=` and finding lines, none of which move |
| `VERSION.md` | The header change alone would be MINOR. The bump to `2.0.0` is driven by the binding path move, not by this field |

## Cross-host comparison

Two reports over the same subject and baseline from different hosts are compared on digest content
(`FR-017`). The `Host` header is what makes a difference attributable. Differences are recorded with a
cause; they do not block release. Assuming two reasoning agents agree would be a claim without
evidence, and `O-11` records that stabilising the digest across runs on a *single* host took four
rounds of specification.
