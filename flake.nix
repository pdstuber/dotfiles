{
  description = "Philipp's darwin system";

  inputs = {
    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    nixpkgs-stable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-23.05";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
  let

    inherit (darwin.lib) darwinSystem;
    inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

    # Configuration for `nixpkgs`
    nixpkgsConfig = {
      config = { allowUnfree = true; };
    }; 
  in
  {
    darwinConfigurations = rec {
      "FORM3-PHILIPPSTUBER" = darwinSystem {
        system = "aarch64-darwin";
        modules = attrValues self.darwinModules ++ [ 
          # Main `nix-darwin` config
          ./configuration.nix
          # `home-manager` module
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pdstuber = import ./boxes/form3/home.nix;            
          }
        ];
      };
      "philipp-macbook" = darwinSystem {
        system = "aarch64-darwin";
        modules = attrValues self.darwinModules ++ [ 
          # Main `nix-darwin` config
          ./configuration.nix
          # `home-manager` module
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pdstuber = import ./boxes/philipp-macbook/home.nix;            
          }
        ];
      };
    };

    darwinModules = {
      programs-nix-index = 
        # Additional configuration for `nix-index` to enable `command-not-found` functionality with Fish.
        { config, lib, pkgs, ... }:

        {
          config = lib.mkIf config.programs.nix-index.enable {
            programs.fish.interactiveShellInit = ''
              function __fish_command_not_found_handler --on-event="fish_command_not_found"
                ${if config.programs.fish.useBabelfish then ''
                command_not_found_handle $argv
                '' else ''
                ${pkgs.bashInteractive}/bin/bash -c \
                  "source ${config.programs.nix-index.package}/etc/profile.d/command-not-found.sh; command_not_found_handle $argv"
                ''}
              end
            '';
            };
        };
    };
  };
}