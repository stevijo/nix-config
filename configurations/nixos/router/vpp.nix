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
          dpdk = {
            dev = {
              default = {
                num-tx-queues = 2;
                num-rx-queues = 2;
                num-rx-desc = 512;
                num-tx-desc = 512;
              };
            };
          };
          cpu = {
            main-core = 0;
            workers = 3;
          };
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
          define ETH0 GigabitEthernet1/0/0
          define ETH1 GigabitEthernet2/0/0

          lcp lcp-sync on
          lcp lcp-auto-subint on

          lcp create $(ETH0) host-if e0
          lcp create $(ETH1) host-if e1

          set int ip address $(ETH0) !!ROUTER-IP!!/24
          set int ip address $(ETH0) !!ROUTER-IP6!!/64
          set int ip address $(ETH0) !!PREFIX!!::1/128 
          set int state $(ETH0) up

          set int ip address $(ETH1) 10.32.32.2/24
          set int state $(ETH1) up

          comment { "internal" }
          loopback create
          set int state loop0 up
          set int ip address loop0 10.12.0.1/24
          set ip neighbor loop0 10.12.0.2 24:6e:96:9c:e5:de

          create gre tunnel src 10.12.0.1 dst 10.12.0.2
          lcp create gre0 host-if wg0 tun
          set int ip address gre0 10.11.0.1/24
          set int state gre0 up
          set int mtu packet 1414 gre0
          set int tcp-mss-clamp gre0 ip4 enable ip4-mss 1374 ip6 disable
          ip route add 224.0.0.5/32 via gre0
          ip route add ff02::5/128 via gre0

          set ipsec async mode on
          set crypto async dispatch mode polling

          comment { "External wireguard" }
          wireguard create listen-port 51820 private-key !!PRIVATE-REMOTE!! src 185.175.59.204
          wireguard peer add wg0 public-key dGNfVhc6e/PNLnRs0Qspkvl1RYwsq0vshxacC4rS+i4= allowed-ip 172.30.0.5/32 allowed-ip !!PREFIX!!:dead::5/128 persistent-keepalive 60
          wireguard peer add wg0 public-key DTSn1nYNsiEIssdXLSKP0juaqOzdQBtLoNyfH25DAGg= allowed-ip 172.30.0.3/32 allowed-ip !!PREFIX!!:dead::3/128 persistent-keepalive 60

          ip route add 172.30.0.3/32 via wg0
          ip route add 172.30.0.5/32 via wg0
          ip route add !!PREFIX!!:dead::/64 via wg0

          set int state wg0 up
          set int tcp-mss-clamp wg0 ip4 enable ip4-mss 1360 ip6 enable ip6-mss 1340
          set int mtu packet 1400 wg0
          set int ip address wg0 172.30.0.1/24

          comment { "This may need some extra vpp instance" }
          set cnat snat-policy addr 10.32.32.2
          set cnat snat-policy if table include-v4 wg0
          set interface feature wg0 cnat-snat-ip4 arc ip4-unicast
        '';
      };
    };
  };
}
