# The nixpkgs overlays of this configuration.
#
# They pull in the packages of nixos-unstable, patch the SteamOS manager for
# the Ally, and add the age plugin for the YubiKey.
{ inputs, ... }:

{
  nixos.modules.base = { ... }:
    {
      nixpkgs.overlays = [
        (self: super:
          let
            inherit (super) lib;
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
          })
      ];
    };
}
