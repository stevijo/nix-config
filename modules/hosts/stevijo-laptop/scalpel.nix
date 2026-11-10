# The scalpel transformation of the laptop: the WireGuard configuration is
# rewritten with the private key and the prefix.
#
# This is an extension of the host, so it gets `prev` bound to the laptop
# without it, which is where the original wg0.conf comes from.
{ config, ... }:

let
  inherit (config.flake.modules.nixos) scalpel;
in
{
  flake.modules.nixos."nixosExtensions/stevijo-laptop" = { config, lib, prev, ... }:
    let
      wgStartup = prev.config.networking.wg-quick.interfaces.wg0.configFile;
    in
    {
      imports = [ scalpel ];

      networking.wg-quick.interfaces.wg0.configFile = lib.mkForce config.scalpel.trafos."wg0.conf".destination;
      scalpel.trafos."wg0.conf" = with config.sops.secrets; {
        source = wgStartup;
        matchers."PREFIX".secret = prefix.path;
        matchers."WG0".secret = wg0.path;
        owner = "root";
        group = "root";
        mode = "0444";
      };
    };
}
