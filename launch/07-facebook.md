# Facebook Group Post

*Facebook engineering groups skew more conversational and less technical than HN or Reddit. The post should be accessible, ask a question, and keep technical density moderate. Target groups: "Developers," "Software Engineering," AI/ML-focused dev groups, regional tech communities.*

---

## Short version (most groups — ~500 words)

**Title / opening line:**
Quick question for anyone building or using AI agents that run real tools →

---

Been chewing on something for the last few weeks and I want to hear how other people are thinking about it.

Command-line tools — `git`, `docker`, `kubectl`, `aws`, `terraform`, all of them — were designed for humans. A human reads the help text, interprets the output, knows when to retry, notices when something went halfway. They work because a thinking person is in the loop.

Now AI agents are running these same tools. Not in five years. Right now. And the tools weren't designed for that operator.

The failure modes are ugly:

- An agent retries a failed command because the network blipped — and accidentally runs the mutation twice because the CLI had no idempotency protection
- A long deploy takes 10 minutes and the only signal of progress is a spinner, so the agent has no idea if it should keep waiting or bail
- The tool's credentials expire mid-operation and the re-auth flow tries to open a browser, which doesn't exist in a headless environment
- An error message is a stack trace meant for a human to read — the agent has no idea what to do with it

I wrote up twelve design principles for CLI tools that can be safely used by both humans and agents. Inspired by Heroku's 12-factor app, updated for this moment.

The short list:

1. Self-describing interfaces (capabilities queryable, not just documented)
2. Structured everything (JSON for success, errors, progress, diffs)
3. Stream and exit discipline (stdout, stderr, and exit codes each have a job)
4. Explicit contracts and recoverable errors
5. Preview before effect (dry-run, plan, diff)
6. Idempotency and atomicity (retries safe, partial failures recoverable)
7. State and context transparency
8. Safe delegation (scoped credentials, bounded blast radius)
9. Observable long-running operations
10. Provenance and reproducibility
11. Evolution without surprise
12. Auth and credential lifecycle

Full writeup with examples from real tools here: [link]

**My question for the group:** which of these bites you hardest in practice? For me it's #6 (retries that double-apply) and #9 (long-running operations with no structured progress). I know people running agents against production CLIs and both of those show up in incident reports constantly.

Curious what your list looks like.

---

## Posting notes

- Facebook favors posts with a clear question at the end — asking drives comments, comments drive reach
- Keep first 2-3 lines punchy; Facebook truncates and shows "See more" — you want the hook in the visible portion
- Respond to every comment, even thank-yous. Engagement velocity matters here more than on other platforms.
- Avoid linking directly in the post body — like LinkedIn, Facebook often throttles external link reach. Put "[link in comments]" in the body and drop it in the first comment.

## If posting to a regional or language-specific group

- Translate the opening hook and closing question into the group's primary language
- Leave the numbered list in English if your audience is technical (devs tend to read English tech terms)
- Keep your personal introduction brief — "I'm jadb, I build stuff at Idea Crafters, been thinking about CLI design lately" is enough
