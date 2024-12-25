{ config, prev, lib, ... }:
let
  mainStartup = prev.config.services.vpp.instances.main.startupConfigFile;
  frrConfig = prev.config.environment.etc."frr/frr.conf".source;
  strongswanConfig = prev.config.environment.etc."swanctl/swanctl.conf".source;
  hash = builtins.hashFile "sha256" mainStartup;
  frrHash = builtins.hashFile "sha256" frrConfig;
  strongswanHash = builtins.hashFile "sha256" strongswanConfig;
in
{
  systemd.services.vpp-main.serviceConfig = {
    Environment = "VPP_HASH=${hash}";
  };
  systemd.services.frr.serviceConfig = {
    Environment = "FRR_HASH=${frrHash}";
  };
  systemd.services.strongswan-swanctl.serviceConfig = {
    Environment = "STRONG_HASH=${strongswanHash}";
  };
  services.frr.configFile = config.scalpel.trafos."frr.conf".destination;
  services.vpp.instances.main.startupConfigFile = config.scalpel.trafos."main-startup.conf".destination;
  environment.etc."swanctl/swanctl.conf".source = lib.mkForce config.scalpel.trafos."swanctl.conf".destination;
  scalpel.trafos."swanctl.conf" = with config.sops.secrets; {
    source = builtins.toString strongswanConfig;
    matchers."ROUTER-IP".secret = router-ip.path;
    matchers."REMOTE-MASTERMIND".secret = remote-mastermind.path;
    matchers."IPSEC-MASTERMIND".secret = ikev2-new.path;
    matchers."IPSEC".secret = ikev2-password.path;
    matchers."IPSEC-FRITZ".secret = ikev-fritz.path;
    matchers."REMOTE".secret = remote.path;
    matchers."REMOTE-LOCAL".secret = remote-local.path;
    matchers."REMOTE-FRITZ".secret = remote-fritz.path;
    owner = "root";
    group = "root";
    mode = "0444";
  };
  scalpel.trafos."main-startup.conf" = with config.sops.secrets; {
    source = builtins.toString mainStartup;
    matchers."ROUTER-IP".secret = router-ip.path;
    matchers."ROUTER-IP6".secret = router-ip6.path;
    matchers."PRIVATE".secret = ikev2-password.path;
    matchers."REMOTE-MASTERMIND".secret = remote-mastermind.path;
    matchers."PRIVATE-REMOTE".secret = private-remote.path;
    matchers."PREFIX".secret = prefix.path;
    owner = "root";
    group = "root";
    mode = "0444";
  };
  scalpel.trafos."frr.conf" = with config.sops.secrets; {
    source = builtins.toString frrConfig;
    matchers."PREFIX".secret = prefix.path;
    matchers."ROUTER-GW".secret = router-gateway.path;
    matchers."ROUTER-IP6".secret = router-ip6.path;
    matchers."BGP-PASSWORD".secret = bgp-password.path;
    matchers."ASN".secret = asn.path;
    owner = "frr";
    group = "frr";
    mode = "0444";
  };

} 
