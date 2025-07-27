{ dpdk
, intel-ipsec-mb
}:
dpdk.overrideAttrs (old: {
  buildInputs = old.buildInputs ++ [
    intel-ipsec-mb
  ];
})
