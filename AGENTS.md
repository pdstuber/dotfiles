# Working in this repo

Read `README.md` first; it is the source of truth for layout and workflow.

- Files in `~` are symlinks into `config/`. Edit the repo file. New config: `dotfiles adopt <path> config/<tool>/<file>`; every link needs a `links.txt` line.
- `config/agents/AGENTS.md` is the global instruction file for every agent on every machine, injected into every session. Keep it lean (Claude Code docs: under 200 lines):
  - Delete resolved investigations; keep the durable gotcha, not the story.
  - Delete dated facts (deadlines, model lists, versions, SHAs).
  - Repo-specific rules go in that repo's notes, not there.
  - If it wouldn't change a decision in the next month, it doesn't belong.
- Never edit `local/` (gitignored, per machine) or paths in `drift-ignore.txt` (secrets, app state).
- Verify with `bash test.sh` and `./dotfiles.bash check`.
