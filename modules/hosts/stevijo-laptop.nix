# The Framework 13 laptop.
#
# The host specific settings live in `modules/hosts/stevijo-laptop/`.
{ config, inputs, ... }:

let
  inherit (config.flake.modules.generic) base;
  inherit (config.flake.modules.nixos) docker home-manager sops sway;
  inherit (config.flake.modules.homeManager) linux stevijo;
  sway-home = config.flake.modules.homeManager.sway;

  stateVersion = "22.11";
in
{
  config = {
    hosts.stevijo-laptop = {
      system = "nixos";
      platform = "x86_64-linux";
      homeManager = inputs.home-manager;

      homeUsers."stevijo" = {
        inherit stateVersion;
        modules = [
          linux
          stevijo
          sway-home
        ];
      };
    };

    flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { config, ... }: {
      imports = [
        base
        docker
        home-manager
        sops
        sway
      ];

      home-manager.users."stevijo" = {
        home.stateVersion = stateVersion;
        imports = [
          linux
          stevijo
          sway-home
        ];
      };
    };
  };
}
