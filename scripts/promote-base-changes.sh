#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/promote-base-changes.sh [--yes]

Cherry-picks commits marked with #base from the current video branch onto a
recontribution branch based on the base branch. The marker may appear anywhere
in the commit subject or body as a standalone token.

Run this from a video worktree, for example:
  scripts/promote-base-changes.sh

Environment:
  BASE_BRANCH   Base environment branch name. Default: base
  BASE_WORKTREE Base worktree path. Default: worktree for BASE_BRANCH
EOF
}

assume_yes=0
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  --yes|-y)
    assume_yes=1
    ;;
  "")
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

base_branch="${BASE_BRANCH:-base}"
source_worktree="$(git rev-parse --show-toplevel)"
source_branch="$(git -C "$source_worktree" branch --show-current)"
safe_source_branch="${source_branch//\//-}"
recontribute_branch="recontribute/${safe_source_branch}-to-${base_branch}"

find_base_worktree() {
  local path=""
  local branch=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      worktree\ *)
        path="${line#worktree }"
        branch=""
        ;;
      branch\ *)
        branch="${line#branch refs/heads/}"
        if [[ "$branch" == "$base_branch" ]]; then
          printf '%s\n' "$path"
          return 0
        fi
        ;;
    esac
  done < <(git -C "$source_worktree" worktree list --porcelain)

  return 1
}

base_worktree="${BASE_WORKTREE:-}"
if [[ -z "$base_worktree" ]]; then
  if ! base_worktree="$(find_base_worktree)"; then
    echo "Could not find a worktree checked out on $base_branch." >&2
    echo "Set BASE_WORKTREE=/path/to/base if needed." >&2
    exit 1
  fi
fi

if [[ "$source_worktree" == "$base_worktree" ]]; then
  echo "Run this from a video worktree, not the base worktree." >&2
  exit 1
fi

if [[ ! "$source_branch" == video/* ]]; then
  echo "Current branch is not a video branch: $source_branch" >&2
  echo "Expected branch name like video/001-topic." >&2
  exit 1
fi

if [[ -n "$(git -C "$base_worktree" status --porcelain)" ]]; then
  echo "Base worktree has uncommitted changes. Commit or stash them first:" >&2
  git -C "$base_worktree" status --short >&2
  exit 1
fi

if git -C "$base_worktree" rev-parse --verify "$recontribute_branch" >/dev/null 2>&1; then
  echo "Recontribution branch already exists: $recontribute_branch" >&2
  echo "Delete, rename, or finish that branch before promoting again." >&2
  exit 1
fi

if ! git -C "$source_worktree" rev-parse --verify "$base_branch" >/dev/null 2>&1; then
  echo "Base branch not found from source worktree: $base_branch" >&2
  echo "Set BASE_BRANCH if your base branch has a different name." >&2
  exit 1
fi

tagged_commits=()
while IFS= read -r commit; do
  message="$(git -C "$source_worktree" show -s --format='%B' "$commit")"
  if grep -Eq '(^|[[:space:]])#base([[:space:]]|$)' <<<"$message"; then
    tagged_commits+=("$commit")
  fi
done < <(git -C "$source_worktree" rev-list --reverse "${base_branch}..HEAD")

if [[ "${#tagged_commits[@]}" -eq 0 ]]; then
  echo "No commits marked with #base were found in ${base_branch}..${source_branch}."
  exit 0
fi

echo "Commits marked for base recontribution:"
git -C "$source_worktree" show -s --format='  %h %s' "${tagged_commits[@]}"

if [[ "$assume_yes" -ne 1 ]]; then
  printf '\nCreate %s and cherry-pick these commits into %s? [y/N] ' \
    "$recontribute_branch" "$base_worktree"
  read -r answer
  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Promotion cancelled."
      exit 0
      ;;
  esac
fi

git -C "$base_worktree" switch "$base_branch"
git -C "$base_worktree" switch -c "$recontribute_branch" "$base_branch"

for commit in "${tagged_commits[@]}"; do
  if ! git -C "$base_worktree" cherry-pick "$commit"; then
    cat >&2 <<EOF
Cherry-pick stopped at $commit.
Resolve the conflict in $base_worktree, then run:
  git cherry-pick --continue
To cancel the recontribution:
  git cherry-pick --abort
EOF
    exit 1
  fi
done

cat <<EOF
Promoted ${#tagged_commits[@]} #base commit(s):
  Source:      $source_branch ($source_worktree)
  Target:      $recontribute_branch ($base_worktree)
  Base branch: $base_branch

Next steps:
  cd "$base_worktree"
  git log "$base_branch..HEAD" --oneline
  git push -u origin "$recontribute_branch"
EOF
