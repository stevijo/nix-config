# The home-manager configuration of the user "stevijo".
{ ... }:

{
  flake.modules.homeManager.stevijo = { lib, ... }: {
    programs.zsh.history = {
      path = lib.mkDefault "/home/stevijo/.histfile";
    };
  };
}
