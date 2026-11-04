# Top-level entry point. Per-category configuration lives alongside this
# file. This file only lists imports.
{ config, flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    # Jovian-NixOS: Steam Deck UI, SteamOS flavoured system configuration
    # and the vendor builds of pipewire/mesa/gamescope.
    self.nixosModules.jovian

    ./configuration.nix
    ./audio.nix
    ./boot.nix
    ./graphics.nix
    ./user.nix
  ];

  nixos-unified.sshTarget = "stevijo@ally";
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };


}
