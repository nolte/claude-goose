# Contract: The Static Gate

**Feature**: `003-cicd-release-pipeline` | **Date**: 2026-07-31

Fixes what the gate checks, how it is invoked, and what it may not do. Consumed by every pull
request targeting the integration branch.

## Invocation

**One entry point.** Every check runs through the task runner, in CI and locally, with the same
definitions:

```sh
task ci          # everything the gate runs
task ci:yaml     # a single class, for iteration
```

CI calls `task ci`. It does **not** re-implement checks inline. A check that exists only in a
workflow file cannot be run by a contributor before pushing, which is what `SC-004` forbids.

## The seven classes

| Class | Entry point | Fails when |
|---|---|---|
| YAML parse | `task ci:yaml` | Any `*.yml`/`*.yaml` does not parse |
| Markdown lint | `task ci:markdown` | A declared style rule is violated |
| Recipe schema | `task ci:recipe-schema` | The review recipe violates its schema |
| Link check | `task ci:links` | An internal relative link or anchor has no target |
| Prose lint | `task ci:prose` | A Vale rule is violated |
| Recipe parse | `task ci:recipe-parse` | `goose run --recipe … --explain` rejects the recipe |
| Format | `task ci:format` | Trailing whitespace, missing final newline, mixed line endings |

**Each is reported as a separately named unit** (`FR-007`). A single aggregate "checks failed" tells
a contributor nothing about where to look.

## Rules

1. **No check may be unable to fail** (`FR-010`). A soft-failing or always-skipped check is worse
   than no check: it reports coverage that does not exist. Every class must be demonstrated to fail
   on a deliberately introduced defect before it counts as wired.
2. **The gate runs unconditionally on every pull request to the integration branch** (`FR-009`). No
   path filters. A path filter is a decision that certain changes need no verification, which is
   exactly the assumption defects exploit.
3. **The gate does not run full reviews** (`FR-031`). `goose run --explain` is a real parser check at
   no LLM cost; the full runs of feature `001` consume a subscription and stay manual.
4. **The gate never writes to the repository.** It verifies; it does not format, fix, or commit.
5. **Every workflow declares its minimum permissions** (`FR-026`). The gate needs read access and
   nothing else.

## Recipe parse check — why it belongs in a static gate

`goose run --recipe <file> --explain` loads and validates a recipe without any model call. It is the
only check here that exercises the *host's own* parser rather than a schema this project wrote, which
makes it the strongest of the seven — and it costs nothing.

Feature `001` measured that five of its ten baseline criteria are enforced by exactly this parser. A
recipe that fails this check would fail at run time for every consumer.

## Determinism

The same commit must produce the same verdict on two consecutive runs, including one with a cold
cache (`FR-011`, `SC-003`).

**Stated limit**: this holds against a fixed state of the shared workflow repository. Those workflows
call each other with `@develop`, which a consumer cannot pin (research Finding 3). The guarantee is
therefore conditional, and `OMISSIONS.md` says so rather than the gate implying otherwise.

## What the gate deliberately does not verify

| Not checked | Why | Recorded in |
|---|---|---|
| That the review's findings are still correct | Requires full runs; subscription cost | `OMISSIONS.md` |
| External link reachability | Network flakiness would make the gate non-deterministic | `OMISSIONS.md` |
| Build artifacts | There are none | `OMISSIONS.md` |

Each is an omission with a reason and a revisit condition, not an oversight.
