# AI-Enabled CLI: 12-Factor Spec

Status: Draft
Purpose: Design principles for CLIs safe/reliable for humans + AI agents.

## Defs

- **Agent**: programmatic CLI consumer; plans, retries, chains commands
- **Structured Output**: machine-readable; stable schema
- **Idempotency**: repeatable without side effects
- **Preview Mode**: non-mutating; shows intended effects

---

## 1. Capability Introspection
MUST expose capabilities machine-readably.
- commands, subcommands, args, flags
- types, constraints, side-effect class
- safety level: read / write / destructive
Why: agents can't parse human docs.

## 2. Intent Clarity
MUST represent domain actions; minimal ambiguity.
- no positional ambiguity
- no overloaded semantics
- explicit > brief when needed
Why: agents infer intent; unclear = errors.

## 3. Structured I/O
All outputs MUST support stable machine-readable format.
- success, errors, warnings, progress, diffs
Why: automation needs reliable parsing.

## 4. Corrective Error Model
Errors SHOULD include corrective guidance.
- classification, likely cause, suggested fix, alternatives
Why: agents must self-recover.

## 5. Explicit Contracts
Command behavior MUST be explicitly defined.
- idempotency guarantees, side-effect class
- retry semantics, schema versioning, partial failure modes
Why: predictability = automation safety.

## 6. Previewability
Mutating ops MUST support preview where feasible.
- dry-run, plan, diff, explain
Why: agents need pre-execution validation.

## 7. Idempotency
Ops SHOULD be idempotent by default.
If not: MUST declare duplication effects + safe retry strategy.
Why: agents retry on failure.

## 8. State Transparency
All implicit state MUST be inspectable.
- active config, auth context, env vars, derived state
Why: hidden state = non-determinism.

## 9. Contextual Guidance
SHOULD provide next-step guidance.
- suggested commands, missing prereqs, workflow hints
Why: agents benefit from embedded ops knowledge.

## 10. Delegation Safety
MUST support safe delegation.
- scoped perms, confirmation policies, sandboxing
- rate limiting, policy enforcement
Why: agents amplify scale + risk.

## 11. Provenance
Outputs SHOULD include provenance metadata.
- data source, timestamp, retrieval method, confidence
Why: agents chain outputs into decisions.

## 12. Evolution Guarantees
Machine interfaces MUST evolve predictably.
- versioned schemas, deprecation policies
- backward compat, capability negotiation
Why: agents break on silent changes.

---

## Non-Goals
- replace human UX
- eliminate human-readable output
- enforce specific serialization formats

## Summary
AI-enabled CLI = contract for safe, observable, repeatable
execution under uncertainty.

Result: automatable, debuggable, resilient, delegatable.
