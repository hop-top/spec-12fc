# The 12-Factor CLI, Rewritten for Agents

## Your command-line tool wasn't built for what's about to use it.

When Heroku published the twelve-factor app in 2011, it was a design manifesto disguised as a deployment guide. It told us how to build software that could survive being run at scale, in production, by people who didn't write it. It worked because it was opinionated, testable, and written for a shift in who the operator actually was.

We're in the middle of another shift like that, and most CLI tools haven't noticed.

The operator of a CLI used to be a human at a terminal. Increasingly, it's an agent — planning multi-step operations, retrying on failure, chaining outputs into decisions, running at speeds and scales no human matches. The tools we built for humans are being used, right now, by something that is not a human. And the failure modes are ugly: silent partial failures, duplicate mutations from naive retries, auth expiries that crash long-running plans, ambiguous output that poisons downstream reasoning.

The question has changed from *can a human use this command well?* to:

> **Can a human and an agent both use this command safely, correctly, and repeatedly under uncertainty?**

What follows is twelve factors for CLI design in that world. They aren't about making CLIs "AI-friendly" through clever prompts or wrapper layers. They're about the interface itself — what it exposes, what it promises, what it refuses to do quietly.

---

### 1. Self-describing interfaces

An agent should discover what a CLI can do from the CLI, not from documentation. Commands, arguments, types, defaults, side effects, safety levels — all queryable. `kubectl api-resources` and `kubectl explain` get this right. Most CLIs don't.

### 2. Structured everything

Anything an agent may need to observe must be parseable. Success, errors, warnings, progress, diffs. JSON is the floor. `gh --json` is the pattern to copy. Human-formatted tables that vary by locale are the pattern to avoid.

### 3. Stream and exit discipline

Stdout for structured data. Stderr for humans and logs. Exit codes carry status classes, not just pass/fail. TTY detection switches presentation. `jq` nails this. Tools that dump colors into pipes don't.

### 4. Explicit contracts and recoverable errors

Declare idempotency, side effects, and schema version up front. When things fail, classify the error and — where safe — suggest remediation an agent can act on. `rustc`'s structured errors with machine-applicable fixes are the bar.

### 5. Preview before effect

Every mutating command supports dry-run, plan, or diff, in the same schema as real execution. `terraform plan` is the canonical example. Tools that force you to run a destructive command to see what it'll do are the canonical failure.

### 6. Idempotency and atomicity

Agents retry. Commands fail halfway. Both need handling. Stripe's idempotency keys prevent double-charges on retry. `sqitch`'s per-change commit tracking makes partial migration failures recoverable. Both patterns generalize.

### 7. State and context transparency

Implicit state is agent poison. Active profile, auth identity, effective config, environment — all inspectable in one command. `aws configure list` with source-annotated values is how this should look.

### 8. Safe delegation

Agents run at scale. Unsafe interfaces amplify. Scoped credentials, programmatic confirmation (not TTY prompts — those are useless to agents), sandbox modes, rate limits. Scoped IAM credentials plus guardrails beat root-equivalent tokens every time.

### 9. Observable long-running operations

A ten-minute deploy cannot be observed through a spinner. Structured progress events, job handles, `status` subcommands, defined cancellation semantics. `gcloud`'s operation IDs with separate describe commands are the right shape.

### 10. Provenance and reproducibility

Agents chain outputs into decisions. Outputs need source, timestamp, schema version, cache status — and a clear declaration of what's deterministic. `nix build`'s content-addressed hashes make provenance and reproducibility the same property.

### 11. Evolution without surprise

Machine interfaces must evolve predictably. Versioned schemas, explicit deprecation, capability negotiation. Kubernetes API versioning and Stripe's per-request pinned versions show what mature looks like.

### 12. Auth and credential lifecycle

Credentials are managed state, not ambient facts. Source, scope, expiry, refresh — all queryable, all scriptable. An interactive browser popup for re-auth breaks any headless agent.

---

## The shift underneath

If you read these and thought "most of this is just good API design," you're right. That's the point. The line between a CLI and an API has been blurring for years; agents finish the job.

A CLI that an agent can use well is a CLI with a machine contract. Everything that used to live in docs, convention, and operator intuition now has to live in the interface — because the operator is no longer someone who read the docs.

The original CLI ethos taught us to build tools humans could learn and trust. The next step is building tools humans can delegate to. In that world, the interface itself has to do more of the work — explaining, previewing, constraining, recovering.

An AI-enabled CLI is not a command runner. It is a contract for safe, observable action under uncertainty.

---

*The full spec, with longer examples and the comparison table, lives on my blog. [Link]*

*Found this useful? I'm collecting patterns from CLIs that get specific factors right — send examples.*
