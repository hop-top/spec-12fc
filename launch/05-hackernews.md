# Hacker News

*HN is hostile to marketing voice, thin content, and self-congratulation. The title does the work, the post is the full canonical piece, and your first comment frames the discussion without pitching.*

---

## Submission

**Title options (ranked):**

1. **"12-Factor AI-Enabled CLI Apps"** — Direct, echoes a canonical HN-friendly reference (Heroku's 12-factor app), no clickbait. Strongest option.

2. **"CLI design for when the operator isn't human"** — More evocative, less SEO-friendly, slightly more clickbait-adjacent. Works if option 1 has been used recently.

3. **"Twelve factors for CLIs that agents can use safely"** — Third choice. Loses the "12-factor" brand echo.

**URL:** Link to your personal blog (the canonical version). Not Medium — HN readers associate Medium with low-signal content and it can hurt reception.

**Do not:**
- Use "[Show HN]" — this isn't a product or demo
- Add any tag like "[Essay]" or "[Manifesto]"
- Submit from Medium or Substack if you have a personal blog alternative

---

## First comment (post within 2-3 minutes of submission)

> Author here. A few things I want to flag preemptively since they'll come up:
>
> **On the "12-factor" echo:** yes, it's deliberate. Heroku's document worked because it was opinionated and testable. I tried to honor that rather than just borrow the branding — each factor is meant to be something you can check, not just nod at.
>
> **On the overlap with "just good API design":** some factors (structured output, versioning, provenance) apply to any machine interface. I kept them because CLI authors routinely under-implement them relative to HTTP API authors — the stakes feel lower until an agent is driving. Three factors are genuinely CLI-specific: stream and exit discipline, long-running operations, and auth lifecycle in a shell context.
>
> **On examples:** I named specific tools (kubectl, terraform, gh, gcloud, nix, stripe). Some of them appear as good examples in one factor and cautionary ones in another. No tool gets it all right. That's the point — "AI-enabled" isn't a property of the tool, it's a property per-factor.
>
> **What I'd most like pushback on:** whether Factor 6 (idempotency AND atomicity) should really be two factors. I merged them because both are about "what happens when execution doesn't go cleanly end-to-end," but they fail for different reasons and I can see the argument.

---

## Why this first comment works

- Names the weakest points in your own argument before anyone else does. HN commenters are faster at finding weaknesses than you are at hiding them; get ahead.
- The "just good API design" objection is the #1 thing that will be raised. Answering it upfront defuses the thread's most predictable critical direction.
- Asking for pushback on one specific factor redirects the comments toward something productive, not "this is just the 12-factor app with extra steps."
- Does not include a pitch for anything, a newsletter signup, or a product. HN downvotes those.

## If the post hits front page

- Respond to every substantive top-level comment within 4 hours
- Do not respond to snark or dismissals — let the community handle those
- If someone suggests a better example or catches a real mistake, thank them and say you'll update the canonical post
- Do NOT cross-link to your other posts (Twitter, LinkedIn, Medium). HN notices and penalizes cross-promotion.

## If the post doesn't hit front page

- Don't resubmit for at least 2 weeks
- Don't post the same URL from another account
- If you resubmit, change the title to option 2 or 3
