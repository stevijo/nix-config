# The home-manager configuration of the macOS hosts.
{ config, inputs, ... }:

let
  inherit (config.homeManager.modules) base kitty neovim shell;
in
{
homeManager.modules.darwin = {
    imports = [
      base
      kitty
      neovim
      shell
      inputs.mac-app-util.homeManagerModules.default
    ];
  };
}
