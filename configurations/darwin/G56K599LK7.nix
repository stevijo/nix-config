{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "G56K599LK7";

  users.users."stefan.mayer".home = "/Users/stefan.mayer";
  home-manager.users."stefan.mayer" = {
    imports = [ (self + "/configurations/home/stefan.mayer@G56K599LK7.nix") ];
  };

  username = "stefan.mayer";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;

  system.primaryUser = "stefan.mayer";
  system.defaults.dock.show-recents = false;
  fonts = {
    packages = with pkgs; [
      nerd-fonts.droid-sans-mono
    ];
  };
  environment.systemPackages = with pkgs; [
    kitty
  ];
}
