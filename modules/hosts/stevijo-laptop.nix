# The Framework 13 laptop.
#
# The host specific settings live in `modules/hosts/stevijo-laptop/`.
{ config, ... }:

let
  nixos = config.nixos.modules;
  home = config.homeManager.modules;

  stateVersion = "22.11";
in
{
  config = {
    nixos.configurations.stevijo-laptop.module = { config, ... }: {
      imports = with nixos; [
        base
        docker
        home-manager
        sops
        sway
      ];

      home-manager.users."stevijo" = {
        home.stateVersion = stateVersion;
        imports = with home; [
          linux
          stevijo
          sway
        ];
      };
    };
  };
}
