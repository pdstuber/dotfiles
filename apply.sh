#!/usr/bin/env sh
for FILE in ".p10k.zsh" ".zshrc" ".hyper.js"; do
  ln -s "$(pwd)/${FILE}" "${HOME}/"
done
