[← Back to README](../README.md)

### 2. Intent over syntax

Humans tolerate memorizing syntax. Agents perform better when the
CLI reflects **clear intent boundaries**.

Commands should represent meaningful operations, not parser
convenience. Flags and subcommands should map to real concepts in
the domain. Ambiguous positional arguments, overloaded semantics,
and hidden mode switches should be minimized.

#### The problem with syntax-first design

Consider a CLI where deployment behavior changes based on subtle
flag combinations:

```
mycli run --target prod --mode fast --skip-checks
```

An agent seeing this for the first time has to reason about what
`--mode fast` means in combination with `--skip-checks`. Is it
safe? Is it destructive? The intent is buried in syntax.

Compare with:

```
mycli deploy-to-production --fast
mycli deploy-to-staging
```

Now the intent is the command itself. An agent can infer:

- what the user is trying to accomplish
- which command is the best fit
- which parameters are missing
- which choices are optional versus dangerous

#### Domain modeling in commands

A good AI-enabled CLI lets an agent map user goals to commands
without ambiguity:

```
# Bad: overloaded verb, behavior depends on flags
mycli process --type=invoice --action=send --target=customer

# Good: domain action is the command
mycli invoice send <customer-id>
```

```
# Bad: positional args with unclear semantics
mycli transfer 500 USD acc_123 acc_456

# Good: named, explicit
mycli transfer --amount 500 --currency USD \
               --from acc_123 --to acc_456
```

The second form in each pair reduces the distance between goal and
invocation. An agent doesn't have to guess argument order or infer
meaning from position.

#### Intent signals for agents

Beyond clear command names, the CLI can declare intent metadata:

```json
{
  "command": "invoice send",
  "intent": "send_invoice_to_customer",
  "domain": "billing",
  "mutates": true,
  "reversible": false,
  "requires_confirmation": true
}
```

This lets an agent reason about _what a command means_ without
parsing its name as English. The `mutates` and `reversible` fields
tell the agent whether to proceed cautiously or request human
approval.

**Principle:** model domain actions explicitly, not just shell
grammar.

[← Capabilities Over Documentation](factor-01-capabilities-over-documentation.md) | [Structured Everything →](factor-03-structured-everything.md)
