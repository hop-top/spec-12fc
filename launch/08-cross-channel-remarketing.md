# Cross-Channel Remarketing Plan

*A sequencing and callback strategy that turns seven separate posts into a coordinated campaign. Each channel feeds the next; nothing is published in isolation.*

---

## The principle

Don't publish all seven posts the same day. That's spray-and-pray — each channel fights the others for attention from the same audiences, and no piece gets time to compound.

Instead, treat the personal blog as the canonical source and every other channel as a funnel *back to it*. Sequence the channels so each one builds on the last: early channels seed early feedback, late channels get to reference "as discussed on HN" or "the thread that hit 2M impressions on X."

The goal: by week three, anyone in your audience's radius should have seen the idea in at least three places, reinforcing it as something "everyone's talking about" rather than "one guy's blog post."

---

## Sequencing (3-week campaign)

### Week 1 — Seed the canonical version

**Day 1 (Tuesday), 9am ET:** Publish personal blog post. This is the canonical URL. Everything else links here. Do not publish anywhere else yet.

**Day 1, 9:30am ET:** Submit to Hacker News. Title: "12-Factor AI-Enabled CLI Apps." Post the first comment within 3 minutes. HN traffic peaks 9-11am ET weekdays.

**Day 1, 10am ET:** Post Twitter/X thread. First tweet quotes the thesis question ("Can a human AND an agent both use this command safely?"). Final tweet links to blog.

**Day 1, afternoon:** Do *not* post anywhere else. Let HN and Twitter run. Monitor and engage.

**Day 2-3:** Reply to every substantive HN comment within 4 hours. Quote-retweet the best replies to your Twitter thread. If HN hits front page, update the blog post with any corrections surfaced in comments.

---

### Week 1.5 — Expand to professional audiences

**Day 4 (Friday), 8am local:** LinkedIn post. Reference neither HN nor Twitter directly — LinkedIn audience is different. But the HN/Twitter traction gives you social proof in replies: "covered on Hacker News this week" can appear in the comments if asked.

**Day 5-6:** Weekend. No posting. Monitor LinkedIn comments.

---

### Week 2 — Reach community-specific audiences

**Day 8 (Monday), 10am:** Medium post. Medium is slower-burn — it gets indexed by Google and surfaces on Medium's homepage if it performs. This is your SEO play and your "essay" play. Title it for search: "The 12-Factor CLI, Rewritten for Agents."

**Day 9 (Tuesday), 10am:** Reddit — `r/programming`. Use the tuned version. Expect critical comments; engage honestly.

**Day 10 (Wednesday), 10am:** Reddit — `r/devops`. Different tuned version. Lead with failure modes.

**Day 11 (Thursday), 10am:** Reddit — `r/commandline`. The "show your work, ask for pushback" version. This community is small but high-signal; it can surface specific corrections.

**Day 12 (Friday):** Reddit — `r/sre`. Incident-flavored framing.

*Do not post all Reddit versions on the same day.* Reddit's anti-spam detection flags cross-posting, even to unrelated subs. One per day, different tuned text each time.

---

### Week 3 — Community and callback

**Day 15 (Monday), 11am:** Facebook group post(s). Post to one or two relevant groups per day, not all at once. Facebook algorithmically penalizes identical posts across groups — vary the opening paragraph each time.

**Day 15-19:** The "callback" phase begins. Use reactions from earlier channels as material for new posts:

- **Twitter:** Quote-tweet the best HN or Reddit comment that pushed back on a specific factor, with your response. "Good critique from @user on HN about Factor 6 — my thinking has evolved, here's why" → 2-3 tweet micro-thread.
- **LinkedIn:** Follow-up post on a single factor that got the most engagement. "The factor that drew the most debate was [X]. Here's why it matters more than people expect." Link back to original.
- **Medium:** Optional follow-up essay expanding on one factor (typically Safe Delegation or Auth Lifecycle — those tend to draw deeper interest).

---

### Week 4+ — Compounding

**Ongoing, low cadence:**

- **Once a week:** Tweet a single factor as a standalone point with a real-world example. "Factor 9: Observable long-running operations. Example from this week: [tool] does X, [tool] does Y, here's what differs." Link to canonical.
- **Once every 2-3 weeks:** Write up a specific tool audit against the 12 factors. "I audited `kubectl` against the 12 factors. Here's what it gets right, where it falls short." Publish on blog, share on Twitter and LinkedIn.
- **Quarterly:** Revise the canonical post based on accumulated feedback. Version it (v1.1, v1.2). Each revision is a fresh posting opportunity: "Updated the spec based on 200+ comments. Here's what changed."

---

## Callback patterns across channels

The crucial mechanic: never let a channel stand alone. Every channel should reference or build on another, so the audience member who sees you in two places encounters a coherent conversation, not two duplicate ads.

| From | To | Mechanic |
|---|---|---|
| HN → Blog | "See the canonical version for full examples" in first comment |
| Twitter → Blog | Last tweet links to blog; pinned for a week |
| HN/Twitter → LinkedIn | LinkedIn references "the response this week has been…" (social proof, no direct link) |
| Blog → Medium | Medium footer: "This is the canonical version: [blog link]" |
| Reddit → Blog | Every Reddit post links to canonical; don't duplicate full text |
| Facebook → Blog | "[link in comments]" with blog URL |
| Blog ← All | Blog gets a "discussed at" section added after week 1: "Discussed on Hacker News, r/programming, r/devops, and others." This is the reinforcement loop — new readers see it's been vetted. |

---

## What NOT to do

- **Don't post the same text everywhere.** Each channel has a tuned version for a reason. Copy-pasting the Medium post to LinkedIn and Reddit will underperform both, and Reddit's users will notice and downvote.
- **Don't link across channels explicitly.** Twitter readers don't want to "see this on LinkedIn." HN downvotes cross-promotion. Instead, let each channel be standalone with a link to the canonical blog.
- **Don't publish all at once.** You'll fragment your own audience's attention and no single post gets traction momentum.
- **Don't chase platforms that didn't land.** If HN didn't hit after one submission, don't resubmit for at least two weeks. If Reddit sub X didn't work, don't try sub Y on day 2.
- **Don't auto-cross-post.** Tools like Buffer or Zapier that copy identical text across platforms kill engagement on all of them. Each channel deserves its own moment.

---

## Metrics to watch, by channel

- **Blog:** Unique visitors, time-on-page, referral source. Time-on-page >3min suggests people are reading; <1min means they bounced on the length.
- **HN:** Front page hit? Points after 2 hours? Top-level comments? A post with 50 points and 30 comments outperforms one with 150 points and 5 comments — the latter was a drive-by upvote, the former sparked discussion.
- **Twitter:** Impressions on tweet 1, bookmarks, quote tweets. Bookmarks are the strongest signal — they mean people want to reference it later.
- **LinkedIn:** Reactions, comments (not just "great post!" — substantive ones), shares. LinkedIn shares from people you don't know are the highest-value signal.
- **Medium:** Reads (not views), fans, highlighted passages. Medium's algorithm weights reading time heavily.
- **Reddit:** Upvote ratio in first 2 hours, comment count, sub-specific upvote threshold for front page.
- **Facebook:** Comments-to-reactions ratio. Comments are worth 5x reactions for algorithmic reach.

---

## Emergency playbook

**If HN goes critical (front page, 300+ points):**
- Update blog post with any corrections surfaced in comments, credit contributors
- Pin the HN thread link on your Twitter for the day
- Do not post to other channels until HN settles — ride the wave

**If Twitter thread goes viral:**
- Reply to the top 10 replies with substantive additions, not just thanks
- Add a "bookmarked by 5k" callout to your LinkedIn version
- Consider a follow-up Medium piece within 7 days to capture the audience

**If nothing lands in week 1:**
- Do not give up on the idea — give up on the current channel strategy
- Revise the blog post based on any feedback you did get
- Wait 3 weeks, restart with a different title ("CLI design for when the operator isn't human" → HN)
- Consider reaching out to 2-3 relevant newsletters (Pragmatic Engineer, Console, TLDR DevOps) offering the piece as a guest submission

---

## The underlying bet

This campaign works if the idea has legs. If the 12-factor framing resonates, each channel reinforces the last and you end up with an artifact that gets cited by others — blog posts, conference talks, internal engineering docs. That's the goal. Virality is a bonus; canonical status is the prize.

If the idea doesn't resonate, no amount of cross-channel choreography rescues it. In that case, treat the campaign as a diagnostic: which factors did people push back on? Which landed? Use that to revise the underlying thesis and try again in a quarter.

Either way, the blog post is the asset. Everything else is distribution.
