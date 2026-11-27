{ ... }:

{
  nixos.configurations.vyos.module = { config, lib, ... }: {
    services.frr = {
      bgpd.enable = true;
      ospfd.enable = true;
      ospf6d.enable = true;
      bfdd.enable = true;

      config = ''
        ip prefix-list internal seq 1 permit 10.32.32.0/24
        ip prefix-list internal seq 2 permit 192.168.2.0/24
        !
        route-map ONLY-INTERNAL permit 1
         match ip address prefix-list internal
        exit
        !
        ip route 0.0.0.0/0 ${config.sops.placeholder."gateway-ipv4"} nexthop-vrf conn1
        ip route ${config.sops.placeholder."public-ipv4"}/32 eth1 nexthop-vrf conn1
        ip route ${config.sops.placeholder."public-ipv4-secondary"}/32 eth2 nexthop-vrf conn2
        ip route 192.168.2.0/24 10.15.0.1

        ip route 192.168.178.135/32 ${(lib.head config.tunnel.tunnels).innerRemote}
        !
        vrf conn1
         ip route 0.0.0.0/0 ${config.sops.placeholder."gateway-ipv4"}
         ip route 10.32.32.0/24 eth0 nexthop-vrf default
         ip route 10.50.50.0/24 eth0 nexthop-vrf default
        exit-vrf
        !
        vrf conn2
         ip route 0.0.0.0/0 ${config.sops.placeholder."gateway-ipv4"}
         ip route 10.32.32.0/24 eth0 nexthop-vrf default
         ip route 10.50.50.0/24 eth0 nexthop-vrf default
        exit-vrf
        !
        interface wg0
         ip ospf area 1.1.1.1
         ip ospf bfd
         ip ospf bfd profile wireguard
         ip ospf cost 5
         ip ospf dead-interval 40
         ip ospf network point-to-point
         ipv6 ospf6 area 1.1.1.1
         ipv6 ospf6 bfd
         ipv6 ospf6 bfd profile wireguard
         ipv6 ospf6 cost 5
        exit
        !
        router bgp ${config.sops.placeholder."asn"}
         bgp router-id ${config.sops.placeholder."public-ipv4-secondary"}
         no bgp ebgp-requires-policy
         no bgp reject-as-sets
         no bgp default ipv4-unicast
         no bgp network import-check
         neighbor ${config.sops.placeholder."peer-ipv6"} remote-as ${config.sops.placeholder."peer-asn"}
         neighbor ${config.sops.placeholder."peer-ipv6"} password ${config.sops.placeholder."bgp-password"}
         neighbor ${config.sops.placeholder."peer-ipv6"} solo
         no neighbor ${config.sops.placeholder."peer-ipv6"} enforce-first-as
         neighbor ${config.sops.placeholder."peer-ipv6"} update-source ${config.sops.placeholder."local-ipv6"}
         !
         address-family ipv4 unicast
          redistribute ospf
          rd vpn export ${config.sops.placeholder."route-target"}
          rt vpn export ${config.sops.placeholder."route-target"}
          export vpn
         exit-address-family
         !
         address-family ipv6 unicast
          network ${config.sops.placeholder."prefix-ipv6"}
          neighbor ${config.sops.placeholder."peer-ipv6"} activate
         exit-address-family
        exit
        !
        router bgp ${config.sops.placeholder."asn"} vrf conn1
         no bgp ebgp-requires-policy
         no bgp reject-as-sets
         no bgp default ipv4-unicast
         no bgp network import-check
         !
         address-family ipv4 unicast
          rt vpn import ${config.sops.placeholder."route-target"}
          export vpn
          import vpn
         exit-address-family
        exit
        !
        router bgp ${config.sops.placeholder."asn"} vrf conn2
         no bgp ebgp-requires-policy
         no bgp reject-as-sets
         no bgp default ipv4-unicast
         no bgp network import-check
         !
         address-family ipv4 unicast
          rt vpn import ${config.sops.placeholder."route-target"}
          import vpn
         exit-address-family
        exit
        !
        router ospf
         ospf router-id 10.10.0.1
         auto-cost reference-bandwidth 100
         timers throttle spf 200 1000 10000
         maximum-paths 5
         redistribute connected route-map ONLY-INTERNAL
         redistribute static route-map ONLY-INTERNAL
         default-information originate always
        exit
        !
        router ospf6
         ospf6 router-id 10.10.0.1
         auto-cost reference-bandwidth 100
         maximum-paths 5
         redistribute connected
         default-information originate always metric-type 2
        exit
        !
        bfd
         profile ipsec
          transmit-interval 200
          receive-interval 200
          minimum-ttl 1
         exit
         !
         profile wireguard
          detect-multiplier 6
         exit
         !
        exit
      '';
    };
  };
}
