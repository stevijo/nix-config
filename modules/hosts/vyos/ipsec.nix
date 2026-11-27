{ ... }:

{
  nixos.configurations.vyos.module = { config, lib, ... }: {

    systemd.services.strongswan-swanctl = {
      after = [ "vpp.service" ];
      wants = [ "vpp.service" ];
    };
    services.strongswan-swanctl = {
      enable = true;

      swanctl = {
        connections = {
          vpp-lab = {
            version = 2;

            proposals = [ "aes256gcm16-sha256-curve25519" ];

            local_addrs = [ "${config.sops.placeholder."public-ipv4"}" ];
            remote_addrs = [ "%any" ];
            dpd_timeout = "120";
            dpd_delay = "30";

            mobike = false;
            encap = true;

            local.main = {
              id = "vpp-lab";
              auth = "psk";
            };

            remote.main = {
              id = "vyos-lab";
              auth = "psk";
            };

            children = lib.mapAttrs
              (_: child: child // { dpd_action = "clear"; })
              config.tunnel.children;
          };
        };

        secrets.ike = {
          "ike-vpp-lab" = {
            id."vyos-lab" = "vyos-lab";
            id."vpp-lab" = "vpp-lab";
            secret = "\"${config.sops.placeholder."ipsec-psk"}\"";
          };
        };
      };
    };
  };
}
