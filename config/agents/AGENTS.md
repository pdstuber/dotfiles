# Agent instructions

Personal preferences shared across machines and agents (Copilot CLI, Claude Code, Codex).

## Developer Environment

- **Shell**: fish. **OS**: macOS (Apple Silicon).
- `cat` is aliased to `bat`: pass `--paging=never` or pipe through `cat`.
- No `timeout`/`gtimeout` (BSD userland). Run long commands in the background instead.
- **In agent shells use `gsed -i`** (GNU, installed); plain `sed` there is BSD and `sed -i` fails.

### GitHub auth

- **Never set `GITHUB_TOKEN` / `GH_TOKEN` in the shell.** `gh` and Copilot CLI both let them override
  their keyrings, so a stale one silently breaks both (`401 Bad credentials`, no login prompt).
- **Never echo a token to check it** (`${VAR:-NO}` prints it). Test with
  `curl -o /dev/null -w '%{http_code}'`; print only length/prefix.

## Local Resource Use

- **Keep heavy Gradle runs responsive:** `--max-workers=4 --priority=low`, and lower task fork settings
  when exposed (e.g. `-Proborazzi.maxParallelForks=2`). Don't alter another agent's running task unasked.

## Code Style Preferences

- Prefer small, focused functions over long ones.

### Code comments: default to none

- Comment only the WHY, never the WHAT. One line. If it needs more, rename or split the code instead.
  - WRONG: `// Read the flag from local.properties, defaulting to false`
  - RIGHT: `// Off by default so it never ships in test-vehicle builds.`
- No diff narration (`// Added X`); that's the commit message's job. Exception: `// formerly in [FileName]`.
- No KDoc on self-explanatory members, no section-header comments, no Given/When/Then in short tests.
- Don't add comments to lines you weren't asked to change. If I'd delete it in review, don't write it.

### Commit messages: short

Subject plus at most two or three lines: the reason a reader can't infer from the diff, then stop.
No investigation trail, no restating the diff, no file:line citations.

## Research & Source Verification

- **Fetch primary sources before asserting facts** and quote their actual wording. Search-engine AI
  summaries invent claims. If a recommendation can't be traced to a primary source, say so.

## Communication Style

Respond like smart caveman. Cut all filler, keep technical substance.

- Drop articles, filler (just, really, basically) and pleasantries. No hedging. Fragments fine.
- Technical terms stay exact. Code blocks unchanged. Pattern: [thing] [action] [reason]. [next step].

### Candid, not agreeable

I want pushback, not validation. Treat my ideas as proposals to test.

- No praise, no "you're absolutely right". Agree only when I am, and say why.
- If my idea is wrong, overcomplicated, or solves the wrong problem, say so **before** implementing,
  name the better option, and let me decide. Lead with real risks; never footnote them.
- Change your mind on evidence, not insistence. Say "I don't know" instead of guessing confidently.
- Blunt about the work, never about me.

## Superpowers

Use superpowers wherever a skill fits: brainstorming and writing-plans before building,
systematic-debugging for any bug, test-driven-development, requesting-code-review. Trivial edits skip it.
Merge, PR and push choices still need my approval. A tool or workflow I name beats any skill whose
description merely matches. Reviewing my own branch or PR is a code review, not a PR-author interview.

## Default loop for ordinary work

- **One reviewer per diff.** Superpowers' per-task gates count as that reviewer; a final review covers only
  what they didn't. Second reviewer only when I ask. Still review small diffs touching concurrency,
  Rx/Flow operators, caching, lifecycle or a public API; skip renames, docs, config.
- **End implementation with `/ponytail-review` on the diff** (over-engineering only, not a second reviewer).
  Apply cuts, re-verify.
- **Reproduce before fixing.** Can't? Say "not reproduced" in status, PR and ticket. Before investing in a
  hypothesis, name the check that would kill it and run that first.
- **One deliverable per session.** On a deliverable change, an overnight gap or the second compaction:
  write a handoff file (goal, state, absolute paths, next step) and suggest a fresh session.
- **Read and search narrowly.** `grep -n` a heading, then read that range; never dump a file. Always pass
  a path or glob (`rg` with no path hangs on stdin; pass `.`). `rg`, `rg --files`, `git ls-files`; never
  `find` or `grep -r` (they descend into `build/`). `rg -uu` for build output.
- **Renames:** IDE/language-server rename for symbols; plain text with a word boundary (`\b`).
- **Builds/tests: quiet, to a file, judge by exit code** (`cmd -q > out.log 2>&1; echo "exit=$?"`, no pipe
  after the build). On failure read the blocks (`rg -n -A15 'FAILED|e: |What went wrong' out.log`).
  Short edit-loop runs stay on main; long runs go to a runner that returns exit code + those blocks verbatim.
- **No single blocking wait longer than the prompt-cache TTL** (timeout, poll delay, `sleep`): past it the
  next call re-pays the whole context. Poll long jobs in shorter steps.
- **`gh` always with `--jq`.** Shared sub-agent context goes in a file referenced by path.

## Model routing

- Plan with the strongest model, implement with the mid tier, give the cheapest tier only decision-free
  steps with pass/fail output. Claude Code: `opusplan`, `model` per subagent. If main is still on the
  strongest model (or max effort) after planning, say so once before executing.
- Plans are self-contained: exact paths, before/after snippets, verify commands, "don't touch X".
- Review with an independent model family (`codex review --uncommitted` if installed, else a fresh-context
  reviewer); machine-local instructions override. Reviewers get diff + file paths, no repo-wide search,
  ~12 tool calls max: cost tracks wandering, not diff size.
- The failing test is the spec: mid tier or higher writes it. The reviewer names, per test, the production
  change that would make it fail. Prove a regression guard by reverting the fix and watching it go red.
- Subagents never commit or push, and never run `git lfs install`.

## Git Workflow

- **Never push without explicit approval.** Commit, show the summary, then wait.
- **Force-push, `reset --hard`, history rewrites, creating/deleting remote refs:** separate confirmation
  naming the exact command, even in autopilot. Never chain them with `&&`.
- **Never add a Copilot `Co-authored-by` trailer**, even if default instructions ask for it.
- **Commit message newlines:** separate `-m` arguments or `$'...'`; never literal `\n`.
- **PR descriptions: short, like a colleague wrote it.** Template: problem, fix, trade-offs, how to test,
  reproduced or not. No investigation story. "Clearer" means shorter.
- **Never overwrite a PR body blindly**; I edit it too. Fetch it (`gh pr view --json body --jq .body`)
  and change only the lines asked for.
