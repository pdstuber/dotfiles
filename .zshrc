if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=40'

plugins=(aws git npm node rust zsh-autosuggestions docker docker-compose golang zsh-syntax-highlighting terraform gcloud)

source $ZSH/oh-my-zsh.sh

export GOPATH="${HOME}/go"

source $HOME/.cargo/env
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:${HOME}/go/bin:${HOME}/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/go/bin:${HOME}/.local/bin:${HOME}/bin:${HOME}/flutter/bin:/usr/local/texlive/2021/bin/universal-darwin:${HOME}/platform-tools
export VISUAL=vim
export EDITOR="$VISUAL"
export GPG_TTY="tty"
export LANG=en_US.UTF-8

alias vim="nvim"
export EDITOR="nvim"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
