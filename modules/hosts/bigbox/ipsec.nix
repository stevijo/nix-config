{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, ... }: {

    systemd.services.strongswan-swanctl = {
      after = [ "vpp.service" ];
      wants = [ "vpp.service" ];
    };
    services.strongswan-swanctl = {
      enable = true;

      swanctl = {
        connections.vyos-lab = {
          version = 2;

          proposals = [ "aes256gcm16-sha256-curve25519" ];

          local_addrs = [ "10.100.20.30" ];
          remote_addrs = [ "${config.sops.placeholder."peer-ipv4"}" ];
          dpd_timeout = "120";
          dpd_delay = "30";

          mobike = false;
          encap = true;

          local.main = {
            id = "vyos-lab";
            auth = "psk";
          };

          remote.main = {
            id = "vpp-lab";
            auth = "psk";
          };

          # The children of the connection: one per tunnel of GRE, with the
          # traffic selector of it. The module of the tunnels makes them.
          children = lib.mapAttrs
            (_: child: child // { dpd_action = "restart"; })
            config.tunnel.children;
        };

        secrets.ike."ike-vyos-lab" = {
          id."vyos-lab" = "vyos-lab";
          id."vpp-lab" = "vpp-lab";
          secret = "\"${config.sops.placeholder."ipsec-psk"}\"";
        };
      };
    };
  };
}
