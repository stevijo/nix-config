# home-manager: the namespace of its features, and the integration which runs
# it inside the NixOS and nix-darwin systems.
{ config, lib, inputs, ... }:

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

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "The Home-manager system of the host.";
          };


          platform = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
            description = "The platform this host runs on.";
          };


          homeManager = lib.mkOption {
            type = lib.types.nullOr lib.types.attrs;
            default = null;
            description = ''
              The home-manager flake to use for this host. It has to match the
              nixpkgs of the host.
            '';
          };

        };
      });
      default = { };
      description = "The NixOS hosts of this configuration.";
    };
  };

  config = {
    nixos.modules.home-manager = integration;
    nixDarwin.modules.home-manager = integration;

    perSystem = { pkgs, ... }: {
      legacyPackages.homeConfigurations = lib.mapAttrs
        (name: host:
          let
            homeManager = if host.homeManager == null then inputs.home-manager else host.homeManager;
          in
          homeManager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs; };
            modules = [
              host.module
            ];
          })
        config.homeManager.configurations;
    };
  };
}
