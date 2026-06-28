#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/promote-base-changes.sh [--yes]

Promotes base-environment changes from the current video worktree into the
base repository. The script only considers approved shared paths, shows the
diff, asks for confirmation, creates a recontribution branch from the base
branch, applies the patch there, and does not commit.

Run this from a video worktree, for example:
  scripts/promote-base-changes.sh

Environment:
  BASE_BRANCH   Base environment branch name. Default: base
  BASE_WORKTREE Base worktree path. Default: worktree for BASE_BRANCH

Notes:
  New files must be tracked or intent-to-add in the video worktree to appear in
  the generated patch. Use git add -N <file> for new shared files you want to
  promote without staging their content.
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

base_paths=(
  AGENTS.md
  README.md
  docs
  scripts
  src
  templates
  .opencode
  .agents
  .gitmodules
  flake.nix
  flake.lock
  manim.cfg
  pyproject.toml
  requirements.txt
  requirements-dev.txt
  uv.lock
  poetry.lock
)

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

status_output="$(git -C "$source_worktree" status --short -- "${base_paths[@]}" || true)"
if [[ -z "$status_output" ]] && git -C "$source_worktree" diff --quiet "$base_branch" -- "${base_paths[@]}"; then
  echo "No promotable base-environment changes found."
  exit 0
fi

untracked_output="$(git -C "$source_worktree" status --short --untracked-files=all -- "${base_paths[@]}" | grep '^??' || true)"
if [[ -n "$untracked_output" ]]; then
  cat <<EOF
Untracked shared files were found. They will not be included unless you mark
them with git add -N or stage them in the video worktree:

$untracked_output
EOF
fi

echo "Promotable shared-path status:"
git -C "$source_worktree" status --short -- "${base_paths[@]}"

echo
echo "Diff to apply to recontribution branch:"
git -C "$source_worktree" diff --binary "$base_branch" -- "${base_paths[@]}"

if [[ "$assume_yes" -ne 1 ]]; then
  printf '\nCreate %s and apply this patch to %s? [y/N] ' "$recontribute_branch" "$base_worktree"
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

patch_file="$(mktemp)"
trap 'rm -f "$patch_file"' EXIT
git -C "$source_worktree" diff --binary "$base_branch" -- "${base_paths[@]}" > "$patch_file"

if [[ ! -s "$patch_file" ]]; then
  echo "No patch was generated. If you only have new files, mark them with git add -N first." >&2
  exit 1
fi

git -C "$base_worktree" switch "$base_branch"
git -C "$base_worktree" switch -c "$recontribute_branch" "$base_branch"
git -C "$base_worktree" apply --3way "$patch_file"

cat <<EOF
Applied shared changes to a recontribution branch:
  Source:      $source_branch ($source_worktree)
  Target:      $recontribute_branch ($base_worktree)
  Base branch: $base_branch

Next steps:
  cd "$base_worktree"
  git diff
  git status --short
  git add <intended files>
  git commit -m "feat(core): describe shared change"
  git push -u origin "$recontribute_branch"
EOF
