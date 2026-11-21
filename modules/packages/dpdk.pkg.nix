# The data plane development of the version which the release of the
# processor of the packets expects.
#
# The one of nixpkgs is newer, and the release does not work with it: the
# plugin of the cards of Mellanox does not find the device of the verbs of
# the card, and the processor of the packets stops.
{ dpdk, fetchurl }:
dpdk.overrideAttrs (old: {
  version = "25.07";

  src = fetchurl {
    url = "https://fast.dpdk.org/rel/dpdk-25.07.tar.xz";
    hash = "sha256-aIbL7cNQu4y+80fRA2fWJZ42Q1Yn+7J9V4rb3A07QQ0=";
  };
})
