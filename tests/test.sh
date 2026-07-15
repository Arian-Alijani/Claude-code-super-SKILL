#!/usr/bin/env bash
set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly INSTALLER="$ROOT/install.sh"
readonly TEST_ROOT="$(mktemp -d "$ROOT/.test-super-dev.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

assert_count() {
  local expected="$1" pattern="$2" file="$3" actual
  actual="$(grep -cF "$pattern" "$file" || true)"
  [[ "$actual" == "$expected" ]] || fail "$file: expected $expected occurrences of $pattern, got $actual"
}

printf '1/5 shell syntax\n'
bash -n "$INSTALLER"

printf '2/5 skill and manifest structure\n'
python3 - "$ROOT" <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
skill = root / "skills/super-dev/SKILL.md"
text = skill.read_text(encoding="utf-8")
match = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
assert match, "SKILL.md frontmatter is missing"
frontmatter = match.group(1)
assert re.search(r"^name:\s*super-dev\s*$", frontmatter, re.MULTILINE)
assert re.search(r"^description:\s*>\s*$", frontmatter, re.MULTILINE)
assert len(text.splitlines()) < 120, "SKILL.md router should stay compact"

references = re.findall(r"`(references/[^`]+\.md)`", text)
assert references, "SKILL.md must route to reference files"
for reference in references:
    assert (skill.parent / reference).is_file(), f"missing {reference}"

for relative in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json", "skills/super-dev/evals/evals.json"):
    with (root / relative).open(encoding="utf-8") as handle:
        json.load(handle)

evals = json.loads((root / "skills/super-dev/evals/evals.json").read_text(encoding="utf-8"))
assert evals["skill_name"] == "super-dev"
assert len(evals["evals"]) >= 6
assert len({case["id"] for case in evals["evals"]}) == len(evals["evals"])
for case in evals["evals"]:
    assert case["prompt"] and case["expected_output"]
    assert case.get("assertions"), f"eval {case['id']} has no assertions"
PY

printf '3/5 idempotent user install and uninstall\n'
user_home="$TEST_ROOT/user-home"
mkdir -p "$user_home/.claude"
printf 'existing instruction\n' >"$user_home/.claude/CLAUDE.md"
HOME="$user_home" "$INSTALLER" >/dev/null
assert_file "$user_home/.claude/skills/super-dev/SKILL.md"
assert_count 1 '<!-- super-dev:begin -->' "$user_home/.claude/CLAUDE.md"
cp "$user_home/.claude/CLAUDE.md" "$TEST_ROOT/first-install.txt"
HOME="$user_home" "$INSTALLER" >/dev/null
cmp -s "$TEST_ROOT/first-install.txt" "$user_home/.claude/CLAUDE.md" || fail "install is not idempotent"
HOME="$user_home" "$INSTALLER" --uninstall >/dev/null
[[ ! -e "$user_home/.claude/skills/super-dev" ]] || fail "uninstall left skill directory"
printf 'existing instruction\n' | cmp -s - "$user_home/.claude/CLAUDE.md" || fail "uninstall changed existing instructions"

printf '4/5 project scope and dry run\n'
project="$TEST_ROOT/project"
mkdir -p "$project"
printf '# Project rules\n' >"$project/CLAUDE.md"
HOME="$user_home" "$INSTALLER" --scope project --project-dir "$project" >/dev/null
assert_file "$project/.claude/skills/super-dev/SKILL.md"
assert_count 1 '<!-- super-dev:begin -->' "$project/CLAUDE.md"
HOME="$user_home" "$INSTALLER" --scope project --project-dir "$project" --uninstall >/dev/null
printf '# Project rules\n' | cmp -s - "$project/CLAUDE.md" || fail "project uninstall changed existing instructions"

dry_project="$TEST_ROOT/dry-project"
mkdir -p "$dry_project"
HOME="$user_home" "$INSTALLER" --scope project --project-dir "$dry_project" --dry-run >/dev/null
[[ ! -e "$dry_project/.claude" && ! -e "$dry_project/CLAUDE.md" ]] || fail "dry run changed the project"

printf '5/5 malformed bootstrap safety\n'
malformed_home="$TEST_ROOT/malformed-home"
mkdir -p "$malformed_home/.claude/skills/super-dev"
printf 'keep me\n<!-- super-dev:begin -->\n' >"$malformed_home/.claude/CLAUDE.md"
printf 'existing skill\n' >"$malformed_home/.claude/skills/super-dev/SKILL.md"
cp "$malformed_home/.claude/CLAUDE.md" "$TEST_ROOT/malformed-before.txt"
if HOME="$malformed_home" "$INSTALLER" --uninstall >/dev/null 2>&1; then
  fail "malformed marker block should fail safely"
fi
cmp -s "$TEST_ROOT/malformed-before.txt" "$malformed_home/.claude/CLAUDE.md" || fail "malformed file was modified"
printf 'existing skill\n' | cmp -s - "$malformed_home/.claude/skills/super-dev/SKILL.md" || fail "malformed uninstall removed the skill"

printf 'PASS\n'
