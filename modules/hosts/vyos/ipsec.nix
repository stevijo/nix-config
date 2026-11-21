# The IPsec tunnel of the faster-router: the connection to the bigbox.
#
# The pre-shared key of the tunnel is written into the configuration of
# swanctl by the scalpel transformation, which reads it from the secrets.
{ config, ... }:

{
  nixos.configurations.vyos.module = { config, lib, ... }: {
    services.strongswan-swanctl = {
      enable = true;

      swanctl = {
        connections.vyos = {
          version = 2;
          proposals = [ "aes256gcm128-sha256-curve25519" ];
          # The local address of the tunnel is the address of the machine on
          # the connection to the provider, which is in the secrets.
          local_addrs = [ "${config.sops.placeholder."public-ipv4"}" ];
          remote_addrs = [ "%any" ];
          dpd_timeout = "120";
          dpd_delay = "30";
          mobike = true;
          encap = true;

          local.main = {
            id = "vpp";
            auth = "psk";
          };

          remote.main = {
            id = "vyos";
            auth = "psk";
          };

          children."vyos-tunnel" = {
            esp_proposals = [ "aes256gcm128-sha256-curve25519" ];
            life_time = "1800s";

            # The addresses of the tunnel are the ones of the router which is
            # in service, because the bigbox in service is still the peer of
            # the tunnel. The tunnel of the lab will use the addresses of the
            # lab when the bigbox of the lab is there.
            local_ts = [ "10.12.0.2/32" ];
            remote_ts = [ "10.12.0.3/32" ];
            ipcomp = false;
            mode = "tunnel";
            start_action = "start";
            dpd_action = "clear";
            close_action = "start";
            replay_window = 2040;
          };
        };

        secrets.ike."ike-vyos" = {
          id.vyos = "vyos";
          id.vpp = "vpp";
          secret = "\"${config.sops.placeholder."ipsec-psk"}\"";
        };
      };
    };
  };
}
