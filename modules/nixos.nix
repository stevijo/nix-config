# The NixOS configurations of this configuration.
#
# The features live in `nixos.modules`, the hosts in `nixos.configurations`.
# The hosts are built into the `nixosConfigurations` of the flake here, next
# to the options they are read from.
{ config, lib, inputs, ... }:

{
  options.nixos = {
    modules = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "The NixOS features of this configuration, keyed by feature name.";
    };

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "The NixOS system of the host.";
          };

          extensions = lib.mkOption {
            type = lib.types.nullOr lib.types.deferredModule;
            default = null;
            description = ''
              A module which is applied after the host, with `prev` bound to
              the host without it.
            '';
          };

          nixpkgs = lib.mkOption {
            type = lib.types.nullOr lib.types.attrs;
            default = null;
            description = ''
              The nixpkgs flake to build this host with. Defaults to the
              `nixpkgs` input.
            '';
          };

          sshTarget = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "user@host used when activating this host remotely over SSH.";
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

  config.flake.nixosConfigurations = lib.mapAttrs
    (name: host:
      let
        nixpkgs = if host.nixpkgs == null then inputs.nixpkgs else host.nixpkgs;
        homeManager = if host.homeManager == null then inputs.home-manager else host.homeManager;

        base = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            host.module
            homeManager.nixosModules.home-manager
          ];
        };
      in
      if host.extensions == null then
        base
      else
        base.extendModules {
          modules = [ host.extensions ];
          specialArgs = { prev = base; };
        }
    )
    config.nixos.configurations;
}
