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
      inputplumber'.overrideAttrs rec {
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
      })
    {
      inputplumber' = super.jovianPackages.inputplumber;
    };
  # The ROG Xbox Ally X20 has the PCI subsystem device id 0x1954. The
  # kernel asks for the TAS2783 amplifier firmware as
  # "<subsystem>-<link>-0x<uid>.bin", but linux-firmware only ships the
  # four field variant.
  linux-firmware = super.linux-firmware.overrideAttrs (oldAttrs: {
    postPatch = ''
      cp ti/audio/tas2783/1954-0-0-0x8.bin ti/audio/tas2783/1954-0-0x8.bin
      cp ti/audio/tas2783/1954-0-0-0xB.bin ti/audio/tas2783/1954-0-0xB.bin

      # copy-firmware.sh only installs what is listed in WHENCE, so the
      # new files have to be added there as well.
      printf '%s\n' \
        'File: ti/audio/tas2783/1954-0-0x8.bin' \
        'File: ti/audio/tas2783/1954-0-0xB.bin' \
        'Link: 1954-0-0x8.bin -> ti/audio/tas2783/1954-0-0x8.bin' \
        'Link: 1954-0-0xB.bin -> ti/audio/tas2783/1954-0-0xB.bin' \
        >> WHENCE
    '';
  });
  age-plugin-yubi25519 = self.callPackage "${packages}/age-plugin-yubi25519.nix" { };
  stevijoAge = age'.withPlugins (plugins: lib.attrsets.attrValues plugins ++ [
    age-plugin-yubi25519
  ]);
}
