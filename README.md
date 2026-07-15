# super-dev — Adaptive Engineering Skill for Claude Code

A compact meta-skill that improves software-engineering behavior while loading only the guidance needed for the current task.

- **Token-aware context engineering:** targeted retrieval, bounded tool output, no duplicate reads, milestone receipts, and concise responses.
- **Stronger implementation:** contract-first design, simple and surgical changes, realistic tests, security and reliability checks.
- **Systematic debugging:** reproduce, localize, form one falsifiable hypothesis, fix the earliest cause, verify the regression.
- **Proportional delivery:** lightweight handling for trivial changes; plans, rollback, and broader review only as risk grows.
- **Automatic routing:** the skill classifies task signals and selectively loads one or more playbooks. It never preloads every reference.

## Architecture

```text
skills/super-dev/
├── SKILL.md                     # compact baseline + adaptive router
├── evals/evals.json             # realistic behavior and trigger cases
└── references/
    ├── token-economy.md         # context and output efficiency
    ├── code-quality.md          # design, security, tests, diff review
    ├── debugging.md             # evidence-driven root-cause workflow
    └── project-workflow.md      # requirements, slices, review gates
```

Claude Code always sees only the skill name and short description. The `SKILL.md` body loads when the skill is invoked; references load on demand. This follows the Agent Skills progressive-disclosure model and avoids turning a large global instruction file into a recurring context tax.

### Adaptive behavior

| Task | Behavior |
|---|---|
| One-line, clear, reversible | Baseline only; edit and focused check |
| Nontrivial implementation or review | Code-quality playbook |
| Bug, regression, failing build, performance issue | Debugging playbook |
| Feature, multi-file work, unclear requirements | Project-workflow playbook |
| Large/noisy context or explicit cost request | Token-economy playbook |
| Auth, payments, migrations, concurrency, production | High-risk mode with explicit invariants, rollback, and broad verification |

Multiple playbooks can apply, but each is read once. Process remains proportional to risk.

## Install

### Direct installer — strongest automatic activation

```bash
git clone https://github.com/Arian-Alijani/Claude-code-super-SKILL.git
cd Claude-code-super-SKILL
./install.sh
```

This installs to `~/.claude/skills/super-dev` and adds a tiny, marker-delimited bootstrap to `~/.claude/CLAUDE.md`. The bootstrap asks Claude to invoke `super-dev` for engineering tasks and lets the skill route itself. Re-running is idempotent and removes stale files from earlier versions.

Options:

```bash
./install.sh --dry-run
./install.sh --scope project --project-dir /path/to/repo
./install.sh --uninstall
./install.sh --scope project --project-dir /path/to/repo --uninstall
```

Project scope installs under `<repo>/.claude/skills/super-dev` and updates `<repo>/CLAUDE.md`. The installer preserves unrelated instructions and refuses to alter malformed marker blocks.

### Claude Code plugin

The repository also follows the standard plugin layout:

```text
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
skills/super-dev/...
```

Add the repository as a marketplace, then install the plugin:

```text
/plugin marketplace add Arian-Alijani/Claude-code-super-SKILL
/plugin install super-dev@super-dev-marketplace
```

Plugin installation uses Claude Code's normal model-driven skill matching. Use the direct installer when you want the additional always-on engineering bootstrap.

## Usage

Usually, ask for work normally. Examples:

- `Fix this intermittent test failure and prove the root cause.`
- `Implement this feature with the smallest maintainable diff.`
- `Review this authentication change for correctness and security.`
- `Reduce context/token use without reducing code quality.`

Manual invocation remains available with `/super-dev`. Asking for `normal mode` or `verbose` relaxes response compression but does not disable quality, safety, debugging, or verification rules.

## Verification

The repository has dependency-free structural and installer tests:

```bash
./tests/test.sh
```

They validate shell syntax, JSON manifests, reference routing, evaluation fixtures, idempotent user/project installation, dry-run behavior, uninstall preservation, and malformed-marker safety.

For behavioral measurement, `skills/super-dev/evals/evals.json` contains realistic low-, medium-, and high-risk prompts. Use Anthropic's `skill-creator` in fresh sessions to compare:

1. trigger precision (should invoke / should not invoke);
2. task success and regressions;
3. total tokens by category when available;
4. tool calls, duplicate reads, elapsed time, and clarification rounds.

## Token claims — intentionally conservative

Caveman-style brevity can substantially reduce **final response output**, but output is only part of a coding session. Input, cache reads, reasoning, skill instructions, code, and tool results often dominate. A large style prompt can even be net-negative on already terse work.

This skill therefore optimizes the larger levers:

- progressive disclosure instead of loading every procedure;
- search and metadata before broad reads;
- bounded, decisive tool output without hiding evidence;
- no unchanged re-reads or repeated conclusions;
- compact handoffs that prevent context reconstruction;
- isolated parallel research only when coordination pays for itself.

There is no universal savings percentage. The objective is **successful engineering work per token**, with correctness and safety as constraints.

## Research basis

The implementation was reviewed against current primary sources and community experience (July 2026):

- [Claude Code Skills documentation](https://docs.anthropic.com/en/docs/claude-code/skills) — description-driven invocation, lifecycle, supporting files, evaluation, and progressive disclosure.
- [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — smallest high-signal context, just-in-time retrieval, compaction, notes, and focused subagents.
- [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) — lean skill bodies, trigger tests, fresh-session baselines, and measured iteration.
- [Caveman](https://github.com/JuliusBrussee/caveman) — concise prose and exact technical content; its honest-numbers caveat informed the rejection of whole-session percentage claims.
- [Superpowers](https://github.com/obra/superpowers) — root-cause debugging, verification before completion, test-first regressions, and evidence over claims.
- [Task Observer](https://github.com/rebelytics/one-skill-to-rule-them-all) — feedback-driven improvement idea; automatic self-mutation was deliberately not adopted because unevaluated prompt changes can regress behavior.
- [ClaudeAI community skills discussion](https://www.reddit.com/r/ClaudeAI/comments/1sx44bc/drop_your_best_claude_skills_in_here/) — recurring user feedback favored progressive disclosure, session handoffs, proportional workflow, Superpowers for scoped work, and skepticism toward output-only token claims.

Community reports are anecdotal, not benchmarks. Repository evals exist so changes can be tested rather than accepted by popularity.

## Design boundaries

- No telemetry, network calls, runtime dependencies, or automatic code execution.
- No silent self-modification. Skill changes should pass evals and human review.
- No guarantee that a model will obey every prompt instruction; deterministic policy belongs in hooks or external tooling when truly required.
- No destructive Git, deployment, or data operation is authorized by this skill.

## License

MIT. See [LICENSE](LICENSE).
