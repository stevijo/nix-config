# The firewall of the faster-router: the filter, the nat and the mangle
# tables of the VyOS configuration.
#
# The mangle table carries the policy routing: the packets of the home
# tunnels are marked, and the mark selects the route table they are sent
# through.
{ config, ... }:

{
  nixos.configurations.vyos.module = { config, ... }: {
    # The ruleset holds the placeholders of the secrets, which are not
    # valid nftables, so it cannot be checked when it is built. It is
    # checked when it is loaded, after the transformation.
    networking.nftables.checkRuleset = false;

    firewall.groups = {
      interface = {
        Internet = [
          "eth1"
          "eth2"
        ];
        home = [
          "wg0"
          "eth5"
          "vppgre0"
        ];
      };

      network = {
        "local-addr" = [
          "10.0.0.0/8"
          "192.168.0.0/16"
          "172.16.0.0/12"
        ];
      };
    };

    firewall.rules = {
      filter.ipv4 = {
        input = {
          defaultAction = "drop";
          rules = [
            {
              action = "accept";
              comment = "Allow the SSH of the administration";
              destinationPort = "2222";
              protocol = "tcp";
            }
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
              comment = "Allow the pings";
              protocol = "icmp";
            }
            {
              action = "accept";
              comment = "Allow BFD";
              destinationPort = "5201";
              protocol = [
                "tcp"
                "udp"
              ];
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
            {
              action = "accept";
              comment = "Allow the WireGuard tunnel";
              destinationPort = "13231";
              protocol = "udp";
            }
            {
              action = "accept";
              comment = "Allow the home tunnels";
              inbound = "home";
            }
          ];
        };

        forward = {
          defaultAction = "drop";
          rules = [
            {
              action = "accept";
              comment = "Allow the packets which were translated";
              counter = false;
              raw = ''
                ct state new ct status dnat
              '';
            }
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
              comment = "Allow the server network";
              inbound = "eth0";
            }
            {
              action = "accept";
              comment = "Allow the traffic to the internet";
              outbound = "eth1";
            }
            {
              action = "accept";
              comment = "Allow all from the home tunnels";
              inbound = "home";
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
          rules = [
            {
              action = "";
              counter = false;
              raw = ''
                udp dport 3784 iifname "vppgre0" ip ttl < 255 ip ttl set 255 continue
              '';
              comment = "Keep the TTL of the BFD packets of the tunnel";
            }
          ];
        };
      };

      filter.ipv6 = {
        input = {
          defaultAction = "accept";
          rules = [ ];
        };

        forward = {
          defaultAction = "accept";
          rules = [ ];
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
              action = "dnat to 10.50.50.1";
              comment = "The interface of the cluster";
              destinationPort = "8006";
              inbound = "Internet";
              protocol = "tcp";
            }
            {
              action = "dnat to 192.168.178.5";
              comment = "The WireGuard of the unifi machines";
              destinationPort = "51820";
              inbound = "eth1";
              protocol = "udp";
            }
            {
              action = "dnat to 192.168.178.20";
              comment = "The Minecraft of the unifi machines";
              destinationPort = "19132";
              inbound = "eth2";
              protocol = "udp";
            }
            {
              action = "dnat to 192.168.178.20";
              comment = "The Minecraft of the unifi machines";
              destinationPort = "25565";
              inbound = "eth2";
              protocol = "tcp";
            }
            {
              action = "dnat to 192.168.178.172";
              comment = "The machine of the office";
              destinationPort = "4230";
              inbound = "eth2";
              protocol = [
                "tcp"
                "udp"
              ];
            }
            {
              action = "dnat to 10.32.32.1:22";
              comment = "The SSH of the server";
              destinationPort = "2222";
              inbound = "eth2";
              protocol = "tcp";
            }
            {
              action = "dnat to 10.32.32.1";
              comment = "The DNS of the server";
              destinationPort = "53";
              inbound = "eth2";
              protocol = [
                "tcp"
                "udp"
              ];
            }
            {
              action = "dnat to 10.32.32.1";
              comment = "The web of the server";
              destinationPort = [
                "80"
                "443"
                "3000"
              ];
              inbound = "eth2";
              protocol = [
                "tcp"
                "udp"
              ];
            }
            {
              action = "dnat to 10.32.32.5";
              comment = "The SSH of the router";
              destinationPort = "22";
              inbound = "eth1";
              protocol = "tcp";
            }
            {
              action = "dnat to 10.50.50.1";
              comment = "The SSH of the cluster";
              destinationPort = "22";
              inbound = "eth2";
              protocol = "tcp";
            }
            {
              action = "dnat to 10.32.32.5";
              comment = "The IPsec tunnel";
              counter = false;
              raw = "iifname \"eth1\" ip saddr != ${config.sops.placeholder."peer-range"} udp dport { 500, 4500 }";
            }
          ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "masquerade";
              comment = "The traffic of the tunnels to the internet";
              outbound = "eth1";
              source = "!10.0.0.0/8";
            }
            {
              action = "masquerade";
              comment = "The traffic of the router";
              outbound = "eth1";
              source = "10.32.32.5/32";
            }
            {
              action = "masquerade";
              comment = "The traffic of the server network";
              outbound = "eth1";
              source = "10.50.50.0/24";
            }
            {
              action = "masquerade";
              comment = "The traffic of the server";
              destination = "!192.168.0.0/16";
              outbound = "eth1";
              source = "10.32.32.1/32";
            }
            {
              action = "masquerade";
              comment = "The traffic of the tunnels to the second connection";
              outbound = "eth2";
              source = "!10.0.0.0/8";
            }
          ];
        };
      };

      mangle.ipv4 = {
        prerouting = {
          defaultAction = "accept";
          rules = [
            {
              action = "jump faster";
              comment = "The packets of the home tunnels";
              inbound = [
                "wg0"
                "eth5"
                "vppgre0"
              ];
            }
            {
              action = "jump inet_forward";
              comment = "The packets which are forwarded";
              inbound = [
                "wg0"
                "eth0"
                "eth5"
                "vppgre0"
              ];
            }
            {
              action = "jump inet_forward_incoming";
              comment = "The packets which come in";
              inbound = "eth2";
            }
          ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [ ];
        };

        faster = {
          rules = [
            {
              action = "meta mark set 0x7fffff9a accept";
              comment = "The packets which leave the local network";
              destination = "!local-addr";
            }
          ];
        };

        inet_forward = {
          rules = [
            {
              action = "meta mark set 0x7fffff9a accept";
              comment = "The packets which were marked already";
              ctMark = 1337;
            }
          ];
        };

        inet_forward_incoming = {
          rules = [
            {
              action = "ct mark set 0x00000539";
              comment = "The packets which come in";
              destination = "${config.sops.placeholder."public-ipv4-secondary"}";
              state = "new";
            }
          ];
        };
      };

      mangle.ipv6 = {
        prerouting = {
          defaultAction = "accept";
          rules = [ ];
        };

        postrouting = {
          defaultAction = "accept";
          rules = [ ];
        };
      };
    };
  };
}
