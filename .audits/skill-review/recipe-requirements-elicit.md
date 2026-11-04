---
review-type: skill-review
target: "skills/recipe-requirements-elicit/SKILL.md"
target-kind: skill
specs-applied:
  - slug: skill-management
    revision: "nolte/claude-shared@4ceb6872"
  - slug: skill-vs-agent
    revision: "nolte/claude-shared@66d65137"
  - slug: review-plan
    revision: "nolte/claude-shared@7be3b552"
  - slug: skill-review
    revision: "nolte/claude-shared@7be3b552"
  - slug: resumable-work
    revision: "nolte/claude-shared@e75ffbba"
  - slug: skill-agent-catalog
    revision: "nolte/claude-shared@2f515909"
  - slug: spec-driven-development
    revision: "nolte/claude-shared@4bff2c8e"
repo-revision: "7c72960fdf48ef7add4af277c4d3d7772f8ffbd7"
created: "2026-11-04"
status: in-progress
---

# Skill Review: recipe-requirements-elicit

## Scope

Target: `skills/recipe-requirements-elicit/` (`SKILL.md` mit 122 Zeilen, ca. 1.900 Tokens; `references/recipe-question-set.md`; `templates/recipe-requirements.template.md`). Kein `agents/`-Dispatch, deshalb kein begleitender `agent-review`. Gelesen als Kontext, aber nicht reviewt: `skills/README.md` (Delimitation Record, Upstream dependencies), `skills/VERSION.md`, `baselines/goose/2026-08-02/ruleset.md` und `coverage.md` (für die Prüfung, ob die zitierten IDs existieren), der Delegationszielskill `nolte-shared:requirements-elicit` in claude-shared@6b255f00 und mit Tag `v0.1.11`.
Specs applied: `skill-management`, `skill-vs-agent`, `review-plan`, `skill-review`, dazu `resumable-work`, `skill-agent-catalog` und `spec/project/spec-driven-development/` für einzelne Checks (Revisionen im Frontmatter). Spec-Override: Die Specs stammen aus nolte/claude-shared@6b255f00 (canonical en), weil claude-goose keine `spec/claude/`-Bäume führt; so hat es der Operator angeordnet. Auf seine Anweisung gilt außerdem: Wenn eine claude-shared-Regel ausdrücklich für Skills des Plugins `nolte-shared` geschrieben ist und auf ein Consumer-Plugin nicht passt, wird das als Info („Spec muss ggf. wachsen“) erfasst und nicht hochgestuft. Nicht anwendbar sind §Source location und §Distribution (Pfad `skills/<name>/` in claude-shared, Auslieferung über `nolte-shared`).
Validator: validate_skills.py 1.0.0 (claude-shared 6b255f00)
Narrowing: none. Neues Artefakt (Lifecycle 0.1.0, Pre-Release), keine Revision eines bereits gereviewten Skills.
research-plan-implement: Der Skill zitiert `spec/claude/research-plan-implement/` nicht. Laut `skill-review` §research-plan-implement kommt deshalb keine Einzelbefund-Meldung hinzu; der Rückstand steht einmal als Aggregat-Info des Validators. Außerdem schreibt der Skill nur Artefakte (`project/recipes/<slug>/requirements.md`), und die liegen laut Spec auf der Read-only-Seite der Schreibgrenze.
Explicitly out of scope: Laufzeitverhalten des Skills (nicht ausgeführt), Vale- und Markdown-Stil (dafür ist `task ci` zuständig), Überschneidungen über Plugin-Grenzen als Befund (laut `skill-review` Sache von `spec-drift-audit`/`portfolio-audit`, hier nur als Info).

Override (2026-11-05): validator warning `[skill-management.tag-vocabulary]` for tag `goose` — kept deliberately as a new cluster tag under the tag-vocabulary MAY; decision recorded in `skills/README.md` §Validator.

## Summary

- Critical: 0
- Warning: 6
- Suggestion: 2
- Info: 7

Go/no-go: CONDITIONAL — kein Critical, freigabefähig; W3 (Resume-Kadenz) und W4 (Teach-back im Template) vor dem Lifecycle-Release 1.0.0 beheben.
Next concrete action: Autor ergänzt in `SKILL.md` §Resuming a run die fehlenden Checkpoints und im Template ein Teach-back-Feld.

## Findings

### Warning

- [x] [skill-management.tag-vocabulary] Der Validator meldet das Tag `goose` als außerhalb des Starter-Vokabulars (validate_skills.py 1.0.0, Warning). Ein neues Tag ist laut §Tag vocabulary per MAY zulässig, und `skills/README.md:79` begründet es als Cluster-Tag.
      Where: `skills/recipe-requirements-elicit/SKILL.md:4` (`tags: [requirements, goose]`).
      Fix: `goose` upstream ins Starter-Vokabular von `spec/claude/skill-management/` §Tag vocabulary aufnehmen lassen. Alternativ beim nächsten Review in `## Scope` einen Override mit Verweis auf §Tag vocabulary MAY und `skills/README.md` §Validator eintragen.
      Verify: `python3 -I <claude-shared>/scripts/validate_skills.py skills/recipe-requirements-elicit/` meldet keine Warnung zu `tag-vocabulary` mehr, oder der Override steht im Scope.

- [x] [skill-management.gotchas] Ein `## Gotchas`-Abschnitt fehlt, obwohl der Skill in einer nicht offensichtlichen Umgebung arbeitet. Er delegiert über eine Plugin-Grenze, löst Pfade über `${CLAUDE_PLUGIN_ROOT}` auf und ist auf die `input_type: file`-Semantik (O-6) angewiesen. Die Fakten stehen verstreut im Text (z. B. „Do not invoke it to find out“, „the question most often answered wrong“). Eine Falle fehlt ganz: Das Delegationsziel kann installiert sein und trotzdem an seiner eigenen Precondition stoppen, wenn im Consumer die Methodik-Spec fehlt.
      Where: `SKILL.md` (Abschnitt fehlt); verstreute Inhalte in `SKILL.md:47-50` und `references/recipe-question-set.md:20-21`.
      Fix: `## Gotchas` vor `## Hard rules` einfügen. Er enthält: Listing statt Probe-Invoke, Zielskill kann an eigener Spec-Precondition stoppen (dann fail-closed wie bei fehlender Installation), file-Parameter liest Inhalt statt Pfad (O-6), `${CLAUDE_PLUGIN_ROOT}` zeigt auf das Plugin, nicht auf das Consumer-Repo.
      Verify: `grep -n '^## Gotchas' skills/recipe-requirements-elicit/SKILL.md` findet den Abschnitt mit mindestens diesen vier Einträgen.

- [x] [resumable-work.checkpoint-cadence] Der Text zählt nur zwei Checkpoints auf („after the delegated interview completes and after each recipe dimension is confirmed“). Es fehlen die Freigabe-Gates aus Schritt 4 (jede Baseline-Check-Zeile wird dem Autor zur Entscheidung vorgelegt) und aus Schritt 5 (Teach-back-Bestätigung). `spec/claude/resumable-work/` verlangt mit MUST einen Checkpoint nach jedem erfolgreichen Freigabe-Gate. Der Skill gibt die zitierte Regel also enger wieder, als sie in der Spec steht (`skill-review` §Progressive disclosure, restated rule).
      Where: `SKILL.md:107-111` (§Resuming a run).
      Fix: Die Aufzählung ersetzen durch „after every successful user-approval gate (each recipe dimension, each baseline-check row decision, the teach-back) and after each named phase boundary“.
      Verify: Jeder Schritt in §Operations 1, der eine Autorentscheidung einholt (3, 4, 5), ist in §Resuming a run als Checkpoint benannt.

- [x] [skill-management.supporting-file-consistency] `SKILL.md` erlaubt `confirmed` nur mit einer aufgezeichneten Teach-back-Bestätigung (Schritt 5, Hard rule, `validate`-Punkt 9: „a teach-back is recorded“). Das Template, aus dem Schritt 6 schreibt, hat dafür kein Feld. Ein korrekt erzeugtes Artefakt kann `validate` Punkt 9 deshalb nicht aus eigenem Inhalt bestehen. Das ist ein Widerspruch in genau der Datei, die ein Run lädt (`skill-review` §Progressive disclosure: contradicting supporting file).
      Where: `templates/recipe-requirements.template.md:8` (nur `**State**: {{draft | confirmed}}`) gegenüber `SKILL.md:83`, `SKILL.md:103`, `SKILL.md:120`.
      Fix: Im Template-Header ein Feld `**Teach-back**: {{YYYY-MM-DD — confirmed by author | none}}` ergänzen, oder in `SKILL.md` festlegen, dass der Teach-back-Nachweis im generischen Artefakt steht, und `validate` Punkt 9 dorthin verweisen lassen.
      Verify: `validate` Punkt 9 lässt sich an einem aus dem Template erzeugten Artefakt prüfen, ohne eine andere Datei zu lesen (oder der Punkt nennt das Artefakt, in dem der Nachweis steht).

- [ ] [skill-management.consistent-terminology] Drei ID-Schemata kollidieren. Die Rezept-Anforderungen im Template heißen `R-1`/`R-{{n}}`, die Baseline-Kriterien `R-004`/`R-xxx` und die Anforderungen des generischen Artefakts `R1`. In der Baseline-Check-Tabelle stehen `R-{{n}}` und `R-xxx` nebeneinander in benachbarten Spalten. `recipe-plan` und ein menschlicher Leser können ein Kriterium dort leicht für eine Anforderung halten und umgekehrt. → deferred: https://github.com/nolte/claude-goose/issues/10
      Where: `templates/recipe-requirements.template.md:26`, `:32`, `:51`; `references/recipe-question-set.md:73-77`.
      Fix: Den Rezept-Anforderungen ein eigenes Präfix geben (z. B. `RR-1`) und es in Template, Question-Set und `validate` einheitlich verwenden.
      Verify: `grep -nE '\bR-[0-9]' skills/recipe-requirements-elicit/templates/` findet nur noch Baseline-Kriterien.

- [x] [skill-management.time-sensitive] Das Question-Set legt eine Abbildungstabelle fest, die an die Revision `2026-08-02` gebunden ist (`R-004 in 2026-08-02`, `R-003`, `R-010`, `R-007`), und zwar außerhalb eines `## Old patterns`-Abschnitts. Zwei Zeilen vorher sagt dieselbe Datei „never a list baked into this file“. Alle IDs existieren in der aktuellen Revision, und Zeile 69 verlangt eine Bestätigung. Mit der nächsten Baseline-Revision veraltet der Text trotzdem, ohne dass jemand den Skill ändert.
      Where: `references/recipe-question-set.md:59-77`.
      Fix: Die Spalte „Look for“ nur über die Erwartung des Kriteriums formulieren (das tut sie größtenteils schon) und die konkreten IDs in einen gekennzeichneten Unterabschnitt „Known mapping — revision 2026-08-02“ verschieben, oder ganz streichen.
      Verify: Der Haupttext der Datei nennt keine Kriterien-ID mehr, und der Satz in Zeile 60 stimmt mit dem Rest der Datei überein.

### Suggestion

- [ ] [skill-management.evaluation-scenarios] Es gibt kein `examples/` und keine drei Evaluationsszenarien (Prompt, Eingaben, erwartetes Verhalten). `tests/goose-implementation-review/RESULTS.md:708-717` belegt nur den Fail-closed-Pfad; der eigentliche Elicitation-Run ist durch claude-shared #665 blockiert.
      Where: `skills/recipe-requirements-elicit/` (Ordner `examples/` fehlt).
      Fix: `examples/01-new-recipe-elicit.md`, `examples/02-validate-existing.md` und `examples/03-delegate-missing.md` anlegen und in `SKILL.md` mit Ladeauslöser verlinken.
      Verify: `ls skills/recipe-requirements-elicit/examples/` zeigt drei Szenarien, und jedes wird in `SKILL.md` mit „Read … when …“ referenziert.

- [x] [skill-management.operations-vocabulary] Die Operation `validate` ist eine reine Leseprüfung. Für diesen Fall empfiehlt §Operations vocabulary das Lifecycle-Verb `audit` („prefer … `audit` over `validate`“). Dagegen spricht, dass das Delegationsziel `nolte-shared:requirements-elicit` ebenfalls `validate` heißt; der Peer-Abgleich nach `skill-vs-agent` §Portfolio-wide consistency spricht also für den heutigen Namen.
      Where: `SKILL.md:89` (Überschrift `2. validate`).
      Fix: Entweder in `audit` umbenennen, oder `validate` behalten und in einem Satz mit dem Peer-Abgleich begründen.
      Verify: Die Operation heißt `audit`, oder `SKILL.md` §Operations enthält die Begründung.

### Info

- [ ] [spec-driven-development.spec-anchor] Der Spec-Anchor-Check ist formal bestanden: Der Text zitiert `spec/claude/resumable-work/` und ergänzt „in `nolte/claude-shared`“. In einem Consumer-Repo lässt sich der Pfad nicht auflösen, und die Envelope-Regeln, auf die der Text verweist, kann ein Run dort nicht nachlesen. Die eigentliche normative Quelle des Skills ist `baselines/goose/<revision>/` samt Constitution, und das ist kein `spec/...`-Pfad. Spec muss ggf. wachsen: `skill-review` §spec-driven-development kennt nur `spec/...` als Anker und hat keine Form für Plugins, deren normativer Baum anders liegt oder in einem anderen Repo steckt.
      Where: `SKILL.md:3` (description), `SKILL.md:109-111`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.self-contained] Der Skill liest Dateien außerhalb seines Ordners: `${CLAUDE_PLUGIN_ROOT}/baselines/goose/`, `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md` und `${CLAUDE_PLUGIN_ROOT}/process/goose-implementation-review/VERSION.md`. Wörtlich widerspricht das §Structure MUST „self-contained“. Die Baselines sind aber unveränderliche Artefakte, die vier Skills und der Review-Prozess gemeinsam nutzen. Eine Kopie im Skill-Ordner würde genau die Duplizierung erzeugen, die die Constitution ausschließt, und `${CLAUDE_PLUGIN_ROOT}` ist portabel. Auf Anweisung des Operators ist das als Info erfasst. Spec muss ggf. wachsen: Plugin-weite, gemeinsam genutzte Daten unter dem Plugin-Root.
      Where: `SKILL.md:67-71`, `SKILL.md:94-95`; `references/recipe-question-set.md:62-65`.
      Fix: n/a (observation).
      Verify: n/a.

- [x] [skill-management.downstream-works] Die Mindestversion in der Fail-closed-Meldung („v0.1.11 or later“) lässt eine Version zu, mit der die Delegation im Consumer nicht läuft. Bei `v0.1.11` verlangt `requirements-elicit` `spec/project/requirements-elicitation/` im aktuellen Projekt und stoppt, wenn die Spec fehlt. Der Plugin-Root-Fallback kam erst mit claude-shared `92d08204` (#669, 2026-09-25), und kein Tag enthält ihn bisher. `skills/README.md:68` führt #665 noch als „open“, auf GitHub ist das Issue CLOSED. Spec muss ggf. wachsen: Es fehlt eine Regel, wie ein Plugin die Mindestversion für eine Delegation über Plugin-Grenzen angibt und prüft.
      Where: `SKILL.md:55`; `skills/README.md:32`, `:43`, `:68`.
      Fix: n/a (observation). Empfehlung: Nach dem ersten claude-shared-Release mit `92d08204` die Mindestversion an drei Stellen anheben und die README-Zeile aktualisieren.
      Verify: n/a.

- [ ] [skill-agent-catalog.use-case-metadata] `dont_use_when[].alternative` und `see_also[]` nennen `nolte-shared:requirements-elicit` mit Namespace-Präfix. §Use-case metadata verlangt den bloßen Artefaktnamen, auflösbar gegen die konfigurierten Source-Roots desselben Monorepos. Über Repo-Grenzen löst keine der beiden Formen auf. In claude-goose gibt es keinen Katalog-Build, also schlägt heute nichts fehl. Spec muss ggf. wachsen: Eine Form für Verweise über Repo-Grenzen fehlt.
      Where: `SKILL.md:10-17`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-vs-agent.duplicate-prevention] Duplikat-Check. Im Repo (`skills/*/SKILL.md`) überschneidet sich keine Beschreibung: `recipe-plan`, `recipe-implement` und `recipe-audit` sind nachgelagerte Glieder derselben Kette. In claude-shared wurden alle Kandidaten gelesen: `requirements-elicit` (äquivalenter generischer Kern, ausdrücklich delegiert und in `skills/README.md:57` abgegrenzt), `security-requirements-reviewer`, `test-case-extractor`, `kpi-derive` und `implementation-plan-author`. Die letzten vier verarbeiten Anforderungen nur, keiner erhebt sie. Kein Befund; die Abgrenzung ist dokumentiert und spiegelt sich in `dont_use_when`.
      Where: `SKILL.md:3`, `SKILL.md:13-14`; `skills/README.md:55-57`.
      Fix: n/a (observation).
      Verify: n/a.

- [x] [skill-review.info-observation] Die Dimensionen 4 und 5 des Question-Sets (Output shape, Prohibited behaviour) überschneiden sich inhaltlich mit den generischen Dimensionen `acceptance_criteria`, `constraints` und `scope_boundaries` des delegierten Interviews. Fragt der Run sie ohne Blick auf das gerade geschriebene generische Artefakt, kann er gegen die eigene Hard rule verstoßen („Never ask a generic requirements question through this skill's own text“) und denselben Punkt zweimal erfragen. Eine Anweisung, bereits erfasste Antworten aus `project/requirements/<slug>.md` zu übernehmen, fehlt. Spec muss ggf. wachsen: Keine Regel deckt Fragedubletten bei Skill-zu-Skill-Delegation ab.
      Where: `references/recipe-question-set.md:43-55`; `SKILL.md:116`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.multi-model-testing] Es gibt keinen Beleg für Tests mit mehreren Modellen (Haiku/Sonnet/Opus), weder im Skill noch in `RESULTS.md` für diesen Skill.
      Where: `skills/recipe-requirements-elicit/`.
      Fix: n/a (observation).
      Verify: n/a.

## Processing log

<!-- Append one line per item closure: YYYY-MM-DD — <item-shorthand> — <action taken> — verified: <method> -->

- 2026-11-05 — W tag-vocabulary — Tag behalten, Override im Scope — verified: Override-Zeile im ## Scope
- 2026-11-05 — W gotchas — ## Gotchas mit Listing statt Probe, installiert ≠ lauffähig, O-6, Plugin-Root — verified: grep ^## Gotchas trifft, vier Einträge
- 2026-11-05 — W checkpoints — §Resuming a run nennt jedes Freigabe-Gate der Schritte 3–5 — verified: Abschnitt gelesen
- 2026-11-05 — W teach-back — Template-Header `Teach-back`; Schritt 5 und validate Punkt 9 verweisen darauf — verified: grep Teach-back im Template trifft
- 2026-11-05 — W time-sensitive — IDs aus Haupttext entfernt, eigener Abschnitt „Known mapping — revision 2026-08-02“ — verified: grep R-0nn/GAP- trifft nur den Known-mapping-Abschnitt
- 2026-11-05 — S operations-vocabulary — validate behalten, Peer-Abgleich begründet — verified: §Operations 2 gelesen
- 2026-11-05 — I minimum version — Fail-closed-Meldung verlangt Release > v0.1.11; Stop des Ziels an eigener Precondition wird wie fehlende Installation behandelt — verified: Precondition gelesen
- 2026-11-05 — I question duplicates — Schritt 3 übernimmt bereits Erfasstes aus dem generischen Artefakt — verified: Schritt 3 gelesen
- 2026-11-05 — W id prefixes — deferred, MAJOR format change per skills/VERSION.md §Semantics — tracked: https://github.com/nolte/claude-goose/issues/10
