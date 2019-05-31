export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git npm node rust cargo zsh-autosuggestions docker mvn rustup docker-compose golang zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=40'

export GOPATH="${HOME}/go"


