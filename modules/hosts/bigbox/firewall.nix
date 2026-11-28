{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, ... }: {
    networking.nftables.checkRuleset = false;

    firewall.groups = {
      interface = {
        ethernet = [
          "eth1.2"
          "eth1.3"
          "eth1.4"
          "eth0"
        ];
        vlans = [
          "eth1.2"
          "eth1.3"
          "eth1.4"
        ];
        wireguard = [
          "wg0"
          "eth2.6"
        ] ++ map (tunnel: "vppgre${toString tunnel.index}") config.tunnel.tunnels;
      };

      address = {
        unifi = [
          "192.168.2.204"
          "192.168.2.162"
        ];
        "google-dns" = [
          "2001:4860:4860::8844"
          "2001:4860:4860::8888"
        ];
      };

      network = {
        "local-addr" = [
          "10.0.0.0/8"
          "192.168.0.0/16"
          "172.16.0.0/12"

          # The unique local addresses, which are the private addresses of
          # the version six.
          "fc00::/7"
        ];

        cloud = [ "ip4:${config.sops.placeholder."cloud-networks"}" ];
      };

      mac = {
        inet = [ ];
        "bypass-cloud" = [ ];
        faster = [ "0A:2A:3D:26:EE:92" ];
      };
    };

    firewall.rules = {
      filter.ipv4 = {
        input = {
          defaultAction = "drop";
          rules = [
            {
              action = "accept";
              comment = "Allow established";
              state = [
                "established"
                "related"
              ];
            }
            {
              action = "accept";
              comment = "Allow the normal vlan";
              inbound = "eth1.2";
            }
            {
              action = "accept";
              comment = "Allow the marked packets";
              mark = 10;
            }
            {
              action = "accept";
              comment = "Allow the home tunnels";
              inbound = "wireguard";
            }
            {
              action = "accept";
              comment = "Allow the DHCP requests";
              destinationPort = "67";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow the DHCP replies";
              destinationPort = "68";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow BFD";
              destinationPort = "5201";
              protocol = "tcp";
            }
            {
              action = "accept";
              comment = "Allow the IPsec tunnel";
              destinationPort = [
                "500"
                "4500"
              ];
              protocol = "udp";
            }
          ];
        };

        forward = {
          defaultAction = "drop";
          rules = [
            {
              action = "accept";
              comment = "Allow established";
              state = [
                "established"
                "related"
              ];
            }
            {
              action = "drop";
              comment = "The internet machines do not go to the internet";
              outbound = "eth0";
              source = "inet";
            }
            {
              action = "reject";
              comment = "Drop the machine which does not belong here";
              source = "40:44:F7:FD:DB:83";
            }
            {
              action = "accept";
              comment = "Outbound internet";
              outbound = "eth0";
            }
            {
              action = "accept";
              comment = "Allow the normal vlan to everything";
              inbound = "eth1.2";
            }
            {
              action = "drop";
              comment = "Only the unifi machines reach the server";
              destination = "!192.168.178.20";
              inbound = "wireguard";
              source = "10.32.32.1/32";
            }
            {
              action = "accept";
              comment = "The home tunnels reach everything but the local network";
              inbound = "wireguard";
              source = "!192.168.2.0/24";
            }
            {
              action = "accept";
              comment = "The unifi machines reach the server";
              destination = "192.168.178.20";
              inbound = "wireguard";
              source = "unifi";
            }
          ];
        };

        output = {
          defaultAction = "accept";
          rules = [ ];
        };

        prerouting = {
          defaultAction = "accept";
          priority = "raw";

          # The rules which are about the tunnels of GRE are in `tunnels.nix`,
          # with the tunnels they are about.
          rules = [ ];
        };
      };

      filter.ipv6 = {
        input = {
          defaultAction = "drop";
          rules = [
            {
              action = "accept";
              comment = "Allow established";
              state = [
                "established"
                "related"
              ];
            }
            {
              action = "accept";
              comment = "Allow the neighbour discovery";
              icmpv6Type = "nd-neighbor-advert";
            }
            {
              action = "accept";
              comment = "Allow the neighbour discovery";
              icmpv6Type = "nd-neighbor-solicit";
            }
            {
              action = "accept";
              comment = "Allow the neighbour discovery";
              icmpv6Type = "packet-too-big";
            }
            {
              action = "accept";
              comment = "Allow the neighbour discovery";
              icmpv6Type = "destination-unreachable";
            }
            {
              action = "accept";
              comment = "Allow the neighbour discovery";
              icmpv6Type = "echo-request";
            }
            {
              action = "accept";
              comment = "Allow the neighbour discovery";
              icmpv6Type = "nd-redirect";
            }
            {
              action = "accept";
              comment = "Allow the router solicitations";
              icmpv6Type = "nd-router-solicit";
              inbound = "vlans";
            }
            {
              action = "accept";
              comment = "Allow the normal vlan";
              inbound = "eth1.2";
            }
            {
              action = "accept";
              comment = "Allow OSPF of the home tunnels";
              inbound = "wireguard";
              protocol = "ospfigp";
            }
            {
              action = "accept";
              comment = "Allow the DHCP requests";
              destinationPort = "547";
              inbound = "eth1.2";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow the DHCP replies";
              destinationPort = "546";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow the SSH of the home tunnels";
              destinationPort = "22";
              inbound = "wireguard";
              protocol = "tcp";
            }
            {
              action = "accept";
              comment = "Allow the BFD of the home tunnels";
              destinationPort = "3784";
              inbound = "wireguard";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow the BFD of the home tunnels";
              destinationPort = "5201";
              inbound = "wireguard";
              protocol = "tcp";
            }
          ];
        };

        forward = {
          defaultAction = "drop";
          rules = [
            {
              action = "accept";
              comment = "Allow established";
              state = [
                "established"
                "related"
              ];
            }
            {
              action = "drop";
              comment = "The internet machines do not go to the tunnels";
              outbound = "wireguard";
              source = "inet";
            }
            {
              action = "reject";
              comment = "Drop the machine which does not belong here";
              source = "40:44:F7:FD:DB:83";
            }
            {
              action = "accept";
              comment = "Allow the pings";
              icmpv6Type = "echo-request";
            }
            {
              action = "accept";
              comment = "Allow the pings";
              icmpv6Type = "packet-too-big";
            }
            {
              action = "accept";
              comment = "Allow the pings";
              icmpv6Type = "parameter-problem";
            }
            {
              action = "accept";
              comment = "Outbound traffic";
              outbound = "wireguard";
            }
            {
              action = "accept";
              comment = "The normal vlan reaches everything";
              inbound = "eth1.2";
            }
            {
              action = "accept";
              comment = "Allow the WireGuard of the unifi machines";
              destination = "${config.sops.placeholder."prefix-be00-host"}";
              destinationPort = "51820";
              inbound = "wireguard";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow the cluster of Kubernetes";
              destination = "${config.sops.placeholder."ipv6-cluster"}";
              destinationPort = [
                "80"
                "443"
                "25565"
              ];
              protocol = "tcp";
            }
            {
              action = "accept";
              comment = "Allow the cluster of Kubernetes";
              destination = "${config.sops.placeholder."ipv6-cluster"}";
              destinationPort = "19132";
              protocol = "udp";
            }
          ];
        };

        output = {
          defaultAction = "accept";
          rules = [ ];
        };
      };

      nat.ipv4 = {
        prerouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "dnat to 192.168.178.1";
              comment = "The DNS of the resolver";
              destination = "8.8.8.8";
              destinationPort = "53";
              protocol = "udp";
            }
            {
              action = "dnat to 192.168.178.1";
              comment = "The DNS of the resolver";
              destination = "8.8.4.4";
              destinationPort = "53";
              protocol = "udp";
            }
          ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "masquerade";
              comment = "The traffic to the internet";
              outbound = "eth0";
            }
            {
              action = "masquerade";
              comment = "The traffic to the cloud";
              outbound = "wg1";
            }
          ];
        };
      };

      nat.ipv6 = {
        prerouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "dnat to ${config.sops.placeholder."ipv6-eth1-2"}";
              comment = "The DNS of the resolver";
              destination = "2001:4860:4860::8844";
              destinationPort = "53";
              inbound = "eth1.2";
              protocol = "udp";
            }
            {
              action = "dnat to ${config.sops.placeholder."ipv6-eth1-2"}";
              comment = "The DNS of the resolver";
              destination = "2001:4860:4860::8888";
              destinationPort = "53";
              inbound = "eth1.2";
              protocol = "udp";
            }
          ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "masquerade";
              comment = "The traffic to the cloud";
              outbound = "wg1";
            }
          ];
        };
      };

      mangle.ipv4 = {
        prerouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "jump cloud";
              comment = "The packets of the cloud";
              inbound = "eth1.2";
            }
            {
              action = "jump clamping";
              comment = "Clamp the MSS of the packets of the tunnel";
              inbound = "wireguard";
            }
            {
              action = "jump inet_cloud";
              comment = "The packets of the internet machines";
              inbound = [
                "wireguard"
              ];
            }
          ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "jump clamping";
              comment = "Clamp the MSS of the packets of the tunnel";
              outbound = [
                "wireguard"
              ];
            }
          ];
        };

        clamping = {
          rules = [
            {
              action = "tcp option maxseg size set 1374";
              counter = false;
              raw = ''
                tcp flags & syn == syn tcp option maxseg size 1375-1460
              '';
              comment = "Clamp the MSS of the tunnel";
            }
          ];
        };

        cloud = {
          rules = [
            {
              action = "meta mark set 0x7fffff98 accept";
              comment = "The packets which were marked already";
              ctMark = 1338;
            }
            {
              action = "meta mark set 0x7fffff97 accept";
              comment = "The packets of the internet machines";
              destination = "!local-addr";
              source = "inet";
            }
            {
              action = "meta mark set 0x7fffff98 accept";
              comment = "The packets which go to the internet";
              destination = "!cloud";
              source = "!bypass-cloud";
            }
          ];
        };

        inet_cloud = {
          rules = [
            {
              action = "ct mark set 0x0000053a";
              comment = "The packets of the internet machines";
              source = "!local-addr";
              state = "new";
            }
          ];
        };
      };

      mangle.ipv6 = {
        prerouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "jump cloud";
              comment = "The packets of the cloud";
              inbound = "eth1.2";
            }
            {
              action = "jump clamping";
              comment = "Clamp the MSS of the packets of the tunnel";
              inbound = "wireguard";
            }
          ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "jump clamping";
              comment = "Clamp the MSS of the packets of the tunnel";
              outbound = "wireguard";
            }
          ];
        };

        clamping = {
          rules = [
            {
              action = "tcp option maxseg size set 1354";
              counter = false;
              raw = ''
                tcp flags & syn == syn tcp option maxseg size 1355-1440
              '';
              comment = "Clamp the MSS of the tunnel";
            }
          ];
        };

        cloud = {
          rules = [
            {
              action = "meta mark set 0x7fffff97 return";
              comment = "The packets of the internet machines";
              source = "inet";
            }
          ];
        };
      };
    };
  };
}
