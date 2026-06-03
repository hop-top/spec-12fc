[← Back to README](../README.md)

## Why AI-Enabled CLIs

### The shift

Human-first CLI design optimized for memorability, brevity, and
manual discoverability. That worked when the operator was always a
person typing commands.

Now the operator may be an agent — planning, calling, retrying,
observing, and chaining tools. The question changes from:

> **"Can a human use this command well?"**

to:

> **"Can a human _and_ an agent both use this command safely,
> correctly, and repeatedly under uncertainty?"**

### What changes

Traditional CLI design assumes a human who can:

- read prose documentation
- memorize syntax over time
- interpret pretty-printed output
- pause and think before pressing enter
- carry session state in their head
- adapt to breaking changes on the fly

Agents can do none of these things reliably. They need:

- machine-readable self-description
- stable, typed, parseable output
- explicit simulation and preview surfaces
- inspectable state with no hidden context
- versioned schemas and predictable evolution

### The design gap

Most CLIs today are human-only interfaces with an afterthought
`--json` flag bolted on. That's not enough. An AI-enabled CLI is
not a human CLI with better help text. It is a **reliable
operational interface** designed for both humans and agents.

That means optimizing not only for discoverability and ergonomics,
but for:

- **introspection** — what can I do? what will this change?
- **structured interaction** — parseable inputs and outputs
- **retry safety** — idempotent by default
- **correction** — errors as recovery paths, not dead ends
- **provenance** — traceable, attributable outputs
- **controlled delegation** — safety boundaries built in

### The best AI-enabled CLI

The best AI-enabled CLI is not one an LLM can "figure out anyway."
It is one that makes correct use obvious, safe use easy, and
recovery from uncertainty built-in.

The original CLI design ethos taught us how to build tools humans
could learn and trust. The next step is building tools that humans
can **delegate to**. In that world, the quality bar changes. The
interface must explain itself, predict failure modes, surface
state, expose intent, and constrain risk.

An AI-enabled CLI is not just a command runner. It is a **contract
for safe, observable action under uncertainty**.

[Factor 1 — Capabilities Over Documentation →](factor-01-capabilities-over-documentation.md)
