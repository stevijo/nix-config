# The nixpkgs overlays of this configuration.
#
# They pull in the packages of nixos-unstable, patch the SteamOS manager for
# the Ally, and add the age plugin for the YubiKey.
{ inputs, ... }:

{
  flake.overlays.default = self: super:
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
      strongswan = super.strongswan.overrideAttrs (oldAttrs: {
        configureFlags = oldAttrs.configureFlags ++ [
          "--enable-ikev1"
        ];
      });
      direnv = super.direnv.overrideAttrs (_: {
        doCheck = false;
      });
      x20-inputplumber = self.callPackage
        ({ inputplumber'
         , fetchFromGitHub
         , rustPlatform
         ,
         }:
          inputplumber'.overrideAttrs (oldAttrs: rec {
            version = "0.83.1";

            src = fetchFromGitHub {
              owner = "ShadowBlip";
              repo = "InputPlumber";
              tag = "v${version}";
              hash = "sha256-2NAIiIZBi1lZdPPND6VCihThvdHd1aJ2X6ZArinIL2E=";
            };

            cargoDeps = rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-d5sW/w5JolX20U2OzGHMDcUXi0+hvXV0kKWXD2FfIKA=";
            };
          }))
        {
          inputplumber' = super.jovianPackages.inputplumber;
        };
      jovianPackages = super.jovianPackages // {
        steamos-manager = super.jovianPackages.steamos-manager.overrideAttrs (oldAttrs: {

          patches = oldAttrs.patches ++ [
            ./nixos/jovian/0004-ally-x.patch
          ];
        });
      };
      age-plugin-yubi25519 = self.callPackage ./packages/age-plugin-yubi25519.pkg.nix { };
      stevijoAge = age'.withPlugins (plugins: lib.attrsets.attrValues plugins ++ [
        age-plugin-yubi25519
      ]);
    };
}
