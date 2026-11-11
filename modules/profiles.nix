# The home-manager profiles of the Linux and the macOS hosts.
{ config, inputs, ... }:

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
