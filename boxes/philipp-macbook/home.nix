{ config, pkgs, lib, ... }:

{
  home.stateVersion = "23.05";
  home.homeDirectory = "/Users/pdstuber";
  home.packages = with pkgs; [
    # basics
    coreutils
    curl
    fish
    # Dev stuff
    jq
  ];
  programs.git.userEmail = lib.mkForce "stuberphd@gmail.com";
    programs.git.extraConfig = {
      user.signingkey = "E61AE540958CA05D";
      commit.gpgsign = true;
      "url \"git@github.com:\"".insteadOf = "https://github.com/";
    };
    programs.gpg.enable = true;
    #programs.gpg.homedir = "/Users/pdstuber/.gnupg";
}