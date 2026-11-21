# The overlay of VPP: the package of nixpkgs is replaced by the patched one,
# with the patches of VyOS and the ones of this configuration.
#
# It is only applied when the service of VPP is enabled, so that the systems
# which do not use it do not pull the package in, which is built from the
# sources and takes a long time.
#
# The data plane development is replaced as well: the release of the
# processor of the packets expects the version which the release of VyOS
# uses, and the one of nixpkgs is newer.
self: super: {
  dpdk = self.callPackage ../packages/dpdk.pkg.nix {
    inherit (super) dpdk;
  };

  vpp = self.callPackage ../packages/vpp.pkg.nix {
    inherit (super) vpp;
    dpdk = self.dpdk;
  };
}
