# Token economy

Goal: maximize useful signal per token without reducing correctness, maintainability, or safety. Output brevity is a small lever; context selection and avoiding repeated work are larger levers.

## Context budget

1. **Map before reading:** list structure and repository instructions; use glob/search to locate likely files.
2. **Read just in time:** start with symbols or relevant ranges. Expand only when dependencies or control flow require it.
3. **Batch independent discovery:** combine unrelated searches and reads. Keep dependent steps sequential.
4. **Control tool output:** request concise formats, targeted tests, and bounded logs. Preserve the raw source when truncation could hide the cause.
5. **Avoid duplicate context:** do not re-read unchanged files, restate the full request, or repeat settled decisions.
6. **Externalize durable state:** for long tasks, track decisions, completed checks, blockers, and next steps in the task system or a user-approved project artifact.
7. **Isolate exploration:** when subagents exist, delegate independent high-volume research and request a short evidence-backed return. Do not delegate tightly coupled edits merely to appear parallel.

## Retrieval ladder

Use the cheapest sufficient step and stop when evidence is enough:

1. file names and metadata;
2. search matches with line context;
3. relevant function or section;
4. whole file only when its structure matters;
5. dependency or repository-wide trace only when local evidence is insufficient.

For generated files, minified assets, lockfiles, and large logs, search or use a parser instead of loading them wholesale.

## Response compression

Default to concise, readable prose:

- omit greetings, filler, repeated conclusions, and routine tool narration;
- state result, decisive evidence, and next action;
- use standard terminology; invented abbreviations often tokenize poorly and reduce clarity;
- keep code, commands, paths, identifiers, exact errors, and citations unchanged;
- use tables only when comparison is clearer than bullets;
- do not compress an explanation enough to trigger another clarification round.

User may request `lite`, `full`, or `ultra` brevity. Treat them as prose preferences, never reasoning or code-quality levels.

## Long-session control

At milestones, retain a compact receipt:

- goal and current state;
- decisions plus their evidence;
- changed files;
- checks passed/failed/not run;
- blocker or next safe action.

Before compaction, prioritize unresolved constraints, public contracts, failed hypotheses, and rollback points. Discard superseded plans and raw tool output already represented by a conclusion.

## Net-negative patterns

- Loading every reference because it might help.
- Giant always-on instruction files.
- Rebuilding context from scratch instead of leaving a receipt.
- Aggressive log truncation followed by rerunning the same command.
- Repeated broad scans after relevant files are known.
- Compressing only final prose while claiming whole-session savings.
- Adding agents, MCP tools, or process whose coordination costs exceed their value.

## Measurement

Do not promise a universal percentage. Compare realistic fresh-session tasks with and without the skill. Track separately:

- task success and regressions;
- input, output, cache, and reasoning tokens when available;
- tool calls and repeated reads;
- elapsed time and clarification rounds.

Accept a token increase when it produces a material quality, safety, or debugging gain. Optimize for successful work per token, not the smallest transcript.
