#!/usr/bin/env sh
for FILE in ".p10k.zsh" ".zshrc"; do
  cp -s "$(pwd)/${FILE}" "${HOME}/"
done