{ ... }:

{
  nixos.configurations.vyos.extensions = { config, lib, pkgs, prev, ... }:
    let
      swanctlConfig = prev.config.environment.etc."swanctl/swanctl.conf".source;
      frrConfig = prev.config.environment.etc."frr/frr.conf".source;
      nftablesRules = builtins.elemAt
        prev.config.systemd.services.nftables.serviceConfig.ExecStart
        1;

      networks = prev.config.systemd.network.networks;
      netdevs = prev.config.systemd.network.netdevs;
    in
    {
      systemd.services = {
        frr = {
          after = [ "sops-install-secrets.service" ];
          requires = [ "sops-install-secrets.service" ];
        };
        nftables = {
          after = [ "sops-install-secrets.service" ];
          requires = [ "sops-install-secrets.service" ];
        };
        "strongswan-swanctl" = {
          after = [ "sops-install-secrets.service" ];
          requires = [ "sops-install-secrets.service" ];
        };

        strongswan-swanctl.restartTriggers = [ swanctlConfig ];

        nftables.serviceConfig.ExecStart = lib.mkForce [
          (builtins.head prev.config.systemd.services.nftables.serviceConfig.ExecStart)
          "${pkgs.nftables}/bin/nft -f ${config.sops.templates."nftables.rules".path}"
        ];
      };

      environment.etc = {
        "swanctl/swanctl.conf".source =
          lib.mkForce config.sops.templates."swanctl.conf".path;

        "frr/frr.conf".source = lib.mkForce config.sops.templates."frr.conf".path;
      } // lib.mapAttrs'
        (name: _:
          lib.nameValuePair "systemd/network/${name}.network" {
            source = lib.mkForce (
              pkgs.runCommand "network-${name}.network" { } ''
                ln -s ${config.sops.templates."${name}.network".path} $out
              ''
            );
          })
        networks // lib.mapAttrs'
        (name: _:
          lib.nameValuePair "systemd/network/${name}.netdev" {
            source = lib.mkForce (
              pkgs.runCommand "netdev-${name}.netdev" { } ''
                ln -s ${config.sops.templates."${name}.netdev".path} $out
              ''
            );
          })
        netdevs;

      sops.templates = {
        "swanctl.conf" = {
          file = swanctlConfig;
          mode = "0444";
        };

        "frr.conf" = {
          file = frrConfig;
          mode = "0444";
        };

        "nftables.rules" = {
          file = nftablesRules;

          mode = "0555";
        };
      } // lib.mapAttrs'
        (name: _:
          lib.nameValuePair "${name}.network" {
            file = prev.config.environment.etc."systemd/network/${name}.network".source;
            mode = "0444";
          })
        networks // lib.mapAttrs'
        (name: _:
          lib.nameValuePair "${name}.netdev" {
            file = prev.config.environment.etc."systemd/network/${name}.netdev".source;
            mode = "0444";
          })
        netdevs;
    };
}
