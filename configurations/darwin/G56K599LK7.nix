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
  
  system.stateVersion = 6;
}
