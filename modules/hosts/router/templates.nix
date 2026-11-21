# The templates of the files which hold the secrets of the router: the
# strongSwan configuration is rendered with the IPsec secrets.
#
# This is an extension of the host, so it gets `prev` bound to the router
# without it, which is where the original swanctl.conf comes from.
{ config, ... }:

{
  nixos.configurations.router.extensions = { config, lib, prev, ... }:
    let
      strongswanConfig = prev.config.environment.etc."swanctl/swanctl.conf".source;
    in
    {
      systemd.services = {
        # The service which reads the rendered file waits for the secrets.
        "strongswan-swanctl" = {
          after = [ "sops-install-secrets.service" ];
          requires = [ "sops-install-secrets.service" ];
        };

        # The configuration of strongSwan is rendered by sops, so the file of
        # the unit does not change when the configuration does. The service
        # is restarted when the file of the module changes.
        "strongswan-swanctl".restartTriggers = [ strongswanConfig ];
      };

      environment.etc."swanctl/swanctl.conf".source =
        lib.mkForce config.sops.templates."swanctl.conf".path;

      sops.templates."swanctl.conf" = {
        file = strongswanConfig;
        mode = "0444";
      };
    };
}
