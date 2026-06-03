# CLI Capability Schema Standard
## A machine-readable contract for AI-enabled CLIs

## Status
Draft v0.1

## Goal

Define a portable, machine-readable schema for command-line interfaces so that humans, scripts, and AI agents can reliably:

- discover capabilities
- understand arguments and types
- detect safety and side effects
- preview changes
- parse outputs
- recover from errors
- evolve across versions

This aims to be to CLIs what OpenAPI is to HTTP APIs.

---

## Design Principles

1. **Human and machine duality**  
   The schema must support both documentation and automation.

2. **Stable contracts**  
   Agents should not need to scrape prose help output.

3. **Safety awareness**  
   Mutation, destructiveness, and retryability must be explicit.

4. **Composable execution**  
   Commands should declare inputs, outputs, and next-step affordances.

5. **Versioned evolution**  
   Breaking changes must be detectable.

---

## Top-Level Schema Shape

```json
{
  "schema_version": "clispec/v1",
  "cli": {
    "name": "mycli",
    "version": "1.4.2",
    "description": "Example AI-enabled CLI",
    "homepage": "https://example.com/mycli"
  },
  "capabilities": {
    "introspection": true,
    "json_output": true,
    "dry_run": true,
    "explain": true,
    "schema_negotiation": true
  },
  "global_options": [],
  "commands": [],
  "errors": [],
  "output_schemas": []
}
```

---

## Top-Level Fields

### `schema_version`
Version of the CLI schema standard itself.

Example:
```json
"schema_version": "clispec/v1"
```

### `cli`
Metadata about the CLI.

Fields:
- `name`
- `version`
- `description`
- `homepage`
- `default_output_mode`
- `supports_noninteractive`

Example:
```json
{
  "name": "mycli",
  "version": "1.4.2",
  "description": "Deployment and operations CLI",
  "homepage": "https://example.com/mycli",
  "default_output_mode": "text",
  "supports_noninteractive": true
}
```

### `capabilities`
Declares global interface guarantees.

Fields may include:
- `introspection`
- `json_output`
- `yaml_output`
- `dry_run`
- `plan`
- `diff`
- `explain`
- `idempotency_keys`
- `context_inspection`
- `schema_negotiation`

---

## Command Object

Each command must be represented explicitly.

```json
{
  "name": "deploy",
  "path": "deploy",
  "summary": "Deploy an application version",
  "description": "Deploys a version to a target environment",
  "aliases": ["dp"],
  "category": "release",
  "examples": [],
  "input": {},
  "execution": {},
  "output": {},
  "guidance": {},
  "deprecation": null
}
```

---

## Command Fields

### Identity
- `name`: leaf command name
- `path`: full invocation path
- `summary`
- `description`
- `aliases`
- `category`

### Examples
Human-readable and machine-usable examples.

```json
[
  {
    "description": "Deploy version 1.2.0 to production",
    "command": "mycli deploy --env prod --version 1.2.0",
    "safe_to_run": false
  }
]
```

---

## Input Definition

The `input` object defines arguments, flags, env vars, stdin behavior, and validation.

```json
{
  "arguments": [],
  "options": [],
  "environment": [],
  "stdin": {
    "supported": false,
    "format": null
  }
}
```

### Positional Arguments

```json
{
  "name": "resource_id",
  "type": "string",
  "required": true,
  "description": "Identifier of the resource"
}
```

### Options / Flags

```json
{
  "name": "env",
  "long": "--env",
  "short": "-e",
  "type": "string",
  "required": true,
  "description": "Target environment",
  "enum": ["dev", "staging", "prod"],
  "default": "dev"
}
```

### Supported Types

Minimum baseline:
- `string`
- `integer`
- `number`
- `boolean`
- `array`
- `object`
- `enum`
- `file`
- `path`
- `duration`
- `uri`

### Validation Metadata

```json
{
  "min": 1,
  "max": 100,
  "pattern": "^[a-z0-9-]+$"
}
```

---

## Execution Contract

The `execution` section is the core of agent operability.

```json
{
  "mode": "write",
  "side_effects": ["service_restart"],
  "destructive": false,
  "idempotent": false,
  "retry_safe": false,
  "partial_failure_possible": true,
  "supports_dry_run": true,
  "supports_plan": true,
  "supports_diff": false,
  "supports_explain": true,
  "timeout_hint_seconds": 120
}
```

### Recommended `mode` values
- `read`
- `write`
- `delete`
- `admin`
- `mixed`

### Required Semantics
- `idempotent`: safe repeated result
- `retry_safe`: can be retried after uncertain failure
- `destructive`: may irreversibly remove or damage state
- `partial_failure_possible`: some sub-operations may succeed while others fail

---

## Output Contract

The `output` section defines schemas and output channels.

```json
{
  "supports": ["text", "json"],
  "default": "text",
  "stdout_schema_ref": "#/output_schemas/deploy_result",
  "stderr_schema_ref": "#/output_schemas/error_result",
  "provenance": {
    "available": true,
    "fields": ["source", "timestamp", "cache"]
  }
}
```

### Output Schema Example

```json
{
  "name": "deploy_result",
  "type": "object",
  "properties": {
    "status": { "type": "string" },
    "deployment_id": { "type": "string" },
    "warnings": {
      "type": "array",
      "items": { "type": "string" }
    },
    "next": {
      "type": "array",
      "items": { "type": "string" }
    }
  },
  "required": ["status"]
}
```

---

## Error Contract

Errors must be structured, classifiable, and recoverable.

```json
{
  "code": "unknown_flag",
  "category": "input",
  "message": "Unknown flag: --envr",
  "retryable": false,
  "suggestions": ["--env"],
  "docs_url": "https://example.com/docs/errors#unknown_flag"
}
```

### Required Error Fields
- `code`
- `category`
- `message`
- `retryable`

### Recommended Fields
- `suggestions`
- `missing_fields`
- `conflicts_with`
- `docs_url`
- `safe_alternative`

### Error Categories
- `input`
- `auth`
- `permission`
- `network`
- `rate_limit`
- `timeout`
- `conflict`
- `not_found`
- `internal`
- `policy`

---

## Guidance Contract

A CLI should not only report outcomes. It should guide next actions.

```json
{
  "next_steps": [
    {
      "description": "Check deployment status",
      "command": "mycli deploy:status --id dep_123",
      "priority": "high"
    }
  ],
  "related_commands": ["logs", "rollback"]
}
```

---

## Context Inspection

The CLI should expose current effective state.

```json
{
  "context": {
    "environment": "prod",
    "profile": "default",
    "user": "agent-service",
    "workspace": "acme",
    "config_sources": [
      "~/.config/mycli/config.yaml",
      "ENV",
      "./.mycli.local"
    ]
  }
}
```

---

## Introspection Endpoints

A compliant CLI should expose some combination of:

- `mycli inspect`
- `mycli inspect --json`
- `mycli inspect commands`
- `mycli inspect command deploy`
- `mycli context`
- `mycli errors --json`

### Minimum Requirement
At least one stable command that returns the full capability graph in JSON.

---

## Schema Negotiation

The CLI must support machine interface versioning.

Example:
```bash
mycli inspect --schema clispec/v1
mycli deploy --output json --schema output/v2
```

### Rules
- breaking changes require version bump
- deprecated fields must be announced
- removed fields should have migration hints

---

## Compliance Levels

### Level 0 — Human-only
- no structured introspection
- text-first help only

### Level 1 — Machine-readable
- JSON output
- command metadata available

### Level 2 — Agent-safe
- execution contract
- error guidance
- dry-run / plan
- context inspection

### Level 3 — Agent-native
- schema negotiation
- provenance
- next-step guidance
- explicit retry/idempotency semantics

---

## Example Full Command Definition

```json
{
  "name": "delete",
  "path": "project delete",
  "summary": "Delete a project",
  "description": "Deletes a project by ID",
  "aliases": [],
  "category": "project",
  "examples": [
    {
      "description": "Preview project deletion",
      "command": "mycli project delete --id prj_123 --dry-run",
      "safe_to_run": true
    }
  ],
  "input": {
    "arguments": [],
    "options": [
      {
        "name": "id",
        "long": "--id",
        "type": "string",
        "required": true,
        "description": "Project identifier"
      },
      {
        "name": "dry_run",
        "long": "--dry-run",
        "type": "boolean",
        "required": false,
        "default": false,
        "description": "Preview deletion without applying it"
      }
    ],
    "environment": [],
    "stdin": {
      "supported": false,
      "format": null
    }
  },
  "execution": {
    "mode": "delete",
    "side_effects": ["resource_removal"],
    "destructive": true,
    "idempotent": true,
    "retry_safe": true,
    "partial_failure_possible": false,
    "supports_dry_run": true,
    "supports_plan": false,
    "supports_diff": false,
    "supports_explain": true
  },
  "output": {
    "supports": ["text", "json"],
    "default": "text",
    "stdout_schema_ref": "#/output_schemas/delete_result",
    "stderr_schema_ref": "#/output_schemas/error_result",
    "provenance": {
      "available": true,
      "fields": ["timestamp"]
    }
  },
  "guidance": {
    "next_steps": [],
    "related_commands": ["project list", "project restore"]
  },
  "deprecation": null
}
```

---

## Reference Command Set Recommendation

To maximize agent compatibility, every AI-enabled CLI should ideally expose:

- `inspect`
- `context`
- `version`
- `errors`
- `doctor`

Suggested behaviors:

### `inspect`
Returns command graph and schemas.

### `context`
Returns effective runtime context.

### `doctor`
Checks auth, config, connectivity, and schema compatibility.

### `errors`
Lists known error codes and meanings.

---

## Security Considerations

The schema must not leak secrets.

Do not expose:
- secret values
- auth tokens
- raw credentials
- sensitive internal config contents

It may expose:
- auth identity
- active profile
- secret source names
- secret presence status

---

## Open Questions

- Should stdin schemas be first-class and versioned separately?
- Should workflow graphs be represented directly?
- Should command-level cost estimates be standardized?
- Should confidence or uncertainty fields be included for inference-heavy tools?

---

## Summary

A CLI capability schema should make the interface self-describing, contract-driven, and safe to delegate. The main outcome is simple:

Agents should not have to guess.