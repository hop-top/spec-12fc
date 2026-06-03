[← Back to README](../README.md)

### 5. Contracts over conventions

Humans can learn conventions. Agents need **contracts they can
rely on**.

Exit codes, schemas, command semantics, idempotency guarantees,
pagination behavior, retry safety, and destructive-action rules
should be explicit and stable. If a command may mutate state, that
should be clearly declared. If it is safe to retry, that should be
declared too.

#### Conventions are implicit; contracts are explicit

A convention: "exit code 0 means success." Everyone knows this.

A contract:

```json
{
  "exit_codes": {
    "0": "success",
    "1": "user error — bad input, missing args",
    "2": "system error — network, permission, timeout",
    "3": "partial success — some items failed",
    "4": "requires human approval — blocked by policy"
  }
}
```

Now an agent doesn't just know success vs failure. It knows _why_
it failed and whether to retry, escalate, or correct input.

#### What to declare as contracts

A CLI for agents must make promises like:

- this output schema is versioned
- this command is read-only
- this action is idempotent
- this command may partially succeed
- this error class is retryable
- this flag is deprecated and until when

#### Example: command contract

```json
{
  "command": "deploy",
  "version": "2.1.0",
  "read_only": false,
  "idempotent": false,
  "retryable": false,
  "partial_success_possible": true,
  "requires_auth": true,
  "auth_scopes": ["deploy:write"],
  "rate_limit": {
    "max_per_minute": 10,
    "retry_after_header": true
  },
  "pagination": {
    "style": "cursor",
    "default_page_size": 50,
    "max_page_size": 200
  },
  "deprecations": [
    {
      "flag": "--env",
      "replacement": "--environment",
      "removal_date": "2026-06-01"
    }
  ]
}
```

An agent reading this contract knows:

- it needs `deploy:write` auth scope
- the command is not safe to retry blindly
- partial success is possible (check each item in results)
- the `--env` flag will stop working on a known date

No guessing. No convention-hunting. No scraping changelogs.

#### Contracts enable automation

When contracts are explicit, agents can build reliable automation:

- **Retry logic** — only retry commands marked `retryable: true`
- **Pagination** — follow cursor-based pagination without hardcoded
  assumptions
- **Auth refresh** — know which scopes to request before calling
- **Deprecation migration** — swap flags before the removal date
- **Partial failure handling** — check individual results when
  `partial_success_possible` is true

**Principle:** predictable contracts beat undocumented norms.

[← Correction Over Rejection](factor-04-correction-over-rejection.md) | [Preview Before Effect →](factor-06-preview-before-effect.md)
