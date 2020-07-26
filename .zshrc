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
export PATH=${HOME}/go/bin:${HOME}/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/go/bin:${HOME}/.local/bin:${HOME}/bin
export VISUAL=vim
export EDITOR="$VISUAL"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
