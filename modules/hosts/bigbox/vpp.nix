# The vector packet processor of the bigbox: the fast path of the router.
#
# VPP owns the interface to the internet, and the GRE tunnel to the
# faster-router is a tunnel of VPP as well.
#
# The card of the provider is an Intel I226-V, which is on the bus at the
# place 02:00.0. The processor of the packets takes it with the driver of the
# data plane development, and the kernel keeps the address of the card on the
# side of the kernel of the pair with the processor.
{ config, lib, pkgs, ... }:

{
  nixos.configurations.bigbox.module = { config, lib, pkgs, ... }: {
    systemd.services.vpp.serviceConfig.Type = lib.mkForce "notify";

    services.vpp = {
      enable = lib.mkForce true;
      hugepages = {
        enable = true;

        count = lib.mkForce 2560;
      };

      settings = {
        unix = {
          log = "/var/log/vpp.log";
          full-coredump = true;

          "systemd-notify" = true;

          "poll-sleep-usec" = 0;
        };

        cpu = {
          main-core = lib.mkForce 2;
          corelist-workers = lib.mkForce "3-5";
        };

        buffers = {
          "buffers-per-numa" = 212480;
          page-size = "2M";
        };

        plugins.plugin = {
          default.disable = true;
          "avf_plugin.so".enable = true;
          "acl_plugin.so".enable = true;
          "dpdk_plugin.so".enable = true;
          "dhcp_plugin.so".enable = true;
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

        "linux-cp" = {
          lcp-sync = true;
          lcp-auto-subint = true;
        };

        "linux-xfrm-nl" = {
          nl-rx-buffer-size = 268435256;
        };

        "linux-nl" = {
          nl-rx-buffer-size = 268435256;
        };

        statseg = {
          size = lib.mkForce "128M";
          page-size = lib.mkForce "2M";
        };

        memory = {
          main-heap-size = lib.mkForce "4G";
          main-heap-page-size = lib.mkForce "2M";
          default-hugepage-size = lib.mkForce "2M";
        };

        dpdk = {
          dev."0000:02:00.0" = {
            name = "eth0";
            num-rx-desc = 4096;
            num-tx-desc = 4096;
            num-rx-queues = 3;
            num-tx-queues = 3;

          };

          uio-bind-force = true;
        };
      };

      startupConfig = ''
        lcp lcp-sync on
        lcp lcp-auto-subint on

        lcp param route-no-paths on

        set ipsec sa spread on

        lcp create eth0 host-if eth0
        set int mtu packet 1500 eth0
        set int state eth0 up

        set dhcp client intfc eth0
      '';
    };

    systemd.services.vpp = {
      wantedBy = lib.mkForce [ "network-pre.target" ];
      before = lib.mkForce [ "network-pre.target" ];
      after = lib.mkForce [
        "syslog.target"
        "auditd.service"
      ];

      serviceConfig.ExecStartPre = lib.mkForce [
        "${pkgs.kmod}/bin/modprobe uio_pci_generic"
      ];
    };

  };
}
