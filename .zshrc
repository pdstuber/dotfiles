export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="agnoster"
ZSH_THEME="powerlevel9k/powerlevel9k"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=40'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline time status root_indicator)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
POWERLEVEL9K_HIDE_BRANCH_ICON=true

plugins=(git npm node rust cargo zsh-autosuggestions docker mvn rustup docker-compose golang zsh-syntax-highlighting terraform kubectl)

source $ZSH/oh-my-zsh.sh

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

export GOPATH="${HOME}/go"


