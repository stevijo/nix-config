{ config, prev, lib, ... }:
let
  strongswanConfig = prev.config.environment.etc."swanctl/swanctl.conf".source;
  strongswanHash = builtins.hashFile "sha256" strongswanConfig;
in
{
  systemd.services.strongswan-swanctl.serviceConfig = {
    Environment = "STRONG_HASH=${strongswanHash}";
  };
  environment.etc."swanctl/swanctl.conf".source = lib.mkForce config.scalpel.trafos."swanctl.conf".destination;
  scalpel.trafos."swanctl.conf" = with config.sops.secrets; {
    source = builtins.toString strongswanConfig;
    matchers."IPSEC".secret = ikev2-password.path;
    matchers."IPSEC-FRITZ".secret = ikev-fritz.path;
    matchers."REMOTE-LOCAL".secret = remote-local.path;
    matchers."REMOTE-FRITZ".secret = remote-fritz.path;
    owner = "root";
    group = "root";
    mode = "0444";
  };
} 
