#!/bin/bash
# Backup workspace files to GitHub
# Usage: ./backup-to-github.sh

set -e

# Configuration
GITHUB_REPO="Franktheb-ot/Frankthebot_backuptest"
GITHUB_BRANCH="master"

# Token from environment (safer - not stored in script)
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Commit message
COMMIT_MSG="${1:-Backup $(date '+%Y-%m-%d %H:%M')}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📦 Backing up workspace to GitHub..."

# Create .gitignore if needed
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
.git
node_modules
*.log
*.tmp
.DS_Store
EOF
    echo "📄 Created .gitignore"
fi

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git config user.email "backup@workspace"
    git config user.name "Workspace Backup"
fi

# Set remote
git remote set-url origin "https://github.com/${GITHUB_REPO}.git" 2>/dev/null || \
git remote add origin "https://github.com/${GITHUB_REPO}.git"

# Add all files (respects .gitignore)
git add -A .

# Check if there are changes
if git diff --cached --quiet 2>/dev/null; then
    echo "✅ No changes to commit - already up to date!"
    exit 0
fi

# Commit and push
git commit -m "$COMMIT_MSG"

# Push using token from environment
if [ -n "$GITHUB_TOKEN" ]; then
    git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git"
    git push -u origin "$GITHUB_BRANCH"
else
    echo "❌ No token found. Set GITHUB_TOKEN env variable:"
    echo "   export GITHUB_TOKEN='your_token_here'"
    exit 1
fi

echo "✅ Backup complete!"