# The router: a small machine which routes between the local network and
# the Fritzbox, and terminates the IPsec tunnel to it.
#
# The host specific settings live in `modules/hosts/router/`.
{ config, ... }:

let
  inherit (config.nixos.modules) base docker home-manager sops;
  inherit (config.homeManager.modules) linux stevijo;

  stateVersion = "22.11";
in
{
  config = {
    nixos.configurations.router = {
      sshTarget = "stevijo@router";
      module = { config, ... }: {
        imports = [
          base
          docker
          home-manager
          sops
        ];

        home-manager.users."stevijo" = {
          home.stateVersion = stateVersion;
          imports = [
            linux
            stevijo
          ];
        };
      };
    };
  };
}
