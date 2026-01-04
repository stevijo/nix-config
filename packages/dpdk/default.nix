{ dpdk
, stdenv
, keepDebugInfo
}:
(dpdk.override {
  # stdenv = keepDebugInfo stdenv;
})
