{ ... }:

{
  nixos.modules.tunnel = { config, lib, pkgs, ... }: {
    options =
      {
        tunnel =
          let
            tunnelType = lib.types.submodule {
              options = {
                index = lib.mkOption {
                  type = lib.types.int;
                  description = ''
                    The number of the tunnel, which is the number of the device of it in
                    the kernel: the device is the one which is named in the rules of the
                    firewall and in the configuration of the routing. It is not the
                    place of the tunnel in the list: the processor of the packets names
                    the tunnels of GRE in the order in which they are made.
                  '';
                };

                outer = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    The address of the tunnel on the connection to the provider. It is
                    the traffic selector of the IPsec and the address of the packets of
                    the tunnel on the wire.
                  '';
                };

                outerRemote = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    The address of the other end of the tunnel on the connection to the
                    provider.
                  '';
                };

                inner = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    The address of the tunnel in the kernel, which is the address of the
                    network of the tunnel of GRE.
                  '';
                };

                innerRemote = lib.mkOption {
                  type = lib.types.str;
                  description = "The address of the other end of the tunnel in the kernel.";
                };

                linkLocal = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    The link-local address of the link of the tunnel. The kernel does not
                    make addresses of its own on the links, so they are written down.
                  '';
                };

                remoteLinkLocal = lib.mkOption {
                  type = lib.types.str;
                  description = "The link-local address of the other side of the tunnel.";
                };

                solicitedNode = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    The group of the neighbour discovery of the other side of the
                    tunnel: the last three bytes of its link-local address, with the
                    prefix ff02::1:ff.
                    The packets of the group have to leave by the tunnel of the other
                    side, or the neighbour of the link-local address of the other side
                    is never resolved, and the sessions which use it -- the BFD -- are
                    never established.
                  '';
                };
              };
            };
          in
          {
            count = lib.mkOption {
              type = lib.types.int;
              description = ''
                The number of the tunnels of GRE of the machine. There is one tunnel
                per worker of the processor of the packets which is used, so that the
                traffic of the tunnels is spread over them.
              '';
            };

            side = lib.mkOption {
              type = lib.types.enum [ "local" "remote" ];
              description = ''
                Which end of the link the machine is.

                The `local` end holds the address of the provider and the other end is
                behind it: the faster-router is the `local` end, and the bigbox of the
                lab is the `remote` one. The addresses of the tunnels are the same on
                both sides, with the addresses of each end exchanged.
              '';
            };

            tunnels = lib.mkOption {
              type = lib.types.listOf tunnelType;
              default = [ ];
              description = ''
                The tunnels of GRE of the machine. The module of the tunnels makes
                them from the number of them and the side of the machine.
              '';
            };

            children = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              description = ''
                The children of the connection of the IPsec: one per tunnel of GRE,
                with the traffic selector of it. The connection of the machine uses
                them.
              '';
            };
          };

      };
    config =
      let
        cfg = config.tunnel;

        sides = {
          local = {
            outer = 2;
            inner = 1;
            linkLocal = "fe80::a074:a5ff:fea1:d5cc";
            remoteLinkLocal = "fe80::aab8:e0ff:fe04:5323";
          };

          remote = {
            outer = 3;
            inner = 2;
            linkLocal = "fe80::aab8:e0ff:fe04:5323";
            remoteLinkLocal = "fe80::a074:a5ff:fea1:d5cc";
          };
        };

        side = sides.${cfg.side};
        other = if cfg.side == "local" then sides.remote else sides.local;

        # The digits of a hexadecimal number.
        digits = hex:
          lib.filter (c: c != "") (lib.splitString "" hex);

        hexDigit = digit:
          let
            count = lib.foldl'
              (acc: c: {
                index = if acc.index == null && c == digit then acc.number else acc.index;
                number = acc.number + 1;
              })
              { index = null; number = 0; }
              (digits "0123456789abcdef");
          in
          count.index;

        hexToInt = hex:
          lib.foldl' (acc: digit: acc * 16 + hexDigit digit) 0 (digits hex);

        intToHex = n:
          let
            all = "0123456789abcdef";
          in
          lib.substring (lib.div n 16) 1 all + lib.substring (lib.mod n 16) 1 all;

        withLastByte = address: n:
          let
            hextets = lib.splitString ":" address;
            last = lib.last hextets;
            byte = hexToInt (lib.substring 2 2 last);
          in
          lib.concatStringsSep ":"
            (lib.init hextets ++ [ ((lib.substring 0 2 last) + intToHex (byte + n)) ]);

        solicitedNode = address:
          let
            hextets = lib.splitString ":" address;
            last = lib.last hextets;
            before = lib.elemAt hextets (lib.length hextets - 2);
            bytes = lib.substring 2 2 before + last;
          in
          "ff02::1:ff" + lib.substring 0 2 bytes + ":" + lib.substring 2 4 bytes;

        tunnels = lib.map
          (n: {
            index = n;
            outer = "10.12.${toString (n + 1)}.${toString side.outer}";
            outerRemote = "10.12.${toString (n + 1)}.${toString other.outer}";
            inner = "10.14.${toString (n + 1)}.${toString side.inner}";
            innerRemote = "10.14.${toString (n + 1)}.${toString other.inner}";
            linkLocal = withLastByte side.linkLocal n;
            remoteLinkLocal = withLastByte side.remoteLinkLocal n;
            solicitedNode = solicitedNode (withLastByte side.remoteLinkLocal n);
          })
          (lib.range 0 (cfg.count - 1));

        children = lib.listToAttrs (map
          (tunnel: {
            name = "tunnel-${toString tunnel.index}";
            value = {
              esp_proposals = [ "aes256gcm128-sha256-curve25519" ];
              life_time = "1800s";
              local_ts = [ "${tunnel.outer}/32" ];
              remote_ts = [ "${tunnel.outerRemote}/32" ];

              ipcomp = false;
              mode = "tunnel";
              start_action = "start";
              close_action = "start";
              replay_window = 2040;
            };
          })
          tunnels);
      in
      {
        tunnel = {
          tunnels = tunnels;
          children = children;
        };

        networking.useNetworkd = lib.mkDefault true;

        services.vpp.startupConfig = lib.mkAfter (
          lib.concatStrings
            (map
              (position:
                let
                  tunnel = lib.elemAt tunnels position;
                  gre = "gre${toString position}";
                  tun = "tun${toString (4097 + position)}";
                in
                ''
                  create gre tunnel src ${tunnel.outer} dst ${tunnel.outerRemote}
                  lcp create ${gre} host-if vppgre${toString tunnel.index} tun
                  set int mtu packet 1414 ${gre}
                  set interface state ${gre} up
                  l3xc add ${gre} via ${tun} ip4
                '')
              (lib.range 0 (lib.length tunnels - 1))
            )
          + lib.concatStrings (map
            (position:
              let
                tunnel = lib.elemAt tunnels position;
              in
              ''
                ip route add 224.0.0.5/32 via gre${toString position}
                ip route add 224.0.0.6/32 via gre${toString position}
                ip route add ff02::5/128 via gre${toString position}
                ip route add ff02::6/128 via gre${toString position}
                ip route add ${tunnel.solicitedNode}/128 via gre${toString position}
                ip route add ${tunnel.remoteLinkLocal}/128 via gre${toString position}
              '')
            (lib.range 0 (lib.length tunnels - 1))
          )
        );

        systemd.network.networks = lib.mkMerge [
          (lib.listToAttrs (map
            (tunnel: {
              name = "40-vppgre${toString tunnel.index}";
              value = {
                matchConfig.Name = "vppgre${toString tunnel.index}";
                address = [
                  "${tunnel.inner}/24"
                  "${tunnel.linkLocal}/128"
                ];
                networkConfig.IPv6LinkLocalAddressGenerationMode = "none";
              };
            })
            tunnels))
        ];

        services.frr.config = lib.mkAfter (
          lib.concatMapStrings
            (tunnel: ''
              ipv6 route ${tunnel.remoteLinkLocal}/128 vppgre${toString tunnel.index}
            '')
            tunnels
          + lib.concatMapStrings
            (tunnel: ''
              interface vppgre${toString tunnel.index}
               ip ospf area 1.1.1.1
               ip ospf bfd
               ip ospf bfd profile wireguard
               ip ospf cost 1
               ip ospf dead-interval 40
               ipv6 ospf6 area 1.1.1.1
               ipv6 ospf6 bfd
               ipv6 ospf6 bfd profile wireguard
               ipv6 ospf6 cost 1
              exit
              !
            '')
            tunnels
        );

        systemd.network.links = lib.mkMerge [
          (lib.listToAttrs (map
            (tunnel: {
              name = "10-vyos-vppgre${toString tunnel.index}";
              value = {
                matchConfig.OriginalName = "vppgre${toString tunnel.index}";
                linkConfig.TransmitQueueLength = 4096;
              };
            })
            tunnels))
        ];

        boot.kernel.sysctl = {
          "net.ipv6.conf.default.addr_gen_mode" = 1;
        };

        firewall.rules.mangle.ipv4.prerouting.rules = map
          (tunnel: {
            action = "";
            counter = false;
            raw = ''
              udp dport 3784 iifname "vppgre${toString tunnel.index}" ip ttl < 255 ip ttl set 255 continue
            '';
            comment = "Keep the TTL of the BFD packets of the tunnel";
          })
          tunnels;

        firewall.rules.mangle.ipv6.prerouting.rules = map
          (tunnel: {
            action = "";
            counter = false;
            raw = ''
              ip6 nexthdr ospfigp iifname "vppgre${toString tunnel.index}" ip6 hoplimit != 255 ip6 hoplimit set 255 continue
              ip6 nexthdr udp udp dport 3784 iifname "vppgre${toString tunnel.index}" ip6 hoplimit != 255 ip6 hoplimit set 255 continue
            '';
            comment = "Keep the hop limit of the packets of the tunnel";
          })
          tunnels;
      };
  };
}
