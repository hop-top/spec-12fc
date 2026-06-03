# 12-Factor AI-Enabled CLI Apps — Publishing Kit

Seven channel-tuned posts plus a cross-channel remarketing plan. Built to be published in sequence, not all at once.

## Files

| File | Channel | Length | Voice |
|---|---|---|---|
| `01-personal-blog.md` | Personal blog (canonical) | ~2,500 words | Full manifesto, authoritative |
| `02-medium.md` | Medium | ~1,400 words | Narrative, SEO-friendly |
| `03-twitter.md` | Twitter / X | 14 tweets | Punchy, numbered thread |
| `04-linkedin.md` | LinkedIn | ~1,300 chars | Professional, business framing |
| `05-hackernews.md` | Hacker News | Submission + first comment | Preemptive, honest |
| `06-reddit.md` | Reddit | 4 versions (programming, devops, commandline, sre) | Community-tuned |
| `07-facebook.md` | Facebook groups | ~500 words | Conversational, question-driven |
| `08-cross-channel-remarketing.md` | All | 3-week sequencing plan | Strategic |

## How to use

1. **Publish `01-personal-blog.md` first.** It's the canonical URL every other channel links to.
2. **Follow the sequence in `08-cross-channel-remarketing.md`.** It's a 3-week plan with day-by-day timing and callback patterns.
3. **Do not copy-paste across channels.** Each version is tuned to its platform's norms. Copy-pasting Medium to LinkedIn, or the HN post to Reddit, will underperform both.
4. **Edit the `[link]` placeholders** to point to the canonical blog URL before publishing.

## Editorial notes

- **Examples mention real tools** (kubectl, terraform, gh, gcloud, nix, stripe, jq, rustc, etc.). Some tools appear as good examples in one factor and cautionary in another — this is deliberate and heads off the "but [tool] is great!" objection.
- **No Anthropic/Claude references** anywhere in the posts. The manifesto is tool-agnostic on purpose — it reads as a standards argument rather than a pitch.
- **Factor 6 (Idempotency and atomicity)** is the one most likely to draw a "should be two factors" critique. The HN first-comment acknowledges this preemptively.
- **Factor 3 (Stream and exit discipline)** is the most CLI-native factor on the list — it's the one that most clearly distinguishes this spec from general API design. Lean into it when engaging with comments that say "this is just good API design."

## If you want changes

The canonical blog post is the source of truth. If you revise it, the other channel versions need to be resynced. The Twitter thread and LinkedIn post are the most independent — they can drift from the canonical text slightly. Medium, Reddit, and Facebook should stay closely aligned to the canonical message.
