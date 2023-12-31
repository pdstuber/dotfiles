# Path
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin $GOPATH/bin /usr/local/bin
fish_add_path /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin

# Environment
set -gx GOPATH "$HOME/go"
set -gx GIT_TERMINAL_PROMPT 1
set -gx VISUAL nvim
set -gx EDITOR "$VISUAL"
set -gx GPG_TTY $(tty)
set -x LANG en_US.UTF-8

starship init fish | source

