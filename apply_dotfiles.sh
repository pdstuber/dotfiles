#!/usr/bin/env bash

if ! command -v fish &> /dev/null
then
    echo "fish is not installed"
    exit 1
fi

if ! command -v kitty &> /dev/null
then
    echo "kitty is not installed"
    exit 1
fi

ln -s config.fish ~/.config/fish/config.fish
ln -s kitty.conf ~/.config/kitty/kitty.conf