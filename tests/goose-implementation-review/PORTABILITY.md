# Portability Check

Verifies Constitution Principle I: `process/` and `baselines/` must be usable in a foreign
repository **without editing them**. Anything subject- or repository-specific must arrive as a
declared parameter.

## Guard — static check

Runs without Goose. Fails when the reusable trees contain anything tied to the repository they
currently live in.

```sh
#!/usr/bin/env sh
# Run from the repository root.
set -u
fail=0

# 1. This repository's own name must not appear in the reusable trees.
if grep -rIn --exclude-dir=.git 'claude-goose' process/ baselines/ 2>/dev/null; then
  echo "FAIL: repository name leaked into a reusable tree"; fail=1
fi

# 2. No absolute paths into a developer's machine.
if grep -rInE '(/home/|/Users/|[A-Za-z]:\\\\)' process/ baselines/ 2>/dev/null; then
  echo "FAIL: absolute path leaked into a reusable tree"; fail=1
fi

# 3. No references to this project's spec tree — consumers do not have it.
#    Covers BOTH trees. An earlier version checked only process/ and missed a real
#    violation in baselines/; see "Guard history" below.
if grep -rIn 'specs/[0-9]' process/ baselines/ 2>/dev/null; then
  echo "FAIL: reference to this project's spec directory in a reusable tree"; fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS: no repository-specific values found"
exit "$fail"
```

**What check 3 does not forbid**: upstream documentation URLs in a baseline's `sources.md`. Those are
a property of the criteria and must travel with them — a criterion whose source a consumer cannot
follow would violate the evidence rule. The distinction is between *external* sources, which belong
in a baseline, and *this project's internal specification files*, which a consumer will never have.

## Guard history

The first version of check 3 scanned only `process/`, on the assumption that `baselines/` needed a
blanket exemption for its source citations. Running it immediately exposed the flaw: it passed while
`baselines/goose/2026-07-31/criterion-format.md` referenced this project's contract file by path. A
consumer copying that revision would have held a pointer to a document they do not possess.

Both were fixed: the criterion format is now self-sufficient, and the check covers both trees. Worth
recording, because the guard's own blind spot was the defect — a passing check that inspects the
wrong scope is more dangerous than no check, since it is reported as evidence.

## Manual procedure — foreign repository run

Requires Goose. Not yet performed; see `RESULTS.md`.

1. Copy `process/` and `baselines/` to a scratch location outside this repository.
2. Point the review at a Goose recipe in an unrelated repository.
3. Run without editing either copied directory.
4. Record the outcome below.

**`SC-004` requires at least two different repositories.** One successful run proves the process is
movable; two prove it is not accidentally shaped by the first host.

## Recorded runs

| Date | Check | Target | Outcome |
|---|---|---|---|
| 2026-07-31 | Static guard | `process/`, `baselines/` | See below |
| — | Foreign repo #1 | — | Not yet run (T045). Goose is available; this is outstanding work, not a blocker |
| — | Foreign repo #2 | — | Not yet run (T045) |
