{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { lib, pkgs, ... }: {

    networking.wireguard.enable = true;
    networking.wg-quick.interfaces = {
      wg0 = {
        autostart = false;
        configFile = builtins.toString (pkgs.writeText "wg0.conf" ''
          [Interface]
          Address = 172.30.0.5/24
          Address = !!PREFIX!!:dead::5/64
          DNS = 192.168.178.1
          MTU = 1340
          PrivateKey = !!WG0!!
          [Peer]
          PublicKey = 3ToM7Pg2tvAalsORya45gR0TS2wHSo7E5Mx7om0QISE=
          Endpoint = router:51820
          PersistentKeepalive = 60
          AllowedIPs = 192.168.178.0/24, 192.168.2.0/24, 10.72.36.0/24
        '');
      };
    };
  };
}
