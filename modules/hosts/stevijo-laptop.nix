# The Framework 13 laptop.
#
# The host specific settings live in `modules/hosts/stevijo-laptop/`.
{ config, ... }:

let
  inherit (config.nixos.modules) base docker home-manager sops sway;
  inherit (config.homeManager.modules) linux stevijo;
  gui = config.homeManager.modules.gui;

  stateVersion = "22.11";
in
{
  config = {
    nixos.configurations.stevijo-laptop.module = { config, ... }: {
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
          gui
        ];
      };
    };
  };
}
