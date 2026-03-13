{ vpp
, keepDebugInfo
, stdenv
, fetchFromGitHub
, fetchgit
, gnused
}:
(vpp.override {
  # stdenv = keepDebugInfo stdenv;
}).overrideAttrs (old: rec {
  # cmakeFlags = old.cmakeFlags ++ [
  #   "-D CMAKE_BUILD_TYPE=Debug"
  # ];

  src = fetchgit {
    leaveDotGit = true;
    url = "https://github.com/FDio/vpp.git";
    rev = "8a3f587695fe6ad4d8297bd4b2f331b7262698d9";
    hash = "sha256-g8TPq+oPlZ/5iSewV/9a3LzFS8oqabIcg9rbixuF840=";
  };

  vppPatches = fetchFromGitHub {
    owner = "vyos";
    repo = "vyos-vpp-patches";
    rev = "42a15a1bdf76cdceb80e76aa9613d3ba360b46bb";
    hash = "sha256-zZuOkWw6B6hR1BAmfYdewjty55tRi5gv//zuVqUiTMQ=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [
    gnused
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
        elif [ "$name" = "0012-linux-cp-Added-routing-for-prefixes-with-no-paths-av.patch" ]; then
            continue
        elif [ "$name" = "0022-vlib-add-optional-systemd-notify-support-for-service.patch" ]; then
            continue
        elif [ "$name" = "0023-linux-cp-T8116-skip-SA-operations-for-non-VPP-interf.patch" ]; then
            continue
        elif [ "$name" = "0024-T7860-IPv6-ICMP-RA-punt-shortcut-36.patch" ]; then
            continue
        fi
        newPatch=patches/vpp/$name
        sed -e 's/src\///g' $patch > $newPatch 
        echo "I: build_cmd applying patch $newPatch..."
        patch -p1 < $newPatch
    done
  '';
  patches = [
    ./0001-fix-dispatch-trace.patch
    ./0002-fix-ike-packages-not-forwarded-to-linux.patch
    ./0003-always-add-loop0.patch
    ./0004-add-chacha20-support.patch
  ];
})
