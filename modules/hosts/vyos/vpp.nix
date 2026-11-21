# The vector packet processor of the faster-router: the fast path of the
# router.
#
# VPP owns the interface of the connection to the provider, and the GRE
# tunnel to the bigbox is a tunnel of VPP as well.
#
# The machine takes the card of the provider of the router which is in
# service, so the processor of the packets binds it with the driver of the
# data plane development and not with the driver of the virtual cards: the
# plugin of the data plane development has to be enabled, the driver of the
# cards of Mellanox has to be loaded, and the settings of the processor have
# to say which card it takes.
#
# The addresses of the connections are not in the configuration of the
# processor: they are in the secrets, they are set by the kernel, and the
# plugin of the network of the kernel gives them to the processor.
{ config, lib, pkgs, ... }:

{
  nixos.configurations.vyos.module = { config, lib, pkgs, ... }: {
    services.vpp = {
      # The package of VPP is built from the sources, which takes a long
      # time.
      enable = lib.mkForce true;

      # The pages of the machine are the ones of the router which is in
      # service: five gigabytes of them. They are for the heap of the
      # processor and for its segment of the counters.
      hugepages = {
        enable = true;
        count = lib.mkForce 2560;
      };

      settings = {
        unix = {
          log = "/var/log/vpp.log";
          full-coredump = true;
        };

        cpu = {
          main-core = lib.mkForce 2;
          corelist-workers = lib.mkForce "3-7";
        };

        # The buffers of the processor, which are the ones of the router
        # which is in service.
        buffers = {
          "buffers-per-numa" = 106240;
          page-size = "2M";
        };

        # The plugins of the processor. The set of the plugins is off by
        # default, so the ones which are needed are switched on one by one.
        plugins.plugin = {
          default.disable = true;
          "avf_plugin.so".enable = true;
          "acl_plugin.so".enable = true;
          "dpdk_plugin.so".enable = true;
          "gre_plugin.so".enable = true;
          "lacp_plugin.so".enable = true;
          "linux_cp_plugin.so".enable = true;
          "linux_nl_plugin.so".enable = true;
          "nat_plugin.so".enable = true;
          "l3xc_plugin.so".enable = true;
          "dns_plugin.so".enable = true;
          "crypto_sw_scheduler_plugin.so".enable = true;
          "ip_session_redirect_plugin.so".enable = true;
          "vmxnet3_plugin.so".enable = true;
          "dispatch_trace_plugin.so".enable = true;
        };

        crypto-engines = {
          default.disable = true;
          native.enable = true;
          ipsecmb.enable = true;
          openssl.enable = true;
        };

        # The settings of the plugin of the network of the kernel. The
        # routing of the prefixes without a path is a patch of VyOS which is
        # not applied here, so it is not a setting of the processor.
        "linux-cp" = {
          lcp-sync = true;
          lcp-auto-subint = true;
        };

        "linux-nl" = {
          nl-rx-buffer-size = 268435456;
        };

        statseg = {
          size = lib.mkForce "128M";
          page-size = lib.mkForce "2M";
        };

        memory = {
          main-heap-size = lib.mkForce "3G";
          main-heap-page-size = lib.mkForce "2M";
          default-hugepage-size = lib.mkForce "2M";
        };

        # The card of the provider, which the processor of the packets uses.
        # The queues are the ones of the router which is in service.
        #
        # The card stays with the kernel: the plugin of the cards of Mellanox
        # finds the device of the verbs only while the driver of the kernel
        # holds it, and the processor of the packets does not need the card
        # for itself.
        dpdk = {
          dev."0000:01:00.0" = {
            name = "eth1";
            num-rx-desc = 4096;
            num-tx-desc = 4096;
            num-rx-queues = 5;
            num-tx-queues = 5;
          };
        };
      };

      # The commands of the start of the processor. They are read one by one,
      # and the first one which fails stops the ones which follow it, so the
      # pair of the tunnel is made at the end.
      startupConfig = lib.mkForce ''
        lcp lcp-sync on
        lcp lcp-auto-subint on

        # The routes which the kernel has and the processor does not are
        # installed as local, like they are on the router which is in
        # service: without it the processor stops when the kernel tells it
        # about an address whose prefix has no path in it.
        lcp param route-no-paths on

        # The pair of the card and of the network of the kernel. The card is
        # taken from the kernel, so the name of the side of the kernel is
        # free and the pair takes it.
        lcp create eth1 host-if eth1
        set int mtu packet 1500 eth1
        set interface state eth1 up

        # The tunnel of GRE points to the other side: to the address of the
        # bigbox on the connection to the provider, which is the address of
        # the policy of the IPsec.
        create gre tunnel src 10.12.0.2 dst 10.12.0.3

        # The pair of the tunnel and of the kernel is made right away, before
        # the address of the tunnel is set: the plugin follows the changes of
        # the addresses of the processor and it gives them to the kernel, so
        # the pair has to be there when the address is set.
        lcp create gre0 host-if vppgre0 tun

        set int mtu packet 1414 gre0
        set interface state gre0 up

        l3xc add gre0 via tun4097 ip4
      '';
    };

    # The processor of the packets starts before the network is configured:
    # the first connection of the kernel is the side of the kernel of the
    # pair with the processor, and the processor creates it. The routing of
    # the routers waits for its address.
    systemd.services.vpp = {
      wantedBy = lib.mkForce [ "network-pre.target" ];
      before = lib.mkForce [ "network-pre.target" ];
      after = lib.mkForce [
        "syslog.target"
        "auditd.service"
      ];
    };
  };
}
