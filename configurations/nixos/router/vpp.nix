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
            "rdma_plugin.so".disable = true;
            "linux_cp_plugin.so".enable = true;
            "linux_nl_plugin.so".enable = true;
            "igmp_plugin.so".disable = true;
            "arping_plugin.so".disable = true;
            "ikev2_plugin.so".disable = true;
          };
        };
        startupConfig = ''
          define ETH0 GigabitEthernet6/12/0
          define ETH1 GigabitEthernet6/13/0

          lcp lcp-sync on
          lcp lcp-auto-subint on

          lcp create $(ETH0) host-if e0

          set int state $(ETH0) up
          set int ip address $(ETH0) 10.32.32.5/24

          loopback create
          set int state loop0 up
          set int ip address loop0 10.12.0.2/31
          set ip neighbor loop0 10.12.0.3 24:6e:96:9c:e5:de

          create gre tunnel src 10.12.0.2 dst 10.12.0.3 teb
          set int state gre0 up
          set int mtu packet 1414 gre0
          set int tcp-mss-clamp gre0 ip4 enable ip4-mss 1360 ip6 disable
        
          set int state $(ETH1) up

          set interface l2 bridge $(ETH1) 100
          set interface l2 bridge gre0 100

          set ipsec async mode on
        '';
      };
    };
  };
}
