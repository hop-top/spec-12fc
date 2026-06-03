# Twitter / X Thread

*Format: 14 tweets. Numbered for pacing. First tweet is the hook — everything else earns the scroll.*

---

**1/**

Your CLI wasn't designed for what's about to use it.

The operator used to be a human at a terminal. Now it's an agent — retrying, chaining, running at scales no human matches.

12 factors for CLI design in that world 🧵

---

**2/**

The question changed.

Not: "can a human use this command well?"

But: "can a human AND an agent both use this safely, correctly, and repeatedly under uncertainty?"

Those are different design problems.

---

**3/ Self-describing interfaces**

An agent should discover what a CLI can do from the CLI, not the docs.

`kubectl api-resources` + `kubectl explain` = ✅
`--help` + a website + tribal knowledge = ❌

---

**4/ Structured everything**

Success, errors, warnings, progress, diffs — all parseable.

JSON is the floor, not the ceiling.

`gh --json` on every read command = ✅
`docker ps` human-formatted tables = ❌

---

**5/ Stream and exit discipline**

The one that's CLI-specific:

• stdout = structured data
• stderr = humans & logs
• exit code = status class
• TTY detection switches format

`jq` nails this. Most tools dump colors into pipes.

---

**6/ Explicit contracts and recoverable errors**

Declare idempotency, side effects, schema version.

When errors happen: classify them, suggest fixes an agent can act on.

`rustc` emits structured errors with machine-applicable fixes. That's the bar.

---

**7/ Preview before effect**

Every mutating command: dry-run, plan, or diff — in the same schema as real execution.

`terraform plan` → `terraform apply` is the canonical pattern.

"Run it and find out" is the canonical failure.

---

**8/ Idempotency and atomicity**

Agents retry. Commands fail halfway.

Stripe's idempotency keys prevent double-charges.
`sqitch` makes partial migration failures recoverable.

Both patterns generalize. Most CLIs implement neither.

---

**9/ State and context transparency**

Hidden state is agent poison.

Active profile, auth identity, effective config — all inspectable in ONE command.

`aws configure list` with source-annotated values is how this should look.

---

**10/ Safe delegation**

Agents amplify. Unsafe interfaces become dangerous at agent speed.

Scoped credentials. Programmatic confirmation (TTY prompts are useless to agents). Sandbox modes. Rate limits.

"Are you sure? [y/N]" is security theater.

---

**11/ Observable long-running operations**

A 10-minute deploy cannot be observed through a spinner.

Structured progress. Job handles. `status` subcommands. Defined cancellation.

`gcloud`'s operation IDs are the right shape.

---

**12/ Provenance and reproducibility**

Agents chain outputs into decisions.

Outputs need source, timestamp, schema version, cache status — and a clear declaration of what's deterministic.

`nix build` makes provenance and reproducibility the same property.

---

**13/ Evolution without surprise + Auth lifecycle**

Last two:

• Versioned schemas, capability negotiation, explicit deprecation
• Credentials are managed state — source, scope, expiry, refresh all queryable

Interactive re-auth breaks any headless agent.

---

**14/**

The shift:

CLI ethos taught us to build tools humans could learn and trust.

Next step: tools humans can *delegate* to.

The interface has to do more of the work now — explaining, previewing, constraining, recovering.

A CLI is a contract.

Full spec: [link]

---

## Posting notes

- Post at 9-10am ET Tuesday/Wednesday for dev audience
- Tweet 1 is the hook — if it doesn't land in 2 hours, the thread won't
- Tweets 5, 8, 10 are the "quote-tweetable" ones — short, opinionated, screenshotable
- Pin the thread for a week
- Reply to your own tweet 14 with "if you want examples of CLIs doing each of these right, my blog has the full comparison table" + link (keeps the scroll going)
