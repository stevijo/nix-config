{ vpp
, keepDebugInfo
, stdenv
}:
(vpp.override {
  # stdenv = keepDebugInfo stdenv;
}).overrideAttrs (old: {
  # cmakeFlags = old.cmakeFlags ++ [
  #   "-D CMAKE_BUILD_TYPE=Debug"
  # ];
  patches = [
    ./0001-fix-dispatch-trace.patch
    ./0002-fix-ike-packages-not-forwarded-to-linux.patch
  ];
})
