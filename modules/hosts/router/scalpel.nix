# The scalpel transformation of the router: the strongSwan configuration is
# rewritten with the IPsec secrets.
#
# This is an extension of the host, so it gets `prev` bound to the router
# without it, which is where the original swanctl.conf comes from.
{ config, ... }:

let
  inherit (config.nixos.modules) scalpel;
in
{
  nixos.configurations.router.extensions = { config, lib, prev, ... }:
    let
      strongswanConfig = prev.config.environment.etc."swanctl/swanctl.conf".source;
      strongswanHash = builtins.hashFile "sha256" strongswanConfig;
    in
    {
      imports = [ scalpel ];

      systemd.services.strongswan-swanctl.serviceConfig = {
        Environment = "STRONG_HASH=${strongswanHash}";
      };
      environment.etc."swanctl/swanctl.conf".source = lib.mkForce config.scalpel.trafos."swanctl.conf".destination;
      scalpel.trafos."swanctl.conf" = with config.sops.secrets; {
        source = builtins.toString strongswanConfig;
        matchers."IPSEC-FRITZ".secret = ikev-fritz.path;
        matchers."REMOTE-LOCAL".secret = remote-local.path;
        matchers."REMOTE-FRITZ".secret = remote-fritz.path;
        owner = "root";
        group = "root";
        mode = "0444";
      };
    };
}
