# Claude model routing

Claude Code routing (Copilot, Codex and Antigravity do not read this file). It refines the shared "Models" section.

Pin `model` and `effort` on every subagent and workflow stage. Explicit asks and project files override.

| Stage | Model | Effort |
|---|---|---|
| Scout, list, count, transcribe, run checks and digest the output | Sonnet | low |
| Code-reference and fact checks | Sonnet | medium |
| Implement a task, and fix what its review found | Sonnet | high |
| Write a plan or design; diagnose a block; review the whole branch once | Opus | high |

Only when the owner asks: a second reviewer, an independent-family reviewer (recipes in the Wargrid memories `second-family-reviewers`, `codex-worker`), Fable for an adversarial verify or a contested design call, ultracode.
