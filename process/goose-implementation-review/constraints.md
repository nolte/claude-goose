# Constraints

The must-not-violate rules of this review process. Each has a stable id, and each is stated **here
and nowhere else** — a rule that also appears in a stage description or in a host binding is a rule
that can drift out of agreement with itself.

`process.md` describes the stages and refers to these ids. Host bindings carry them at the point of
invocation and are generated, never authored.

## Notation

A constraint refers to a run's inputs by their contract names, wrapped as `{{ input_name }}`. That is
**contract notation, not any host's templating syntax**. A binding is responsible for turning it into
whatever substitution its host performs — templating, environment expansion, or an operator typing
the value. `invocation-contract.md` states this as a binding obligation.

Inputs are named in `invocation-contract.md`. Nothing here declares one.

## A note on the word "host"

Two different things could be called a host, and conflating them would defeat the purpose of this
file:

- The **execution host** — the agent runtime that carries out a review. Nothing in this file, or in
  any other host-neutral artifact, may name one.
- The **subject domain** — the kind of implementation being reviewed. This process reviews Goose
  recipes and extension configurations, and saying so is a statement about *what is examined*, not
  about *what does the examining*.

## Why a binding carries these at the point of invocation

A constraint that is present but not at the point where the host begins work has been observed to be
ignored. On one execution host, a pinned-revision constraint stated only in a background field was
overridden on two consecutive runs: the value arrived correctly, the field rendered verbatim, and
stronger wording changed nothing. Naming the same constraint at the point of invocation fixed it on
the first attempt.

That measurement is why a binding cannot be a bare pointer to this file. It is also why the binding
contributes nothing of its own: what it carries is spliced from here mechanically, and a gate
re-renders and compares.

Every constraint below is marked `carried_at_invocation=yes`. Each of them can change a review's
outcome, and the failure above showed that presence alone is not enough. The flag exists so a future
constraint that governs only how the process is maintained — rather than what a run concludes — can
be recorded here without being pushed into every invocation.

## Status

A constraint is `active` or `superseded`. A superseded one keeps its id, is marked, and is never
deleted or renumbered; ids are not reused. That is what lets a reader of an older report reconstruct
which rules were in force.

---

## C-1 — Use exactly the pinned baseline revision

<!-- BEGIN CONSTRAINT: C-1 carried_at_invocation=yes status=active -->
USE EXACTLY THE BASELINE REVISION `{{ baseline_revision }}`. Read its criteria from that revision and
no other. If a newer revision exists on disk, that is REPORTED as a BASELINE-DRIFT finding and
otherwise IGNORED — never silently applied, never treated as an improvement, and never merged with
the pinned one. Applying a different revision than the one requested makes the report unreproducible
and every comparison against it meaningless. The only exception is the literal value `latest`, which
resolves to the lexicographically greatest revision; the resolved id, never the word `latest`, goes
in the report.
<!-- END CONSTRAINT: C-1 -->

## C-2 — Never modify the subject

<!-- BEGIN CONSTRAINT: C-2 carried_at_invocation=yes status=active -->
NEVER modify anything under `{{ subject_path }}`. Checksum every file before subject discovery and
verify after the findings are complete. Any difference fails the run and the report is discarded,
however correct the findings are.
<!-- END CONSTRAINT: C-2 -->

## C-3 — Never execute the subject

<!-- BEGIN CONSTRAINT: C-3 carried_at_invocation=yes status=active -->
NEVER execute the subject. Findings come from reading the material.
<!-- END CONSTRAINT: C-3 -->

## C-4 — Never invent a criterion

<!-- BEGIN CONSTRAINT: C-4 carried_at_invocation=yes status=active -->
NEVER invent a criterion. Only criteria present in the pinned baseline revision's ruleset may produce
findings. An expectation that seems obviously right but is not in the ruleset is not a finding — at
most it is a proposed criterion for the baseline.
<!-- END CONSTRAINT: C-4 -->

## C-5 — Never write a finding without criterion, location and source

<!-- BEGIN CONSTRAINT: C-5 carried_at_invocation=yes status=active -->
NEVER write a finding without a criterion id, a location, and the source its criterion cites. A
report containing such a finding is invalid and must not be written at all.
<!-- END CONSTRAINT: C-5 -->

## C-6 — Never report a declared baseline gap as passing

<!-- BEGIN CONSTRAINT: C-6 carried_at_invocation=yes status=active -->
NEVER report a declared baseline gap as passing. Gaps become findings with outcome `undecided`.
<!-- END CONSTRAINT: C-6 -->

## C-7 — Never exceed what the evidence class supports

<!-- BEGIN CONSTRAINT: C-7 carried_at_invocation=yes status=active -->
NEVER phrase a finding more strongly than its criterion's evidence class supports. Only
`authoritative` criteria may state that something is wrong.
<!-- END CONSTRAINT: C-7 -->

## C-8 — Spend the coverage budget in a stated order, and never partially review a file

<!-- BEGIN CONSTRAINT: C-8 carried_at_invocation=yes status=active -->
Coverage budget for one pass: `{{ max_bytes_per_pass }}` bytes, where `0` means unlimited and is the
normal operating mode. If non-zero, take in-scope files in ascending path order until the budget is
spent. Every file not taken goes in the coverage statement's not-examined list with the reason
"coverage limit". A single file larger than the whole budget is NEVER partially reviewed — it goes in
the not-examined list with the reason "exceeds per-pass budget". A partial review is fine; a partial
review that reads as complete is not.
<!-- END CONSTRAINT: C-8 -->

## C-9 — Compare against a prior report only when one was requested

<!-- BEGIN CONSTRAINT: C-9 carried_at_invocation=yes status=active -->
Prior report to compare against: `{{ compare_to }}`. If that value is non-empty, perform the delta
stage: read that report's digest block and classify every finding as new, resolved or unchanged, with
a cause of subject or baseline. If it is empty, SKIP the delta stage entirely and emit no delta
fields — an absent comparison and an empty comparison are different claims.
<!-- END CONSTRAINT: C-9 -->

---

## Where each constraint is verified

A constraint that nothing checks is a wish. Each is enforced by a stage in `process.md`:

| Constraint | Verified by |
|---|---|
| `C-1` | Baseline currency — the revision id in the digest must equal the requested revision |
| `C-2` | Read-only verification — re-checksum the subject and fail the run on any difference |
| `C-3` | Read-only verification, same mechanism; a probe never touches the subject tree |
| `C-4` | Criterion evaluation — every finding's identity resolves to the pinned ruleset |
| `C-5` | Report rendering — publication is blocked, not merely warned about |
| `C-6` | Undecided and gap handling — no criterion passes whose topic is a declared gap |
| `C-7` | Criterion evaluation — the wording constraint on each finding |
| `C-8` | Subject discovery — the three coverage classifications account for every file |
| `C-9` | Delta — the stage is skipped entirely when no prior report was named |
