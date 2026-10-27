#!/bin/bash
# dotfiles link|install|apply|check|adopt — see README. Bash 3.2 compatible (runs before brew/fish exist).
set -u
REPO=${DOTFILES:-$HOME/dotfiles}
LINKS=$REPO/links.txt
PRIVATE_DIRS=("$HOME/.config" "$HOME/.config/fish" "$HOME/.config/gh")
BREW_DIR=${DOTFILES_BREW_DIR:-/opt/homebrew/bin}
rc=0

usage() { echo "usage: dotfiles link|install|apply|check|adopt <target> [<repo-src>]"; }
drift() { echo "drift: $*"; rc=1; }
err() { echo "error: $*"; rc=1; }

expand() { case "$1" in "~"*) REPLY=$HOME${1#\~} ;; *) REPLY=$1 ;; esac; }

# Parses one links.txt line into OPT, SRC, S (abs source), T (abs target); fails on blank/comment lines.
parse() {
  local line=$1
  case "$line" in ''|'#'*) return 1 ;; esac
  OPT=0
  case "$line" in '?'*) OPT=1; line=${line#\?} ;; esac
  SRC=${line%% -> *}
  expand "${line#* -> }"; T=$REPLY
  S=$REPO/$SRC
}

# Calls "$@" once per mapping; parse results are in OPT/SRC/S/T.
each_link() {
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    parse "$line" && "$@"
  done < "$LINKS"
}

exists() { [ -e "$1" ] || [ -L "$1" ]; }

link_one() {
  if ! exists "$S"; then
    if [ "$OPT" = 1 ]; then echo "skip: $SRC"; else err "missing source $SRC"; fi
    return
  fi
  if [ -L "$T" ]; then
    local cur; cur=$(readlink "$T")
    [ "$cur" = "$S" ] && return
    if ln -sfn "$S" "$T"; then echo "relinked: $T (was $cur)"; else err "cannot relink $T"; fi
  elif [ -e "$T" ]; then
    echo "conflict: $T is a real file/dir; run 'dotfiles adopt $T'"; rc=1
  else
    if mkdir -p "$(dirname "$T")" && ln -s "$S" "$T"; then echo "linked: $T"; else err "cannot link $T"; fi
  fi
}

cmd_link() {
  each_link link_one
  local d
  for d in "${PRIVATE_DIRS[@]}"; do
    [ -d "$d" ] && { chmod 700 "$d" || err "chmod $d"; }
  done
}

install_fonts() {
  local f dest=$HOME/Library/Fonts
  shopt -s nullglob
  for f in "$REPO"/config/fonts/*.ttf "$REPO"/config/fonts/*.otf; do
    cmp -s "$f" "$dest/$(basename "$f")" && continue
    { mkdir -p "$dest" && cp -p "$f" "$dest/"; } || err "font $f"
  done
  shopt -u nullglob
}

# tools.txt lines are "kind name [source]"; mode is install or check.
tool_have() {
  case "$1" in
    uv) uv tool list 2>/dev/null | grep -q "^$2 " ;;
    cargo) cargo install --list 2>/dev/null | grep -q "^$2 " ;;
    rustup) rustup toolchain list 2>/dev/null | grep -q "^$2" ;;
    node) fnm list 2>/dev/null | grep -q "v$2 default" ;;
    fisher) [ "$(fish -c 'fisher list' 2>/dev/null | sort)" = "$(grep . "$REPO/$2" | sort)" ] ;;
    *) echo "unknown tool kind: $1" >&2; return 2 ;;
  esac
}

tool_install() {
  case "$1" in
    uv) if [ -n "$3" ]; then uv tool install --editable "$3"; else uv tool install "$2"; fi ;;
    cargo) if [ -n "$3" ]; then cargo install --path "$3"; else cargo install "$2"; fi ;;
    rustup) rustup toolchain install "$2" ;;
    node) fnm install "$2" && fnm default "$2" ;;
    fisher) fish -c 'type -q fisher; or curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher update' &&
      fish -c "type -q tide; or exit 0; tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Few icons' --transient=Yes" ;;
  esac
}

run_tools() {
  local mode=$1 kind name src f
  local PATH="$HOME/.cargo/bin:$HOME/.local/bin:$BREW_DIR:$PATH"
  for f in "$REPO/tools.txt" "$REPO/local/tools.txt"; do
    [ -f "$f" ] || continue
    while read -r kind name src; do
      case "$kind" in ''|'#'*) continue ;; esac
      case "$src" in "~"*) src=$HOME${src#\~} ;; esac
      tool_have "$kind" "$name" && continue
      if [ "$mode" = check ]; then
        drift "missing tool: $kind $name"
      else
        tool_install "$kind" "$name" "$src" </dev/null || err "install failed: $kind $name"
      fi
    done < "$f"
  done
}

have_brew() {
  command -v brew >/dev/null 2>&1 && return
  PATH="$PATH:$BREW_DIR"
  command -v brew >/dev/null 2>&1
}

cmd_install() {
  if have_brew; then
    brew bundle check --file "$REPO/Brewfile" >/dev/null 2>&1 ||
      brew bundle install --file "$REPO/Brewfile" --no-upgrade || err "brew bundle"
  else
    err "brew not found (https://brew.sh)"
  fi
  install_fonts
  run_tools install
}

TARGETS=()
collect_target() { TARGETS+=("$T"); }

is_target() {
  local x
  for x in ${TARGETS[@]+"${TARGETS[@]}"}; do [ "$x" = "$1" ] && return; done
  return 1
}

has_target_below() {
  local x
  for x in ${TARGETS[@]+"${TARGETS[@]}"}; do
    case "$x" in "$1"/*) return 0 ;; esac
  done
  return 1
}

check_link_one() {
  if ! exists "$S"; then
    [ "$OPT" = 1 ] || drift "missing source $SRC"
    return
  fi
  if [ -L "$T" ]; then
    local cur; cur=$(readlink "$T")
    [ "$cur" = "$S" ] || drift "$T -> $cur (want $S)"
  elif [ -e "$T" ]; then
    drift "$T not a symlink"
  else
    drift "$T missing"
  fi
}

check_perms() {
  local d mode
  for d in "${PRIVATE_DIRS[@]}"; do
    [ -d "$d" ] || continue
    mode=$(stat -f %Lp "$d")
    [ "$mode" = 700 ] || drift "$d mode $mode (want 700)"
  done
}

# Links into the repo that links.txt does not map, in the dirs it links into.
check_stale() {
  local seen="|" dir l cur
  local t
  for t in ${TARGETS[@]+"${TARGETS[@]}"}; do
    dir=$(dirname "$t")
    case "$seen" in *"|$dir|"*) continue ;; esac
    seen="$seen$dir|"
    [ -d "$dir" ] || continue
    while IFS= read -r l; do
      cur=$(readlink "$l")
      case "$cur" in "$REPO"/*) is_target "$l" || drift "stale link $l -> $cur" ;; esac
    done < <(find "$dir" -maxdepth 1 -type l)
  done
}

ignored() {
  local g
  while IFS= read -r g; do
    case "$g" in ''|'#'*) continue ;; esac
    # shellcheck disable=SC2254
    case "$1" in $g) return 0 ;; esac
  done < "$REPO/drift-ignore.txt"
  return 1
}

scan_unmanaged() {
  local e rel
  for e in "$1"/*; do
    exists "$e" || continue
    is_target "$e" && continue
    if [ -d "$e" ] && [ ! -L "$e" ] && has_target_below "$e"; then
      scan_unmanaged "$e"
    else
      rel=${e#"$HOME"/}
      ignored "$rel" || drift "unmanaged: $rel"
    fi
  done
}

check_unmanaged() {
  [ -d "$HOME/.config" ] || return
  shopt -s dotglob nullglob
  scan_unmanaged "$HOME/.config"
  shopt -u dotglob nullglob
}

check_brew() {
  if ! have_brew; then drift "brew not found"; return; fi
  brew bundle check --file "$REPO/Brewfile" --verbose || rc=1
}

check_vscode() {
  command -v code >/dev/null 2>&1 || return
  local have; have=$(mktemp) || { err "mktemp failed"; return; }
  if ! code --list-extensions | tr '[:upper:]' '[:lower:]' | sort > "$have"; then
    err "code --list-extensions failed"
  else
    sort "$REPO/config/vscode/extensions.txt" | diff "$have" - || rc=1
  fi
  rm -f "$have"
}

check_repo() {
  local st
  st=$(git -C "$REPO" status --porcelain 2>&1) || { drift "git status failed: $st"; return; }
  [ -z "$st" ] || { echo "$st"; rc=1; }
}

cmd_check() {
  TARGETS=(); each_link collect_target
  echo "== links";        each_link check_link_one; check_perms
  echo "== stale links";  check_stale
  echo "== unmanaged";    check_unmanaged
  echo "== brew";         check_brew
  echo "== tools";        run_tools check
  echo "== vscode";       check_vscode
  echo "== repo changes"; check_repo
  [ "$rc" = 0 ] && echo "no drift"
}

find_mapping() {
  [ "$T" = "$1" ] && { MAPPED=$SRC; MAPPED_OPT=$OPT; }
}

cmd_adopt() {
  local tgt=${1:-} src=${2:-} dir
  [ -n "$tgt" ] || { usage; return 2; }
  tgt=${tgt%/}
  expand "$tgt"; tgt=$REPLY
  case "$tgt" in /*) ;; *) tgt=$PWD/$tgt ;; esac
  dir=$(cd "$(dirname "$tgt")" 2>/dev/null && pwd) || { err "no such dir for $tgt"; return 1; }
  tgt=$dir/$(basename "$tgt")
  case "$tgt" in "$HOME"/*) ;; *) err "target must be under $HOME"; return 1 ;; esac

  MAPPED=
  each_link find_mapping "$tgt"
  if [ -n "$MAPPED" ]; then
    [ -z "$src" ] || [ "$src" = "$MAPPED" ] || { err "$tgt is already mapped to $MAPPED"; return 1; }
    { [ -f "$tgt" ] && [ ! -L "$tgt" ]; } || { err "$tgt must be a real file to take back"; return 1; }
    mkdir -p "$(dirname "$REPO/$MAPPED")" && mv -f "$tgt" "$REPO/$MAPPED" || { err "mv failed"; return 1; }
    rc=0; each_link link_one; return $rc
  fi

  src=${src%/}
  [ -n "$src" ] || { err "<repo-src> required for an unmapped target"; return 1; }
  case "/$src/" in */../*|//*) err "bad <repo-src>: $src"; return 1 ;; esac
  case "$src" in /*) err "bad <repo-src>: $src"; return 1 ;; esac
  [ -L "$tgt" ] && { err "$tgt is already a symlink"; return 1; }
  [ -e "$tgt" ] || { err "$tgt does not exist"; return 1; }
  exists "$REPO/$src" && { err "$src already exists in the repo"; return 1; }

  local line="$src -> ~${tgt#"$HOME"}"
  mkdir -p "$(dirname "$REPO/$src")" && mv "$tgt" "$REPO/$src" || { err "mv failed"; return 1; }
  if ! printf '%s\n' "$line" >> "$LINKS"; then
    mv "$REPO/$src" "$tgt"; err "cannot update links.txt"; return 1
  fi
  parse "$line"; rc=0; link_one
  if [ "$rc" != 0 ]; then
    sed '$d' "$LINKS" > "$LINKS.tmp" && mv "$LINKS.tmp" "$LINKS"
    mv "$REPO/$src" "$tgt"
    return 1
  fi
}

[ -f "$LINKS" ] || { echo "error: $LINKS not found" >&2; exit 1; }
cmd=${1:-}
[ $# -gt 0 ] && shift
case "$cmd" in
  link) cmd_link ;;
  install) cmd_install ;;
  apply) cmd_link; cmd_install ;;
  check) cmd_check ;;
  adopt) cmd_adopt "$@" ;;
  *) usage >&2; exit 2 ;;
esac
[ "$rc" = 0 ]
