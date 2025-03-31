{ self, nixpkgs, ... }:
let

  inputs = self.inputs;
  lib = nixpkgs.lib;

  hosts = builtins.attrNames (
    inputs.nixpkgs.lib.attrsets.filterAttrs (_n: t: t == "directory") (
      builtins.readDir ./nixosConfigurations
    )
  );

  mkHost = (
    hostname: {
    hostname = nixpkgs.lib.nixosSystem {

      specialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          system = "x86_64-linux";
        };

        inherit
          inputs
          hostname
          lib
          self
          ;
      };
      modules = [
        ./nixosConfigurations/${hostname}
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
      ];
    };
    }
    );

in
{
  nixosConfigurations = lib.genAttrs hosts mkHost;
}
