# Data Model: Portable Process Logic

**Feature**: `004-portable-process-logic` | **Date**: 2026-08-02

There is no database and no compiled type system here. The "entities" are files and the blocks
inside them, and the relationships are which artifact derives from which. That derivation direction
is the whole feature, so it is stated exactly.

## Target layout

```text
process/goose-implementation-review/
├── README.md                  # orientation; how to run under each host
├── VERSION.md                 # process semver + history (2.0.0)
├── process.md                 # HOST-NEUTRAL — the stages
├── constraints.md             # HOST-NEUTRAL — the must-not-violate constraints  [NEW]
├── invocation-contract.md     # HOST-NEUTRAL — named inputs + binding obligations [NEW]
├── report-template.md         # HOST-NEUTRAL — report shape
├── tools/
│   └── render-bindings.sh     # renders every binding; --check compares          [NEW]
└── bindings/
    ├── goose/
    │   ├── recipe.yaml.tmpl   # AUTHORED — host shape + host-specific notes      [NEW]
    │   └── recipe.yaml        # GENERATED — moved from the tree root
    └── claude-code/
        ├── run.sh.tmpl        # AUTHORED                                         [NEW]
        └── run.sh             # GENERATED                                        [NEW]
```

Everything above `bindings/` is host-neutral. Inside it, a `.tmpl` is authored and everything else is
derived from it — the distinction `SC-004` counts and `FR-018` polices. No arrow points
upward: no host-neutral artifact may reference a binding, a host, or a host's field names.

## Entities

### Process definition

The host-neutral statement of the review. Comprises `process.md`, `constraints.md`,
`invocation-contract.md` and `report-template.md`.

| Attribute | Value |
|---|---|
| Version | Semantic, in `VERSION.md`; `2.0.0` after this feature |
| Identity | The directory name |
| Mutability | Editable, with a version bump and a history entry (`FR-010`) |

**Validation**: contains no host name, no host field name, and no reference to `specs/` (`FR-001`,
`FR-011`). The published-baseline immutability rule does not apply here — see research `R6`.

### Constraint

One normative statement that can change a review's outcome. Lives in `constraints.md`. Not called a
"binding rule": that name reads as a rule belonging to a host binding, which is the one place it may
never live.

| Attribute | Rule |
|---|---|
| `id` | `C-<n>`, stable across revisions; never reused after retirement |
| `text` | Imperative prose. States the rule and what happens when it is violated |
| `carried_at_invocation` | `yes` / `no`. Whether the renderer splices it into every binding |

**Validation**: ids are unique and contiguous at authoring time; every rule marked
`carried_at_invocation: yes` appears in every rendered binding; no rule text appears anywhere outside
`constraints.md` and generated output (`FR-001`, `SC-002`).

**State**: a rule is `active` or `superseded`. A superseded rule keeps its id and is marked, never
deleted (Principle III).

### Invocation contract

The named inputs of a run plus the obligations a binding must satisfy. Lives in
`invocation-contract.md`; specified in `contracts/invocation-contract.md`.

| Input | Required | Default | Meaning |
|---|---|---|---|
| `subject_path` | yes | *none permitted* | The implementation to review |
| `baseline_revision` | no | `latest` | Which baseline revision to apply |
| `output_path` | no | `./review-report.md` | Where the report is written |
| `compare_to` | no | `""` | A prior report, for a delta. Empty means no comparison |
| `max_bytes_per_pass` | no | `0` | Byte budget for one pass; `0` is unlimited |

**Validation**: unchanged from the current contract in names, requiredness, defaults and meaning
(`FR-009`). A change to any cell is a MAJOR bump with migration guidance.

### Host binding

The rendered artifact that lets one host start a run. One per host, committed alongside its template.

| Attribute | Value |
|---|---|
| `host` | Identifier recorded in the report, e.g. `goose`, `claude-code` |
| `generated` | Always. Never hand-edited — an edit here is drift, repaired by re-rendering |
| `source` | `constraints.md` + `invocation-contract.md` + the binding's template |
| `host_notes` | Facts about this host that are not rules of the process, marked as such |

**Validation**: re-rendering reproduces the committed file byte for byte (`FR-006`, `SC-008`). It
declares every contract input with matching requiredness and defaults (`FR-003`). It states no rule
absent from `constraints.md` (`FR-004`).

**Relationship**: many bindings to one process definition. Adding one **authors** exactly one
artifact — the template below — and modifies zero host-neutral artifacts (`SC-004`). The rendered
output is generated rather than authored and is not counted.

### Binding template

The one artifact a person writes when adding a host. Modelled explicitly because `FR-018` and
`FR-019` place rules on it, and because it is the only place in a binding where a hand-written rule
could otherwise survive a green gate.

| Attribute | Value |
|---|---|
| `path` | `bindings/<host>/<file>.tmpl` — exactly one per host directory (`FR-021`) |
| `host` | The directory name. Not declared anywhere else, so it cannot disagree with itself (`FR-020`) |
| `renders_to` | The same path with `.tmpl` removed |
| `regions` | Every line sits in exactly one: a `GENERATED` region or a `HOST-SPECIFIC` one (`FR-018`) |
| `authored` | Yes — this is the artifact `SC-004` counts |

**Validation**: no line falls outside a declared region (`FR-018`). No `HOST-SPECIFIC` region is
written in normative voice; a rule written here is a gate failure naming the region and the line
(`FR-019`). Both checks live in the renderer — see `contracts/binding-render.md` — and both run in the
default mode as well, where they refuse before writing rather than reporting after.

**Why the distinction matters**: the binding is generated and the template is authored, so "never
hand-edited" applies to one and not the other. Collapsing them was the reasoning error that made an
earlier draft claim a hand-written rule could not survive anywhere in a binding.

### Host-specific note

A recorded fact about one host that is not a rule of the process — for instance why the Goose recipe
declares no `extensions`, or that an optional file parameter is unconstructible under the documented
schema rules.

Lives in the binding it describes, under a heading that marks it as host-specific so a reader cannot
mistake it for process logic (`FR-014`, US2 scenario 4). These notes are the current recipe's most
valuable content and are carried across rather than discarded.

### Review report

Unchanged in structure except for one added header field.

| Field | Change |
|---|---|
| `Host` | **New.** The binding that executed the run (`FR-007`) |
| `DIGEST v1` | **Structurally unchanged** — still `v1`, and host identity is deliberately outside it (`FR-008`, research `R5`). Its `process=` field follows the bump to `2.0.0`, which is what MAJOR means here; every other field stays byte-identical |

**Validation**: the digest stays byte-stable across runs over an unchanged subject and baseline on the
same host. Across hosts the digests are compared and every difference is explained, not required to
be absent (`FR-017`).

## Derivation

```text
constraints.md ──────┐
                     ├──▶ tools/render-bindings.sh ──▶ bindings/<host>/<file>
invocation-contract.md ┘                                        │
                                                                ▼
                                                     gate: re-render, compare
```

The gate never edits a binding. It renders into a temporary location, compares, and fails naming the
artifact and the expected content. Repairing drift means running the renderer, not editing the
binding — which is the point.

## State transitions

**Process version** — `2.0.0` on release of this feature. Later: MAJOR on a contract or report-format
break, MINOR on a compatible stage or capability, PATCH on wording (`VERSION.md`).

**Binding** — `absent` → `generated` → `committed` → (`drifted` → `regenerated`). `drifted` is a gate
failure state, never a released one.
