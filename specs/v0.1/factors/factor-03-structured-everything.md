[← Back to README](../README.md)

### 3. Structured everything

A human can interpret pretty text. An agent needs **stable, typed,
parseable output**.

Every command should support machine-readable output by default or
via a consistent mode. JSON is the floor, not the ceiling.

#### What to structure

The structure should include:

- outcome status
- returned entities
- warnings
- errors
- suggested next actions
- provenance
- confidence or uncertainty where relevant

Free-form text can still exist for humans, but it should never be
the only reliable interface.

This applies equally to success, failure, progress, logs, prompts,
and diffs.

#### The problem with pretty output

Here is typical human-friendly output:

```
✓ Deployed backend v1.2.3 to staging
  3 containers updated, 1 restarted
  Health check passed (2.3s)
  Dashboard: https://staging.example.com/deploy/abc123
```

An agent has to regex-parse this to extract the version, container
count, health status, and URL. Every formatting change breaks the
parser.

The same information, structured:

```json
{
  "status": "success",
  "command": "deploy",
  "result": {
    "service": "backend",
    "tag": "v1.2.3",
    "environment": "staging",
    "containers_updated": 3,
    "containers_restarted": 1,
    "health_check": {
      "passed": true,
      "duration_ms": 2300
    },
    "dashboard_url": "https://staging.example.com/deploy/abc123"
  },
  "suggested_next": [
    "deploy backend v1.2.3 --env production",
    "deploy frontend v1.2.3 --env staging"
  ]
}
```

Now an agent can reliably chain this output into its next decision.

#### Structured errors

Errors deserve the same treatment:

```json
{
  "status": "error",
  "command": "deploy",
  "error": {
    "code": "ENV_NOT_FOUND",
    "message": "Environment 'prod' not found",
    "suggestion": "Did you mean 'production'?",
    "valid_values": ["staging", "production", "development"]
  }
}
```

This is actionable. An agent can read the suggestion, pick the
correct value, and retry — no human intervention needed.

#### Consistent output modes

Pick a convention and stick to it:

```
mycli deploy --output json       # structured
mycli deploy --output text       # human-friendly (default)
mycli deploy --output yaml       # alternative structured
```

Or use an environment variable:

```
MYCLI_OUTPUT=json mycli deploy   # all commands honor it
```

The key is consistency. Every command, same flag, same behavior.

**Principle:** anything an agent may need to observe should be
structured.

[← Intent Over Syntax](factor-02-intent-over-syntax.md) | [Correction Over Rejection →](factor-04-correction-over-rejection.md)
