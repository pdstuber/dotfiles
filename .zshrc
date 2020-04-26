export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel9k/powerlevel9k"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=40'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline time status root_indicator)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
POWERLEVEL9K_HIDE_BRANCH_ICON=true

plugins=(aws git npm node rust cargo zsh-autosuggestions docker mvn docker-compose golang zsh-syntax-highlighting terraform kubectl gcloud)

source $ZSH/oh-my-zsh.sh
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection clipboard -o'

export GOPATH="${HOME}/go"

source $HOME/.cargo/env
export PATH=${HOME}/go/bin:${HOME}/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/go/bin:${HOME}/node-v12.13.0-linux-x64/bin:${HOME}/.npm-packages/bin:${HOME}/.local/bin:${HOME}/bin
export GCLOUD_CREDENTIALS_JSON=~/.gcloud/creds.json
export GCLOUD_PROJECT_ID=arcane-glow-256905
export VISUAL=vim
export EDITOR="$VISUAL"
