# The nixpkgs overlays of this configuration.
#
# They pull in the packages of nixos-unstable, patch the SteamOS manager for
# the Ally, and add the age plugin for the YubiKey.
#
# The overlay is exported as `overlays.default` (which every configuration
# applies via `base.nix`), and the packages it defines are exported as
# `packages.<system>.*`, so they can be installed with `nix profile`.
{ inputs, lib, config, ... }:

let
  overlay = self: super:
    let
      system = super.stdenv.hostPlatform.system or super.system;
      age' = super.age;
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    rec {
      inherit (unstable)
        kitty
        neovim-unwrapped
        sway-unwrapped
        wlroots
        yubico-piv-tool
        nerd-fonts;
      direnv = super.direnv.overrideAttrs (_: {
        doCheck = false;
      });
      age-plugin-yubi25519 = self.callPackage ./packages/age-plugin-yubi25519.pkg.nix { };
      stevijoAge = age'.withPlugins (plugins: lib.attrsets.attrValues plugins ++ [
        age-plugin-yubi25519
      ]);
    };
in
{
  flake.overlays.default = overlay;

  perSystem = { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      # The overlaid nixpkgs, also for the other perSystem modules.
      _module.args.pkgs = pkgs;

      # All of nixpkgs, with the overlay applied. `nix profile install .#foo`
      # looks in `packages` first and then here. Like nixpkgs' own flake, it
      # goes in `legacyPackages`: `packages` must be a flat set of derivations,
      # which nixpkgs is not.
      legacyPackages = pkgs;
    };
}
