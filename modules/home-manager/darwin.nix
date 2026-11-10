# The home-manager configuration of the macOS hosts.
{ config, inputs, ... }:

let
  inherit (config.flake.modules.homeManager) base kitty neovim shell;
in
{
  flake.modules.homeManager.darwin = {
    imports = [
      base
      kitty
      neovim
      shell
      inputs.mac-app-util.homeManagerModules.default
    ];
  };
}
