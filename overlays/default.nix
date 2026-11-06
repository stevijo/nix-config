{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super:
let
  inherit (super) stdenvAdapters lib;
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
  # The kernel asks for the TAS2783 amplifier firmware as
  # "<subsystem>-<link>-0x<uid>.bin", but linux-firmware only ships the
  # four field variant. The files also have to be listed in WHENCE, which
  # is what copy-firmware.sh installs from.
  linux-firmware = super.linux-firmware.overrideAttrs (oldAttrs: {
    postPatch = ''
      cp ti/audio/tas2783/1954-0-0-0x8.bin ti/audio/tas2783/1954-0-0x8.bin
      cp ti/audio/tas2783/1954-0-0-0xB.bin ti/audio/tas2783/1954-0-0xB.bin

      printf '%s\n' \
        'File: ti/audio/tas2783/1954-0-0x8.bin' \
        'File: ti/audio/tas2783/1954-0-0xB.bin' \
        'Link: 1954-0-0x8.bin -> ti/audio/tas2783/1954-0-0x8.bin' \
        'Link: 1954-0-0xB.bin -> ti/audio/tas2783/1954-0-0xB.bin' \
        >> WHENCE
    '';
  });
  jovianPackages = super.jovianPackages // {
    steamos-manager = super.jovianPackages.steamos-manager.overrideAttrs (oldAttrs: {

      patches = oldAttrs.patches ++ [
        ./0004-ally-x.patch
      ];
    });
  };
  age-plugin-yubi25519 = self.callPackage "${packages}/age-plugin-yubi25519.nix" { };
  stevijoAge = age'.withPlugins (plugins: lib.attrsets.attrValues plugins ++ [
    age-plugin-yubi25519
  ]);
}
