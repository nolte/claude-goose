---
review-type: skill-review
target: "skills/recipe-implement/SKILL.md"
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
  - slug: spec-driven-development
    revision: "4bff2c8e"
  - slug: skill-agent-catalog
    revision: "6b255f00"
  - slug: skill-agent-naming
    revision: "4ceb6872"
repo-revision: "7c72960fdf48ef7add4af277c4d3d7772f8ffbd7"
created: "2026-11-04"
status: open
---

# Skill Review: recipe-implement

## Scope

Target: `skills/recipe-implement/` (`SKILL.md` mit Frontmatter und Body, 97 Zeilen, ca. 1.300 Tokens; die einzige referenzierte Datei `references/traceability-comments.md`, 58 Zeilen). Kein dispatchter Agent; der Skill delegiert nur an `goose run --recipe <file> --explain`. Zur Einordnung gelesen, aber nicht reviewt: `skills/README.md` (Delimitation Record, Upstream-Abhängigkeiten), `skills/VERSION.md`, `specs/005-recipe-lifecycle-skills/contracts/skill-interfaces.md` und `contracts/recipe-artifacts.md` (der Contract, gegen den die Regeln des Skills geprüft wurden — konsistent), `tests/goose-implementation-review/RESULTS.md` Runs 6–7.
Specs applied: `skill-management`, `skill-vs-agent`, `review-plan`, `skill-review` (revisions recorded in frontmatter), dazu für einzelne Checks `spec-driven-development`, `skill-agent-catalog`, `skill-agent-naming`.
Spec-Override: Specs aus nolte/claude-shared@6b255f00 (canonical en), da claude-goose keine spec/claude/-Bäume führt — auf Anweisung des Operators. Zitierpfade in den Findings beziehen sich auf `spec/claude/<topic>/` bzw. `spec/project/<topic>/` in claude-shared.
Validator: validate_skills.py 1.0.0 (claude-shared 6b255f00)
Validator-Overrides (per `skill-review` §Checks derived from external skill-structure validation, MAY): (1) Warning `[skill-management.tag-vocabulary]` für Tag `goose` unterdrückt — `skill-management` §Tag vocabulary erlaubt per MAY einen neuen Tag, wenn kein Starter-Begriff passt (keiner passt auf Goose), und `skills/README.md` §Validator hält `goose` als bewusst eingeführten Cluster-Tag fest. (2) Suggestion `[skill-management.name-form]` unterdrückt — `spec/claude/skill-agent-naming/` erklärt das Action-Vokabular auf Regelebene für offen (jedes finite Verb), `implement` ist eines; `skills/README.md` §Validator hält dieselbe Entscheidung fest. Beide Overrides sind unten als Info dokumentiert.
Research-plan-implement: Der Skill schreibt getrackten State (die Recipe-Datei), zitiert `spec/claude/research-plan-implement/` aber nicht; das fällt unter das korpusweite Aggregat-Info `[skill-management.rpi-adoption-backlog]` des Validators und wird hier nicht pro Skill erhoben. Die Urteils-Checks (Tier-Passung, Write-Gate-Platzierung, Operator-Gate) greifen erst nach Adoption.
Ohne Finding bestanden: Frontmatter-Grenzen (`name`, `description` 627 Zeichen, dritte Person, Was und Wann), `phase`, Use-case-Felder in der Form, Rationale-Abschnitt mit exakter Überschrift plus Gegen-Dimension, `## Hard rules`, Englisch in Frontmatter und Body, Längen-/Token-Cap, Ein-Hop-Referenzen, Forward-Slash-Pfade, keine MCP-Referenzen, keine zeitgebundenen Aussagen, Konsistenz zwischen `SKILL.md`, Referenzdatei und `contracts/recipe-artifacts.md`.
Narrowing: none.
Explicitly out of scope: runtime behavior of the skill, Vale/markdown style (handled by `task ci`), dispatched agents beyond confirming the orchestration direction (none dispatched).

## Summary

- Critical: 1
- Warning: 4
- Suggestion: 2
- Info: 8

Go/no-go: FAIL — ein offenes Critical (fehlender Spec-Anker).
Next concrete action: Autor ergänzt im Body von `SKILL.md` die Zitierung der Feature-Spec `specs/005-recipe-lifecycle-skills/`, danach die Warnings zu Load-Trigger, Gotchas und Überschreib-Verhalten.

## Findings

### Critical

- [ ] [spec-driven-development.skill-cites-spec] Der Body von `SKILL.md` zitiert keine einzige Spec, die der Skill implementiert — weder einen `spec/...`-Pfad noch die eigene Feature-Spec `specs/005-recipe-lifecycle-skills/` (FR-021–FR-024, `contracts/skill-interfaces.md` §`recipe-implement`); `skills/README.md` ist ein Delimitation Record, keine Spec. Geschwister `recipe-requirements-elicit` zitiert immerhin `spec/claude/resumable-work/`.
      Where: `skills/recipe-implement/SKILL.md:22-97` (gesamter Body); Frontmatter `description` (Zeile 3) ebenfalls ohne Spec-Bezug.
      Fix: Unter der H1 einen Satz ergänzen, der `specs/005-recipe-lifecycle-skills/contracts/skill-interfaces.md` und `contracts/recipe-artifacts.md` als maßgebliche Quelle nennt; da `marketplace.json` `source: "."` das ganze Repo ausliefert, ist der Pfad im Consumer als `${CLAUDE_PLUGIN_ROOT}/specs/005-recipe-lifecycle-skills/...` auflösbar.
      Verify: `grep -n "specs/005-recipe-lifecycle-skills" skills/recipe-implement/SKILL.md` liefert mindestens einen Treffer im Body; die Datei existiert unter dem genannten Pfad.

### Warning

- [ ] [skill-management.load-trigger] Die einzige Referenzdatei wird ohne Inhalt- und Wann-Klausel geladen („Read `references/traceability-comments.md`.“); die Spec verlangt, dass jede Referenz benennt, was die Datei enthält und wann sie zu laden ist.
      Where: `skills/recipe-implement/SKILL.md:59` (Procedure Schritt 1); Rückverweis „as the reference describes“ in Zeile 66.
      Fix: Satz umformulieren zu z. B. „Read `references/traceability-comments.md` before writing, for the provenance-block format and the element-comment rules.“
      Verify: Zeile enthält den Pfad plus eine `when`/`for`-Klausel, die Provenance-Block und Element-Kommentare nennt.

- [ ] [skill-management.gotchas] Kein `## Gotchas`-Abschnitt, obwohl der Skill gegen eine nicht offensichtliche Umgebung arbeitet (Goose-Parser): die nötigen Fakten stehen verstreut in Procedure Schritt 3 (Parser stoppt am ersten Defekt, Fehlererkennung über `Error:`-Präfix), und mehrere fehlen ganz — Precondition 1 prüft nur `PATH`, nicht die in `skills/README.md` §Distribution contract fixierte Version 1.45.0, gegen die das Parser-Urteil verifiziert ist; offen bleibt, ob `Error:` auf stderr landet und ob der Exit-Code ausgewertet wird; Run 6 in `RESULTS.md` hielt fest, dass der erste Bash-Aufruf trotz `Bash(goose:*)` abgelehnt wurde.
      Where: `skills/recipe-implement/SKILL.md:52-55`, `:75-78`; Beleg `tests/goose-implementation-review/RESULTS.md` Run 6.
      Fix: `## Gotchas` ergänzen mit: Versionsbindung 1.45.0 (`goose --version` prüfen, Abweichung melden), stdout und stderr zusammen auf `Error:` prüfen, Parser meldet nur den ersten Defekt, Hinweis auf die einmal abgelehnte Bash-Freigabe.
      Verify: Abschnitt `## Gotchas` existiert und nennt mindestens Versionsbindung und Stream-/Exit-Code-Behandlung.

- [ ] [skill-management.specificity-fragility] Der Fall „Recipe existiert schon am Zielpfad“ ist nicht geregelt, obwohl `use_when` ausdrücklich das Neugenerieren nach Plan-Änderung nennt: Schritt 2 schreibt einfach, ohne Bestätigung und ohne Aussage zu Hand-Edits, und die Hard rule „Never move or rewrite a traceability comment“ steht unaufgelöst neben einer Regeneration, die jeden Kommentar neu schreibt. Für eine destruktive Operation ist die Spec-Regel „be prescriptive for fragile or sequential operations“ verfehlt.
      Where: `skills/recipe-implement/SKILL.md:9` (`use_when`), `:60-68` (Procedure Schritt 2), `:96` (Hard rule).
      Fix: In Preconditions oder Schritt 2 festlegen: existiert die Datei, Diff zum Plan zeigen und vor dem Überschreiben bestätigen lassen; die Hard rule präzisieren auf „außer bei Regeneration aus einem geänderten Plan“.
      Verify: Body nennt den Existiert-schon-Fall mit genau einem Default-Verhalten; Hard rule und `use_when` widersprechen sich nicht mehr.

- [ ] [skill-agent-catalog.cross-plugin-prose-conditional] Die `description` verweist unbedingt auf `nolte-engineering:fullstack-developer`, obwohl `nolte-engineering` keine deklarierte Voraussetzung des Plugins ist (`skills/README.md` §Prerequisites nennt nur `nolte-shared`); die Spec verlangt für Prosa-Verweise auf andere Plugins eine bedingte Formulierung, weil ein Consumer das Plugin evtl. nicht installiert hat. (Der Verweis auf `nolte-shared:pull-request-create` ist dagegen gedeckt, da `nolte-shared` Voraussetzung ist.)
      Where: `skills/recipe-implement/SKILL.md:3` (`description`, letzter Satz).
      Fix: zu „(`nolte-engineering:fullstack-developer`, if installed)“ umformulieren oder den Verweis auf „for code that is not a Goose recipe“ kürzen.
      Verify: `description` enthält keinen unbedingten Verweis auf ein nicht als Voraussetzung deklariertes Plugin.

### Suggestion

- [ ] [skill-management.allowed-tools] Der Skill könnte per MAY `allowed-tools` für genau den Parser-Aufruf deklarieren (z. B. `Bash(goose run --recipe * --explain)`, wie die Claude-Code-Binding von `recipe-audit` es belegt) und den Grant im Body begründen; Run 6 musste den abgelehnten ersten Aufruf erst wiederholen.
      Where: `skills/recipe-implement/SKILL.md:1-20` (Frontmatter), `:69-73`.
      Fix: `allowed-tools` mit dem eng gefassten Muster ergänzen und einen Satz im Abschnitt „What is delegated“ dazu schreiben.
      Verify: Frontmatter trägt das Feld; Body nennt, was der Skill sich vorab genehmigt und warum.

- [ ] [skill-management.evaluation-scenarios] Weniger als drei Evaluations-Szenarien: es gibt kein `examples/`, und `RESULTS.md` hält für diesen Skill zwei Runs fest (6: ready-Plan angenommen; 7: Parser-Ablehnung). Die Verweigerungspfade (Plan `blocked`, Goose fehlt) sind nicht belegt.
      Where: `skills/recipe-implement/` (kein `examples/`); `tests/goose-implementation-review/RESULTS.md` Runs 6–7.
      Fix: drittes Szenario für einen Verweigerungspfad aufnehmen, entweder als `examples/` im Skill (mit Load-Trigger) oder als Run in `RESULTS.md`.
      Verify: mindestens drei Szenarien mit Eingabe und erwartetem Verhalten sind auffindbar.

### Info

- [ ] [skill-review.validator-override] Validator-Warning `[skill-management.tag-vocabulary]` (Tag `goose`) per Override unterdrückt, siehe `## Scope`; Begründung: `skill-management` §Tag vocabulary MAY plus Projektentscheidung in `skills/README.md` §Validator.
      Where: `skills/recipe-implement/SKILL.md:4`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-review.validator-override] Validator-Suggestion `[skill-management.name-form]` (`implement` kein bekanntes Action-Token) per Override unterdrückt, siehe `## Scope`; laut `spec/claude/skill-agent-naming/` ist `SKILL_ACTION_TOKENS` nur ein Oberflächen-Spiegel, kein semantisches Gate. Die Korrektur gehört upstream: `implement` in `SKILL_ACTION_TOKENS` von `scripts/validate_skills.py` aufnehmen.
      Where: `skills/recipe-implement/SKILL.md:2`.
      Fix: n/a (observation) — upstream in nolte/claude-shared.
      Verify: n/a.

- [ ] [spec-driven-development.skill-cites-spec] Spec muss ggf. wachsen: Der Spec-Anchor-Check in `skill-review` und das Akzeptanzkriterium in `spec-driven-development` prüfen literal auf `spec/`; ein Consumer-Plugin mit Spec-Kit-Layout führt seine maßgeblichen Specs unter `specs/NNN-<slug>/`, was `grep "spec/"` nicht trifft. Nach Behebung des Critical oben würde der mechanische Check weiter anschlagen, obwohl die Absicht der Regel erfüllt ist.
      Where: `spec/claude/skill-review/` §Checks derived from spec-driven-development; `spec/project/spec-driven-development/` Acceptance Criteria.
      Fix: n/a (observation) — Kandidat für eine Spec-Erweiterung in claude-shared (zulässige Spec-Wurzeln eines Consumers konfigurierbar machen).
      Verify: n/a.

- [ ] [skill-agent-catalog.alternative-bare-name] Spec muss ggf. wachsen: `dont_use_when[].alternative` trägt `nolte-shared:pull-request-create` plugin-qualifiziert; `skill-agent-catalog` §Use-case metadata verlangt den nackten Namen, weil der Katalog über die Source-Roots eines Monorepos auflöst. Für ein Plugin aus einem anderen Repo ist der qualifizierte Name die einzige eindeutige Form, und claude-goose baut keinen Katalog — die Regel passt auf diesen Fall nicht.
      Where: `skills/recipe-implement/SKILL.md:16`.
      Fix: n/a (observation) — Spec-Erweiterung für repo-übergreifende Alternativen.
      Verify: n/a.

- [ ] [skill-management.self-contained] Precondition 3 verlangt `${CLAUDE_PLUGIN_ROOT}/skills/VERSION.md` — eine Plugin-weite Datei außerhalb des Skill-Ordners —, aber kein Procedure-Schritt liest sie; `lifecycle_version` wird aus dem Plan-Header übernommen. Die Spec kennt nur skill-lokale Assets und keine Plugin-weit geteilten Dateien. Naheliegend wäre, entweder die Plan-`lifecycle_version` gegen `VERSION.md` zu prüfen (Plan unter älterer Lifecycle-Version erkannt) oder die Precondition zu streichen.
      Where: `skills/recipe-implement/SKILL.md:55`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.acceptance-writes-documented] Zwei Lücken in den dokumentierten Schreib-Voraussetzungen: kein Schritt sagt, wie der Plan gewählt wird, wenn mehrere `project/recipes/*/plan.md` existieren oder kein Slug genannt ist; und Schritt 2 schreibt „extension configurations that live in their own files“, obwohl `contracts/recipe-artifacts.md` im Plan-Format kein Feld für solche Dateien und `references/traceability-comments.md` keine Kommentar-Regel für sie vorsieht.
      Where: `skills/recipe-implement/SKILL.md:24`, `:54`, `:67-68`.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-management.evaluation-multi-model] Kein Beleg für Tests über mehrere Modelle; `RESULTS.md` §Feature 005 hält fest: „The model the nested sessions resolved to was not captured“.
      Where: `tests/goose-implementation-review/RESULTS.md` §Feature 005.
      Fix: n/a (observation).
      Verify: n/a.

- [ ] [skill-vs-agent.duplicate-prevention] Kein Duplikat. Im Repo bilden `recipe-plan` → `recipe-implement` → `recipe-audit` eine Kette mit gegenseitigen `dont_use_when`/`see_also`. In claude-shared (alle Plugin-Roots) sind `nolte-engineering:fullstack-developer` (Code gegen erkannten Stack, nicht Goose) und `implementation-plan-author` (plant, schreibt nicht) benachbart und abgegrenzt; cross-plugin liegt ohnehin außerhalb des Duplikat-Checks. Nebenbefund, nicht dieser Skill: die `implementation-plan-author`-Description bei 6b255f00 akzeptiert jetzt „a confirmed requirements-elicit artifact with no issue“ — die `recipe-plan`-Zeile im Delimitation Record und der Upstream-Eintrag #666 in `skills/README.md` sind damit möglicherweise überholt; gehört in den Review von `recipe-plan`.
      Where: `skills/README.md` §Delimitation record, §Upstream dependencies.
      Fix: n/a (observation).
      Verify: n/a.

## Processing log

<!-- Append one line per item closure: YYYY-MM-DD — <item-shorthand> — <action taken> — verified: <method> -->
