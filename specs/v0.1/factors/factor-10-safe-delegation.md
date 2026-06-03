[← Back to README](../README.md)

### 10. Safe delegation over raw power

An agent can operate at high speed and large scale, which makes
unsafe interfaces much more dangerous.

AI-enabled CLIs should encode safety boundaries directly.

#### Speed multiplies risk

A human might accidentally delete one resource. An agent in a loop
might delete a hundred before anyone notices. The same power that
makes agents useful makes them dangerous when safety is not built
into the interface.

The CLI should not assume the caller is careful just because the
caller is sophisticated. Quite the opposite.

#### What to build in

- **read vs write separation** — clearly distinguish commands that
  observe from commands that mutate
- **confirmation policies** — require explicit `--confirm` for
  destructive actions, not just absence of `--dry-run`
- **scoped credentials** — support auth tokens with minimal
  permissions
- **approval gates** — high-stakes commands can require out-of-band
  approval before execution
- **policy-aware execution** — check org-level policies before
  running
- **sandbox modes** — execute against a simulated environment
- **rate and blast-radius controls** — limit how many resources a
  single invocation can affect

#### Confirmation policies

Instead of a generic "are you sure?" prompt (which an agent can't
answer), use structured confirmation:

```
# This requires --confirm because it's destructive
$ mycli delete-environment production
```

```json
{
  "status": "blocked",
  "reason": "destructive_action_requires_confirmation",
  "action": "delete-environment",
  "target": "production",
  "impact": {
    "resources_affected": 47,
    "data_loss": true,
    "reversible": false
  },
  "to_proceed": "mycli delete-environment production --confirm",
  "alternative": "mycli delete-environment production --dry-run"
}
```

An agent reads this, understands the impact, and can either
proceed with `--confirm` (if authorized) or escalate to a human.

#### Blast-radius controls

```
# Limit the scope of bulk operations
mycli cleanup stale-resources \
  --max-items 10 \
  --older-than 30d \
  --dry-run
```

The `--max-items` flag prevents an agent from accidentally deleting
everything. The `--older-than` flag adds a time-based safety net.
Combined with `--dry-run`, the agent can preview the full impact
before committing.

#### Safety levels in metadata

Expose the risk level of every command:

```json
{
  "commands": [
    {
      "name": "list",
      "safety": "safe",
      "mutates": false
    },
    {
      "name": "deploy",
      "safety": "moderate",
      "mutates": true,
      "reversible": true
    },
    {
      "name": "delete-environment",
      "safety": "destructive",
      "mutates": true,
      "reversible": false,
      "requires_confirmation": true
    }
  ]
}
```

An agent can now implement a simple policy: run `safe` commands
freely, request human review for `moderate` commands, and require
explicit human approval for `destructive` commands.

A command that can delete production resources should be hard to
invoke accidentally, easy to preview, and impossible to
misunderstand.

**Principle:** delegation multiplies risk, so safety must be
built in.

[← Guidance Over Help](factor-09-guidance-over-help.md) | [Provenance Over Plausibility →](factor-11-provenance-over-plausibility.md)
