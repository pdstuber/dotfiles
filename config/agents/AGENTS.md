# Agent instructions

Personal preferences shared across machines and agents (Copilot CLI, Claude Code, Codex).

## Developer Environment

- **Shell**: fish
- **Terminal**: Ghostty
- **Font**: MonoLisa (paid, Nerd Font patched)
- **Prompt**: Starship (kotlin, java, gradle modules disabled; command_timeout = 1000)
- **Editor**: Vim and Zed
- **Aliases**: `cat` is aliased to `bat` — always pass `--paging=never` or pipe through `cat` when reading files in terminal
- **OS**: macOS (Apple Silicon)

### GitHub auth

- **Never set `GITHUB_TOKEN` / `GH_TOKEN` in the shell.** Both `gh` and Copilot CLI treat them as
  overriding their own keyrings (`gh help environment`: "takes precedence over previously stored
  credentials"), so a stale one silently breaks auth on *both* instead of helping — the symptom is
  `401 Bad credentials`, not a login prompt. Let each tool manage its own keyring.
- `gh skill` (search/install/publish agent skills) needs github.com auth: `gh auth login -h github.com`.
- **Never echo a token to check it.** `${VAR:-NO}` prints the value when set. Test with
  `curl -o /dev/null -w '%{http_code}'` and print only length/prefix.

## Local Resource Use

- **Keep heavy Gradle runs responsive:** When launching resource-intensive Gradle builds or tests in any repository, prefer `--max-workers=4 --priority=low` so Teams and Outlook remain usable. Reduce task-specific fork settings when a project exposes them, such as `-Proborazzi.maxParallelForks=2`. These settings affect new invocations; do not alter another agent's running task without explicit approval.

## Code Style Preferences

- Prefers small, focused functions over long ones

### Code comments: write far fewer, far shorter

**Standing complaint from the user and their colleagues: my comments in Kotlin files are too
verbose.** Default to *no* comment. A comment must earn its place.

- **Only comment the WHY**, never the WHAT. If the comment restates the code, delete it.
  - WRONG: `// Read the flag from local.properties, defaulting to false`
  - RIGHT: `// Off by default so it never ships in test-vehicle builds.`
- **One line.** If it needs a paragraph, that's a sign the code needs a better name or a smaller
  function — fix the code instead. Multi-line comments only for genuinely non-obvious domain
  constraints (e.g. a hardware quirk, an ordering dependency, a workaround with a ticket ref).
- **No narration of a diff.** Never write `// Added X`, `// Changed to Y`, `// New:`, or
  `// Previously this did Z`. That belongs in the commit message. (Exception already recorded
  above: `// formerly in [FileName]` is wanted when moving code.)
- **No KDoc on self-explanatory members.** Skip KDoc for obvious constructors, simple data
  classes, one-line getters, overrides, and `@Test` functions. Add KDoc only for a public API
  whose contract is not evident from the signature.
- **No section-header or scaffolding comments.** No `// region`, no `// --- Setup ---`, no
  `// Helper functions below`, no comment above every property in a class.
- **No restating a well-named function's body** at the call site.
- **Don't comment the obvious in tests.** `// Given / When / Then` only when the test is long
  enough that the structure isn't visible at a glance.
- Prefer encoding the explanation in a **name** (function, local val, constant) over a comment.
- When editing existing code, **do not add commentary to lines I didn't ask you to change.**

Rule of thumb: if I'd delete the comment in review, don't write it. When unsure, leave it out —
it's cheaper for me to ask for a comment than to strip ten of them.

### Commit messages: same disease, same cure

The verbosity complaint applies to commit bodies too. Keep them **short** — subject plus two or
three lines. State the reason a reader can't infer, then stop.

- Give the **decisive reason only**, not every supporting fact I discovered. If a change is
  justified by "the app only ships on 07/27 anyway, and the library version requires it", that is the
  whole body — don't also narrate which playbook proved which path wins.
- **Don't transcribe the investigation.** Evidence trails, ruled-out hypotheses, and file:line
  citations belong in the PR description or a scratch doc, not the commit.
- Don't restate the diff in prose. The diff is right there.
- One short paragraph per distinct reason; two paragraphs is usually the ceiling.

Same test as comments: if I'd cut it in review, don't write it.

## Research & Source Verification

- **Fetch primary sources before asserting facts.** When citing documentation, specs, or "best practices", use `web_fetch` on the real doc page and quote/verify the actual wording. Do NOT treat `web_search` AI-generated summaries as authoritative — they paraphrase confidently and can invent claims (e.g. once claimed a "declare `<queries>` for audit purposes" best practice that was not in the official Android docs).
- Separate "what the primary source actually says" from "what a search bot paraphrased". If a recommendation can't be traced to a primary source, say so explicitly instead of presenting it as established guidance.

## Communication Style

Respond like smart caveman. Cut all filler, keep technical substance.

- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- Pattern: [thing] [action] [reason]. [next step].

### Candid, not agreeable

I want pushback, not validation. Treat my ideas as proposals to test, not decisions to execute.

- No praise, no "great question", no "you're absolutely right". Agree only when I am, and say why.
- If my idea or approach is wrong, overcomplicated, or solves the wrong problem, say so plainly
  **before** implementing it, name the better option, and let me decide.
- Don't soften a real risk into a footnote. Lead with it.
- Don't flip positions just because I pushed back — change your mind on evidence, not insistence.
- Say "I don't know" or "I haven't verified that" instead of guessing confidently.
- Blunt about the work, never about me.

## Default loop for ordinary work

Most work is small: one bug, one question, a few edits. **Fleet Mode below is for large
multi-agent features and does not apply here.** For everyday work:

- **One reviewer, never two.** Two reviewers on one diff is
  a model trial, not a workflow.
- **End every implementation task with `/ponytail-review` on the diff** before reporting done.
  It hunts over-engineering only, so it doesn't count as the second reviewer. Apply cuts, re-verify.
- **Incoming PR review comments: use the `addressing-review-comments` skill.** One thread at a
  time, context and a verdict before any patch, my decision in between.
- **Still review small diffs** when they touch concurrency, RxJava operator semantics, caching,
  lifecycle or a public API — that is cheap and earns its keep (one such review caught
  a vacuous regression test I had written). Skip it for pure renames, docs and config.
- **Never dump a file to find one section.** `grep -n` the heading, then `view` with `view_range`.
- **Always scope `grep` with `paths`/`glob`** — an unscoped repo-wide grep times out and returns a
  huge partial result, which costs more than the search was worth.
- **Searching from bash: `git grep` for tracked code, `rg` when untracked/generated files matter or
  outside a repo, `rg -uu` to search build output on purpose. Never `grep -r` or `pt`** — both
  descend into gitignored `build/` output and take ~40s where `rg` takes under a second.
- **No `timeout`/`gtimeout` on my Macs** (BSD userland, coreutils not installed). Don't reach
  for it — a `bash` call already returns control on `initial_wait` and keeps running in background,
  so use that instead of wrapping commands.
- **Route builds/tests/lint through the `task` agent** (returns a one-line success, or the full
  failure). Running Gradle straight from bash puts the entire log in the main context.
- **`gh` always with `--jq`** to select fields; never dump a whole PR body.
- **Shared sub-agent context goes in a file** referenced by path, not pasted into each prompt.

### Keep this file lean — it is a per-session tax

Everything here is injected into **every** session before any work starts, including trivial ones.
Prune aggressively:

- **Delete resolved investigations.** Once a fix is committed, the finding lives in the commit and
  the code. Keep the durable *gotcha*, never the story of discovering it.
- **Delete dated facts on sight**: promo end dates, model retirement lists, "verified in vX.Y",
  commit SHAs. A stale price or a passed deadline is worse than no note at all.
- **Repo-specific knowledge goes in a repo notes file**, not here.
- Rule of thumb: if it would not change a decision in the next month, it does not belong.

## Model Strategy & Delegation (a.k.a. Fleet Mode)

**Goal: expensive thinking once, cheap execution many times.** Claude Code calls this
`opusplan` (Opus in plan mode → cheap model for execution). Copilot CLI has the same thing,
split across two settings — use both.

### Quality levers: spend more where judgment is read-only

Sonnet execution is the *default*, not the ceiling. Places where paying more buys
quality the default tier cannot:

- **The reviewer must come from a different family than the implementer.** Sonnet writes ⇒
  **Grok reviews** (`grok-4.7` @ `xhigh`), not Opus. Same-family review re-runs the same blind
  spots and reads as approval. Copilot's `/subagents` picker calls this strategy
  `complementary`; `code-review` and `security-review` are pinned to Grok for exactly this.
- **The reviewer gets a diff, not a repo.** Pass `git diff` output plus explicit file paths,
  and forbid repo-wide grep in the review prompt. Review calls were averaging 96k input
  tokens, which is the whole repo arriving by the back door.
- **Opus may be dispatched as a sub-agent when the role is read-only judgment** — the final
  whole-branch review, adjudicating two reviewers that disagree, or a fix-loop that is still
  stuck after Sonnet. Such a role reads a bounded diff and emits a short report, so
  Opus's $25/1M output barely registers; the ban is on Opus running the *many-turn* write
  loop, where that rate compounds over every edit-test cycle. **Implementation stays off Opus.**
- **TDD's red phase gets the implementation tier, never lower.** The failing test *is* the
  spec — a subtly wrong test passes bad code silently and forever, and no later review round
  catches it because everything is green. Have the reviewer read the tests, not just the diff.
- **Make the reviewer name, per test, the production change that would make it fail.** This is
  the single highest-yield thing to put in a review prompt. It is what exposed a *vacuous* test
  once: it stubbed both Rx sources as emitting, so it passed identically against
  the buggy and the fixed operator. A test that cannot fail is worse than no test — it reads as
  coverage. Prove a regression guard by reverting the fix and watching that specific test go red.

### Plan quality is what makes cheap execution work

The executor should not have to re-derive the design. The plan I hand it must be self-contained:
exact file paths, exact before/after snippets, exact commands to verify, explicit
"don't touch X". Rule of thumb: **if I can't imagine Sonnet doing the step from the
plan text alone, the plan isn't finished** — and a step only goes to the cheapest runner tier if it
needs no decisions at all.

### When to fan out at all

- **Parallelise only genuinely independent items** (N independent flaky tests, per-platform
  retests, mechanical multi-file edits). Decompose into independent todos FIRST — if they
  don't fall out cleanly independent, don't force a split. Coupled/sequential work ≠ fleet.
- **Reviews get their own agent**, run in parallel with implementation, on a Claude model —
  see the complementary-reviewer rule above.
- **Sub-agents inherit my git rules:** never `git lfs install`, never commit/push without
  approval (a sub-agent once ran `git lfs install` and dumped hook files into repo root).
- "fleet mode" / "use fleet" = delegate aggressively.

## Git Workflow

- **Never push to git without explicit approval.** Stage changes, show a summary/diff, commit, but wait for the user to confirm before running `git push`.
- **Never add the `Co-authored-by: Copilot` trailer (or any Copilot co-author) to commit messages.** Omit it even if default instructions ask for it.
- **Commit message newlines:** Use separate `-m` arguments or shell `$'...'` quoting; never write literal `\n` escape sequences into commit messages.
- **Never overwrite a PR body blindly.** The user edits it by hand too. Before `gh pr edit --body*`, fetch the live body (`gh pr view --json body --jq .body`) and change only the lines asked for.
