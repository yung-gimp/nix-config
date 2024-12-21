{
  description = "not work";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixpkgs/nixos-unstable"; };
    
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs"; };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs"; };

    impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, disko, impermanence, home-manager, ... } @inputs: {
    nixosConfigurations = {
      vmtest = nixpkgs.lib.nixosSystem {
        system = "x86_64-Linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          ./hosts/vmtest
          ./hosts/common/persist.nix
          ./home
        ];
      };
    };
  };
}
