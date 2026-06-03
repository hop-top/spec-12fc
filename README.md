# 12-Factor CLI Conformance

A GitHub Action that verifies a CLI conforms to the [12-Factor AI-CLI specification](specs/v0.1/spec.md), generates a structured JSON report, a shields.io endpoint-badge JSON, and (optionally) SARIF results that annotate the PR diff via GitHub code-scanning.

```yaml
- uses: hop-top/spec-12fc@v1
```

## What it does

- Runs the `kit conformance` gate tree (`verify-no-leak`, `verify-stories`, optional `grade`) against your CLI source.
- Aggregates leaf results into a single `12fc-report.json` with stable schema.
- Builds a per-factor matrix (`12fc-matrix.json`) covering all 12 factors of the spec.
- Generates `.12fc.json` — the shields.io endpoint-badge payload — so a single badge in your README always reflects the latest verdict.
- Emits SARIF and uploads to GitHub code-scanning so individual findings render inline on the PR diff.
- Posts a sticky PR comment with the verdict, leaf-level breakdown, and the first 20 findings.
- Optionally commits the updated badge JSON back to your default branch on `push` events.

## Outputs

| File | Purpose |
|------|---------|
| `12fc-report.json` | Full aggregated report (schema `12fc/v1`) |
| `12fc-matrix.json` | Per-factor pass/fail matrix |
| `.12fc.json` | shields.io endpoint-badge payload |
| `12fc.sarif` | SARIF v2.1.0 results for code-scanning |

## Exit codes

Inherited from `kit conformance`:

| Code | Meaning |
|------|---------|
| 0 | clean |
| 2 | leak detected |
| 3 | usage error |
| 4 | I/O error (retryable) |
| 5 | config error |

The Action fails the job when the aggregate exit code is in `fail-on` (default `2,3,5` — code 4 is excluded so flaky networks don't red-light the build).

## Inputs

See [`action.yml`](action.yml). Defaults are tuned for the common case (PR gate with a sticky comment, no badge commit). For a push-only badge regeneration workflow, set `pr-comment: false` and `commit-badge: true`.

## Badge

After the Action runs at least once on your default branch with `commit-badge: true`, add this to your README:

```markdown
![12fc](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/<owner>/<repo>/main/.12fc.json)
```

The badge colour is verdict-driven: green (pass), red (fail), grey (ungradable / not yet run).

## Example workflow

See [`specs/v0.1/examples/workflow.yml`](specs/v0.1/examples/workflow.yml).

## How factors map to leaves

| Factor | Leaf | Notes |
|--------|------|-------|
| F1 Capability Introspection | `verify-stories` | story-doc presence + shape |
| F2 Intent Clarity | `verify-stories` | grammar / noun-verb check |
| F3 Structured I/O | `grade` | requires service tier |
| F4 Corrective Error Model | `grade` | typed error contract |
| F5 Explicit Contracts | `grade` | side-effect annotations |
| F6 Previewability | `grade` | dry-run discipline |
| F7 Idempotency | `grade` | declarative-verb check |
| F8 State Transparency | `grade` | `status` subcommand probe |
| F9 Contextual Guidance | `verify-stories` | examples + next-steps |
| F10 Delegation Safety | `verify-no-leak` | scenario isolation |
| F11 Exit Code Semantics | `grade` | exit-code taxonomy probe |
| F12 Evolution Guarantees | `verify-stories` | schema version present |

Factors without an active leaf fall back to `skip` in the matrix (grey).

## The spec

The full specification lives in [`specs/v0.1/spec.md`](specs/v0.1/spec.md). This Action is the executable counterpart: every `MUST` in the spec maps to a check the gate enforces.

## License

CC-BY-4.0 for the spec text; MIT for examples and this Action's code.
See [`LICENSE`](LICENSE).
