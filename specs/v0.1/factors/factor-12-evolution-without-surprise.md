[← Back to README](../README.md)

### 12. Evolution without surprise

Humans can adapt to breaking changes. Agents often fail silently,
repeatedly, and expensively.

AI-enabled CLIs must evolve with strong compatibility discipline.

#### Why this matters more for agents

When a CLI changes a flag name, a human reads the error, updates
their script, and moves on. An agent might:

- fail silently because the flag is now ignored
- retry the same broken command in a loop
- produce corrupted output because a schema field was renamed
- break downstream workflows that depend on exact output structure

The cost of surprise changes in agentic systems is
disproportionately high.

#### What to provide

- **versioned schemas** — output structure tied to a version
- **stable machine modes** — `--output json` always returns the
  same schema within a major version
- **explicit deprecations** — machine-readable deprecation notices
  with timelines
- **migration hints** — tell the caller what changed and how to
  adapt
- **capability negotiation** — let the caller ask "do you support
  feature X?"
- **feature detection** — let the caller discover available
  features at runtime
- **backward compatibility windows** — old behavior available for
  a declared period

#### Versioned output schemas

```
$ mycli deploy --output json --schema-version 2
```

Or via header-style negotiation:

```
$ MYCLI_SCHEMA_VERSION=2 mycli deploy --output json
```

The CLI returns output conforming to schema version 2. When
version 3 is released, existing agents continue to work until
they explicitly upgrade.

#### Machine-readable deprecation

```json
{
  "deprecations": [
    {
      "type": "flag",
      "name": "--env",
      "replacement": "--environment",
      "deprecated_since": "2.0.0",
      "removal_version": "3.0.0",
      "removal_date": "2026-06-01",
      "migration": "Replace --env with --environment in all calls"
    },
    {
      "type": "output_field",
      "name": "server_count",
      "replacement": "instance_count",
      "deprecated_since": "2.3.0"
    }
  ]
}
```

An agent can parse this and either adapt immediately or flag it
for a human to handle before the removal date.

#### Capability negotiation

```
$ mycli --capabilities --version
```

```json
{
  "version": "2.5.0",
  "schema_versions": ["1", "2"],
  "features": [
    "dry-run",
    "idempotency-keys",
    "structured-errors",
    "provenance"
  ],
  "deprecated_features": [
    {
      "name": "legacy-auth",
      "removal_version": "3.0.0"
    }
  ]
}
```

An agent checks this before starting a workflow. If a required
feature is missing, it knows immediately — not three commands
into a multi-step operation.

#### The rule

Do not make an agent scrape changed prose to discover that a flag
moved or a field vanished. Let it detect and adapt intentionally.

The CLI should make change legible.

**Principle:** interfaces for agents must age gracefully.

[← Provenance Over Plausibility](factor-11-provenance-over-plausibility.md)
