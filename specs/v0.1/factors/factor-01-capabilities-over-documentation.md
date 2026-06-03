[← Back to README](../README.md)

### 1. Capabilities over documentation

A human can read docs. An agent should be able to **discover
affordances from the interface itself**.

An AI-enabled CLI must expose its capabilities in machine-usable
form: commands, arguments, schemas, defaults, side effects,
constraints, examples, and safety levels. Help text still matters,
but it is secondary to structured introspection.

The CLI should make it easy to answer questions like:

- what can I do?
- what inputs are required?
- what types are accepted?
- what will this command change?
- is it safe to run in dry mode?
- what usually comes next?

In a human CLI, progressive disclosure often means more docs. In
an AI CLI, progressive disclosure means **queryable
self-description**.

#### What this looks like in practice

A traditional CLI might document its capabilities in a man page:

```
USAGE: deploy [OPTIONS] <SERVICE> <TAG>

OPTIONS:
  --env <ENV>       Target environment (default: staging)
  --dry-run         Show what would happen without applying
  --force           Skip confirmation prompts
```

An AI-enabled CLI exposes the same information as structured data:

```json
{
  "command": "deploy",
  "arguments": [
    {
      "name": "service",
      "type": "string",
      "required": true,
      "description": "Service to deploy"
    },
    {
      "name": "tag",
      "type": "string",
      "required": true,
      "description": "Git tag or SHA to deploy"
    }
  ],
  "options": [
    {
      "name": "env",
      "type": "string",
      "default": "staging",
      "enum": ["staging", "production"],
      "description": "Target environment"
    },
    {
      "name": "dry-run",
      "type": "boolean",
      "default": false,
      "side_effects": "none"
    },
    {
      "name": "force",
      "type": "boolean",
      "default": false,
      "safety_level": "destructive"
    }
  ],
  "side_effects": ["deploys code to target environment"],
  "supports_dry_run": true,
  "idempotent": false
}
```

The prose version requires parsing natural language. The structured
version is immediately actionable by an agent — it knows the types,
the defaults, the constraints, and the risk level without guessing.

#### The introspection surface

Consider exposing a dedicated introspection subcommand or flag:

```
mycli --capabilities               # full schema, all commands
mycli deploy --schema              # schema for one command
mycli --capabilities --format json # explicit format
```

This gives both humans and agents a single entry point to discover
everything the CLI can do. No scraping prose. No guessing from
`--help` output.

**Principle:** every meaningful capability should be discoverable
without scraping prose.

[← Why AI-Enabled CLIs](why-ai-enabled-clis.md) | [Intent Over Syntax →](factor-02-intent-over-syntax.md)
