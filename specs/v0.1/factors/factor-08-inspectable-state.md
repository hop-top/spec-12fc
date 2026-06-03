[← Back to README](../README.md)

### 8. State must be inspectable, not implicit

Human users often carry state in their heads. Agents need state
exposed in the system.

Avoid hidden session state, magical cwd-dependent behavior,
undocumented config precedence, or invisible auth context. When
state exists, it should be inspectable and explainable.

#### Hidden state is agent poison

Consider a CLI where behavior silently changes based on:

- which directory you're in
- a `.env` file three levels up
- a config file at `~/.myclirc` that was edited last month
- an environment variable set in a parent shell
- a cached auth token that expired

A human might remember setting these. An agent has no idea any of
this exists. It calls the command, gets unexpected results, and
has no way to diagnose why.

#### Make state queryable

An agent should be able to ask the CLI: "what assumptions are you
currently making?" and get a useful answer.

```
$ mycli status --context
```

```json
{
  "active_profile": "production",
  "environment": "us-east-1",
  "workspace": "acme-corp",
  "auth": {
    "identity": "deploy-bot@acme.iam",
    "method": "service-account",
    "expires_at": "2024-03-15T12:00:00Z",
    "scopes": ["deploy:read", "deploy:write"]
  },
  "config_sources": [
    {
      "path": "/etc/mycli/config.yaml",
      "priority": 1,
      "keys_set": ["default_env", "log_level"]
    },
    {
      "path": "~/.myclirc",
      "priority": 2,
      "keys_set": ["profile", "workspace"]
    },
    {
      "source": "environment",
      "priority": 3,
      "keys_set": ["MYCLI_ENV=us-east-1"]
    }
  ],
  "effective_config": {
    "default_env": "us-east-1",
    "log_level": "info",
    "profile": "production",
    "workspace": "acme-corp"
  },
  "resource_locks": [],
  "pending_operations": []
}
```

Now an agent knows exactly what context it's operating in. If
something goes wrong, it can diagnose the issue — maybe auth is
expired, maybe the wrong profile is active, maybe a config file
is overriding the environment variable.

#### What state to expose

At minimum:

- active profile
- environment
- selected workspace
- auth identity and expiry
- effective config after merges (with source attribution)
- resource locks
- pending operations

#### State inspection as a pre-flight check

Agents should be able to run a state check before any mutating
operation:

```
# Check state, then act
mycli status --context --output json
mycli deploy backend v1.2.3 --env production
```

This is the agent equivalent of a human glancing at their terminal
prompt to confirm they're in the right directory and logged into
the right account.

**Principle:** hidden state is agent poison.

[← Idempotency By Default](factor-07-idempotency-by-default.md) | [Guidance Over Help →](factor-09-guidance-over-help.md)
