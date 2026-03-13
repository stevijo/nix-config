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
  age-plugin-yubi25519 = self.callPackage "${packages}/age-plugin-yubi25519.nix" { };
  stevijoAge = age'.withPlugins (plugins: lib.attrsets.attrValues plugins ++ [
    age-plugin-yubi25519
  ]);
  vpp = self.callPackage "${packages}/vpp" {
    inherit (super) vpp;
    inherit (stdenvAdapters) keepDebugInfo;
  };
}
