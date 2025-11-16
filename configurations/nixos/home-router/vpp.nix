# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    (self + /modules/nixos/linux/vpp)
  ];

  environment.systemPackages = with pkgs; [
    vpp
  ];

  networking.networkmanager.enable = false;
  networking.useDHCP = false;
  networking.interfaces = { };
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  systemd.services.vpp-main.serviceConfig.ExecStartPre = [
    "-${pkgs.bash}/bin/bash -c 'echo 0000:06:12.0 > /sys/bus/pci/drivers/virtio-pci/unbind'"
    "-${pkgs.bash}/bin/bash -c 'echo 0000:06:13.0 > /sys/bus/pci/drivers/virtio-pci/unbind'"
    "-${pkgs.bash}/bin/bash -c 'echo uio_pci_generic > /sys/bus/pci/devices/0000\\:06\\:12.0/driver_override'"
    "-${pkgs.bash}/bin/bash -c 'echo uio_pci_generic > /sys/bus/pci/devices/0000\\:06\\:13.0/driver_override'"
  ];
  services.vpp = {
    hugepages.autoSetup = true;
    instances = {
      main = {
        enable = true;
        settings = {
          api-segment = {
            prefix = false;
          };
          plugins.plugin = {
            "dpdk_plugin.so".disable = true;
            "rdma_plugin.so".disable = true;
            "linux_cp_plugin.so".enable = true;
            "linux_nl_plugin.so".enable = true;
            "igmp_plugin.so".disable = true;
            "arping_plugin.so".disable = true;
            "ikev2_plugin.so".disable = true;
          };
        };
        startupConfig = ''
          create interface virtio 0000:06:12.0
          create interface virtio 0000:06:13.0
          define ETH0 virtio-0/6/12/0
          define ETH1 virtio-0/6/13/0

          lcp lcp-sync on
          lcp lcp-auto-subint on

          lcp create $(ETH0) host-if e0

          set int mtu packet 1500 $(ETH0)
          set int state $(ETH0) up
          set int ip address $(ETH0) 10.13.0.5/31

          loopback create
          set int state loop0 up
          set int ip address loop0 10.12.0.3/31
          set ip neighbor loop0 10.12.0.2 24:6e:96:9c:e5:de

          create gre tunnel src 10.12.0.3 dst 10.12.0.2 teb
          set int state gre0 up
          set int mtu packet 1414 gre0
        
          set int mtu packet 1500 $(ETH1)
          set int state $(ETH1) up

          set interface l2 bridge $(ETH1) 100
          set interface l2 bridge gre0 100

          set ipsec async mode on
        '';
      };
    };
  };
}
