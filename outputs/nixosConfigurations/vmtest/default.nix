{
  inputs,
  lib,
  pkgs,
  ...
}:
{

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  ff = {
    system = {
      systemd-boot.enable = true;
      persistence.enable = true;
    };
    common.enable = true;
  };

  users = {
    mutableUsers = false;
    users = {
      codman = {
        initialPassword = "password";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = with pkgs; [
          tree
        ];
      };
    };
  };

  services.getty.autologinUser = "codman";

  imports = [
    inputs.ff.nixosModules.freedpomFlake
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
  ];
}
