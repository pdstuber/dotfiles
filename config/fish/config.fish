# Path
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin $GOPATH/bin /usr/local/bin
fish_add_path /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin

# Environment
set -gx GOPATH "$HOME/go"
set -gx GIT_TERMINAL_PROMPT 1
set -gx VISUAL vim
set -gx EDITOR "$VISUAL"
set -x LANG en_US.UTF-8

type -q fzf_configure_bindings; and fzf_configure_bindings --directory=\ct

type -q tide; or type -q starship; and starship init fish | source