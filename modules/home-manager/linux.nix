# The home-manager configuration of the Linux hosts.
{ config, ... }:

let
  inherit (config.homeManager.modules) base fontconfig kitty neovim shell;
in
{
  homeManager.modules.linux = {
    imports = [
      base
      fontconfig
      kitty
      neovim
      shell
    ];
  };
}
