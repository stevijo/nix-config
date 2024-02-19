{ vpp
}:
vpp.overrideAttrs {
  patches = [
    ./0001-ipsec-fix-UDP-flow-in-ipsec-inbound-policy.patch
    ./0001-fix-dispatch-trace.patch
  ];
}
