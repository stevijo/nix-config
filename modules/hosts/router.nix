# The router: a small machine which routes between the local network and
# the Fritzbox, and terminates the IPsec tunnel to it.
#
# The host specific settings live in `modules/hosts/router/`.
{ config, inputs, ... }:

let
  inherit (config.flake.modules.generic) base;
  inherit (config.flake.modules.nixos) docker home-manager sops;
  inherit (config.flake.modules.homeManager) linux stevijo;

  stateVersion = "22.11";
in
{
  config = {
    hosts.router = {
      system = "nixos";
      platform = "x86_64-linux";
      homeManager = inputs.home-manager;
      sshTarget = "stevijo@router";

      homeUsers."stevijo" = {
        inherit stateVersion;
        modules = [ linux stevijo ];
      };
    };

    flake.modules.nixos."nixosConfigurations/router" = { config, ... }: {
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
}
