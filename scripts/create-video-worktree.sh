#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/create-video-worktree.sh <id> <topic-slug>

Creates a new video branch and worktree under ../videos/.

Environment:
  BASE_BRANCH   Base environment branch name. Default: base

Example:
  scripts/create-video-worktree.sh 001 intro-to-derivatives
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 2
fi

id="$1"
topic="$2"
base_branch="${BASE_BRANCH:-base}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
base_dir="$(cd -- "$script_dir/.." && pwd)"
worktree_parent="$(cd -- "$base_dir/.." && pwd)/videos"
worktree_dir="$worktree_parent/$id-$topic"
branch="video/$id-$topic"

if [[ ! "$id" =~ ^[0-9][0-9A-Za-z_-]*$ ]]; then
  echo "Invalid id: $id" >&2
  exit 2
fi

if [[ ! "$topic" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Invalid topic slug: $topic" >&2
  echo "Use lowercase letters, numbers, and hyphens." >&2
  exit 2
fi

if ! git -C "$base_dir" rev-parse --verify "$base_branch" >/dev/null 2>&1; then
  echo "Base branch not found: $base_branch" >&2
  echo "Set BASE_BRANCH if your base branch has a different name." >&2
  exit 1
fi

if git -C "$base_dir" rev-parse --verify "$branch" >/dev/null 2>&1; then
  echo "Branch already exists: $branch" >&2
  exit 1
fi

if [[ -e "$worktree_dir" ]]; then
  echo "Worktree path already exists: $worktree_dir" >&2
  exit 1
fi

mkdir -p "$worktree_parent"
git -C "$base_dir" worktree add "$worktree_dir" -b "$branch" "$base_branch"

cat <<EOF
Created video worktree:
  Branch:   $branch
  Worktree: $worktree_dir
EOF
