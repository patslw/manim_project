#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-video-with-base.sh [--fetch]

Rebases the current video worktree onto the base environment branch.

Environment:
  BASE_BRANCH   Base environment branch name. Default: base

Options:
  --fetch       Run git fetch --all --prune before rebasing.
EOF
}

fetch_first=0
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  --fetch)
    fetch_first=1
    ;;
  "")
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

base_branch="${BASE_BRANCH:-base}"
worktree_dir="$(git rev-parse --show-toplevel)"
branch="$(git -C "$worktree_dir" branch --show-current)"

if [[ ! "$branch" == video/* ]]; then
  echo "Current branch is not a video branch: $branch" >&2
  echo "Expected branch name like video/001-topic." >&2
  exit 1
fi

if [[ -n "$(git -C "$worktree_dir" status --porcelain)" ]]; then
  echo "Worktree has uncommitted changes. Commit or stash them before rebasing." >&2
  exit 1
fi

if [[ "$fetch_first" -eq 1 ]]; then
  git -C "$worktree_dir" fetch --all --prune
fi

if ! git -C "$worktree_dir" rev-parse --verify "$base_branch" >/dev/null 2>&1; then
  echo "Base branch not found: $base_branch" >&2
  echo "Set BASE_BRANCH if your base branch has a different name." >&2
  exit 1
fi

git -C "$worktree_dir" rebase "$base_branch"

cat <<EOF
Synced video branch with base:
  Branch:      $branch
  Base branch: $base_branch
EOF
