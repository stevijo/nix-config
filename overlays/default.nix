{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super:
let
  strongswan' = self.callPackage "${packages}/strongswan" { inherit (super) strongswan; };
  system = super.stdenv.hostPlatform.system or super.system;
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
rec {
  inherit (unstable)
    neovim-unwrapped
    azure-cli
    azure-cli-extensions
    nerd-fonts;
  vpp-sswan = self.callPackage "${packages}/vpp-sswan" { inherit (super) strongswan; };
  strongswan = strongswan'.withPlugins [
    vpp-sswan
  ];
  vpp = self.callPackage "${packages}/vpp" { inherit (super) vpp; };
}
