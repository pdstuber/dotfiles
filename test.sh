#!/bin/bash
# Self-contained tests for ./dotfiles: temp HOME, stubbed brew, no network.
set -u
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home DOTFILES=$tmp/repo
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export TMPT=$tmp DOTFILES_BREW_DIR=$tmp/nobrew
export PATH="$HOME/.local/bin:/usr/bin:/bin"
n=0

fail() { echo "FAIL (case $n): $*"; echo "--- output:"; echo "$out"; exit 1; }
run() { out=$(cd / && "$here/dotfiles" "$@" 2>&1); rc=$?; }
has() { case $out in *"$1"*) ;; *) fail "output lacks: $1" ;; esac; }
hasnt() { case $out in *"$1"*) fail "output has: $1" ;; esac; }
expect_rc() { [ "$rc" = "$1" ] || fail "rc=$rc, want $1"; }
case_() { n=$((n + 1)); echo "case $n: $*"; }
is_link_to() { [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; }
commit() { git -C "$DOTFILES" add -A && git -C "$DOTFILES" commit -qm x; }
baseline() { run link; run check; expect_rc 0; }

mkdir -p "$HOME/.local/bin" "$DOTFILES/config/a" "$DOTFILES/config/d" "$DOTFILES/config/sp ace"
cat > "$HOME/.local/bin/brew" <<'EOF'
#!/bin/sh
echo "$@" >> "$TMPT/brew.log"
case "$*" in
  *cleanup*) cat "$TMPT/cleanup.out" 2>/dev/null ;;
  *check*) [ -e "$TMPT/check.fail" ] && exit 1 ;;
esac
exit 0
EOF
chmod +x "$HOME/.local/bin/brew"
echo a > "$DOTFILES/config/a/file.txt"
echo f > "$DOTFILES/config/sp ace/f.txt"
echo x > "$DOTFILES/config/d/x.fish"
printf '# comment\n\nconfig/a/file.txt -> ~/.config/a/file.txt\nconfig/sp ace/f.txt -> ~/Library/Application Support/x/f.txt\nconfig/d -> ~/.config/d\n?config/mem.md -> ~/.copilot/mem.md\n' > "$DOTFILES/links.txt"
printf '# ignores\n.config/ignored*\n' > "$DOTFILES/drift-ignore.txt"
printf '# none\n' > "$DOTFILES/tools.txt"
: > "$DOTFILES/Brewfile"
git -C "$DOTFILES" init -q -b main

case_ "link creates links incl. spaces; optional source skipped"
run link; expect_rc 0
is_link_to "$HOME/.config/a/file.txt" "$DOTFILES/config/a/file.txt" || fail "file link"
is_link_to "$HOME/Library/Application Support/x/f.txt" "$DOTFILES/config/sp ace/f.txt" || fail "space link"
is_link_to "$HOME/.config/d" "$DOTFILES/config/d" || fail "dir link"
has "skip: config/mem.md"

case_ "required missing source fails"
cp "$DOTFILES/links.txt" "$tmp/links.bak"
echo 'config/nope -> ~/.config/nope' >> "$DOTFILES/links.txt"
run link; expect_rc 1; has "missing source config/nope"
cp "$tmp/links.bak" "$DOTFILES/links.txt"

case_ "second link is silent and idempotent"
echo m > "$DOTFILES/config/mem.md"; run link; expect_rc 0
commit; run link; expect_rc 0; [ -z "$out" ] || fail "not silent"

case_ "clean check passes and used the brew stub"
run check; expect_rc 0; has "no drift"
[ -s "$tmp/brew.log" ] || fail "brew stub not called"

case_ "conflicts: real file and real dir are never touched"
rm "$HOME/.config/a/file.txt"; echo mine > "$HOME/.config/a/file.txt"
rm "$HOME/.config/d"; mkdir "$HOME/.config/d"; echo keep > "$HOME/.config/d/child"
run link; expect_rc 1; has "conflict:"
[ "$(cat "$HOME/.config/a/file.txt")" = mine ] || fail "file clobbered"
[ "$(cat "$HOME/.config/d/child")" = keep ] || fail "dir clobbered"
rm "$HOME/.config/a/file.txt"; rm -r "$HOME/.config/d"; baseline

case_ "check flags a copy instead of a link"
rm "$HOME/.config/a/file.txt"; cp "$DOTFILES/config/a/file.txt" "$HOME/.config/a/file.txt"
run check; expect_rc 1; has "not a symlink"
rm "$HOME/.config/a/file.txt"; baseline

case_ "check flags unmanaged files, top-level and nested"
touch "$HOME/.config/zzz"; run check; expect_rc 1; has "unmanaged: .config/zzz"; rm "$HOME/.config/zzz"
touch "$HOME/.config/a/extra"; run check; expect_rc 1; has "unmanaged: .config/a/extra"; rm "$HOME/.config/a/extra"
baseline

case_ "check flags stale links into the repo"
ln -s "$DOTFILES/config/a/file.txt" "$HOME/.config/a/old.txt"
run check; expect_rc 1; has "stale link"; rm "$HOME/.config/a/old.txt"; baseline

case_ "check flags uncommitted repo changes"
touch "$DOTFILES/zz"; run check; expect_rc 1; has "zz"; rm "$DOTFILES/zz"; baseline

case_ "check flags loose permissions; link repairs them"
chmod 755 "$HOME/.config"; run check; expect_rc 1; has "mode 755"
baseline

case_ "ignore globs hide entries"
touch "$HOME/.config/ignored1"; run check; expect_rc 0; rm "$HOME/.config/ignored1"

case_ "brew drift: missing flagged, undeclared allowed"
touch "$tmp/check.fail"; run check; expect_rc 1; rm "$tmp/check.fail"
echo "Would uninstall foo" > "$tmp/cleanup.out"; run check; expect_rc 0
rm "$tmp/cleanup.out"; baseline

case_ "local/tools.txt is checked too"
echo local/ > "$DOTFILES/.gitignore"; commit
mkdir -p "$DOTFILES/local"; echo 'uv localtool' > "$DOTFILES/local/tools.txt"
run check; expect_rc 1; has "missing tool: uv localtool"
rm -r "$DOTFILES/local"; baseline

case_ "fisher plugin drift is flagged, order-insensitive"
mkdir -p "$DOTFILES/config/fish"; printf 'a/one\nb/two\n' > "$DOTFILES/config/fish/fish_plugins"
echo 'fisher config/fish/fish_plugins' > "$DOTFILES/tools.txt"; commit
printf '#!/bin/sh\necho a/one\n' > "$HOME/.local/bin/fish"; chmod +x "$HOME/.local/bin/fish"
run check; expect_rc 1; has "missing tool: fisher config/fish/fish_plugins"
printf '#!/bin/sh\nprintf "b/two\\na/one\\n"\n' > "$HOME/.local/bin/fish"
run check; expect_rc 0
rm -r "$HOME/.local/bin/fish" "$DOTFILES/config/fish"; printf '# none\n' > "$DOTFILES/tools.txt"; commit; baseline

case_ "vscode extension drift is flagged"
mkdir -p "$DOTFILES/config/vscode"; echo pub.one > "$DOTFILES/config/vscode/extensions.txt"; commit
printf '#!/bin/sh\nprintf "Pub.One\\npub.two\\n"\n' > "$HOME/.local/bin/code"; chmod +x "$HOME/.local/bin/code"
run check; expect_rc 1; has "pub.two"
echo pub.two >> "$DOTFILES/config/vscode/extensions.txt"; commit; run check; expect_rc 0
rm "$HOME/.local/bin/code"

case_ "missing brew counts as drift"
mv "$HOME/.local/bin/brew" "$tmp/brew.off"
run check; expect_rc 1; has "brew not found"
mv "$tmp/brew.off" "$HOME/.local/bin/brew"; baseline

case_ "adopt moves a new file into the repo and links it"
mkdir -p "$HOME/.config/new"; echo hi > "$HOME/.config/new/n.txt"
run adopt "$HOME/.config/new/n.txt" config/new/n.txt; expect_rc 0
is_link_to "$HOME/.config/new/n.txt" "$DOTFILES/config/new/n.txt" || fail "adopt link"
grep -qxF 'config/new/n.txt -> ~/.config/new/n.txt' "$DOTFILES/links.txt" || fail "links.txt line"
commit; run check; expect_rc 0

case_ "adopt handles dirs with trailing slash, refuses bad input"
mkdir -p "$HOME/.config/nd"; echo y > "$HOME/.config/nd/y"
run adopt "$HOME/.config/nd/" config/nd; expect_rc 0
is_link_to "$HOME/.config/nd" "$DOTFILES/config/nd" || fail "dir adopt"
echo z > "$HOME/.config/z.txt"
run adopt "$HOME/.config/z.txt" ../z; expect_rc 1
[ -f "$HOME/.config/z.txt" ] || fail "z.txt moved despite refusal"
run adopt "$HOME/.config/z.txt" config/a/file.txt; expect_rc 1
run adopt "$HOME/.config/d" config/dd; expect_rc 1
rm "$HOME/.config/z.txt"; commit; baseline

case_ "adopt recovers an app-rewritten mapped file"
rm "$HOME/.config/a/file.txt"; echo edited > "$HOME/.config/a/file.txt"
run adopt "$HOME/.config/a/file.txt"; expect_rc 0
[ "$(cat "$DOTFILES/config/a/file.txt")" = edited ] || fail "edit not kept"
is_link_to "$HOME/.config/a/file.txt" "$DOTFILES/config/a/file.txt" || fail "relink"
run adopt "$HOME/.config/a/file.txt"; expect_rc 1
commit; baseline

case_ "link repairs dangling and wrong dir links"
rm "$HOME/.config/a/file.txt"; ln -s /nonexistent "$HOME/.config/a/file.txt"
mkdir "$tmp/other"; ln -sfn "$tmp/other" "$HOME/.config/d"
run link; expect_rc 0; has "relinked:"
is_link_to "$HOME/.config/a/file.txt" "$DOTFILES/config/a/file.txt" || fail "dangling not fixed"
is_link_to "$HOME/.config/d" "$DOTFILES/config/d" || fail "dir link not fixed"
[ ! -e "$tmp/other/x.fish" ] || fail "wrote into wrong dir"

echo "all $n cases passed"
