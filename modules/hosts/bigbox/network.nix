{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, pkgs, ... }: {
    networking.useNetworkd = true;

    networking.useDHCP = false;

    networking.nameservers = [ "1.1.1.1" ];

    services.resolved.enable = lib.mkForce false;

    systemd.network.config.networkConfig = {
      IPv4Forwarding = true;
      IPv6Forwarding = true;
    };

    systemd.network.wait-online.ignoredInterfaces = [
      "eth1"
      "eth2"
      "eth3"
    ];

    networking.interfaces = lib.mkForce {
      eth0 = { };
      eth1 = { };
      eth2 = { };
      eth3 = { };
    };

    systemd.network.netdevs = {
      "10-eth1-2" = {
        netdevConfig = {
          Name = "eth1.2";
          Kind = "vlan";
        };
        vlanConfig.Id = 2;
      };

      "10-eth1-3" = {
        netdevConfig = {
          Name = "eth1.3";
          Kind = "vlan";
        };
        vlanConfig.Id = 3;
      };

      "10-eth1-4" = {
        netdevConfig = {
          Name = "eth1.4";
          Kind = "vlan";
        };
        vlanConfig.Id = 4;
      };

      "10-eth2-5" = {
        netdevConfig = {
          Name = "eth2.5";
          Kind = "vlan";
        };
        vlanConfig.Id = 5;
      };

      "10-eth2-6" = {
        netdevConfig = {
          Name = "eth2.6";
          Kind = "vlan";
        };
        vlanConfig.Id = 6;
      };
    };

    systemd.network.networks = {
      "40-eth1-2" = {
        matchConfig.Name = "eth1.2";
        networkConfig.Address = [
          "192.168.178.1/24"
          "${config.sops.placeholder."ipv6-eth1-2"}/64"
        ];
        networkConfig.IPv6AcceptRA = false;
      };

      "40-eth1-3" = {
        matchConfig.Name = "eth1.3";
        networkConfig.Address = [
          "192.168.10.1/24"
          "${config.sops.placeholder."ipv6-eth1-3"}/64"
        ];
        networkConfig.IPv6AcceptRA = false;
      };

      "40-eth1-4" = {
        matchConfig.Name = "eth1.4";
        networkConfig.Address = [
          "192.168.11.1/24"
          "${config.sops.placeholder."ipv6-eth1-4"}/64"
        ];
        networkConfig.IPv6AcceptRA = false;
      };

      "40-eth1" = {
        matchConfig.Name = "eth1";
        vlan = [
          "eth1.2"
          "eth1.3"
          "eth1.4"
        ];
        networkConfig.DHCP = lib.mkForce false;
        linkConfig.RequiredForOnline = false;
      };
      "40-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig.Address =
          map (tunnel: "${tunnel.outer}/32") config.tunnel.tunnels;
        networkConfig.IPv6AcceptRA = false;
        linkConfig.RequiredForOnline = true;

        networkConfig.KeepConfiguration = true;

        routingPolicyRules = [
          {
            Family = "ipv4";
            FirewallMark = "0x7fffff98";
            Priority = 103;
            Table = 103;
          }
          {
            Family = "ipv4";
            FirewallMark = "0x7fffff97";
            Priority = 104;
            Table = 104;
          }
        ];
      };

    };

    networking.wireguard.interfaces = lib.mkForce {
      wg0 = {
        privateKeyFile = config.sops.secrets.wg0-private-key.path;
        listenPort = 13231;
        mtu = 1414;
        ips = [
          "10.11.0.2/24"
          "fd00:11::1/128"

          "fe80::7a58:ccff:fe73:f037/64"
        ];
        peers = [
          {
            name = "edge";
            publicKey = "T4/LQXsAV6hgNRYjWJvcAOIGrW4DA20K+8oVmKwhs3s=";
            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];

            endpoint = "${config.sops.placeholder."wg-endpoint"}";

            persistentKeepalive = 60;
          }
        ];

        allowedIPsAsRoutes = false;
      };

      wg1 = {
        privateKeyFile = config.sops.secrets.wg1-private-key.path;
        ips = [
          "10.70.82.22/32"
          "fc00:bbbb:bbbb:bb01::7:5215/128"
        ];
      };
    };

    systemd.network.links = {
      "10-vyos-eth1" = {
        matchConfig.MACAddress = "a8:b8:e0:04:52:22";
        linkConfig.Name = "eth1";
      };

      "10-vyos-eth2" = {
        matchConfig.MACAddress = "a8:b8:e0:04:52:23";
        linkConfig.Name = "eth2";
      };

      "10-vyos-eth3" = {
        matchConfig.MACAddress = "a8:b8:e0:04:52:24";
        linkConfig.Name = "eth3";
      };
    };
  };
}
