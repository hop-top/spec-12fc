[← Back to README](../README.md)

### 6. Preview before effect

Humans can pause and think before pressing enter. Agents need
built-in support for **simulation, preview, and explainability**.

Every state-changing operation should support a way to inspect
intended effects before applying them.

#### Why this matters more for agents

This is one of the biggest differences between human UX and agent
UX. Humans rely on intuition and context. They read the command,
think about it, maybe check the docs. Agents don't have that
luxury. They need explicit preflight surfaces.

An agent operating at speed and scale can issue dozens of mutating
commands in seconds. Without preview, there is no checkpoint
between "the agent decided to do X" and "X happened."

#### What to support

- **dry run** — execute logic, show effects, apply nothing
- **plan** — show the full set of changes before applying
- **diff** — show what would change vs current state
- **preview** — render the outcome without committing
- **explain** — describe _why_ this command would do what it does
- **cost estimate** — show resource/billing impact
- **impacted resources** — list what would be touched
- **policy checks** — show whether the action passes org policies

#### Structured preview output

A `--dry-run` flag that prints human text is a start. But for
agents, the preview should be structured:

```json
{
  "dry_run": true,
  "command": "deploy",
  "would_affect": {
    "services": ["backend"],
    "environments": ["production"],
    "containers": 3
  },
  "changes": [
    {
      "resource": "backend-pod-1",
      "current": "v1.2.2",
      "proposed": "v1.2.3",
      "action": "update"
    },
    {
      "resource": "backend-pod-2",
      "current": "v1.2.2",
      "proposed": "v1.2.3",
      "action": "update"
    }
  ],
  "policy_check": {
    "passed": true,
    "rules_evaluated": 4
  },
  "estimated_duration_seconds": 120,
  "reversible": true,
  "rollback_command": "mycli rollback backend --to v1.2.2"
}
```

An agent can now:

1. Read the preview
2. Decide whether to proceed (or ask a human)
3. Know exactly what will change
4. Know how to undo it if something goes wrong

#### The preview-then-apply pattern

A common pattern is to separate preview and apply into two steps:

```
# Step 1: preview
mycli deploy backend v1.2.3 --env production --dry-run

# Step 2: apply (if preview looks good)
mycli deploy backend v1.2.3 --env production --confirm
```

Or with a plan ID for consistency:

```
# Generate a plan
mycli deploy backend v1.2.3 --env production --plan
# => plan_id: plan_abc123

# Apply the exact plan
mycli apply plan_abc123
```

This ensures the agent applies exactly what it previewed, even if
state changed between the two calls.

**Principle:** do not force execution to discover consequences.

[← Contracts Over Conventions](factor-05-contracts-over-conventions.md) | [Idempotency By Default →](factor-07-idempotency-by-default.md)
