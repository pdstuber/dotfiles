# Path
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin $GOPATH/bin /usr/local/bin
fish_add_path /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin

# Environment
set -gx GOPATH "$HOME/go"
set -gx GIT_TERMINAL_PROMPT 1
set -gx VISUAL nvim
set -gx EDITOR "$VISUAL"
set -x LANG en_US.UTF-8

alias vim nvim

type -q fzf_configure_bindings; and fzf_configure_bindings --directory=\ct

if not type -q tide; and type -q starship
    starship init fish | source
end

# Added by Antigravity CLI installer
set -gx PATH "/Users/pdstuber/.local/bin" $PATH
