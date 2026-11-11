# home-manager: the namespace of its features, and the integration which runs
# it inside the NixOS and nix-darwin systems.
{ lib, ... }:

let
  integration = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
in
{
  options.homeManager = {
    modules = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "The home-manager features of this configuration, keyed by feature name.";
    };
  };

  config = {
    nixos.modules.home-manager = integration;
    nixDarwin.modules.home-manager = integration;
  };
}
