{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, ... }: {
    services.frr = {
      ospfd.enable = true;
      ospf6d.enable = true;
      bfdd.enable = true;

      config = ''
        ip prefix-list default seq 1 permit 0.0.0.0/0
        ip prefix-list default seq 2 permit 192.168.2.0/24
        !
        route-map not-default deny 1
         match ip address prefix-list default
        exit
        !
        route-map not-default permit 2
        exit
        !

        ip route 0.0.0.0/0 ${config.sops.placeholder."gateway-ipv4"} eth0 tag 210 210
        ip route 0.0.0.0/0 wg1 table 104
        ip route 10.32.32.3/32 blackhole
        ip route 10.72.36.0/24 192.168.178.5
        ip route 192.168.0.0/16 blackhole
        ipv6 route ::/0 wg1 table 104
        ipv6 route ${config.sops.placeholder."ipv6-host"}/128 eth0
        !
        ip route 0.0.0.0/0 10.32.32.2 table 103
        ipv6 route ${config.sops.placeholder."prefix-local"} blackhole
        !
        ipv6 route ${config.sops.placeholder."prefix-dd00"} blackhole
        ipv6 route ${config.sops.placeholder."prefix-dns64"} blackhole
        ipv6 route ${config.sops.placeholder."prefix-dd01"} fe80::c05b:2fff:fec0:73f2 eth1.2
        ipv6 route ${config.sops.placeholder."prefix-dd02"} fe80::78d6:d8ff:fe54:2f56 eth1.2
        ipv6 route ${config.sops.placeholder."prefix-dead"} ${config.sops.placeholder."prefix-be00-host"}
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
        router ospf
         ospf router-id 10.10.0.2
         auto-cost reference-bandwidth 100
         timers throttle spf 200 1000 10000
         redistribute static route-map not-default
         distance 210
         maximum-paths 5
        exit
        !
        router ospf6
         ospf6 router-id 10.10.0.2
         auto-cost reference-bandwidth 100
         redistribute static
         maximum-paths 5
        exit
        !
        bfd
         profile ipsec
          transmit-interval 200
          receive-interval 200
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
