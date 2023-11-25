{ config, pkgs, lib, ... }:

{
  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    # basics
    coreutils
    curl
    fish
    # Dev stuff
    jq
  ];
  programs.git.userEmail = lib.mkForce "philipp.stuber@form3.tech";
    programs.git.extraConfig = {
      user.signingkey = "6441B1BC81F8FB1561C9AFF5534222210FE423ED";
      commit.gpgsign = true;
      "url \"git@github.com:\"".insteadOf = "https://github.com/";
    };
    programs.gpg.enable = true;
    programs.gpg.homedir = "/Users/philippstuber/.gnupg";
}