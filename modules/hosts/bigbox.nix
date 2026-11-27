# The bigbox: the router of the home network.
#
# It routes between the local networks and the internet, serves the
# addresses of the local networks, and terminates the IPsec tunnel to the
# faster-router.
#
# The host specific settings live in `modules/hosts/bigbox/`.
{ config, ... }:

let
  inherit (config.nixos.modules) base firewall sops tunnel vpp;
in
{
  config = {
    nixos.configurations.bigbox = {
      sshTarget = "stevijo@192.168.178.1";

      module = { config, lib, ... }: {
        imports = [
          base
          firewall
          sops
          tunnel
          vpp
          ./bigbox/_hardware-configuration.nix
        ];

      };
    };
  };
}
