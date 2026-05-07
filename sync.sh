#!/bin/bash
# Daily-use: stage all changes, commit with a timestamp, push to GitHub.
cd "$(dirname "$0")"

# Stage everything (respects .gitignore)
git add -A

# Bail out if there's nothing to push
if git diff --cached --quiet; then
  echo "Nothing new to sync."
  exit 0
fi

# Show what will be committed
echo "── Changes to be pushed ──"
git diff --cached --stat
echo ""

# Commit with a timestamp
STAMP=$(date +'%Y-%m-%d %H:%M')
git commit -m "update · $STAMP"

# Push
echo ""
echo "→ pushing to GitHub..."
git push

echo ""
echo "✅ Done. Site updates at https://tempo-see.github.io within ~1 minute."
