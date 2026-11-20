# Claude model routing

Claude Code routing (Copilot and Codex do not read this file; Grok loads it through its Claude compatibility and may ignore it). It refines the shared "Model routing" section.

Pin `model` and `effort` on every workflow stage and subagent, so the fleet never inherits the session's
model by accident; put the mix in the workflow description. Route by how hard the stage's judgment is,
never variety for its own sake. Explicit asks and project files override.

The main session runs Opus. If a plan is due and the session is not on Opus, say so and delegate the plan
to an Opus high agent.

| Stage | Model | Effort |
|---|---|---|
| Scout, inventory, list or count, transcribe a result verbatim | Sonnet | low |
| Decision-free transform; run checks and digest the output | Sonnet | low |
| Code-reference and fact checks | Sonnet | medium |
| Implement a plan task | Sonnet | high |
| Write a plan, spec or design; fix round; correctness review | Opus | high |
| Closure check; synthesis of many results | Opus | medium |
| Final (gate) review of a branch | Grok 4.7 plus an Opus whole-branch pass; Opus alone if Grok is missing or fails | high |
| Adversarial verify, judging between options, contested design call (a few calls, never a whole stage) | Fable | high or xhigh |

Fable outside the table only when the owner asks; on a Fable main session keep decisions there and hand building and
fact-finding to Sonnet or Opus agents. Independent-family reviewers (Grok, Codex): recipes in the project's private
handoffs (Wargrid memories `grok-final-reviews`, `codex-worker`); Opus when the CLI is missing or failing.
