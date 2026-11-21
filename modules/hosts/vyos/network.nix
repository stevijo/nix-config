# The network of the faster-router: the connections of the machine and the
# tunnel of WireGuard of the VyOS configuration.
#
# The public addresses of the router are not part of this configuration: they
# are kept in the secrets, and the files of the network of systemd hold their
# placeholders, which sops replaces when it writes the secrets.
#
# The names of the interfaces are the ones of the VyOS configuration. They
# have to be replaced by the names of the network interfaces of the machine,
# which are the predictable names of the kernel.
{ config, lib, pkgs, ... }:

{
  nixos.configurations.vyos.module = { config, lib, pkgs, ... }: {
    # The network of systemd, which knows the rules of the policy routing and
    # the virtual routing instances.
    networking.useNetworkd = true;

    networking.useDHCP = false;

    # The nameservers of the machine.
    networking.nameservers = [ "1.1.1.1" ];

    # The resolver of systemd is off, like it is on the laptop. The stub of
    # the resolver does not answer the queries of the resolver of nix, which
    # is not the one of the system, and the command of nix times out on the
    # names of the machines.
    services.resolved.enable = lib.mkForce false;

    # The connections of the machine are described in the files of the
    # network of systemd below, with the instance they are in. They are
    # named here, so that the files of the network of systemd know which
    # device they describe.
    networking.interfaces = lib.mkForce {
      eth0 = { };
      eth1 = { };
      eth2 = { };
      eth5 = { };
    };

    # The files of the network of systemd.
    #
    # The addresses of the provider are in the secrets: they are written in
    # the files as the placeholders of the secrets, and the files are
    # rendered by sops when the secrets are written.
    systemd.network.networks = {
      # The connection to the office of the router. It is in the default
      # instance, like the connection to the office of the routers, which the
      # instances reach through the routes which point to it.
      "40-eth0" = {
        address = [
          "10.50.50.2/24"
          "10.32.32.2/24"
          "${config.sops.placeholder."host-ipv6"}/64"
        ];
        linkConfig.RequiredForOnline = false;
      };

      # The connection to the provider. It is in the first instance, and it
      # holds the pair of the address of the policy of the IPsec.
      "40-eth1" = {
        networkConfig.VRF = "conn1";
        address = [
          "${config.sops.placeholder."public-ipv4"}/24"
          "10.12.0.2/31"
        ];
        linkConfig.RequiredForOnline = false;
      };

      # The second connection to the provider, which is in the second
      # instance. The vlan of the provider is made on it.
      "40-eth2" = {
        networkConfig = {
          VRF = "conn2";
          VLAN = "eth2.1481";
        };
        address = [ "${config.sops.placeholder."public-ipv4-secondary"}/24" ];
        linkConfig.RequiredForOnline = false;
      };

      # The vlan of the second connection to the provider, which is the way
      # to the provider of the version six. It is not in an instance, like
      # the one of the router which is in service, so that the session of
      # the BGP is in the instance of the BGP itself.
      "40-eth2-1481" = {
        matchConfig.Name = "eth2.1481";
        address = [
          "${config.sops.placeholder."public-ipv6"}/128"
          "${config.sops.placeholder."local-ipv6"}/127"
        ];
        linkConfig.RequiredForOnline = false;
      };

      # The connection to the servers.
      "40-eth5" = {
        address = [ "10.15.0.2/24" ];
        linkConfig.MTUBytes = 1400;
        linkConfig.RequiredForOnline = false;
      };
    };

    # The rules of the policy routing: the marks which the rules of the
    # firewall set select the table of the route which is used.
    systemd.network.networks."40-eth1".routingPolicyRules = [
      {
        Family = "ipv4";
        FirewallMark = "0x7fffff9a";
        Priority = 101;
        Table = 101;
      }
    ];

    # The vlan of the second connection to the provider, which is the way to
    # the provider of the version six. The network of systemd makes it on
    # the connection to the provider, which names it.
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

    # The tunnel to the bigbox: the same tunnel as the one of the router to
    # the bigbox, with the addresses of the tunnel of the router and with its
    # keys, so that the tunnel of the routers which are in service is the
    # same one.
    #
    # The peer is the bigbox, which is reached at its public address.
    #
    # The tunnel has an address of the version six as well, so that the
    # adjacency of OSPFv3 and the session of BFD of the version six of the
    # tunnel come up, like they do on the routers.
    networking.wireguard.interfaces = lib.mkForce {
      wg0 = {
        privateKeyFile = config.sops.secrets.wg0-private-key.path;
        listenPort = 13231;
        mtu = 1414;
        ips = [
          "10.11.0.1/24"
          "fd00:11::2/128"

          # The link-local address of the tunnel. The mask is the one of the
          # link and not a single address, so that the kernel makes the route
          # of the link scope by itself, like it does on the bigbox: the
          # session of BFD of the version six of the tunnel needs it to reach
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

            # The endpoint of the peer is in the secrets: the file of the
            # device of the tunnel is rendered by sops, like the files of the
            # network.
            endpoint = "${config.sops.placeholder."wg-endpoint"}";

            persistentKeepalive = 60;
          }
        ];

        # The routes of the allowed addresses are not added: the tables of the
        # policy routing decide where the traffic goes.
        allowedIPsAsRoutes = false;
      };
    };

    # The tunnel of GRE is the pair of the tunnel of the processor and of the
    # kernel. The device is made by the processor, so the network of systemd
    # configures it when it appears.
    #
    # The address of the version six of the link is the one of the router
    # which is in service, and the other side of the tunnel points at it.
    # The kernel makes an address of its own as well, so the network of
    # systemd is told not to make one, and the one of the router which is in
    # service is the only one on the link.
    systemd.network.networks."50-vppgre0" = {
      matchConfig.Name = "vppgre0";
      address = [
        "10.14.0.1/24"
        "fe80::a074:a5ff:fea1:d5cb/128"
      ];
      networkConfig.IPv6LinkLocalAddressGenerationMode = "none";
    };

    # The units which are needed by the network of the machine.
    systemd.services = { };

    # The names of the interfaces of the machine, which are the ones of the
    # VyOS configuration.
    #
    # The first card of the machine is the network of the office, which is
    # the one of eth0, and the second one is the network of the servers,
    # which is the one of eth5.
    #
    # The card of the provider is taken by the processor of the packets, so
    # the side of the kernel of the pair with it is the one of eth1. The
    # second function of the card is not taken by the processor, so the
    # connection of the kernel with it is the one of eth2.
    systemd.network.links = {
      "10-vyos-eth0" = {
        matchConfig.MACAddress = "bc:24:11:11:3a:99";
        linkConfig.Name = "eth0";
      };
      "10-vyos-vpp0" = {
        # The card of the provider is used by the processor of the packets, so
        # the kernel does not manage it. The rule names it by its place in the
        # bus as well, because the side of the kernel of the pair has the
        # address of the card.
        matchConfig.MACAddress = "e8:eb:d3:2b:1f:13";
        matchConfig.Path = "pci-*";
        linkConfig.Name = "defunct_eth1";
      };
      "10-vyos-eth2" = {
        # The vlan of the card has the address of the card, so the rule names
        # the card by its place in the bus as well.
        matchConfig.MACAddress = "e8:eb:d3:2b:1f:14";
        matchConfig.Path = "pci-*";
        linkConfig.Name = "eth2";
      };
      "10-vyos-vppgre0" = {
        matchConfig.OriginalName = "vppgre0";
        linkConfig.TransmitQueueLength = 4096;
      };
      "10-vyos-eth5" = {
        matchConfig.MACAddress = "bc:24:11:ee:c6:f6";
        linkConfig.Name = "eth5";
      };
    };
  };
}
