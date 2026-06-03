#!/usr/bin/env bash
# Commit the badge JSON back to the default branch when its content
# has changed. No-op on identical content (avoids empty commits and
# CI loops). Uses the actions[bot] identity so the commit is clearly
# automated.
set -euo pipefail

BADGE_PATH="${BADGE_PATH:?missing}"
TARGET="${TARGET_BRANCH:?missing}"

if ! git diff --quiet -- "$BADGE_PATH"; then
  git config user.name  "github-actions[bot]"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git add "$BADGE_PATH"
  git commit -m "chore(badge): update 12fcc verdict"
  git push origin "HEAD:$TARGET"
  echo "Badge committed to $TARGET"
else
  echo "Badge unchanged; skipping commit"
fi
