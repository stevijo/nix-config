{ dpdk
, fetchurl
, stdenv
, keepDebugInfo
}:
(dpdk.override {
  # stdenv = keepDebugInfo stdenv;
}).overrideAttrs (old: rec {
  version = "24.11.1";
  src = fetchurl {
    url = "https://fast.dpdk.org/rel/dpdk-${version}.tar.xz";
    sha256 = "sha256-vK59QsRJ/EVt+yef6ry+BZmim+uy/ikFdh4YcznZa44=";
  };
})
