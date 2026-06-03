# 12-Factor AI-CLI v0.1

**Status:** Draft
**Last updated:** 2026-06-02

First published version of the 12-Factor AI-CLI specification.

## Files

| File | What |
|------|------|
| [`spec.md`](spec.md) | Full prose specification. Read this first. |
| [`spec.short.md`](spec.short.md) | One-page summary of the twelve factors. |
| [`opencli.md`](opencli.md) | OpenCLI mapping — how each factor surfaces in the CLI manifest. |
| [`factors/why-ai-enabled-clis.md`](factors/why-ai-enabled-clis.md) | Background: why CLIs need a separate spec for AI consumers. |
| [`factors/factor-01-capabilities-over-documentation.md`](factors/factor-01-capabilities-over-documentation.md) | F1 — Capabilities Over Documentation. |
| [`factors/factor-02-intent-over-syntax.md`](factors/factor-02-intent-over-syntax.md) | F2 — Intent Over Syntax. |
| [`factors/factor-03-structured-everything.md`](factors/factor-03-structured-everything.md) | F3 — Structured Everything. |
| [`factors/factor-04-correction-over-rejection.md`](factors/factor-04-correction-over-rejection.md) | F4 — Correction Over Rejection. |
| [`factors/factor-05-contracts-over-conventions.md`](factors/factor-05-contracts-over-conventions.md) | F5 — Contracts Over Conventions. |
| [`factors/factor-06-preview-before-effect.md`](factors/factor-06-preview-before-effect.md) | F6 — Preview Before Effect. |
| [`factors/factor-07-idempotency-by-default.md`](factors/factor-07-idempotency-by-default.md) | F7 — Idempotency By Default. |
| [`factors/factor-08-inspectable-state.md`](factors/factor-08-inspectable-state.md) | F8 — Inspectable State. |
| [`factors/factor-09-guidance-over-help.md`](factors/factor-09-guidance-over-help.md) | F9 — Guidance Over Help. |
| [`factors/factor-10-safe-delegation.md`](factors/factor-10-safe-delegation.md) | F10 — Safe Delegation. |
| [`factors/factor-11-provenance-over-plausibility.md`](factors/factor-11-provenance-over-plausibility.md) | F11 — Provenance Over Plausibility. |
| [`factors/factor-12-evolution-without-surprise.md`](factors/factor-12-evolution-without-surprise.md) | F12 — Evolution Without Surprise. |
| [`examples/workflow.yml`](examples/workflow.yml) | Reference GitHub Actions workflow consuming the conformance Action. |

## Conformance (planned)

A conformance runner will live under `conformance/` once the spec ships
its first tagged release. The executable counterpart already lives at
the repo root as a GitHub Action — see the root [`README.md`](../../README.md).
