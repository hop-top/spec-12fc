# AI-Enabled CLI: 12-Factor Specification

## Status
Draft

## Purpose
Define design principles for CLI applications intended to be safely and reliably used by both humans and AI agents.

## Definitions

- **Agent**: A system that programmatically interacts with a CLI, capable of planning, retrying, and chaining commands.
- **Structured Output**: Machine-readable output with a stable schema.
- **Idempotency**: Ability to safely repeat an operation without unintended side effects.
- **Preview Mode**: Non-mutating execution that reveals intended effects.

---

## Factor 1: Capability Introspection

### Requirement
The CLI MUST expose its capabilities in a machine-readable format.

### Includes
- Commands and subcommands
- Arguments and flags
- Types and constraints
- Side effects classification
- Safety level (read/write/destructive)

### Rationale
Agents cannot rely on parsing human-oriented documentation.

---

## Factor 2: Intent Clarity

### Requirement
Commands MUST represent domain-level actions with minimal ambiguity.

### Constraints
- Avoid positional ambiguity
- Avoid overloaded semantics
- Prefer explicit naming over brevity when necessary

### Grammar
Commands MUST follow a `noun verb` hierarchy (e.g. `user create`, `image list`, `pod logs`) rather than flat hyphenated verbs (`create-user`) or mixed separators.

Benefits:
- Subcommand trees enable deterministic discovery via `--help` at each level
- Stable naming across the surface reduces inference error
- Mirrors established conventions (`docker container ls`, `gh pr create`, `kubectl pod get`)

### Rationale
Agents perform intent inference; unclear mappings increase error rates. A predictable grammar turns exploration into a tree walk rather than a guess.

---

## Factor 3: Structured I/O

### Requirement
All outputs MUST support a stable, machine-readable format.

### Includes
- Success responses
- Errors
- Warnings
- Progress updates
- Diffs

### Channel discipline
- Structured output (the machine contract) MUST be written to **stdout**.
- Logs, progress, spinners, warnings, and prompts MUST be written to **stderr**.
- A non-empty stdout MUST be parseable as a single document (or stream of documents) of the declared format.
- The CLI MUST accept an opt-in flag to force structured output (e.g. `--json`, `--output json`).
- If a `--quiet` mode is provided, it MUST emit bare values (one per line) suitable for pipe consumption.

### Shape rules
- **Flat over nested**: prefer `{"pod_name": "web-1"}` over deeply nested wrappers when the depth carries no semantics.
- **Type stability**: a given field name MUST hold the same type across every command and every invocation within a schema version (e.g. `age` is always a number, never sometimes a string).
- **Streaming**: when results are unbounded or long-running, the CLI MUST emit JSON Lines (one object per line) rather than buffering a single document.
- **No interleaving**: machine output on stdout MUST NOT be mixed with human-oriented framing (banners, ANSI colors, progress bars).

### Rationale
Automation requires reliable parsing. Channel separation lets agents capture the contract while still surfacing diagnostics; shape discipline keeps downstream parsers from breaking on cosmetic changes.

---

## Factor 4: Corrective Error Model

### Requirement
Errors MUST include corrective guidance.

### Must include
- Error classification
- Likely cause
- Suggested fix
- Alternatives (if applicable)

### Wire format
Structured errors MUST carry:
- A **stable error code** as a string token (e.g. `"image_not_found"`, `"auth_expired"`, `"rate_limited"`) — not a free-form human sentence.
- An **echo of the failing input** (resource id, argument value) so the agent can correlate.
- A **transience class**: `transient` (retry-worthy), `permanent` (do not retry), or `unknown`.
- An optional **suggestion** field with a next command or remediation hint.

Error codes MUST be documented in the capability surface (Factor 1) and versioned (Factor 12). Renaming or removing an error code is a breaking change.

### Rationale
Agents must recover without human intervention. Stable codes enable programmatic branching; transience classes prevent retry storms on permanent failures; echoed input prevents correlation drift across pipelined calls.

---

## Factor 5: Explicit Contracts

### Requirement
Command behavior MUST be explicitly defined.

### Includes
- Idempotency guarantees
- Side-effect classification
- Retry semantics
- Schema versioning
- Partial failure modes

### Rationale
Predictability is critical for automation safety.

---

## Factor 6: Previewability

### Requirement
All mutating operations MUST support preview modes where feasible.

### Includes
- dry-run
- plan
- diff
- explain

### Preview output
Preview output MUST be structured (e.g. a typed diff or plan object) rather than human prose, so agents can decide programmatically whether to proceed.

### Non-interactive execution
A CLI used by agents MUST be runnable end-to-end without a TTY.

- The CLI MUST detect non-interactive stdin/stdout and either:
  - skip confirmation prompts automatically, or
  - fail fast with a structured error directing the caller to pass an explicit confirmation flag.
- Confirmation bypass MUST be available as an explicit flag (e.g. `--yes`, `--no-confirm`, `--force`).
- The CLI MUST NEVER block waiting on interactive input when stdin is not a TTY.

### Rationale
Agents require pre-execution validation, and they cannot answer `y/n` prompts. A CLI that hangs on a confirmation prompt is functionally broken under automation, even if it works for humans.

---

## Factor 7: Idempotency

### Requirement
Operations MUST be idempotent unless explicitly declared non-idempotent in the capability surface (Factor 1).

### Naming
Idempotent operations MUST use declarative verbs: `ensure`, `apply`, `sync`, `set`. Imperative verbs (`create`, `add`) are reserved for cases where re-execution is genuinely an error.

When an imperative verb is unavoidable, the CLI MUST expose `--if-not-exists` (or equivalent) so the agent can opt into idempotent semantics without parsing error output.

### Conflict handling
When a non-idempotent operation encounters an existing resource, the CLI MUST signal the conflict via a distinct exit code (see Factor 11) and a stable error code (see Factor 4), not via a generic failure.

### If not possible
The CLI MUST declare:
- duplication effects
- safe retry strategy

### Rationale
Agents will retry operations under failure conditions. Declarative verbs make retries safe by construction; explicit conflict signaling makes non-idempotent operations recoverable without log-scraping.

---

## Factor 8: State Transparency

### Requirement
All implicit state MUST be inspectable.

### Includes
- active configuration
- authentication context
- environment variables
- derived operational state

### Rationale
Hidden state introduces non-determinism.

---

## Factor 9: Contextual Guidance

### Requirement
The CLI SHOULD provide contextual next-step guidance.

### Includes
- suggested commands
- missing prerequisites
- workflow hints

### Rationale
Agents benefit from embedded operational knowledge.

---

## Factor 10: Delegation Safety

### Requirement
The CLI MUST support safe delegation mechanisms.

### Includes
- scoped permissions
- confirmation policies
- sandboxing
- rate limiting
- policy enforcement

### Rationale
Agents amplify execution scale and risk.

---

## Factor 11: Exit Code Semantics

### Requirement
Process exit codes MUST carry meaningful, stable signal about the outcome of execution.

### Constraints
- Exit code `0` MUST mean full success. Partial success or "no-op success" MUST still be `0`.
- A non-zero exit code MUST NEVER accompany a successful operation.
- A successful exit code MUST NEVER accompany a failed operation (no swallowed errors).
- Exit codes MUST be documented in the capability surface (Factor 1).

### Taxonomy
Failure classes MUST be distinguished via exit code so agents can branch on `$?` before parsing stdout. When a class below is applicable to a given command, the assigned code MUST be used; classes that are inapplicable to the tool need not appear at all.

| Code | Meaning |
|------|---------|
| 0 | success |
| 1 | general / unclassified failure |
| 2 | usage error (bad arguments, unknown flags) |
| 3 | resource not found |
| 4 | permission denied / authentication failure |
| 5 | conflict (resource already exists, version mismatch) |
| 6 | transient / retryable failure (rate limit, timeout) |

Codes above 6 MAY be defined per-tool and MUST appear in the capability surface.

### Interaction with structured errors
Exit code is the **first-line** signal; the structured error code (Factor 4) is the second. Agents are expected to branch on exit code first, then refine with the error code string. The two MUST agree (e.g. exit code `3` and error code `"image_not_found"` should always co-occur).

### Rationale
Agents check `$?` before reading stdout. A CLI that returns `0` on failure breaks every retry loop, every pipeline gate, and every conditional shell construct. A CLI that returns `1` for everything forces agents to parse prose to decide what to do next.

---

## Factor 12: Evolution Guarantees

### Requirement
Machine interfaces MUST evolve predictably.

### Includes
- versioned schemas
- deprecation policies
- backward compatibility guarantees
- capability negotiation

### Rationale
Agents are sensitive to silent breaking changes.

---

## Non-Goals

- Replacing human UX best practices
- Eliminating human-readable output
- Enforcing specific serialization formats

---

## Summary

An AI-enabled CLI is not just a tool interface.
It is a contract for safe, observable, and repeatable execution under uncertainty.

The contract spans three surfaces:
- **Process** (exit codes, channels, TTY behavior) — the first signal an agent reads.
- **Payload** (structured output, typed errors, stable shapes) — the second signal.
- **Semantics** (idempotency, previewability, provenance, evolution) — what the agent can safely build on.

Systems that follow these factors are:
- automatable
- debuggable
- resilient
- delegatable