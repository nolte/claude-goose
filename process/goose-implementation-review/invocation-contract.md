# Invocation Contract

The named inputs of a review run, and the obligations a host binding must satisfy to be considered
conformant. This is the reuse boundary: everything run-specific enters through here, and it is
expressed without naming any execution host.

A reader should be able to name every input, its requiredness and its default from this file alone,
without opening a binding.

## Inputs

| Name | Required | Default | Meaning |
|---|---|---|---|
| `subject_path` | yes | *none permitted* | The implementation to review; a file or a directory |
| `baseline_revision` | no | `latest` | Which baseline revision to apply. `latest` resolves to the lexicographically greatest revision present |
| `output_path` | no | `./review-report.md` | Where the report is written |
| `compare_to` | no | `""` | A prior report, to classify findings as new, resolved or unchanged. Empty means no comparison |
| `max_bytes_per_pass` | no | `0` | Byte budget for one pass. `0` means unlimited |

Five inputs, and no others. A host that needs further material declares it as a host-specific note in
its own binding.

### `subject_path` has no default and must not acquire one

Two independent reasons, either of which stands alone:

1. A default would name material the caller did not choose. A review of the wrong subject that
   reports success is worse than a run that refuses to start.
2. On at least one execution host, a path-shaped input is *read and inlined* rather than passed
   through as a path. A default there silently imports whatever it points at, which is a security
   defect and not merely a surprise.

The second reason is a property of one host. The first is not, which is why the rule survives on
hosts where the second does not apply.

### Notation for inputs inside constraints

`constraints.md` refers to these inputs as `{{ input_name }}`. That is the notation of this contract,
not the templating syntax of any host — it is a placeholder a binding is required to resolve, by
whatever means its host offers.

## Obligations on a host binding

A binding is conformant when all of the following hold. Each is checkable.

1. **Declares every input** in the table above, with the same name, the same requiredness and the
   same default. No renaming, no tightening a default, no making an optional input required.

2. **Adds no input of its own.** A host that needs extra material records it as a host-specific note,
   not as a contract input. Otherwise two bindings of the same process stop being interchangeable.

3. **Carries the invocation constraints.** Every rule in `constraints.md` marked
   `carried_at_invocation=yes` appears in the binding, verbatim, at the point where the host begins
   work — not in a field the host treats as background. `constraints.md` records the measurement
   behind this: a constraint present only as background material was overridden twice on one host,
   and honoured on the first attempt once it appeared at the point of invocation.

4. **Resolves the contract's placeholders.** Every `{{ input_name }}` a carried constraint contains
   is substituted with the run's actual value before the host begins work, by whatever mechanism the
   host provides. A binding that passes the placeholder through unresolved has carried the words of
   the constraint without its content.

5. **States no rule of its own.** A binding may not introduce a rule, restate an existing one in its
   own words, or narrow one. Every normative statement it contains came from `constraints.md`.

6. **Is generated, not authored.** The binding is a function of the host-neutral sources and its own
   template. Re-rendering reproduces it byte for byte, and a check that re-renders and compares is
   what makes obligation 5 mechanical rather than aspirational.

7. **Names its host.** The binding declares the identifier the report records in its `Host` field.

8. **Records its own limitations.** Where the host cannot express part of this contract, the binding
   says so under a heading marking it host-specific. It does not resolve the gap by changing a
   host-neutral artifact — a gap in one host is not a change to the process.

## Outputs

| Output | Form | Notes |
|---|---|---|
| Review report | Markdown at `output_path` | Conforms to `report-template.md`; carries `Host` |
| Exit condition | Success / failure | Failure means the review could not be performed, **not** that findings were found |

**A review that produces findings is a successful run.** Conflating "found problems" with "failed to
run" would make the process unusable in any automated gate.

## Preconditions

1. `subject_path` exists and is readable.
2. The requested `baseline_revision` exists and contains its ruleset, sources, coverage and criterion
   format files.
3. When `compare_to` is set, that report exists and names a baseline revision.

A failed precondition aborts before any report is written. A partial report is never emitted: it
would understate coverage without saying so.

## What this contract does not fix

- **How a host names its inputs syntactically.** Parameters, arguments, flags, variables and
  placeholders are all conformant. Only the names, requiredness, defaults and meanings are fixed.
- **How a host substitutes them.** Templating, environment expansion, or an operator typing them by
  hand all satisfy obligation 4.
- **Whether a host separates background material from task material.** That is a host property.
  Obligation 3 states what must be true regardless, and each binding records how it achieves it.
- **What the host is called, or how it is installed.** A binding answers that for itself.
