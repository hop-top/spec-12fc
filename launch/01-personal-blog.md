# 12-Factor AI-Enabled CLI Apps

*The canonical version. Link everything else back here.*

CLI design used to optimize for humans: memorable commands, terse flags, help text you could skim. That ethos built tools we could learn and trust.

The operator has changed. It may still be a person at a terminal, but increasingly it is an agent — planning, invoking, retrying, observing, chaining. The question is no longer "can a human use this command well?" It is:

**Can a human and an agent both use this command safely, correctly, and repeatedly under uncertainty?**

An AI-enabled CLI is not a human CLI with better help text. It is a contract for safe, observable action — one that explains itself, previews its effects, bounds its damage, and ages gracefully. The twelve factors below are what that contract looks like in practice.

---

## 1. Self-describing interfaces

A human can read docs. An agent should discover affordances from the interface itself.

The CLI must expose, in machine-usable form: commands, subcommands, arguments, types, defaults, side-effect classifications, and safety levels. Help text still matters, but structured introspection is primary. Commands should map cleanly to domain actions — one command, one intent — so an agent can infer which invocation fits a goal without parsing prose.

Progressive disclosure in a human CLI means more documentation. In an AI CLI it means queryable self-description.

**Good:** `kubectl api-resources` and `kubectl explain <resource>.<field>` let an agent discover the full resource graph and field schemas without reading the docs site.
**Bad:** CLIs whose only introspection surface is `--help` output written for humans, with capabilities spread across man pages and a website.

---

## 2. Structured everything

Anything an agent may need to observe should be parseable.

Every command should support a machine-readable output mode — covering success responses, errors, warnings, progress events, diffs, and suggested next actions. JSON is the floor. The structure should include outcome status, returned entities, and any uncertainty or confidence the command can report. Free-form text is fine for humans; it should never be the only reliable surface.

**Good:** `gh` exposes `--json` on nearly every read command, with `--jq` for field selection.
**Bad:** `docker ps` emitting a human-formatted table that varies by platform and locale.

---

## 3. Stream and exit discipline

Channels have defined roles. Respect them.

Stdout carries structured data — nothing else. Stderr carries human output, logs, and progress. The exit code carries a machine-readable status class, not just zero-or-nonzero. The CLI detects whether it is attached to a TTY and switches presentation accordingly: colors and tables for humans, stable structured output for pipes and agents.

This is the most commonly botched piece of CLI machine-readability, and the one thing on this list that truly distinguishes a CLI from any other machine interface.

**Good:** `jq` puts JSON on stdout, diagnostics on stderr, and distinguishes "no match" (exit 1) from "parse error" (exit 2).
**Bad:** `npm install` writing progress and warnings to stdout, mixing them with any structured output.

---

## 4. Explicit contracts and recoverable errors

Agents need promises they can rely on, and failures they can act on.

Commands should declare their semantics explicitly: idempotency guarantees, side-effect classification, pagination behavior, retry safety, schema version. When things go wrong, errors should be classified (not just stringified), include likely cause, and — where safe — suggest remediation. "Did you mean," "this flag was renamed to," "this resource no longer exists, closest matches are." An error an agent can act on is worth far more than an error with a stack trace.

Distinguish diagnostic fields (human-readable cause) from actionable fields (structured remediation an agent may auto-apply). The latter needs a safety classification.

**Good:** `rustc` emits structured JSON errors with spans, suggestions, and machine-applicable fixes.
**Bad:** `make` errors that depend on the underlying tool and rarely classify the failure.

---

## 5. Preview before effect

Every state-changing operation should support a way to inspect intended effects before applying them.

Dry run. Plan. Diff. Explain. Cost estimate. Impacted resources. Policy checks. The preview output should use the same schema as real execution, so an agent can validate its plan against the same parser it will use on the result. Preview must not mutate state — including caches, rate-limit budgets, and audit logs where feasible.

This is one of the largest gaps between human UX and agent UX. Humans rely on intuition. Agents need explicit preflight surfaces.

**Good:** `terraform plan` produces a structured diff that `terraform apply` will execute.
**Bad:** `rm -rf` with no preview; `apt upgrade` lists packages but shows no structured diff.

---

## 6. Idempotency and atomicity

Agents retry. Networks flake. Context windows drift. Duplicate invocations happen. And commands fail halfway.

Mutating operations should be idempotent by default, or require an explicit idempotency key, or be gated behind preview-and-confirm. When strict idempotency is impossible, the CLI must declare duplication effects and safe retry strategy.

Atomicity is the other half. When a command fails partway, the CLI must make clear what was committed, what was rolled back, and how to reconcile. Half-applied migrations, half-sent batches, half-deleted resources — this is where agent-induced damage actually happens.

**Good:** Stripe accepts an `Idempotency-Key` so retries return the original result rather than charging twice; `sqitch` tracks per-change commit state so a failed migration leaves a recoverable boundary.
**Bad:** A `curl -X POST` retried after timeout that may double-submit; a failed `rsync` mid-transfer leaving ambiguous partial state.

---

## 7. State and context transparency

Hidden state is agent poison.

All implicit state should be inspectable: active profile, selected workspace, auth identity, effective config after precedence resolution, environment variables in effect, resource locks, pending operations. An agent should be able to ask the CLI "what assumptions are you making right now?" and get a structured answer in a single command.

Context also means forward guidance. After any operation, the CLI should be able to answer "what can I do next from here?" — prerequisites, likely follow-ups, blocked operations. This is not chatty hand-holding; it is operational scaffolding that an agent can query.

**Good:** `aws configure list` shows the fully resolved credential chain, region, and profile — with source annotations per value.
**Bad:** `kubectl` silently using whatever context is active in `~/.kube/config` with no single resolved view.

---

## 8. Safe delegation

An agent operates at high speed and large scale. Unsafe interfaces become far more dangerous in its hands.

Safety must be built into the interface, not left to operator discipline. That means: scoped credentials, read/write separation, confirmation policies that are programmatic rather than TTY prompts, sandbox modes, rate limits, and blast-radius controls. A command that can delete production resources should be hard to invoke accidentally, easy to preview, and impossible to misunderstand.

Confirmation in particular deserves care. A TTY prompt is useless to an agent. Real confirmation is a signed approval, a policy token, or a structured out-of-band handshake — not "are you sure? [y/N]."

**Good:** AWS IAM with scoped credentials plus Service Control Policies — narrow creds cannot exceed scope even if reasoning fails.
**Bad:** A shell with `sudo` and an AWS root key — one typo from catastrophe, with "are you sure? [y/N]" as the last line of defense.

---

## 9. Observable long-running operations

A ten-minute deploy cannot be observed through a spinner.

Any operation that takes meaningful time must expose structured progress — either as events on stderr, or as a job handle with a `status` subcommand. Cancellation semantics must be defined: what happens on SIGINT? Is there cleanup? What state does a cancelled job leave behind? An agent that cannot interrupt safely cannot use the tool safely.

Progress events should carry the same structure as final output: phase, percent complete where meaningful, current step, estimated completion. Not a progress bar.

**Good:** `gcloud` returns an operation ID for long-running work; `gcloud operations describe <id>` returns structured status the agent can poll.
**Bad:** `docker build` streaming mixed progress and log text; `terraform apply` on a large plan blocking the terminal with no structured progress.

---

## 10. Provenance and reproducibility

Agents chain outputs into decisions. Outputs must be traceable and, where possible, reproducible.

Whenever the CLI returns information that may drive subsequent actions, it should expose provenance: data source, fetch timestamp, schema version, whether the value is cached, inferred, defaulted, or authoritative. If the tool synthesized or inferred anything, that fact should be visible.

Reproducibility is the other half. Same inputs, same environment, same output — or explicit declaration of which fields are non-deterministic (timestamps, generated IDs, ordering). An agent that cannot tell reproducible data from volatile data will build fragile chains.

**Good:** `nix build` produces outputs with content-addressed hashes derived from fully-specified inputs; `cargo` with `Cargo.lock` yields bit-identical builds across machines.
**Bad:** `npm install` without a lockfile producing different trees on different days.

---

## 11. Evolution without surprise

Humans adapt to breaking changes. Agents fail silently, repeatedly, and expensively.

Machine interfaces must evolve predictably. Versioned schemas. Explicit deprecation with timelines. Backward compatibility windows. Capability negotiation — the agent declares the schema version it understands, the CLI responds in that version or returns a structured incompatibility error. Feature detection rather than version sniffing.

The goal: an agent written against today's interface can detect exactly what changed tomorrow, rather than discovering it through a chain of silent failures.

**Good:** Kubernetes API versioning (`v1`, `v1beta1`) with explicit conversion and deprecation timelines; Stripe API versions pinned per-request so old clients keep working indefinitely.
**Bad:** A CLI that renames a flag in a minor release and lets downstream automation discover it through broken scripts.

---

## 12. Auth and credential lifecycle

Credentials are not ambient facts. They are managed state.

The CLI must declare where credentials come from (env var, config file, keyring, exchange), what scopes they carry, when they expire, and what happens when they expire mid-operation. Re-authentication must be a structured surface — not an interactive browser popup that blocks a headless agent.

An agent needs to answer, at any moment: *who am I acting as, what am I allowed to do, and how long until that changes?* If the CLI cannot answer, the agent is operating on faith.

**Good:** `gcloud auth print-access-token` and `gcloud auth application-default login` make the credential chain explicit, scriptable, and queryable.
**Bad:** A CLI that silently caches credentials in `~/.config` and fails unpredictably when they expire.

---

## The compact version

1. **Self-describing interfaces** — every affordance discoverable in machine-usable form
2. **Structured everything** — outputs, errors, progress, diffs, all parseable
3. **Stream and exit discipline** — stdout for data, stderr for humans, exit code for status
4. **Explicit contracts and recoverable errors** — stable semantics, classified failures, actionable remediation
5. **Preview before effect** — dry-run, plan, diff, explain, in the same schema as real execution
6. **Idempotency and atomicity** — retries are safe, partial failures are declared and recoverable
7. **State and context transparency** — nothing implicit, everything queryable, next steps included
8. **Safe delegation** — scoped authority, programmatic confirmation, bounded blast radius
9. **Observable long-running operations** — structured progress, job handles, defined cancellation
10. **Provenance and reproducibility** — traceable sources, declared non-determinism
11. **Evolution without surprise** — versioned schemas, capability negotiation, explicit deprecation
12. **Auth and credential lifecycle** — explicit source, scope, expiry, and refresh path

---

## Closing

The original CLI ethos taught us to build tools humans could learn and trust. The next step is building tools humans can delegate to. In that world, the interface itself has to do more of the work — explaining, previewing, constraining, recovering.

An AI-enabled CLI is not a command runner. It is a contract for safe, observable action under uncertainty.

---

*This is the canonical version. Shorter takes live on Medium, LinkedIn, Twitter, Hacker News, and Reddit — all link back here.*
