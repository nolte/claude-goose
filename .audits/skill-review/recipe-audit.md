---
review-type: skill-review
target: "skills/recipe-audit/SKILL.md"
target-kind: skill
specs-applied:
  - slug: skill-management
    revision: "4ceb6872"
  - slug: skill-vs-agent
    revision: "66d65137"
  - slug: review-plan
    revision: "7be3b552"
  - slug: skill-review
    revision: "7be3b552"
repo-revision: "7c72960fdf48ef7add4af277c4d3d7772f8ffbd7"
created: "2026-11-04"
status: in-progress
---

# Skill Review: recipe-audit

## Scope

Target: `skills/recipe-audit/` (`SKILL.md` only, 114 lines, ~1,550 tokens; no supporting files in the skill folder; plugin-root assets read as referenced: `process/goose-implementation-review/bindings/claude-code/run.sh`, `process/goose-implementation-review/invocation-contract.md`, the opening of `constraints.md`; context: `skills/README.md` (Delimitation record, upstream dependencies), `skills/VERSION.md`, `specs/005-recipe-lifecycle-skills/spec.md` FR-011–FR-014, `tests/goose-implementation-review/RESULTS.md` "Feature 005").
Specs applied: `skill-management`, `skill-vs-agent`, `review-plan`, `skill-review` (revisions recorded in frontmatter). Spec override: Specs aus nolte/claude-shared@6b255f00 (canonical en), da claude-goose keine spec/claude/-Bäume führt — auf Anweisung des Operators. Zitierpfade in Findings beziehen sich auf `spec/claude/<topic>/` bzw. `spec/project/<topic>/` in claude-shared.
Validator: validate_skills.py 1.0.0 (claude-shared 6b255f00)
Narrowing: none. New-vs-revision context: first review of a newly authored skill (lifecycle 0.1.0, pre-release). Dispatched agents: none — the skill dispatches no `agents/<name>.md`; it shells out to a headless `claude --print` session via the binding, so no companion `agent-review` is triggered. `research-plan-implement` judgement checks: not applicable — the skill does not cite that spec (covered once by the validator's aggregate `rpi-adoption-backlog` Info, not re-raised), and its only write is the review report, a findings artifact on the read-only side of the write boundary.
Explicitly out of scope: runtime behavior of the skill, Vale/markdown style (handled by `task lint`), dispatched agents beyond confirming the orchestration direction, the correctness of the review process and of the generated binding themselves.

Override (2026-11-05): validator warning `[skill-management.tag-vocabulary]` for tag `goose` — kept deliberately as a new cluster tag under the tag-vocabulary MAY; decision recorded in `skills/README.md` §Validator.

## Summary

- Critical: 2
- Warning: 3
- Suggestion: 1
- Info: 5

Go/no-go: FAIL
Next concrete action: Autor verankert die beiden Plugin-Root-Verweise mit `${CLAUDE_PLUGIN_ROOT}` und ergänzt im Body einen Spec-Anker auf `specs/005-recipe-lifecycle-skills/spec.md` (FR-011–FR-014).

## Findings

### Critical

- [x] [skill-management.runtime-discovery-no-project-relative-path] Zwei Verweise auf die Normquellen stehen ohne `${CLAUDE_PLUGIN_ROOT}`-Präfix und lösen im Consumer-Repository gegen dessen Arbeitsverzeichnis auf, wo kein `process/`-Baum existiert; die Preconditions verwenden für denselben Baum korrekt `${CLAUDE_PLUGIN_ROOT}`, der Body ist damit in sich uneinheitlich. Der Abschnitt „Where the rules are“ fordert den Leser ausdrücklich auf, genau diese Dateien zu lesen — im Consumer findet er sie unter diesem Pfad nicht.
      Where: `skills/recipe-audit/SKILL.md:45` (`process/goose-implementation-review/invocation-contract.md`), `:99` (`process/goose-implementation-review/constraints.md`).
      Fix: beide Pfade als `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/…` schreiben, wie in den Zeilen 62 und 76.
      Verify: `grep -nE '(^|[^}/])process/goose' skills/recipe-audit/SKILL.md` liefert keinen Treffer mehr.

- [ ] [skill-review.spec-anchor / spec-driven-development.skill-cites-spec] Der Body zitiert keinen einzigen Spec — weder einen `spec/...`-Pfad noch die Spec-Kit-Spec dieses Repos; er verweist nur auf den Invocation Contract und `constraints.md`, die normativ sind, aber keine Specs im Sinne von `spec/project/spec-driven-development/` („cite at least one spec the artefact implements“). Ein auflösbarer Anker existiert: `specs/005-recipe-lifecycle-skills/spec.md` (FR-011–FR-014 definieren genau diesen Skill) liegt im Plugin-Root (`marketplace.json` `source: "."`) und ist damit auch im Consumer über `${CLAUDE_PLUGIN_ROOT}` erreichbar.
      Where: `skills/recipe-audit/SKILL.md` (gesamter Body, insbesondere Einleitung Z. 20–25 und „Where the rules are“ Z. 96–103).
      Fix: in der Einleitung oder unter „Where the rules are“ einen Satz ergänzen, der `${CLAUDE_PLUGIN_ROOT}/specs/005-recipe-lifecycle-skills/spec.md` (FR-011–FR-014) als implementierte Spec nennt.
      Verify: `grep -n 'specs/005-recipe-lifecycle-skills/spec.md' skills/recipe-audit/SKILL.md` liefert mindestens einen Treffer im Body.

### Warning

- [x] [skill-management.tag-vocabulary] Der externe Validator meldet `tags outside the starter vocabulary: ['goose']` (Validator-Warning → Warning). Inhaltlich ist der Tag durch die MAY-Klausel desselben Abschnitts gedeckt (neuer Tag, wenn kein Starter-Begriff passt) und in `skills/README.md` §Validator als bewusste Cluster-Entscheidung dokumentiert.
      Where: `skills/recipe-audit/SKILL.md:5` (`tags: [review, goose]`).
      Fix: Operator-Entscheidung — `goose` behalten und die Validator-Meldung per expliziter Override-Zeile im `## Scope` dieses Plans unterdrücken, verankert in `skills/README.md` §Validator und skill-management §Tag vocabulary (MAY).
      Verify: Override-Zeile im `## Scope` vorhanden, oder erneuter Lauf `python3 -I …/validate_skills.py skills/recipe-audit/` ohne diese Warning.

- [x] [skill-management.authoring-quality-consistent-terminology] Der Prüfgegenstand wird vierfach benannt („Goose recipe“, „subject“, „implementation“, „material“), und der Umfang ist widersprüchlich: der Was-Teil der `description` nennt nur „a Goose recipe“, der Don't-use-Teil schließt nur Material aus, „that is not a Goose recipe or extension configuration“ — Extension-Konfigurationen sind laut `constraints.md:27` Prüfgegenstand, werden aber weder im Was-Teil noch in den Triggern noch im Body genannt.
      Where: `skills/recipe-audit/SKILL.md:3` (description), `:6` (summary), `:22`, `:50`, `:66`, `:109–111`.
      Fix: den Was-Teil auf „a Goose recipe or extension configuration“ erweitern und im Body durchgehend „subject“ für den Prüfgegenstand verwenden (die wörtlich kopierte Contract-Zeile Z. 50 ausgenommen).
      Verify: `description` nennt beide Gegenstandsarten im Was-Teil; `grep -n 'material' skills/recipe-audit/SKILL.md` ohne Treffer.

- [x] [skill-review.best-practices-gotchas / skill-management.authoring-quality-gotchas] Kein `## Gotchas`-Abschnitt, obwohl der Skill gegen eine nicht offensichtliche Umgebung arbeitet: (a) die Review startet eine verschachtelte headless-Claude-Code-Session, deren gemessene Laufzeit 197 s betrug (`RESULTS.md:451`) — über dem Standard-Timeout des Bash-Tools von 120 s, sodass ein Aufruf ohne erhöhten `timeout` abgebrochen und nach den Hard rules als Fehlschlag ohne Retry gemeldet würde; (b) Exit-Code `3` bedeutet „CLI endete mit 0, aber ohne Report“ (`run.sh`, `RESULTS.md` Run 9) und ist etwas anderes als Exit `2` (Precondition); (c) die Auflösung von `${CLAUDE_PLUGIN_ROOT}` im Skill-Body ist durch keinen Lauf belegt (`RESULTS.md` „Not run“, Szenario 1).
      Where: `skills/recipe-audit/SKILL.md:73–88` (Procedure Schritte 2–4); Abschnitt fehlt.
      Fix: `## Gotchas` ergänzen mit der Anweisung, den Bash-Aufruf mit `timeout` 600000 ms (oder `run_in_background`) zu starten, und mit der Bedeutung der Exit-Codes `2`/`3`.
      Verify: `grep -n '^## Gotchas' skills/recipe-audit/SKILL.md` trifft; der Abschnitt nennt Timeout und Exit-Code 3.

### Suggestion

- [ ] [skill-management.evaluation-discipline-three-scenarios] Der Skill hat keine Evaluationsszenarien unter `examples/` oder einem Geschwisterort, und `RESULTS.md` führt seinen einzigen geplanten Lauf (Szenario 1, Audit über den Skill vs. über das Binding) als „Not run“; der Release-Status steht auf „blocked“. Neuer Skill → Suggestion.
      Where: `skills/recipe-audit/` (kein `examples/`); `tests/goose-implementation-review/RESULTS.md` §„Not run, and why“, §„Release condition (T037)“.
      Fix: drei Szenarien festhalten (sauberes Subjekt → Exit 0 mit Digest; fehlendes `subject_path` → Exit 2 wörtlich; Lauf ohne Report → Exit 3 wörtlich) und Szenario 1 nach Entblockung durch Feature 004 US1 als realen Lauf aufzeichnen.
      Verify: drei Szenariodateien vorhanden und `RESULTS.md` verzeichnet einen Lauf von `recipe-audit` über den Skill.

### Info

- [x] [skill-vs-agent.rationale-documentation] Der Rationale-Abschnitt ist konform (exakte Überschrift, entscheidende Dimension Context-window impact, Gegen-Dimension genannt), aber der zweite Bullet beruft sich auf „the portfolio's artifact-type rule“, die so im Primary decision rule nicht steht. Die zitierfähige Begründung wäre „one step in a larger human-driven workflow (… running an audit)“ samt Auflösung des Konflikts mit dem Agent-Kriterium „self-contained, well-defined input/output“ über den Default-to-skill-Rule.
      Where: `skills/recipe-audit/SKILL.md:31–33`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.restated-rule-sync] Der Skill sagt, er füge nichts Normatives hinzu, kopiert aber die Inputs-Tabelle des Invocation Contracts wörtlich (inklusive der `latest`-Auflösungsregel); aktuell identisch (diff ohne Unterschied), doch anders als das generierte `run.sh` (`render-bindings.sh --check`) schützt kein Gate diese Kopie vor Drift. Die Hard rules (Z. 104–114) regeln dagegen nachvollziehbar das Verhalten des Skills selbst, nicht das der Review (so auch `RESULTS.md` Run 1).
      Where: `skills/recipe-audit/SKILL.md:48–54` gegen `process/goose-implementation-review/invocation-contract.md` §Inputs.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-vs-agent.duplicate-prevention] Duplikat-Check ohne Treffer: in claude-goose ist `recipe-implement` nur benachbart (Parser-Prüfung vs. Kriterien-Review, Kette über `see_also`/`dont_use_when`); in claude-shared (134 Skill-/Agent-Beschreibungen über alle Plugin-Roots) prüft keine Beschreibung Goose-Material — alle review/audit-Treffer gehören anderen Domänen. Deckt sich mit dem Delimitation record in `skills/README.md`.
      Where: `skills/*/SKILL.md` (claude-goose); `skills/`, `agents/`, `plugins/*/skills/`, `plugins/*/agents/` (claude-shared 6b255f00).
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-review.spec-anchor] Spec muss ggf. wachsen: der Check verlangt wörtlich einen `spec/...`-Pfad, dieses Repo führt seine Specs im Spec-Kit-Layout unter `specs/NNN-<slug>/spec.md`, und die `spec/claude/`-Bäume von claude-shared sind in einem Consumer nicht auflösbar. Der Critical oben stützt sich darauf, dass gar kein Spec zitiert ist; ob ein `specs/…`-Zitat den Check formal erfüllt, sollte skill-review/spec-driven-development ausdrücklich regeln.
      Where: claude-shared `spec/claude/skill-review/` §„Checks derived from spec-driven-development“.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.structure-self-contained] Spec muss ggf. wachsen: der Skill hängt von Assets außerhalb seines Ordners ab (`${CLAUDE_PLUGIN_ROOT}/process/…`, `baselines/`), weil das Binding generiert und mit dem Goose-Binding geteilt ist; das ist eine bewusste, fail-closed abgesicherte Design-Entscheidung (Preconditions Z. 61–64, `skills/README.md` „What this directory is not“). skill-management kennt nur „assets live inside the skill folder“ und hat keine Regel für plugin-weite, über `${CLAUDE_PLUGIN_ROOT}` erreichte Bäume — daher hier kein Critical.
      Where: `skills/recipe-audit/SKILL.md:61–64`, `:76`.
      Fix: n/a (observation).
      Verify: n/a.

## Processing log

<!-- Append one line per item closure: YYYY-MM-DD — <item-shorthand> — <action taken> — verified: <method> -->

- 2026-11-05 — C runtime-discovery — beide Pfade mit `${CLAUDE_PLUGIN_ROOT}` präfixiert — verified: grep -nE '(^|[^}/])process/goose' ohne Treffer
- 2026-11-05 — W tag-vocabulary — Tag behalten, Override im Scope — verified: Override-Zeile im ## Scope; skills/README.md §Validator Zeile 2026-11-05
- 2026-11-05 — W terminology — description/summary/Body nennen Rezept und Extension-Konfiguration, Body sagt „subject“ — verified: grep material ohne Treffer; Contract-Zeile bewusst wörtlich
- 2026-11-05 — W gotchas — ## Gotchas mit Timeout 600000 ms, Exit-Codes 2/3, Plugin-Root — verified: grep ^## Gotchas trifft; Schritt 2 verweist auf Timeout
- 2026-11-05 — I rationale — zweiter Bullet zitiert Workflow-Kriterium und Default-to-skill — verified: Rationale-Abschnitt gelesen
