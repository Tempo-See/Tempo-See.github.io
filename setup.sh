#!/bin/bash
# One-time setup: connect this folder to the GitHub repo.
# Safe to re-run if something gets stuck.
set -e

cd "$(dirname "$0")"
REPO_URL="https://github.com/Tempo-See/Tempo-See.github.io.git"

echo "── Setup: linking $(pwd) to $REPO_URL ──"
echo ""

# 1. Initialize git if not already a repo
if [ ! -d .git ]; then
  echo "→ git init"
  git init
  git branch -M main
else
  echo "→ already a git repo, skipping init"
fi

# 2. Make sure git knows who you are
if [ -z "$(git config user.email)" ]; then
  echo ""
  echo "git needs to know your name + email for commit history."
  read -r -p "  Email (e.g. shim7@hawaii.edu): " EMAIL
  read -r -p "  Name  (e.g. Moki): " NAME
  git config user.email "$EMAIL"
  git config user.name  "$NAME"
fi

# 3. Add or update the remote
if git remote get-url origin >/dev/null 2>&1; then
  CURRENT=$(git remote get-url origin)
  if [ "$CURRENT" != "$REPO_URL" ]; then
    echo "→ updating origin: $CURRENT → $REPO_URL"
    git remote set-url origin "$REPO_URL"
  else
    echo "→ origin already set"
  fi
else
  echo "→ adding origin"
  git remote add origin "$REPO_URL"
fi

# 4. Try to merge any history that's already on GitHub
echo ""
echo "→ fetching from GitHub (in case there's already content there)..."
if git fetch origin main 2>/dev/null; then
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    # We have local commits — try to rebase
    echo "→ rebasing local on top of remote main"
    if ! git rebase origin/main 2>/dev/null; then
      echo ""
      echo "  Local + remote have unrelated histories."
      echo "  Pulling with --allow-unrelated-histories instead..."
      git rebase --abort 2>/dev/null || true
      git pull origin main --allow-unrelated-histories --no-edit
    fi
  else
    # No local commits yet — just check out the remote
    git checkout -b main origin/main
  fi
else
  echo "→ no remote main found yet — first push will create it"
fi

# 5. Stage everything and make initial commit
echo ""
echo "→ staging files..."
git add -A
if git diff --cached --quiet; then
  echo "→ nothing new to commit"
else
  STAMP=$(date +'%Y-%m-%d %H:%M')
  git commit -m "initial local sync · $STAMP"
fi

# 6. First push (will prompt for GitHub login if needed)
echo ""
echo "→ pushing to GitHub (may prompt for login the first time)..."
git push -u origin main

echo ""
echo "✅ Setup complete!"
echo ""
echo "   From now on, after editing files, run:"
echo "       ./sync.sh"
echo ""
echo "   Site URL: https://tempo-see.github.io"
