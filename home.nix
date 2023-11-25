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
  ]

  # Misc configuration files --------------------------------------------------------------------{{{

  # https://docs.haskellstack.org/en/stable/yaml_configuration/#non-project-specific-config
  home.file.".stack/config.yaml".text = lib.generators.toYAML {} {
    templates = {
      scm-init = "git";
      params = {
        author-name = "Your Name"; # config.programs.git.userName;
        author-email = "youremail@example.com"; # config.programs.git.userEmail;
        github-username = "yourusername";
      };
    };
    nix.enable = true;
  };

}