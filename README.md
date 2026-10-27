# dotfiles

Plain symlinks, driven by `links.txt` and one bash script, `dotfiles`. Editing a file in `~` edits the repo. Not pushed anywhere.

## New Mac

1. Copy this repo to `~/dotfiles` (no remote) and the MonoLisa font to `config/fonts/` (gitignored, paid).
2. Install [Homebrew](https://brew.sh) and rustup (`curl https://sh.rustup.rs | sh`); `tools.txt` needs rustup for its `cargo`/`rustup` lines.
3. `~/dotfiles/dotfiles apply` links everything, runs `brew bundle`, copies fonts and installs the tools in `tools.txt`. Add `~/.local/bin` to `PATH` to call it as `dotfiles`.

## Daily

- Edit files in `~`; the change lands in the repo. Commit with `git -C ~/dotfiles`.
- New config: `dotfiles adopt <path> config/<tool>/<file>` moves it into the repo and adds the `links.txt` line.
- An app replaced a link with a real file (gh, Copilot CLI do this): `dotfiles adopt <path>` keeps the app's version in the repo; review it with `git diff`.
- `dotfiles link` never overwrites a real file; it reports a conflict instead.
- Package: add to `Brewfile` (brew/cask) or `tools.txt` (`kind name [source]`: uv, cargo, rustup, node). Machine-specific apps can stay manually installed.
- Secrets or app state: add the path to `drift-ignore.txt`.

## Drift check

`dotfiles check` exits 1 if anything differs: links, folder permissions, stale links into the repo, unmanaged `~/.config` entries, Brewfile (missing only; extra packages are fine), `tools.txt`, VS Code extensions, uncommitted repo changes. A function saved with `funcsave` shows up as an uncommitted repo change.

`bash test.sh` runs the script's tests in a temp home.

## Layout

- `config/<tool>/`: the files; `links.txt` maps each to its target
- `config/fonts/`: font source, copied by `dotfiles install`
- `config/agents/AGENTS.md`: global instructions for Copilot CLI, Claude Code and Codex. For machine-specific instructions, add `local/agents/*.instructions.md` and set `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` to that folder in `local/fish/conf.d/` (Copilot only)
- `local/`: gitignored, per-machine (e.g. work proxy). `local/fish/conf.d/*.fish` is sourced, `local/fish/functions/` autoloads, `local/tools.txt` extends `tools.txt`
