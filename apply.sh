#!/usr/bin/env sh
box=$1
nix build .#darwinConfigurations.${box}.system
./result/sw/bin/darwin-rebuild switch --flake .