# Contract: Binding Renderer

**Feature**: `004-portable-process-logic` | **Date**: 2026-08-02

Specifies `process/goose-implementation-review/tools/render-bindings.sh` — the tool that makes
"the binding contributes nothing of its own" a mechanical fact rather than a convention.

## Placement and dependencies

Lives **inside** the reusable tree, not in `scripts/`. User Story 3 has a consumer adding a binding in
their own repository, and they will not have this repository's tooling.

**Dependency budget: POSIX `sh` and `awk`. Nothing else.** The reusable tree currently has no runtime
dependency beyond the host itself, and this tool must not be the one that gives it a build step. See
research `R3`.

## Interface

```sh
render-bindings.sh              # render every binding, writing in place
render-bindings.sh --check      # render to a temporary location and compare; write nothing
render-bindings.sh <host>       # render one binding
```

| Exit | Meaning |
|---|---|
| `0` | Every binding matches its sources (`--check`), or was written (default) |
| `1` | Drift, an undeclared template line, or normative voice in a `HOST-SPECIFIC` region. `--check` only |
| `2` | Usage error, missing source, unreadable template, or a template that fails a region check in the default mode |

`--check` **never writes to a binding**. A gate that repairs what it is checking cannot report drift,
and a maintainer would learn nothing from a check that silently fixed their edit.

## Discovery

Everything the renderer needs to know about a host comes from where its template sits. **There is no
registry, and nothing to register.**

| Question | Answer | Derived from |
|---|---|---|
| Which bindings exist? | Every `bindings/*/` directory containing a template | A glob over `bindings/*/*.tmpl` |
| Where does one render to? | The template path with `.tmpl` removed | `recipe.yaml.tmpl` → `recipe.yaml` |
| What is the host called? | The directory name | `bindings/goose/` → `goose` |

The host name derived here is the identifier `<host>` selects on the command line **and** the value
the report carries in its `Host` field. Deriving it once, from the directory, keeps it from being
stated in two places that can disagree.

**Exactly one template per host directory.** A directory holding none, or more than one, is exit `2`
naming the directory and what it found. This is what keeps `SC-004` measurable: adding a host costs
one authored file, and the renderer enforces it rather than trusting it. A host that appears to need
two authored files is a signal to examine — either part of it belongs in the host-neutral definition,
or the invocation is not minimal.

**Why not a manifest.** A list of hosts would have to live somewhere, and every new binding would
edit it. That is the second authored artifact `SC-004` exists to rule out, and it would give the host
identifier a second home that can drift from the directory name.

## Failure output

On drift the tool names the artifact, the source it disagrees with, and the difference:

```text
DRIFT  bindings/goose/recipe.yaml
       differs from constraints.md + invocation-contract.md
       run tools/render-bindings.sh to regenerate
       --- committed
       +++ rendered
       @@ ...
```

Naming the repair command matters. The maintainer's instinct on a red gate is to edit the file the
gate named, which is exactly the wrong move here.

## Sources and markers

| Source | Contributes |
|---|---|
| `constraints.md` | Rules marked `carried_at_invocation: yes`, in id order |
| `invocation-contract.md` | The input table: names, requiredness, defaults, meanings |
| `bindings/<host>/<file>.tmpl` | The host's own shape, plus its host-specific notes |

Templates carry named markers; the renderer replaces the region between a marker pair and leaves
everything else byte-identical:

```text
# BEGIN GENERATED: constraints
# END GENERATED: constraints
```

A template declares two kinds of region, and **every line belongs to exactly one of them**:

```text
# BEGIN GENERATED: constraints        # replaced from a host-neutral source
# END GENERATED: constraints
# BEGIN HOST-SPECIFIC: extensions     # the template's own; never touched by the renderer
# END HOST-SPECIFIC: extensions
```

**Rules for markers**:

1. A `GENERATED` pair's content is fully replaced. Editing inside it is always drift.
2. A `HOST-SPECIFIC` pair's content is the template's own and is never touched.
3. A line inside no declared region fails the run (`FR-018`). This is the rule that makes "the binding
   contributes nothing of its own" mechanical rather than aspirational: an earlier draft left unmarked
   content free-form, which meant a rule written into a template would be reproduced faithfully forever
   while the render check reported green.

   **Both modes reject it, with different exit codes.** Under `--check` it is exit `1` — it is a finding
   about the repository's state, like drift. In the default mode it is exit `2` **before anything is
   written**: rendering a template the tool cannot account for would commit exactly the content the rule
   exists to keep out, and the gate would then pass on it forever. The same applies to normative voice
   in a `HOST-SPECIFIC` region. A renderer that writes first and complains second is not a gate.
4. An unclosed marker, a duplicated marker name, or a marker naming an unknown source is exit `2` —
   not a silent skip. A renderer that quietly ignores a marker it does not understand produces a
   binding that looks generated and is not.

## Normative voice in a host-specific region

The renderer fails when a `HOST-SPECIFIC` region uses the modal verbs the process reserves for its
rules (`FR-019`) — exit `1` under `--check`, exit `2` before writing in the default mode, per marker
rule 3. The check is lexical, case-sensitive on the emphatic forms, and reports the region and the
line:

```text
NORMATIVE VOICE  bindings/goose/recipe.yaml.tmpl:41
                 HOST-SPECIFIC: extensions
                 "the recipe MUST NOT declare inline_python"
                 a rule belongs in constraints.md, not in a template
```

**What this does and does not claim.** It catches a rule written in the voice rules are written in,
which is the observed failure mode. It does not detect a rule phrased as description ("this binding
declares no extensions, because …"), and it cannot detect the same rule restated in different words
inside a host-neutral artifact. Neither limit is worked around; `OMISSIONS.md` records both. A check
that passed for the wrong reason would be reported as evidence, which is worse than an absent one.

A host-specific region states **facts about a host** — what it requires, what it cannot express, what
was measured about it. Those are recorded, not commanded.

## Indentation

The constraints block is spliced into contexts with different indentation — a YAML block scalar in one
binding, a shell heredoc in another. The marker's own indentation sets the block's, applied uniformly
to every line. Blank lines stay empty rather than becoming lines of spaces, because the repository
gate rejects trailing whitespace.

## What the renderer does not do

- **It does not parse YAML.** The Goose binding is spliced as text, so its comments survive verbatim.
  Those comments carry findings from real runs and round-tripping a YAML library would reflow or drop
  them.
- **It does not validate the host's schema.** That is the existing recipe-schema and recipe-parse
  checks, which run against the rendered file.
- **It does not know what a rule means.** It moves marked text. Whether the rules are the right rules
  is a question for the process definition, not the tool.
