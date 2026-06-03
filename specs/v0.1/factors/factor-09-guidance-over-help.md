[← Back to README](../README.md)

### 9. Guidance over generic help

Human help systems usually answer "how do I use this?" Agent help
systems should also answer **"what should I do next?"**

#### Beyond syntax help

A powerful AI-enabled CLI does not stop at syntax help. It provides
contextual guidance based on the current situation:

- next-best command suggestions
- prerequisite detection
- missing step identification
- workflow hints
- examples tailored to current command/resource/context

This is not chatty hand-holding. It is operational scaffolding.

#### Docs are static. Guidance is situational.

Traditional `--help` output:

```
USAGE: mycli deploy [OPTIONS] <SERVICE> <TAG>

OPTIONS:
  --env         Target environment
  --dry-run     Preview changes
  --force       Skip confirmation
```

Contextual guidance (when the agent runs
`mycli deploy --help --context`):

```json
{
  "command": "deploy",
  "help": "Deploy a service to the specified environment",
  "current_context": {
    "active_env": "staging",
    "auth_scopes": ["deploy:read"],
    "missing_scopes": ["deploy:write"]
  },
  "prerequisites": [
    {
      "check": "auth scope",
      "status": "missing",
      "detail": "You need deploy:write scope",
      "fix": "mycli auth refresh --scope deploy:write"
    }
  ],
  "suggested_workflow": [
    "mycli deploy backend v1.2.3 --env staging --dry-run",
    "mycli deploy backend v1.2.3 --env staging",
    "mycli test run --env staging --suite smoke",
    "mycli deploy backend v1.2.3 --env production --dry-run"
  ],
  "common_patterns": [
    {
      "name": "staged rollout",
      "steps": [
        "deploy to staging",
        "run smoke tests",
        "deploy to production with dry-run",
        "deploy to production"
      ]
    }
  ]
}
```

Now an agent doesn't just know the syntax — it knows the
recommended workflow, that it's missing a required scope, and how
to fix it.

#### Workflow hints

After any command completes, the CLI can include guidance about
what typically comes next:

```json
{
  "status": "success",
  "result": { "...": "..." },
  "next_steps": [
    {
      "command": "mycli test run --env staging",
      "reason": "Verify deployment with smoke tests",
      "priority": "recommended"
    },
    {
      "command": "mycli deploy backend v1.2.3 --env production",
      "reason": "Promote to production after staging verification",
      "priority": "optional"
    }
  ]
}
```

This turns the CLI from a set of isolated commands into a guided
workflow engine.

#### Prerequisite detection

Before a command runs, the CLI can check whether the caller is
set up to succeed:

```json
{
  "preflight": {
    "passed": false,
    "checks": [
      {
        "name": "authentication",
        "status": "pass"
      },
      {
        "name": "target environment exists",
        "status": "fail",
        "fix": "mycli env create production"
      },
      {
        "name": "service registered",
        "status": "pass"
      }
    ]
  }
}
```

An agent runs the preflight, sees the failure, executes the fix,
and retries. Self-healing through guidance.

**Principle:** a good CLI teaches in context, not just in manuals.

[← Inspectable State](factor-08-inspectable-state.md) | [Safe Delegation →](factor-10-safe-delegation.md)
