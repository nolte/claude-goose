---
review-type: skill-review
target: "skills/recipe-plan/SKILL.md"
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
status: open
---

# Skill Review: recipe-plan

## Scope

Target: `skills/recipe-plan/` (`SKILL.md`, 105 Zeilen, ca. 1.700 Token; einziges referenziertes Asset `templates/recipe-plan.template.md`; kein dispatchter Agent). Zur Beurteilung mitgelesen, aber nicht Review-Gegenstand: `skills/README.md` (Delimitation Record, Upstream dependencies), `skills/VERSION.md`, `specs/005-recipe-lifecycle-skills/` (`spec.md`, `contracts/skill-interfaces.md`, `contracts/recipe-artifacts.md`), `scripts/check-portability.sh`, `tests/goose-implementation-review/RESULTS.md` §Feature 005.
Specs applied: `skill-management`, `skill-vs-agent`, `review-plan`, `skill-review` (revisions recorded in frontmatter). Spec-Override: Specs aus nolte/claude-shared@6b255f00 (canonical en), da claude-goose keine spec/claude/-Bäume führt — auf Anweisung des Operators. Für Einzelchecks zusätzlich gelesen: `spec/project/spec-driven-development/` (claude-shared@6b255f00).
Validator: validate_skills.py 1.0.0 (claude-shared 6b255f00)
Narrowing: none. Der Skill ist neu (eine einzige Commit-Historie, 7c72960); Duplikat-Severity ist davon unabhängig.
Duplicate check: `description:` aller Skills in claude-goose (`skills/*/SKILL.md`) sowie aller Skills und Agents in claude-shared (`skills/`, `agents/`, `plugins/*/skills/`, `plugins/*/agents/`) gelesen; Kandidaten `implementation-plan-author`, `feature-decompose`, `sprint-plan`, `requirements-elicit`, `kpi-derive`, `working-copy-start` einzeln beurteilt. Innerhalb des Plugins `nolte-goose` keine Überlappung (die vier Phasen sind über Input/Output disjunkt). Pluginübergreifende Überlappung ist laut `skill-review` außer Scope und steht nur als Info unten.
Research-plan-implement: Der Skill zitiert `spec/claude/research-plan-implement/` nicht; der Backlog ist das Aggregat-Info des Validators und wird hier nicht pro Skill erneut erhoben. Die Urteils-Checks (Tier-Fit, Write-Gate-Position) entfallen mangels Adoption. Resumability: `contracts/skill-interfaces.md` legt "Resumable: No; one approval span" fest; nicht beanstandet.
Explicitly out of scope: runtime behavior of the skill, Vale/markdown style (handled by `task lint`), dispatched agents beyond confirming the orchestration direction.

## Summary

- Critical: 1
- Warning: 4
- Suggestion: 0
- Info: 6

Go/no-go: FAIL — ein offener Critical (Spec-Anker fehlt).
Next concrete action: Autor stellt einen im Consumer auflösbaren Spec-Anker her oder verankert eine dokumentierte Ausnahme, danach Template-Kommentar und die veraltete Ownership-Begründung bereinigen.

## Findings

### Critical

- [ ] [spec-driven-development.skill-spec-citation] `SKILL.md` zitiert in `description` und Body keinen einzigen Spec, den der Skill implementiert; der Spec-Anker-Check (`skill-review` §"Checks derived from spec-driven-development") schlägt fehl. Der eigentliche Governing-Spec (`specs/005-recipe-lifecycle-skills/`, User Story 3, FR-005–FR-007) darf wegen Check 3 von `scripts/check-portability.sh` (`specs/[0-9]` in `skills/` verboten) bewusst nicht zitiert werden.
      Where: `skills/recipe-plan/SKILL.md` gesamt (Frontmatter Z. 3, Body Z. 23–105); Kollisionsregel `scripts/check-portability.sh` Z. 43–48.
      Fix: Einen Anker setzen, den der Portabilitäts-Guard zulässt und der im Consumer auflöst (z. B. Abschnitt "Governing spec" im Body, der auf `${CLAUDE_PLUGIN_ROOT}/skills/README.md` §Delimitation record verweist und dort die Feature-Nummer ohne `specs/<n>`-Pfad nennt) — oder eine dokumentierte Projektentscheidung (etwa in `OMISSIONS.md`) anlegen, die den Check für Consumer-Plugin-Skills aussetzt, und sie in der nächsten Review als Scope-Override zitieren.
      Verify: `grep -nE 'spec/|Governing spec' skills/recipe-plan/SKILL.md` liefert einen Treffer bzw. die Scope-Override-Zeile zitiert die Entscheidung; `./scripts/check-portability.sh` bleibt PASS.

### Warning

- [ ] [skill-management.tag-vocabulary] Externer Validator meldet `tags outside the starter vocabulary: ['goose']` (Validator-Warning → Warning). Die Tag-vocabulary-MAY erlaubt einen neuen Tag, und `skills/README.md` §Validator hält `goose` bereits als bewusst eingeführten Cluster-Tag fest — die Entscheidung ist also dokumentiert, nur nicht als Review-Override.
      Where: `skills/recipe-plan/SKILL.md:4` (`tags: [planning, goose]`).
      Fix: Keine Skill-Änderung nötig; in der nächsten Review den Befund per Scope-Override mit Verweis auf `skills/README.md` §Validator unterdrücken (`skill-review` §"Checks derived from external skill-structure validation", MAY).
      Verify: Scope der Folge-Review enthält die Override-Zeile mit Begründung; `validate_skills.py` meldet sonst nur noch diesen bekannten Warning.

- [ ] [skill-management.time-sensitive-information] `description` und Body begründen die Format-Ownership mit einer Tatsachenbehauptung über ein Peer-Artefakt ("no shared capability accepts a requirement artifact without a GitHub issue"), die bereits veraltet: `implementation-plan-author` akzeptiert seit claude-shared 92d08204 (#669, Issue #666 geschlossen 2026-09-25) "a confirmed requirements-elicit artifact with no issue". Die Aussage steht weder versioniert in der `description` noch in einem `## Old patterns`-Abschnitt.
      Where: `skills/recipe-plan/SKILL.md:3` (description, Satz 2); `skills/recipe-plan/SKILL.md:38–45` (§"Why this skill owns its format", nur im Body auf v0.1.11 gepinnt).
      Fix: Den Begründungssatz aus der `description` entfernen (nur Routing behalten) und §"Why this skill owns its format" nach Prüfung des neuen `implementation-plan-author`-Eingangs entweder auf Delegation umstellen oder die v0.1.11-Begründung in `## Old patterns` verschieben.
      Verify: `grep -n "without a GitHub issue" skills/recipe-plan/SKILL.md` liefert keinen Treffer außerhalb von `## Old patterns`.

- [ ] [skill-management.supporting-file-sync] Der Template-Kommentar sagt "Every header value except the recipe path and the date is carried from that artifact unchanged" — damit auch `State`, das laut `SKILL.md` Schritt 5 und `contracts/recipe-artifacts.md` neu als `ready`/`blocked` entschieden wird (im Input steht `confirmed`). `SKILL.md` Schritt 6 nennt dagegen genau drei übernommene Werte.
      Where: `skills/recipe-plan/templates/recipe-plan.template.md:11–15` gegen `skills/recipe-plan/SKILL.md:79–84`.
      Fix: Kommentar auf die drei übernommenen Felder (`baseline_revision`, `lifecycle_version`, `review_process_version`) plus Slug/Titel einschränken und `State` ausdrücklich als von diesem Skill entschieden kennzeichnen.
      Verify: Template-Kommentar und Schritt 6 nennen dieselbe Feldmenge; `State` steht nicht mehr unter "carried unchanged".

- [ ] [skill-management.gotchas] Kein `## Gotchas`-Abschnitt, obwohl der Skill eine nicht-offensichtliche Umgebung adressiert: er entscheidet Wert und Platzierung von `instructions`/`prompt` und `parameters[]`, wo das beobachtete Goose-Verhalten von der Doku abweicht (O-12: Constraint nur in `instructions` wird ignoriert; O-6: `input_type: file` inlined den Inhalt) — O-12 ist in keinem Kriterium der Baseline kodiert, Schritt 4 fängt es also nicht ab. Dazu kommt die Auflösung über `${CLAUDE_PLUGIN_ROOT}`.
      Where: `skills/recipe-plan/SKILL.md` (Abschnitt fehlt; betroffen Schritt 2, Z. 64–68).
      Fix: `## Gotchas` mit den Umgebungsfakten ergänzen, die eine Element-Entscheidung kippen (mindestens O-12 und O-6, je mit Quelle in `tests/goose-implementation-review/RESULTS.md`, sofern im Consumer nicht auflösbar: als Kurzfassung).
      Verify: `grep -n '^## Gotchas' skills/recipe-plan/SKILL.md` trifft; der Abschnitt nennt die `prompt`-vor-`instructions`-Regel.

### Info

- [ ] [skill-management.self-contained] Der Skill liest Daten außerhalb seines Ordners (`${CLAUDE_PLUGIN_ROOT}/baselines/goose/<rev>/ruleset.md`, `coverage.md`, `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md`). Das Portabilitätsziel der Regel ist erfüllt (Plugin-Root-Variable, keine absolute Pfadannahme, Abhängigkeit in `skills/README.md` §Distribution contract deklariert), und ein Kopieren der unveränderlichen Baselines in den Skill-Ordner widerspräche der Revisions-Immutabilität. Spec muss ggf. wachsen: `skill-management` kennt keine plugin-weit geteilten Daten-Assets.
      Where: `skills/recipe-plan/SKILL.md:55–58`, `:62–63`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [spec-driven-development.skill-spec-citation] Spec muss ggf. wachsen: Der Spec-Anker-Check prüft wörtlich auf `spec/...`-Pfade und setzt voraus, dass der Governing-Spec im Consumer existiert. Für ein Consumer-Plugin mit SpecKit-Layout (`specs/NNN-*/`), dessen Spec-Baum per Portabilitäts-Guard bewusst nicht aus `skills/` referenziert werden darf, gibt es keinen vorgesehenen Ankerweg und keine passende Ausnahme (die MAY-Ausnahme deckt nur "implementation-only"-Skills).
      Where: `spec/claude/skill-review/` §"Checks derived from spec-driven-development"; `spec/project/spec-driven-development/` Requirement #4.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-vs-agent.duplicate-prevention] Pluginübergreifend (außer Scope der Duplikatregel): `nolte-engineering:implementation-plan-author` deckt seit claude-shared 92d08204 (nach v0.1.11, noch in keinem Tag) den bisher fehlenden Eingang ab; damit ist die Vorbedingung erfüllt, unter der `skills/README.md` die Delegation des Planformats vorsieht, und Akzeptanzszenario 4 von User Story 3 ("structure comes from the portfolio's generic planning capability") wird erreichbar. `skills/README.md` §Upstream dependencies führt #665, #666 und #667 noch als "open"; alle drei sind seit 2026-09-25 geschlossen.
      Where: `skills/README.md:58`, `:66–70`; `skills/recipe-plan/SKILL.md:38–45`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.consistent-terminology] Vorbedingung 3 liest `skills/VERSION.md`, "so the plan can carry the lifecycle version it was written under", während Schritt 6 und `contracts/recipe-artifacts.md` `lifecycle_version` unverändert aus dem Input übernehmen. Weicht die installierte Lifecycle-Version von der des Requirement-Artefakts ab, ist offen, welche gilt; die gelesene Datei wird sonst nirgends verwendet. Keine Spec-Regel deckt Widersprüche innerhalb von `SKILL.md` direkt ab.
      Where: `skills/recipe-plan/SKILL.md:57–58` gegen `:83–84`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.progressive-disclosure] "The upstream proposal is recorded in this plugin's `README.md`" zeigt auf das Plugin-Root-`README.md`, das den Vorschlag nicht enthält; er steht in `skills/README.md` §Upstream dependencies. Kein Laufzeit-Asset, daher kein Broken-Reference-Critical.
      Where: `skills/recipe-plan/SKILL.md:44–45`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-review.evaluation-discipline] Drei Evaluationsszenarien existieren (Runs 3–5 in `tests/goose-implementation-review/RESULTS.md` §Feature 005: ready, draft-Refusal, blocked-Konflikt), aber außerhalb des Skill-Ordners und damit nicht im Consumer; ein Multi-Model-Nachweis fehlt ("The model the nested sessions resolved to was not captured").
      Where: `tests/goose-implementation-review/RESULTS.md:486–529`; `skills/recipe-plan/` (kein `examples/`).
      Fix: n/a (observation).
      Verify: n/a.

## Processing log

<!-- Append one line per item closure: YYYY-MM-DD — <item-shorthand> — <action taken> — verified: <method> -->
