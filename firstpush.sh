#!/bin/bash
# One-time first-push script.
# Runs the cleanup commit and pushes to GitHub.
# Run this in Terminal:   cd ~/PageTempo && bash firstpush.sh
set -e

cd "$(dirname "$0")"

echo "── First push setup ──"
echo ""

# 1. Clear any stale git locks from the sandbox
echo "→ clearing any stale git locks..."
rm -f .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock 2>/dev/null
# clean up any leftover fetch tmp objects (sandbox couldn't delete these)
find .git/objects -name "tmp_obj_*" -delete 2>/dev/null || true

# 2. Verify we're connected to the right repo
EXPECTED="https://github.com/Tempo-See/Tempo-See.github.io.git"
if ! git remote get-url origin 2>/dev/null | grep -q "Tempo-See.github.io.git"; then
  echo "→ adding origin remote"
  git remote add origin "$EXPECTED" 2>/dev/null || git remote set-url origin "$EXPECTED"
fi
echo "  origin = $(git remote get-url origin)"

# 3. Verify identity
if [ -z "$(git config user.email)" ]; then
  git config user.email "shim7@hawaii.edu"
  git config user.name  "Moki"
  echo "→ set git identity"
fi

# 4. Stage all current changes (deletions + new files), respecting .gitignore
echo ""
echo "→ staging changes..."
git add -A

# 5. Remove tracked junk that the .gitignore now covers (uploaded by web UI before .gitignore existed)
for path in \
  images/_temp_landscape.jpg \
  images/temp_rotated.jpg \
  images/temp_rotated2.jpg \
  images/4.271.JPG \
  images/4.272.JPG \
  images/4.273.JPG \
  images/4.274.JPG \
  images/4.275.JPG \
  fonts/xingshu.woff2 \
  _xingshu_chars.txt \
  _jinglei_chars.txt
do
  git rm --cached --ignore-unmatch "$path" >/dev/null 2>&1 || true
done

# 6. Show what's about to be committed
echo ""
echo "── Changes ready to commit ──"
git diff --cached --stat | tail -25
echo ""

# 7. Commit
read -r -p "Proceed? (y/N) " ANS
if [ "$ANS" != "y" ] && [ "$ANS" != "Y" ]; then
  echo "Cancelled."
  exit 1
fi

git commit -m "sync local working tree · clean up tracked source/temp files"

# 8. Push (will prompt for GitHub login the first time)
echo ""
echo "→ pushing to GitHub (may prompt for login)..."
git push -u origin main

echo ""
echo "✅ All set!"
echo "   From now on, after editing files, run:   ./sync.sh"
echo "   Site:                                    https://tempo-see.github.io"
