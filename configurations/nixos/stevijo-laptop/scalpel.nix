{ config, prev, lib, ... }:
let
  wgStartup = prev.config.networking.wg-quick.interfaces.wg0.configFile;
in
{
  networking.wg-quick.interfaces.wg0.configFile = lib.mkForce config.scalpel.trafos."wg0.conf".destination;
  scalpel.trafos."wg0.conf" = with config.sops.secrets; {
    source = wgStartup;
    matchers."PREFIX".secret = prefix.path;
    matchers."WG0".secret = wg0.path;
    owner = "root";
    group = "root";
    mode = "0444";
  };
}
