{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super:
let
  strongswan' = self.callPackage "${packages}/strongswan" { inherit (super) strongswan; };
in
rec {
  vpp-sswan = self.callPackage "${packages}/vpp-sswan" { inherit (super) strongswan; };
  strongswan = strongswan'.withPlugins [
    vpp-sswan
  ];
  vpp = self.callPackage "${packages}/vpp" { inherit (super) vpp; };
}
