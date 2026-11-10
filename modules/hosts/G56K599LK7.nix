# The macOS host.
#
# The host specific settings live in `modules/hosts/G56K599LK7/`.
{ config, inputs, ... }:

let
  inherit (config.darwin.modules) base home-manager;
  inherit (config.homeManager.modules) darwin;
  stefan-mayer = config.homeManager.modules."stefan.mayer";

  stateVersion = "22.11";
in
{
  config = {
    nixDarwin.configurations.G56K599LK7 = {
      platform = "aarch64-darwin";
      module = { config, ... }: {
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
  };
}
