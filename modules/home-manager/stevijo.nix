# The home-manager configuration of the user "stevijo".
{ ... }:

{
  homeManager.modules.stevijo = { lib, ... }: {
    programs.zsh.history = {
      path = lib.mkDefault "/home/stevijo/.histfile";
    };
  };
}
