# super-dev — Meta Skill for Claude Code

One always-on meta skill that combines four disciplines into a single, token-optimized package:

1. **Token economy** — caveman-style output compression + input economy (grep-before-read, no re-reads, batched tool calls, handoff receipts). Prose gets terse; code never does.
2. **Code quality** — think-before-coding, simplicity first, surgical diffs, English WHY-only comments, adversarial self-review.
3. **Systematic debugging** — iron law: no fix without root cause. Four-phase process (investigate → compare → hypothesize → fix), safe-edit rules, rollback points, red-flag stops.
4. **Project workflow** — grill the plan, verifiable steps, vertical slices, honest verification, 5-line handoffs. Ceremony proportional to risk.

## Design

Built on Anthropic's skill-authoring best practices with **progressive disclosure**:

```
skills/super-dev/
├── SKILL.md                     # router + 7 core laws (~600 tokens, always loaded)
└── references/                  # loaded ONLY when triggered
    ├── token-economy.md         # long sessions / context pressure
    ├── code-quality.md          # nontrivial code writing / review
    ├── debugging.md             # any bug / test failure / error
    └── project-workflow.md      # features / multi-file / projects
```

The hub file costs a few hundred tokens per session; deep playbooks load on demand. Trivial tasks never load a reference at all.

Idea sources: [caveman](https://github.com/JuliusBrussee/caveman) (compression rules, anti-patterns like fake abbreviations), Karpathy-derived coding principles (think-first, simplicity, surgical changes, goal-driven loops), [superpowers](https://github.com/obra/superpowers) systematic-debugging (four phases, iron law, red flags), plus community findings on context-reconstruction cost and handoff receipts.

## Install

```bash
git clone https://github.com/Arian-Alijani/Claude-code-super-SKILL.git
cd Claude-code-super-SKILL
./install.sh
```

The installer:
- copies the skill to `~/.claude/skills/super-dev`
- appends an idempotent auto-activation block to `~/.claude/CLAUDE.md` so the skill is active from message one of every session — no manual trigger needed

Re-run anytime to update. Remove by deleting `~/.claude/skills/super-dev` and the `<!-- super-dev -->` block in `~/.claude/CLAUDE.md`.

### Project-scoped install (alternative)

Copy `skills/super-dev/` into `<project>/.claude/skills/` and add the same activation block to the project's `CLAUDE.md`.

## Usage

Nothing to do — it activates automatically and stays silent. Optional controls:

| Say | Effect |
|---|---|
| `verbose` / `normal mode` | Relax output compression (other laws stay) |
| `ultra` / `lite` | Change compression intensity |
| any bug report | Debugging playbook auto-loads |
| "build X" / feature request | Project workflow auto-loads |

## Honest notes

- Output compression saves ~40–65% on prose replies; whole-session savings are smaller because tool output and code dominate. The input-economy rules (targeted reads, no re-reads, piped commands, handoff receipts) are the bigger lever.
- Compression auto-disables for security warnings, destructive-action confirmations, and anywhere ambiguity would cost a clarification round-trip — one clarification costs more than compression saves.
