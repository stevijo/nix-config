{ vpp
}:
vpp.overrideAttrs (old: {
  patches = [
    ./0001-fix-dispatch-trace.patch
    ./0002-fix-ike-packages-not-forwarded-to-linux.patch
    ./0003-fib-fix-adj_get_rewrite.patch
  ];
})
