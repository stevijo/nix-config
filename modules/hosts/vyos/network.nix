{ ... }:

{
  nixos.configurations.vyos.module = { config, lib, pkgs, ... }: {
    networking.useNetworkd = true;

    networking.useDHCP = false;

    networking.nameservers = [ "1.1.1.1" ];

    services.resolved.enable = lib.mkForce false;

    networking.interfaces = lib.mkForce {
      eth0 = { };
      eth1 = { };
      eth2 = { };
      eth5 = { };
    };

    systemd.network.networks = {
      "40-eth0" = {
        address = [
          "10.50.50.2/24"
          "10.32.32.2/24"
          "${config.sops.placeholder."host-ipv6"}/64"
        ];
        linkConfig.RequiredForOnline = false;
      };

      "40-eth1" = {
        networkConfig.VRF = "conn1";
        address = [
          "${config.sops.placeholder."public-ipv4"}/24"
          "10.12.0.2/31"
        ]

        ++ map (tunnel: "${tunnel.outer}/32") config.tunnel.tunnels;
        linkConfig.RequiredForOnline = false;
      };

      "40-eth2" = {
        networkConfig = {
          VRF = "conn2";
          VLAN = "eth2.1481";
        };
        address = [ "${config.sops.placeholder."public-ipv4-secondary"}/24" ];
        linkConfig.RequiredForOnline = false;
      };

      "40-eth2-1481" = {
        matchConfig.Name = "eth2.1481";
        address = [
          "${config.sops.placeholder."public-ipv6"}/128"
          "${config.sops.placeholder."local-ipv6"}/127"
        ];
        linkConfig.RequiredForOnline = false;
      };

      "40-eth5" = {
        address = [ "10.15.0.2/24" ];
        linkConfig.MTUBytes = 1400;
        linkConfig.RequiredForOnline = false;
      };
    };

    systemd.network.networks."40-eth1".routingPolicyRules = [
      {
        Family = "ipv4";
        FirewallMark = "0x7fffff9a";
        Priority = 101;
        Table = 101;
      }
    ];

    systemd.network.netdevs."10-eth2-1481" = {
      netdevConfig = {
        Name = "eth2.1481";
        Kind = "vlan";
      };
      vlanConfig.Id = 1481;
    };


    systemd.network.config.networkConfig = {
      IPv4Forwarding = true;
      IPv6Forwarding = true;
    };

    networking.wireguard.interfaces = lib.mkForce {
      wg0 = {
        privateKeyFile = config.sops.secrets.wg0-private-key.path;
        listenPort = 13231;
        mtu = 1414;
        ips = [
          "10.11.0.1/24"
          "fd00:11::2/128"

          "fe80::be24:11ff:fe11:3a98/64"
        ];
        peers = [
          {
            name = "home";
            publicKey = "4KHs1m9blcYU6R4lpEpKcp3tDKhBNJDLFlrN/iC3gAQ=";
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
    };

    systemd.services = { };

    systemd.network.links = {
      "10-vyos-eth0" = {
        matchConfig.MACAddress = "bc:24:11:11:3a:99";
        linkConfig.Name = "eth0";
      };
      "10-vyos-vpp0" = {
        matchConfig.MACAddress = "e8:eb:d3:2b:1f:13";
        matchConfig.Path = "pci-*";
        linkConfig.Name = "defunct_eth1";
      };
      "10-vyos-eth2" = {
        matchConfig.MACAddress = "e8:eb:d3:2b:1f:14";
        matchConfig.Path = "pci-*";
        linkConfig = {
          Name = "eth2";

          RxBufferSize = 4096;
          TxBufferSize = 4096;
        };
      };
      "10-vyos-eth5" = {
        matchConfig.MACAddress = "bc:24:11:ee:c6:f6";
        linkConfig.Name = "eth5";
      };
    };

  };
}
