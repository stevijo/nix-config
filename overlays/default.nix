{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super:
let
  inherit (super) stdenvAdapters;
  strongswan' = self.callPackage "${packages}/strongswan" { inherit (super) strongswan; };
  system = super.stdenv.hostPlatform.system or super.system;
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
rec {
  inherit (unstable)
    kitty
    neovim-unwrapped
    nerd-fonts;
  vpp-sswan = self.callPackage "${packages}/vpp-sswan" { inherit (super) strongswan; };
  strongswan = strongswan'.withPlugins [
    vpp-sswan
  ];
  dpdk = self.callPackage "${packages}/dpdk" {
    inherit (super) dpdk;
    inherit (stdenvAdapters) keepDebugInfo;
  };
  vpp = self.callPackage "${packages}/vpp" {
    inherit (super) vpp;
    inherit (stdenvAdapters) keepDebugInfo;
  };
  intel-ipsec-mb = self.callPackage "${packages}/intel-ipsec-mb" { };
}
