#!/usr/bin/env bash
# super-dev installer for Claude Code.
# Copies the skill to ~/.claude/skills and adds an auto-activation
# directive to ~/.claude/CLAUDE.md (idempotent, safe to re-run).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$REPO_DIR/skills/super-dev"
SKILL_DST="$HOME/.claude/skills/super-dev"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER_BEGIN="<!-- super-dev:begin -->"
MARKER_END="<!-- super-dev:end -->"

[ -d "$SKILL_SRC" ] || { echo "error: skill source not found at $SKILL_SRC" >&2; exit 1; }

mkdir -p "$SKILL_DST/references"
cp "$SKILL_SRC/SKILL.md" "$SKILL_DST/SKILL.md"
cp "$SKILL_SRC/references/"*.md "$SKILL_DST/references/"
echo "installed skill -> $SKILL_DST"

# Remove any previous marker block, then append fresh one.
mkdir -p "$(dirname "$CLAUDE_MD")"
touch "$CLAUDE_MD"
if grep -qF "$MARKER_BEGIN" "$CLAUDE_MD"; then
  tmp="$(mktemp)"
  awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
    index($0,b){skip=1} !skip{print} index($0,e){skip=0}
  ' "$CLAUDE_MD" > "$tmp" && mv "$tmp" "$CLAUDE_MD"
fi

cat >> "$CLAUDE_MD" <<EOF
$MARKER_BEGIN
## super-dev (always on)
At session start, silently activate the super-dev skill and apply its core
laws to every response: terse prose / full-quality code, think before coding,
simplicity first, surgical changes, root-cause debugging, English WHY-only
comments, verify before done. Load its reference files only when their
triggers fire (see the skill's routing table). Never announce activation.
$MARKER_END
EOF
echo "auto-activation added -> $CLAUDE_MD"
echo "done. Restart Claude Code session to take effect."
