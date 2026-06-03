# LinkedIn Post

*Format: ~1,300 characters in the main body (LinkedIn sweet spot), link in first comment.*

---

The CLI tools your team relies on were designed for humans at terminals.

They're increasingly being used by AI agents — planning, retrying, chaining commands, running at scales no human matches. And the failure modes are expensive: duplicate mutations from naive retries, silent partial failures, auth expiries that crash long-running plans, ambiguous output that poisons downstream decisions.

I spent the last few weeks writing down what CLI design should look like when the operator might not be human. Twelve factors, inspired by Heroku's twelve-factor app.

The short version:

1. Self-describing interfaces — capabilities queryable, not just documented
2. Structured everything — JSON is the floor for outputs, errors, progress
3. Stream and exit discipline — stdout, stderr, and exit codes each have a job
4. Explicit contracts and recoverable errors — declare semantics, classify failures
5. Preview before effect — every mutating command supports dry-run
6. Idempotency and atomicity — retries are safe, partial failures are recoverable
7. State and context transparency — nothing implicit, everything queryable
8. Safe delegation — scoped authority, programmatic confirmation, bounded damage
9. Observable long-running operations — progress events and job handles, not spinners
10. Provenance and reproducibility — traceable sources, declared non-determinism
11. Evolution without surprise — versioned schemas, explicit deprecation
12. Auth and credential lifecycle — source, scope, expiry all queryable

The line between a CLI and an API has been blurring for years. Agents finish the job.

A CLI that an agent can use well is a CLI with a machine contract. Everything that used to live in docs, convention, and operator intuition now has to live in the interface — because the operator is no longer someone who read the docs.

The full spec, with examples from tools like `kubectl`, `terraform`, `gh`, `gcloud`, `nix`, and `stripe`, is in the first comment 👇

What CLIs have you seen get this right or wrong? Curious what's on your list.

#DevTools #AIEngineering #SoftwareDesign #DeveloperExperience

---

## First comment:
Full spec with side-by-side comparison table: [link to blog]

## Posting notes

- Tuesday or Wednesday morning, 8-10am in your audience's primary timezone
- Don't post links in the main body — LinkedIn throttles reach on posts with external links. Put the link in the first comment.
- Engage with every comment in the first 2 hours
- If a specific factor draws questions, consider a follow-up post on just that factor a week later
