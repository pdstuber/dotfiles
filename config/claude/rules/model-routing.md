# Claude model routing

Claude Code routing (Copilot, Codex and Antigravity do not read this file). It refines the shared "Models" section.

Pin `model` and `effort` on every subagent and workflow stage. Explicit asks and project files override.

| Stage | Model | Effort |
|---|---|---|
| Scout, list, count, transcribe, run checks and digest the output | Sonnet | low |
| Code-reference and fact checks | Sonnet | medium |
| Implement a task, and fix what its review found | Sonnet | high |
| Write a plan or design; diagnose a block; review the whole branch once | Opus | high |
| Judging between options, a contested design call, an adversarial verify, a diagnosis that failed once (a few calls, never a whole stage) | Fable | high |

Fable outside the table only when the owner asks; on a Fable main session keep decisions there and hand building and
fact-finding to Sonnet or Opus agents.

Only when the owner asks: a second reviewer, an independent-family reviewer (recipes in the Wargrid memories `second-family-reviewers`, `codex-worker`), ultracode.
