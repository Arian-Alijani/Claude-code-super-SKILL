#!/usr/bin/env bash
# Install super-dev as a personal or project-scoped Claude Code skill.
set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SKILL_SRC="$REPO_DIR/skills/super-dev"
readonly MARKER_BEGIN="<!-- super-dev:begin -->"
readonly MARKER_END="<!-- super-dev:end -->"

scope="user"
project_dir=""
dry_run=0
uninstall=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --scope user|project  Install for every project or only one project (default: user)
  --project-dir PATH    Project root for --scope project (default: current directory)
  --dry-run             Print planned actions without changing files
  --uninstall           Remove the skill and its bootstrap block
  -h, --help            Show this help
EOF
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --scope)
      (($# >= 2)) || fail "--scope requires user or project"
      scope="$2"
      shift 2
      ;;
    --project-dir)
      (($# >= 2)) || fail "--project-dir requires a path"
      project_dir="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --uninstall)
      uninstall=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown option: $1"
      ;;
  esac
done

[[ "$scope" == "user" || "$scope" == "project" ]] || fail "scope must be user or project"
[[ -d "$SKILL_SRC" && -f "$SKILL_SRC/SKILL.md" ]] || fail "skill source not found: $SKILL_SRC"

if [[ "$scope" == "user" ]]; then
  [[ -z "$project_dir" ]] || fail "--project-dir is valid only with --scope project"
  skill_dst="$HOME/.claude/skills/super-dev"
  bootstrap_file="$HOME/.claude/CLAUDE.md"
else
  project_dir="${project_dir:-$PWD}"
  [[ -d "$project_dir" ]] || fail "project directory not found: $project_dir"
  project_dir="$(cd "$project_dir" && pwd -P)"
  skill_dst="$project_dir/.claude/skills/super-dev"
  bootstrap_file="$project_dir/CLAUDE.md"
fi

run() {
  if ((dry_run)); then
    printf 'would run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

validate_bootstrap() {
  local file="$1" begin_count end_count
  [[ -f "$file" ]] || return 0

  begin_count="$(grep -cxF "$MARKER_BEGIN" "$file" || true)"
  end_count="$(grep -cxF "$MARKER_END" "$file" || true)"
  [[ "$begin_count" == "$end_count" ]] || fail "malformed super-dev marker block in $file"
}

remove_bootstrap() {
  local file="$1" begin_count temp
  [[ -f "$file" ]] || return 0
  validate_bootstrap "$file"

  begin_count="$(grep -cxF "$MARKER_BEGIN" "$file" || true)"
  ((begin_count > 0)) || return 0

  if ((dry_run)); then
    printf 'would remove super-dev bootstrap from %s\n' "$file"
    return 0
  fi

  temp="$(mktemp "$(dirname "$file")/.super-dev-bootstrap.XXXXXX")"
  awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
    $0 == begin { skipping = 1; next }
    $0 == end && skipping { skipping = 0; next }
    !skipping { print }
  ' "$file" >"$temp"
  chmod --reference="$file" "$temp" 2>/dev/null || true
  mv "$temp" "$file"
}

append_bootstrap() {
  local file="$1"
  remove_bootstrap "$file"

  if ((dry_run)); then
    printf 'would append super-dev bootstrap to %s\n' "$file"
    return 0
  fi

  mkdir -p "$(dirname "$file")"
  touch "$file"
  if [[ -s "$file" ]] && [[ "$(tail -c 1 "$file" | od -An -t u1 | tr -d ' ')" != "10" ]]; then
    printf '\n' >>"$file"
  fi
  cat >>"$file" <<'EOF'
<!-- super-dev:begin -->
For software-engineering tasks, silently invoke `super-dev` before acting. Let it
classify risk and load only the relevant reference; do not preload every file.
<!-- super-dev:end -->
EOF
}

install_skill() {
  local parent stage backup=""
  parent="$(dirname "$skill_dst")"

  if ((dry_run)); then
    printf 'would replace %s from %s\n' "$skill_dst" "$SKILL_SRC"
    return 0
  fi

  mkdir -p "$parent"
  stage="$(mktemp -d "$parent/.super-dev-stage.XXXXXX")"
  cp -R "$SKILL_SRC/." "$stage/"

  if [[ -e "$skill_dst" ]]; then
    backup="$parent/.super-dev-backup.$$"
    mv "$skill_dst" "$backup"
  fi

  if ! mv "$stage" "$skill_dst"; then
    [[ -z "$backup" ]] || mv "$backup" "$skill_dst"
    fail "could not activate staged skill"
  fi
  [[ -z "$backup" ]] || rm -rf "$backup"
}

validate_bootstrap "$bootstrap_file"

if ((uninstall)); then
  remove_bootstrap "$bootstrap_file"
  run rm -rf "$skill_dst"
  printf 'super-dev removed from %s scope\n' "$scope"
  exit 0
fi

install_skill
append_bootstrap "$bootstrap_file"
printf 'super-dev installed at %s\n' "$skill_dst"
printf 'automatic routing configured in %s\n' "$bootstrap_file"
printf 'restart Claude Code if the skill directory was created during this session\n'
