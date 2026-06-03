#!/usr/bin/env bash
# Post or update a sticky PR comment with the 12fcc verdict.
# Identified by a hidden marker so re-runs replace prior comments
# instead of stacking.
set -euo pipefail

PR="${PR_NUMBER:?missing}"
REPO="${REPO:?missing}"
REPORT="${REPORT_PATH:?missing}"
BADGE_URL="${BADGE_URL:-}"
VERDICT="${VERDICT:-unknown}"
MARKER="<!-- 12fcc-action -->"

body=$(python3 - "$REPORT" "$VERDICT" "$BADGE_URL" <<'PY'
import json, sys
report_path, verdict, badge_url = sys.argv[1], sys.argv[2], sys.argv[3]
with open(report_path) as f: r = json.load(f)
s = r.get("summary", {})
lines = [
  "<!-- 12fcc-action -->",
  "## 12-Factor CLI Conformance",
  "",
]
if badge_url:
  lines += [f"![badge]({badge_url})", ""]
lines += [
  f"**Verdict:** `{verdict}`",
  f"**Findings:** {len(r.get('findings', []))}",
  f"**Leaves:** {s.get('pass', 0)} pass · {s.get('fail', 0)} fail · {s.get('skip', 0)} skip",
  "",
  "### Leaves",
  "",
  "| Leaf | Status | Exit |",
  "|------|--------|------|",
]
for leaf in r.get("leaves", []):
  lines.append(f"| `{leaf['name']}` | {leaf['status']} | {leaf['exitCode']} |")

findings = r.get("findings", [])
if findings:
  lines += ["", "### Findings (top 20)", ""]
  for fnd in findings[:20]:
    code = fnd.get("code") or fnd.get("rule") or "—"
    msg  = fnd.get("message") or fnd.get("raw") or ""
    loc  = fnd.get("path") or fnd.get("file") or ""
    line = fnd.get("line")
    where = f"`{loc}`" + (f":{line}" if line else "") if loc else ""
    lines.append(f"- **{code}** {where} — {msg}")
  if len(findings) > 20:
    lines.append(f"- _…and {len(findings) - 20} more (see full report artifact)_")
print("\n".join(lines))
PY
)

# Find prior sticky comment.
prior=$(gh api "repos/$REPO/issues/$PR/comments" --paginate \
  --jq ".[] | select(.body | startswith(\"$MARKER\")) | .id" | head -n1 || true)

if [ -n "$prior" ]; then
  gh api -X PATCH "repos/$REPO/issues/comments/$prior" -f body="$body" >/dev/null
  echo "Updated PR comment $prior"
else
  gh api -X POST "repos/$REPO/issues/$PR/comments" -f body="$body" >/dev/null
  echo "Posted new PR comment"
fi
