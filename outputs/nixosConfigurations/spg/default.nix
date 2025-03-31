{
  inputs,
  lib,
  pkgs,
  ...
}:
{

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

  # ff = {
  #   system = {
  #     nix.enable = true;
  #     systemd-boot.enable = true;
  #     persistence.enable = true;
  #   };
  #   services.kmscon = {
  #     enable = true;
  #     disableAt = [
  #       "tty1"
  #     ];
  #   };
  #   common.enable = true;
  #   userConfig = {
  #     users = {
  #       codman = {
  #         uid = 1000;
  #         role = "admin";
  #         tags = [ "base" ];
  #       };
  #     };
  #   };
  # };

  environment = {
    systemPackages = with pkgs; [
      pciutils
      usbutils
    ];
    variables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
  };

  services.getty.autologinUser = "codman";

  programs.neovim.enable = true;

  imports = [
    inputs.ff.nixosModules.freedpomFlake
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
  ];
}
