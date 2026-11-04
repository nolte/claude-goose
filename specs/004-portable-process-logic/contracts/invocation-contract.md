# Contract: Invocation Contract

**Feature**: `004-portable-process-logic` | **Date**: 2026-08-02

Specifies the artifact that ships as `process/goose-implementation-review/invocation-contract.md`.
This is the reuse boundary: everything run-specific enters through here, and it is expressed without
naming any host.

## Why this artifact exists

A contract with the same content already exists at
`specs/001-goose-implementation-review/contracts/recipe-interface.md`. It is complete and correct,
and consumers cannot read it — the spec tree does not travel, which is what
`tests/goose-implementation-review/PORTABILITY.md` check 3 enforces. This contract is that one,
restated on the consumer's side of the boundary and stripped of host-specific framing.

The spec-tree contract stays where it is as the record of feature `001`. The shipped one becomes
authoritative for what a run takes.

## Inputs

| Name | Required | Default | Meaning |
|---|---|---|---|
| `subject_path` | yes | *none permitted* | The implementation to review; a file or a directory |
| `baseline_revision` | no | `latest` | Which baseline revision to apply. `latest` resolves to the lexicographically greatest revision present |
| `output_path` | no | `./review-report.md` | Where the report is written |
| `compare_to` | no | `""` | A prior report, to classify findings as new, resolved or unchanged. Empty means no comparison |
| `max_bytes_per_pass` | no | `0` | Byte budget for one pass. `0` means unlimited |

**`subject_path` has no default and must not acquire one.** The reason is stated host-neutrally: a
default would name material the caller did not choose, and on at least one host a path-shaped input
is read and inlined rather than passed, so a default silently imports whatever it points at. The rule
survives even on a host where that mechanism does not exist, because the first reason stands alone.

## Obligations on a host binding

A binding is conformant when all of the following hold. Each is checkable.

1. **Declares every input** in the table above, with the same name, the same requiredness and the
   same default.
2. **Adds no input** of its own. A host that needs extra material declares it as a host-specific note,
   not as a contract input.
3. **Carries the invocation constraints.** Every rule in `constraints.md` marked
   `carried_at_invocation: yes` appears in the binding, verbatim, at the point where the host begins
   work — not in a field the host treats as background. See `constraints.md` for why this is stated
   as an obligation rather than left to the host.
4. **States no rule of its own.** A binding may not introduce, restate in its own words, or narrow
   any rule of the process.
5. **Is generated, not authored.** The binding is a function of the host-neutral sources and its own
   template. Re-rendering reproduces it byte for byte.
6. **Names its host.** The binding declares the identifier the report records in its `Host` field.
7. **Records its own limitations.** Where the host cannot express part of this contract, the binding
   says so, under a heading marking it host-specific. It does not resolve the gap by changing a
   host-neutral artifact.

## Outputs

| Output | Form | Notes |
|---|---|---|
| Review report | Markdown at `output_path` | Conforms to the report contract; carries `Host` |
| Exit condition | Success / failure | Failure means the review could not be performed, **not** that findings were found |

A review that produces findings is a successful run. Conflating "found problems" with "failed to run"
would make the process unusable in any automated gate.

## What this contract does not fix

- **How a host names its inputs syntactically.** A host may call them parameters, arguments,
  variables or placeholders. Only the names, requiredness, defaults and meanings are fixed.
- **How a host substitutes them.** Templating, environment, or an operator typing them by hand are
  all conformant.
- **Whether a host needs a separate field for background versus task material.** That is a host
  property, handled by obligation 3 and recorded per binding.
