[← Back to README](../README.md)

### 4. Correction over rejection

Traditional CLIs stop at "invalid input." AI-enabled CLIs should
try to **repair the path forward**.

When input is wrong, incomplete, outdated, or ambiguous, the CLI
should not merely fail. It should explain what was likely intended
and offer safe correction paths.

#### Dead-end errors vs recovery paths

A traditional CLI:

```
$ mycli deploy --env prod
Error: unknown environment 'prod'
```

An AI-enabled CLI:

```json
{
  "status": "error",
  "error": {
    "code": "UNKNOWN_ENVIRONMENT",
    "input": "prod",
    "message": "Environment 'prod' not found",
    "corrections": [
      {
        "suggestion": "production",
        "confidence": 0.95,
        "command": "mycli deploy --env production"
      }
    ]
  }
}
```

The agent reads the correction, sees 95% confidence, and retries
with the right value. No human needed. No guessing.

#### Types of correction

A good AI-enabled CLI covers these patterns:

- **"did you mean…"** — fuzzy match on typos
- **"this flag was renamed to…"** — migration from deprecated
  syntax
- **"you are missing X; here are valid ways to provide it"** —
  incomplete input with enumerated options
- **"this resource no longer exists; here are the closest
  matches"** — stale references
- **"this operation is blocked in current mode; here is the safe
  alternative"** — context-aware redirection

#### Structured corrections

Every correction should be machine-actionable:

```json
{
  "corrections": [
    {
      "type": "flag_renamed",
      "old": "--env",
      "new": "--environment",
      "deprecated_until": "2026-01-01",
      "corrected_command": "mycli deploy --environment production"
    }
  ]
}
```

An agent can parse this, apply the correction, and continue
without breaking its workflow. A human sees the same information
formatted as a helpful message.

#### This is not about hiding errors

Correction is not error suppression. The error happened. The CLI
acknowledges it. But instead of leaving the caller at a dead end,
it provides a concrete path forward.

For agents especially, the difference between "command failed" and
"command failed, here's what to do instead" is the difference
between a stuck workflow and a self-healing one.

**Principle:** errors should be machine-actionable opportunities,
not dead ends.

[← Structured Everything](factor-03-structured-everything.md) | [Contracts Over Conventions →](factor-05-contracts-over-conventions.md)
