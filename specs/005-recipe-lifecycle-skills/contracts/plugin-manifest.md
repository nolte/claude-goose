# Contract: Plugin Manifest

**Feature**: `005-recipe-lifecycle-skills` | **Date**: 2026-09-24

How this repository is declared as a Claude Code plugin, and what the declaration promises.

## `.claude-plugin/plugin.json`

```json
{
  "name": "nolte-goose",
  "description": "Goose recipe lifecycle: requirements, plan, implementation and audit against a pinned, source-backed baseline. Requires Goose 1.45.0 and the nolte-shared plugin.",
  "author": { "name": "nolte", "url": "https://github.com/nolte" },
  "repository": "https://github.com/nolte/claude-goose",
  "homepage": "https://github.com/nolte/claude-goose"
}
```

- **No `version` field.** `OMISSIONS.md` §Version-bearing files records that the repository has none
  and the tag is the version; a `version` here would make the record false (research `R1`).
  Consumers pin by git tag. The semver of the lifecycle lives in `skills/VERSION.md` (research `R14`),
  which states a process version, not a release version, like the two `VERSION.md` files that
  already exist under that record.
- **`name` is the skill namespace.** Every skill routes as `/nolte-goose:<name>`. Renaming it is a
  breaking change for every consumer's call sites (`spec/claude/plugin-scoping/` §Namespace).
- **The plugin root is the repository root.** `${CLAUDE_PLUGIN_ROOT}/process/` and
  `${CLAUDE_PLUGIN_ROOT}/baselines/` are therefore the trees the audit skill uses. No copy is made.

## `.claude-plugin/marketplace.json`

```json
{
  "name": "nolte-goose",
  "owner": { "name": "nolte" },
  "metadata": { "description": "Goose recipe lifecycle skills and the review process they audit against." },
  "plugins": [
    {
      "name": "nolte-goose",
      "source": ".",
      "description": "Goose recipe lifecycle: requirements, plan, implementation and audit against a pinned, source-backed baseline. Requires Goose 1.45.0 and the nolte-shared plugin."
    }
  ]
}
```

## Installing the plugin

The form a consumer uses, shown in the repository's root `README.md` §Usage — a GitHub repository,
never a local path. It is deliberately **not** in `skills/README.md`: the portability guard's first
check rejects this repository's name anywhere under `skills/`, and the install command must name
it (measured on the first guard run over `skills/`; analysis U1 had placed the command there).
Commands verified per research R13:

```sh
claude plugin marketplace add nolte/claude-goose
claude plugin install nolte-goose@nolte-goose
```

The quickstart may add the marketplace from a working copy instead; that form is for verifying this
repository, not for consumers.

## Distribution contract

Recorded here because `spec/claude/plugin-scoping/` requires the concrete difference to be named
where the unit is described, and `skills/README.md` repeats it:

| Property | Value |
|---|---|
| Consumer audience | Repositories that author Goose recipes |
| Runtime requirement | Goose 1.45.0 on `PATH`; the Claude Code CLI for the audit |
| Prerequisite plugin | `nolte-shared` at the release recorded in `skills/README.md`; absence fails closed |
| Release cadence | This repository's own tags; independent of claude-shared's |

The difference from every claude-shared plugin is the runtime requirement. Topic is not cited.

## What the plugin must not contain

- A skill whose name exists in any claude-shared plugin (spec `FR-008`).
- A skill that performs generic work a named shared capability owns (spec `FR-005`).
- Any repository-specific value under `skills/`; the portability guard's three checks are extended
  to that tree (spec `FR-027`).
