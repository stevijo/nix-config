# The macOS host.
#
# The host specific settings live in `modules/hosts/G56K599LK7/`.
{ config, inputs, ... }:

let
  inherit (config.flake.modules.darwin) base home-manager;
  inherit (config.flake.modules.homeManager) darwin;
  stefan-mayer = config.flake.modules.homeManager."stefan.mayer";

  stateVersion = "22.11";
in
{
  config = {
    hosts."G56K599LK7" = {
      system = "nix-darwin";
      platform = "aarch64-darwin";
      homeManager = inputs.home-manager;

      homeUsers."stefan.mayer" = {
        inherit stateVersion;
        modules = [
          darwin
          stefan-mayer
        ];
      };
    };

    flake.modules.darwin."darwinConfigurations/G56K599LK7" = { config, ... }: {
      imports = [
        base
        home-manager
      ];

      nixpkgs.hostPlatform = "aarch64-darwin";
      networking.hostName = "G56K599LK7";
      system.stateVersion = 6;

      home-manager.users."stefan.mayer" = {
        home.stateVersion = stateVersion;
        imports = [
          darwin
          stefan-mayer
        ];
      };
    };
  };
}
