{
  self,
  inputs,
  lib,
  ...
}:
let

  hosts = builtins.attrNames (
    lib.attrsets.filterAttrs (_n: t: t == "directory") (builtins.readDir ./nixosConfigurations)
  );

  mkHost =
    hostname:
    inputs.nixpkgs.lib.nixosSystem {

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

  homeCfgs = builtins.attrNames (
    lib.attrsets.filterAttrs (_n: t: t == "directory") (builtins.readDir ./homeConfigurations)
  );

  mkHomeCfg =
    homeCfg:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit self inputs; };
      modules = [
        ./homeConfigurations/${homeCfg}
      ];
    };

  homeMods = builtins.attrNames (
    lib.attrsets.filterAttrs (_n: t: t == "directory") (builtins.readDir ./homeModules)
  );

  mkHomeMod = homeMod: {
    imports = [
      ./homeModules/${homeMod}
    ];
  };

in
{
  flake = {
    nixosConfigurations = lib.genAttrs hosts mkHost;
    homeConfigurations = lib.genAttrs homeCfgs mkHomeCfg;
    homeModules = lib.genAttrs homeMods mkHomeMod;
  };
}
