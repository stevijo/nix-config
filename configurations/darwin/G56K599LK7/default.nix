# Top-level entry point. Per-category configuration lives alongside this
# file. This file only lists imports and host-level attrs.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
    ./java.nix
    ./pki.nix
    ./user.nix
    ./system-packages.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "G56K599LK7";
  system.stateVersion = 6;

  home-manager.users."stefan.mayer" = {
    imports = [
      (self + "/configurations/home/stefan.mayer@G56K599LK7.nix")
    ];
  };
}
