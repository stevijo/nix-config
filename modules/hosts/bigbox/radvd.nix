{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, pkgs, ... }: {
    environment.etc."radvd.conf".source =
      pkgs.writeText "radvd.conf" config.services.radvd.config;

    services.radvd = {
      enable = true;

      config = ''
        interface eth1.2 {
          AdvSendAdvert on;
          AdvDefaultPreference medium;
          MaxRtrAdvInterval 60;
          MinRtrAdvInterval 30;
          AdvDefaultLifetime 1800;
          AdvOtherConfigFlag on;
          prefix ${config.sops.placeholder."prefix-be00"} {
            AdvAutonomous on;
            AdvOnLink on;
            AdvValidLifetime 2592000;
            AdvPreferredLifetime 14400;
          };
          RDNSS ${config.sops.placeholder."ipv6-eth1-2"} {
          };
        };

        interface eth1.3 {
          AdvSendAdvert off;
          AdvDefaultPreference medium;
          MaxRtrAdvInterval 60;
          MinRtrAdvInterval 30;
          AdvDefaultLifetime 1800;
          prefix ${config.sops.placeholder."prefix-be01"} {
            AdvAutonomous on;
            AdvOnLink on;
            AdvValidLifetime 2592000;
            AdvPreferredLifetime 14400;
          };
          RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {
          };
        };

        interface eth1.4 {
          AdvSendAdvert off;
          AdvDefaultPreference medium;
          MaxRtrAdvInterval 60;
          MinRtrAdvInterval 30;
          AdvDefaultLifetime 1800;
          prefix ${config.sops.placeholder."prefix-be02"} {
            AdvAutonomous on;
            AdvOnLink on;
            AdvValidLifetime 2592000;
            AdvPreferredLifetime 14400;
          };
          RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {
          };
        };
      '';
    };
  };
}
