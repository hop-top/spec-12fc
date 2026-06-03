[← Back to README](../README.md)

### 7. Idempotency by default

Agents retry. Networks flake. Context windows drift. Duplicate
invocations happen.

An AI-enabled CLI should assume commands may be reissued and
should minimize harm when that occurs.

#### Why agents retry more than humans

A human who runs a command and sees it succeed will not run it
again. An agent might — because its context window was truncated,
because it lost track of what already happened, because it was
restarted mid-workflow, or because the orchestrator retried the
entire step.

This is not a bug in the agent. It is normal operating behavior
in agentic systems. The CLI must be designed for it.

#### Read operations: side-effect free

Read operations should be completely side-effect free. Running
`mycli list deployments` ten times should return the same result
each time (given the same state) and change nothing.

This sounds obvious, but CLIs sometimes have side effects in read
operations:

- writing to an audit log on every query
- refreshing a cache destructively
- creating a session or lock file

Audit logging is fine. But the operation itself should be safe to
repeat without consequence.

#### Mutating operations: idempotency strategies

For commands that change state, support idempotency through:

**Idempotency keys:**

```
mycli deploy backend v1.2.3 \
  --idempotency-key deploy-backend-2024-03-15-001
```

If this command is issued twice with the same key, the second call
returns the result of the first without re-executing.

**Safe upserts:**

```
mycli config set log-level debug
```

Running this ten times has the same effect as running it once.

**Deduplication:**

```
mycli invoice create --customer cust_123 \
  --dedup-key invoice-march-2024
```

The CLI detects the duplicate and returns the existing invoice
instead of creating a second one.

#### When idempotency is impossible

When strict idempotency is impossible, the CLI should clearly
expose:

- what may happen on repeated execution
- how to detect duplication
- how to resume safely
- how to roll back or reconcile

```json
{
  "command": "transfer",
  "idempotent": false,
  "on_duplicate": {
    "risk": "double transfer",
    "detection": "check transfer history with --since flag",
    "prevention": "use --idempotency-key flag",
    "recovery": "mycli transfer reverse <transfer-id>"
  }
}
```

An agent reads this and knows to always pass an idempotency key
for transfers. If it doesn't, it knows how to check for duplicates
and how to reverse one.

**Principle:** retry safety is not optional in agentic systems.

[← Preview Before Effect](factor-06-preview-before-effect.md) | [Inspectable State →](factor-08-inspectable-state.md)
