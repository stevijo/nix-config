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

  home.username = "sz7296";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/sz7296";
  home.stateVersion = "22.11";

  home.packages = [
    (pkgs.azure-cli.withExtensions (with pkgs.azure-cli-extensions; [
      ssh
    ]))
  ];

  programs.zsh = {
    history = {
      path = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/sz7296/.histfile";
    };
    envExtra = ''
      # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
    '';
  };

}
