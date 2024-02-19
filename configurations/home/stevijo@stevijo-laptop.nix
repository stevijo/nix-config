{ flake, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.common
  ];
  home.username = "stevijo";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/stevijo";
  home.stateVersion = "22.11";

  programs.zsh.history = {
    path = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/stevijo/.histfile";
  };
}
