# Contract: What This Feature Produces for `001`

**Feature**: `002-qa-documentation-base` | **Date**: 2026-07-31

The consuming side of this interface is already specified in
`specs/001-goose-implementation-review/contracts/baseline-contract.md`, and **that document
governs**. This one states the producer's obligations and must not restate the consumer's schema —
two copies would drift, which is the defect this project exists to prevent.

## The division

| Concern | Owner |
|---|---|
| What a revision must contain, field by field | `001`'s baseline contract — **normative** |
| How gaps propagate into `undecided` findings | `001`'s baseline contract |
| How material *enters* a revision, and on what evidence | **This feature** |
| When a source is stale and must be re-checked | This feature — see `drift-detection.md` |
| Which topics to research next | This feature — the gap list, by observed demand |

## Producer obligations

1. **Never publish an unsourced statement.** `SC-001` sets this at zero, as a release condition.
   A single unsourced statement blocks publication; it is not a quality target to approach.

2. **Never silently drop a topic.** Research that finds nothing admissible produces an Open Question
   with what was searched — never silence. Silence reads to the consumer as "nothing to check here",
   which is the false-confidence failure mode.

3. **Never widen an evidence class to make a statement stronger.** If a rule is only observed, it
   stays observed. Promoting it to authoritative because it "obviously" holds is exactly the
   invention this feature forbids.

4. **Never edit a published revision** except by appending verification records. Corrections produce
   a new revision, so reports citing the old one stay interpretable.

5. **Carry the criterion format inside each revision.** A shared format file would re-interpret every
   earlier revision the moment it changed.

## What the producer may assume of the consumer

- It pins a revision per run and never re-resolves mid-review.
- It reports a declared gap as `undecided`, never as a pass.
- It states which revision it used, so a report stays interpretable after the baseline moves on.

These are `001`'s obligations, verified in its own test suite. This feature does not re-verify them.

## Growth policy

New criteria come from **closing declared gaps**, in order of observed demand (`research.md`
Finding 3). Three of the six current gaps can never fire under `001`'s scope; researching them first
would produce material nothing consumes.

**Prefer criteria the host does not enforce.** Five of the ten shipped criteria describe conditions
under which a recipe will not load at all — for those the review offers earlier detection and a
sourced explanation, but nothing that was not already caught. The two that matter, `R-002` and
`R-010`, describe behaviour the host accepts and the documentation misstates. That is where the base
adds something nothing else provides.
