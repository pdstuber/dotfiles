{
  description = "Philipp's Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    defaultPackage.aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
 
    homeConfigurations = {
	    # TODO: Modify "your.username" below to match your username
      "pdstuber" = inputs.home-manager.lib.homeManagerConfiguration {
        system = "aarch64-darwin"; # TODO: replace with x86_64-linux on Linux
        homeDirectory = "/Users/pdstuber"; # TODO: make this match your home directory
        username = "pdstuber"; # TODO: Change to your username
        configuration.imports = [ ./home.nix ];
      };
    };
  };
}
