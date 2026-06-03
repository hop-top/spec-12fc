# Reddit

*Reddit is not one community. Each subreddit has its own norms, and cross-posting the same text tanks everywhere. Below are versions tuned to four viable subreddits.*

---

## r/programming

**Title:** 12-Factor AI-Enabled CLI Apps — design principles for tools that agents use

**Body:**

I wrote up twelve design principles for CLI tools that get used by AI agents, not just humans. Echoing Heroku's 12-factor app deliberately — the goal is something opinionated and testable, not a wishlist.

The shift: CLI design used to assume the operator was a human at a terminal. Increasingly the operator is an agent — planning, retrying, chaining outputs, running at scales no human matches. And most CLI tools weren't designed for that. Failure modes include duplicate mutations from naive retries, silent partial failures, auth expiries that crash headless agents, and ambiguous output that poisons downstream decisions.

The twelve:

1. Self-describing interfaces
2. Structured everything
3. Stream and exit discipline (stdout/stderr/exit code have defined jobs)
4. Explicit contracts and recoverable errors
5. Preview before effect
6. Idempotency and atomicity
7. State and context transparency
8. Safe delegation
9. Observable long-running operations
10. Provenance and reproducibility
11. Evolution without surprise
12. Auth and credential lifecycle

Full spec with examples from kubectl, terraform, gh, gcloud, nix, stripe: [link]

Genuinely curious what CLIs you've seen get this right or wrong — particularly for factors 3 (stream discipline), 6 (idempotency/atomicity), and 9 (long-running ops), which are the ones I see botched most often.

**Posting notes for r/programming:**
- Accepts the "list + link" format
- Prefers the subject matter framed as technical, not as essay/manifesto
- Comments will focus on specific tools — be ready to engage per-tool, not per-principle

---

## r/devops

**Title:** If an agent is going to run your CLI, it needs a different contract — 12 factors

**Body:**

Most CLI tools we run in pipelines and automation were designed for humans. They work okay when a human is there to interpret output, retry the right way, and notice when something's half-done. They work poorly when an agent is running them unattended at scale.

I wrote up twelve factors for CLI design when the operator might be an agent. The ones most relevant to devops work:

- **Preview before effect** — every mutating command supports dry-run/plan/diff in the same schema as execution. `terraform plan` is the model.
- **Idempotency and atomicity** — retries are safe, partial failures declare what committed. Stripe's idempotency keys and `sqitch`'s per-change commit tracking generalize.
- **Observable long-running operations** — progress events and job handles, not spinners. `gcloud`'s operation IDs are the right pattern.
- **Auth and credential lifecycle** — credentials are managed state. Source, scope, expiry all queryable. Interactive browser re-auth breaks any headless pipeline.
- **Safe delegation** — scoped credentials, programmatic confirmation, blast-radius controls. "Are you sure? [y/N]" is useless in CI.

Full list plus comparison table with concrete examples from kubectl, terraform, aws, gcloud, stripe: [link]

What's tripped up your pipelines? The two patterns I see most are (1) retries that multi-apply because the tool has no idempotency semantics, and (2) long-running commands that can't be cancelled safely mid-run.

**Posting notes for r/devops:**
- This audience has the most first-hand pain with the failure modes, so lead with concrete problems
- Expect strong opinions on specific tools — terraform and ansible especially
- Don't frame as "AI" primarily — frame as "automation," which this audience has been doing for a decade

---

## r/commandline

**Title:** Writing up 12 principles for CLIs that agents use — would love pushback

**Body:**

Been thinking a lot about CLI design lately, specifically about how our tools hold up when the thing running them isn't a human.

I love good CLI design. Terse flags, clean help text, sensible defaults — the human-side craft is real and important. But I think there's a parallel set of principles for when the operator is an agent, and most of it is under-discussed.

Wrote up twelve factors. Some apply to any machine interface (structured output, versioning). A few are genuinely CLI-specific:

- **Stream and exit discipline**: stdout = structured data, stderr = humans, exit code = status class. TTY detection switches format. `jq` does this well, most tools don't.
- **Long-running operations**: progress events on stderr or a job handle with a status subcommand. Cancellation semantics defined. `gcloud` does this; most don't.
- **Auth and credential lifecycle**: where creds come from, when they expire, how to refresh without a browser popup.

Full spec: [link]

The pushback I most want: I merged "idempotency" and "atomicity" into one factor because both are about "what happens when execution doesn't go cleanly end-to-end." Is that right, or should they be separate? I flip-flopped on this one.

**Posting notes for r/commandline:**
- Smaller, more engaged community — they will actually read the full post
- Show your work, acknowledge what you're uncertain about
- Don't call it a "manifesto" here — call it "principles" or "factors"

---

## r/sre

**Title:** 12 factors for CLI design when agents are the operator

**Body:**

The operator of your CLI tools used to be a human with context. Increasingly it's an agent with none. SRE feels the failure modes first — runbooks invoked by automation, unattended remediation, chained commands in incident response.

Twelve factors, with the ones most load-bearing for SRE work:

**Idempotency and atomicity** — retries are safe, partial failures are declared. The classic nightmare is a remediation that partially applied and the runbook retries, compounding the incident.

**Observable long-running operations** — progress you can poll, cancellation you can invoke. If the only way to know a deploy is progressing is to tail a log, agents can't help.

**State and context transparency** — effective config queryable in one command. Half of SRE work is "what state is this thing actually in right now?" Tools that can answer that are force multipliers.

**Safe delegation** — scoped credentials, programmatic confirmation, bounded blast radius. When an agent can reach production, the interface itself has to enforce limits.

**Auth and credential lifecycle** — source, scope, expiry all queryable. Credential expiry mid-incident is a well-known class of compounding failure.

Full list: [link]

Curious what tools you've seen that handle these well — especially around incident response and remediation pipelines.

**Posting notes for r/sre:**
- Ground everything in incident/failure language — this audience lives there
- Respect that they've seen more tool failures than most; don't oversell novelty
- Expect tool-specific debate (PagerDuty, Rundeck, Ansible, custom runbook systems)
