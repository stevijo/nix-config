{ flake, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.common
    self.homeModules.darwin-only
  ];

  home.username = "stefan.mayer";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/stefan.mayer";
  home.stateVersion = "22.11";

  programs.zsh = {
    history = {
      path = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/stefan.mayer/.histfile";
    };
    envExtra = ''
      # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
    '';
  };

  programs.kitty.font.size = lib.mkForce 18;
}
