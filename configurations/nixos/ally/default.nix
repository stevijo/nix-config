# Top-level entry point. Per-category configuration lives alongside this
# file. This file only lists imports.
{ config, flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.jovian
    inputs.sops-nix.nixosModules.sops

    ./configuration.nix
    ./sops.nix
    ./audio.nix
    ./boot.nix
    ./graphics.nix
    ./kernel.nix
    ./steam.nix
    ./udev.nix
    ./user.nix
  ];

  nixos-unified.sshTarget = "stevijo@ally";

  environment.systemPackages = with pkgs; [ vim ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
}
