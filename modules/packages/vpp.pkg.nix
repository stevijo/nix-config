# The package of VPP with the patches of VyOS and the ones of this
# configuration.
#
# It replaces the package of nixpkgs: the sources are the ones of the release
# which is built, and the patches are applied to them. Everything else is the
# package of nixpkgs.
{ vpp
, dpdk
, fetchFromGitHub
, fetchgit
, gnused
, lib
, systemd
}:
let
  # The data plane development of the release, with the driver of the cards of
  # Mellanox, which the package of nixpkgs adds to its own.
  dpdk' = dpdk.overrideAttrs (old: {
    mesonFlags = old.mesonFlags ++ [ "-Denable_driver_sdk=true" ];
  });
in
vpp.overrideAttrs (old: rec {
  version = "25.10";

  src = fetchgit {
    leaveDotGit = true;
    url = "https://github.com/FDio/vpp.git";
    rev = "8a3f587695fe6ad4d8297bd4b2f331b7262698d9";
    hash = "sha256-g8TPq+oPlZ/5iSewV/9a3LzFS8oqabIcg9rbixuF840=";
  };

  # The data plane development of nixpkgs is newer than the one which the
  # release expects, so ours takes its place in the inputs of the build.
  buildInputs =
    map (
      input:
      if input ? name && lib.hasPrefix "dpdk-" input.name then dpdk' else input
    )
    old.buildInputs
    # The library of systemd is needed for the support of the notification of
    # the readiness of the processor of the packets.
    ++ [ systemd ];

  # The patches of VyOS. They are applied in `prePatch`, because they are
  # patches of the release and not of the derivation.
  vppPatches = fetchFromGitHub {
    owner = "vyos";
    repo = "vyos-vpp-patches";
    rev = "42a15a1bdf76cdceb80e76aa9613d3ba360b46bb";
    hash = "sha256-zZuOkWw6B6hR1BAmfYdewjty55tRi5gv//zuVqUiTMQ=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ gnused ];

  # The processor of the packets tells systemd when it is ready, so that the
  # services which wait for it start after it. The support of it is built
  # with the library of systemd.
  cmakeFlags = old.cmakeFlags ++ [ "-DVPP_ENABLE_SYSTEMD_NOTIFY=ON" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=maybe-uninitialized"
    "-Wno-error=compare-distinct-pointer-types"
    "-Wno-error=incompatible-pointer-types"
    "-Wno-error=stringop-truncation"
  ];

  prePatch = ''
    # Patches for vpp should applied here
    mkdir -p patches/vpp
    for patch in ${vppPatches}/patches/vpp/*.patch; do
        name=$(basename $patch)
        if [ "$name" = "0008-linux-cp-Added-build-dependency-for-XFRM.patch" ]; then
            continue
        elif [ "$name" = "0011-build-Fixed-compatibility-with-build-on-Debian-12-an.patch" ]; then
            continue
        elif [ "$name" = "0023-linux-cp-T8116-skip-SA-operations-for-non-VPP-interf.patch" ]; then
            continue
        elif [ "$name" = "0024-T7860-IPv6-ICMP-RA-punt-shortcut-36.patch" ]; then
            continue
        elif [ "$name" = "0027-linux-cp-T8251-sync-VPP-IPsec-SA-counters-to-Linux-X.patch" ]; then
            continue
        fi
        if [ "$name" = "0022-vlib-add-optional-systemd-notify-support-for-service.patch" ]; then
            # The patch has the file of the root of the sources, which is the
            # Makefile of the distribution, and the files of the sources, so it
            # is applied from the root of them and not from the sources.
            #
            # The Makefile is not built here, the processor of the packets is
            # built with cmake, and the hunks of it do not fit the release:
            # they are left out. The rest of the patch fits the release
            # exactly, and it is applied without the fuzz, so that it is
            # applied cleanly.
            newPatch=$PWD/patches/vpp/$name
            awk '/^diff --git /{ skip = ($0 ~ /a\/Makefile b\/Makefile$/) } !skip' $patch > $newPatch
            cd ..
            patch -p1 --fuzz=0 < $newPatch
            cd -
            continue
        fi
        newPatch=patches/vpp/$name
        sed -e 's/src\///g' $patch > $newPatch
        echo "I: build_cmd applying patch $newPatch..."
        patch -p1 --fuzz=3 < $newPatch
    done
  '';

  # The patches of this configuration, which are applied after the ones of
  # VyOS.
  patches = [
    ./vpp/0001-fix-snap-crash.patch
    ./vpp/0033-increase-ring-size-for-lcp-interfaces.patch
    ./vpp/0001-fix-dispatch-trace.patch
    ./vpp/0002-add-chacha20-support.patch
    ./vpp/0034-spread-ipsec-sa-over-workers.patch
  ];
})
