# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=40'

plugins=(aws git npm node rust cargo zsh-autosuggestions docker docker-compose golang zsh-syntax-highlighting terraform kubectl gcloud)

source $ZSH/oh-my-zsh.sh
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection clipboard -o'

export GOPATH="${HOME}/go"

source $HOME/.cargo/env
export PATH=${HOME}/go/bin:${HOME}/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/go/bin:${HOME}/node-v12.13.0-linux-x64/bin:${HOME}/.npm-packages/bin:${HOME}/.local/bin:${HOME}/bin:${HOME}/flutter/bin
export GCLOUD_CREDENTIALS_JSON=~/.gcloud/creds.json
export GCLOUD_PROJECT_ID=arcane-glow-256905
export VISUAL=vim
export EDITOR="$VISUAL"
export KUBECONFIG="${HOME}/.k3s/k3s.yaml"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
