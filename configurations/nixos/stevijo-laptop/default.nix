# Top-level entry point. Per-category configuration lives alongside this
# file. This file only lists imports.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote
    self.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    ./configuration.nix
    (self + /modules/nixos/linux/windowmanager/sway)
    (self + /modules/nixos/linux/docker.nix)
    ./sops.nix
    ./fingerprint.nix
    ./smartcard.nix
    ./printing-avahi.nix
    ./steam.nix
    ./wireguard.nix
    ./system-packages.nix
    ./env.nix
    ./graphics.nix
    ./lock-screen.nix
    ./secure-boot.nix
    ./power.nix
    ./audio.nix
    ./user.nix
    ./misc.nix
  ];
}
