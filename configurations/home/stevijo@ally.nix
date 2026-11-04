# Home-manager configuration for the ASUS ROG Xbox Ally X20.
{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.common
    self.homeModules.linux-only
  ];
  home.username = "stevijo";
  home.homeDirectory = lib.mkDefault "/home/stevijo";
  home.stateVersion = "26.05";

  programs.zsh.history = {
    path = lib.mkDefault "/home/stevijo/.histfile";
  };
}
