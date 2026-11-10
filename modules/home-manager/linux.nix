# The home-manager configuration of the Linux hosts.
{ config, ... }:

let
  inherit (config.flake.modules.homeManager) base fontconfig kitty neovim shell;
in
{
  flake.modules.homeManager.linux = {
    imports = [
      base
      fontconfig
      kitty
      neovim
      shell
    ];
  };
}
