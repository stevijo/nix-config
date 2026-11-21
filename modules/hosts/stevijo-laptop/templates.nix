# The templates of the files which hold the secrets of the laptop: the
# WireGuard configuration is rendered with the private key and the prefix.
#
# This is an extension of the host, so it gets `prev` bound to the laptop
# without it, which is where the original wg0.conf comes from.
{ config, ... }:

{
  nixos.configurations.stevijo-laptop.extensions = { config, lib, prev, ... }:
    let
      wgStartup = prev.config.networking.wg-quick.interfaces.wg0.configFile;
    in
    {
      systemd.services = {
        # The service which reads the rendered file waits for the secrets.
        "wg-quick@wg0" = {
          after = [ "sops-install-secrets.service" ];
          requires = [ "sops-install-secrets.service" ];
        };
      };

      networking.wg-quick.interfaces.wg0.configFile =
        lib.mkForce config.sops.templates."wg0.conf".path;

      sops.templates."wg0.conf" = {
        file = wgStartup;
        mode = "0444";
      };
    };
}
