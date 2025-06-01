{ vpp
, pkgsStatic
}:
vpp.overrideAttrs (old: {
  buildInputs = old.buildInputs ++ [
    pkgsStatic.intel-ipsec-mb
  ];
  patches = [
    ./0001-fix-dispatch-trace.patch
    ./0002-fix-ike-packages-not-forwarded-to-linux.patch
  ];
})
