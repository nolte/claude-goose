# Quickstart Scenario Status

Recorded 2026-07-31 against process 1.0.0, baseline 2026-07-31b, Goose 1.45.0.
Evidence for each is in `RESULTS.md`. A scenario is PASS only if a run demonstrated it.

| # | Scenario | Status | Evidence |
|---|---|---|---|
| 1 | A finding is traceable | **PASS** | Review of `recipe-with-deviations`: every finding carried criterion, location, source |
| 2 | Clean vs. unexamined | **PASS** | `recipe-clean` (no deviations, full coverage stated) and `no-goose-material` ("nothing reviewable found") |
| 3 | Reproducibility | **PASS** | Two consecutive runs, byte-identical digests matching the golden file |
| 4 | Undecidable criteria are visible | **PASS** | Declared gaps surfaced as `undecided`, never as passes |
| 5 | Reuse against a foreign repository | **PASS** | Two unrelated repositories, no edits to `process/` or `baselines/` |
| 6 | Self-review | **PASS** | Final self-review of the finished process: no findings |
| 7 | Delta between reviews | **PASS** | `resolved`/`subject` for a corrected defect; `resolved`/`baseline` for a narrowed gap |
| 8 | The subject is not modified | **PASS** | All 24 runs: sha256 before and after identical |
| 9 | A partial review says so | **PASS** | `max_bytes_per_pass=5000` against an 11215-byte subject: "exceeds per-pass budget" |
| 10 | Offline behaviour | **NOT RUN** | Cannot be exercised with `claude-acp`, which needs the network before a review starts. Needs a local provider or a stubbed drift check |
| 11 | Published revisions survive | **PASS** | `2026-07-31` byte-identical after `2026-07-31b` was published, verified against its commit |
| 12 | Citations hold up for a stranger | **PASS** | Operator (did not author the baseline) resolved 20/20 on 2026-07-31; threshold was 18. See `SC-003-SAMPLE.md` |
| 13 | Time to triaged findings | **PASS** | 197 seconds against the reference fixture; limit 900 |

**Release gate**: scenarios 1–6 and 8–12 must pass. **All of them now do.** Scenario 10 (offline)
remains unrun and is not part of the gate; it stays listed so the gap is visible. Scenarios 6 and 8 —
the two non-negotiable ones — both pass.
