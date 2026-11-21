# The templates of the files which hold the secrets of the faster-router.
#
# The files are rendered by sops: the secrets are replaced by their values
# and the result is written under `/run/secrets/rendered`, at every boot.
#
# This is an extension of the host, so it gets `prev` bound to the
# faster-router without it, which is where the original configurations come
# from.
{ config, lib, pkgs, ... }:

{
  nixos.configurations.vyos.extensions = { config, lib, pkgs, prev, ... }:
    let
      swanctlConfig = prev.config.environment.etc."swanctl/swanctl.conf".source;
      frrConfig = prev.config.environment.etc."frr/frr.conf".source;
      nftablesRules = builtins.elemAt
        prev.config.systemd.services.nftables.serviceConfig.ExecStart
        1;

      # The files of the network of systemd. They hold the addresses of the
      # provider and the endpoint of the tunnel, which are in the secrets, so
      # they are rendered by sops like the other files which hold the
      # secrets.
      #
      # The network of systemd reads the files when it starts, which is after
      # the secrets are written, so the files are read from there.
      networks = prev.config.systemd.network.networks;
      netdevs = prev.config.systemd.network.netdevs;
    in
    {
      systemd.services = {
        # The services which read the rendered files wait for the secrets, and
        # they fail with them when they are missing: the firewall must not be
        # loaded without its rules.
        #
        # The network of systemd sets the addresses of the connections when it
        # starts, which is before the network is up, so the routing and the
        # tunnel of IPsec find them.
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

        # The configuration of strongSwan is rendered by sops, so the file of
        # the unit does not change when the configuration does. The service
        # is restarted when the file of the module changes.
        strongswan-swanctl.restartTriggers = [ swanctlConfig ];

        # The ruleset of nftables is written by the unit, so it has to be
        # replaced by the rendered one. It is read by nftables and not
        # run, because the rendered files are on a file system which can
        # not be executed.
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
            # The file of the network is the one which sops renders: the
            # addresses of the secrets are in it.
            source = lib.mkForce (
              pkgs.runCommand "network-${name}.network" { } ''
                ln -s ${config.sops.templates."${name}.network".path} $out
              ''
            );
          })
        networks // lib.mapAttrs'
        (name: _:
          lib.nameValuePair "systemd/network/${name}.netdev" {
            # The file of the device is the one which sops renders: the
            # endpoint of the tunnel is in it.
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

          # The ruleset is executed by the unit of nftables, so it has to be
          # executable.
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
