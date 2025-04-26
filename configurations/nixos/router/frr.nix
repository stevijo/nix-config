# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  systemd.services.frr.requires = [
    "vpp-main.service"
  ];
  services.frr = {
    ospfd.enable = true;
    bfdd.enable = true;
    bgpd.enable = true;
    ospf6d.enable = true;
    config = ''
      ip route 0.0.0.0/0 !!ROUTER-GW!! e0
      ipv6 route 2605:4840:ffff::179/128 fe80::1 e0
      !
      interface wg0
       ip ospf area 1.1.1.1
       ip ospf dead-interval 40
       ip ospf bfd
       ip ospf bfd profile wireguard
       ip ospf network point-to-point
       ip ospf6 area 1.1.1.1
       ip ospf6 cost 30
       ip ospf6 bfd
       ip ospf6 bfd profile wireguard
      exit
      !
      interface wg1
       ip ospf6 area 1.1.1.1
       ip ospf6 cost 30
       ip ospf6 bfd
      exit
      !
      ip prefix-list hosthatch seq 1 permit 10.32.32.0/24
      !
      router ospf
       ospf router-id 10.10.0.1
       neighbor 10.11.0.2 poll-interval 10
       timers throttle spf 200 1000 10000
       redistribute connected route-map hosthatch
      exit
      !
      router ospf6
        ospf6 router-id 10.10.0.1
        redistribute connected
        default-information originate always metric-type 2
      exit
      !
      router bgp !!ASN!!
        no bgp ebgp-requires-policy
        no bgp default ipv4-unicast
        no bgp network import-check
        neighbor 2605:4840:ffff::179 remote-as 65473
        neighbor 2605:4840:ffff::179 password !!BGP-PASSWORD!!
        neighbor 2605:4840:ffff::179 solo
        neighbor 2605:4840:ffff::179 update-source !!ROUTER-IP6!!
        neighbor 2605:4840:ffff::179 ebgp-multihop 2
        !
        address-family ipv6 unicast
          network !!PREFIX!!::/48
          neighbor 2605:4840:ffff::179 activate
          neighbor 2605:4840:ffff::179 route-map prepend out
        exit-address-family
      exit
      !
      route-map hosthatch permit 1
       match ip address prefix-list hosthatch
      exit
      !
      route-map prepend permit 1
       set as-path prepend !!ASN!! !!ASN!!
       set community 63473:2090 additive
      exit
      !
      bfd
       profile wireguard
        detect-multiplier 4
       exit
       !
      exit
    '';
  };
}
