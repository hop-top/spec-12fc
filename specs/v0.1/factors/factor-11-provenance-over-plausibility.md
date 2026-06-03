[← Back to README](../README.md)

### 11. Provenance over plausibility

Humans may accept plausible output. Agents need **traceable
output**.

Whenever the CLI returns information that may drive subsequent
actions, it should make provenance available.

#### Why provenance matters for agents

Agents chain outputs into decisions. If command A returns a value
and command B uses that value as input, the agent needs to trust
that the value is accurate. A plausible answer without provenance
is a trap — the agent will confidently make decisions based on
data it cannot verify.

#### What to expose

- where data came from
- when it was fetched
- which resources were consulted
- which version/schema was used
- whether values are cached, inferred, defaulted, or authoritative

If the tool synthesized or inferred anything, that should be
visible too.

#### Example: with and without provenance

Without provenance:

```json
{
  "service": "backend",
  "status": "healthy",
  "version": "v1.2.3",
  "uptime": "48h"
}
```

With provenance:

```json
{
  "service": "backend",
  "status": "healthy",
  "version": "v1.2.3",
  "uptime": "48h",
  "_provenance": {
    "source": "kubernetes-api",
    "cluster": "prod-us-east-1",
    "fetched_at": "2024-03-15T10:30:00Z",
    "cache": "none",
    "schema_version": "v2.1",
    "fields": {
      "status": {
        "source": "health-check-endpoint",
        "last_checked": "2024-03-15T10:29:55Z"
      },
      "uptime": {
        "source": "pod-metadata",
        "precision": "minutes",
        "note": "rounded to nearest hour"
      }
    }
  }
}
```

Now an agent knows the health check is 5 seconds old, the uptime
is approximate, and the data came from a specific Kubernetes
cluster. If it needs higher precision or fresher data, it knows
to re-query.

#### Cached vs authoritative

One of the most common provenance traps: the CLI returns cached
data without saying so.

```json
{
  "result": { "...": "..." },
  "_provenance": {
    "source": "local-cache",
    "cached_at": "2024-03-15T09:00:00Z",
    "ttl_seconds": 3600,
    "refresh_command": "mycli status --no-cache"
  }
}
```

An agent operating in a fast-moving deployment can now decide:
"this data is 90 minutes old, I should refresh before making a
deployment decision."

#### Inferred values

When the CLI fills in defaults or infers values, say so:

```json
{
  "environment": "production",
  "_inferred": {
    "environment": {
      "source": "config-file",
      "path": "~/.myclirc",
      "reason": "no --env flag provided, used default"
    }
  }
}
```

This prevents agents from assuming an explicit choice was made
when the CLI silently applied a default.

**Principle:** downstream automation requires traceability.

[← Safe Delegation](factor-10-safe-delegation.md) | [Evolution Without Surprise →](factor-12-evolution-without-surprise.md)
