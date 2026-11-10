# The nix-darwin configurations of this configuration.
#
# The features live in `nixDarwin.modules`, the hosts in
# `nixDarwin.configurations`. They are built into the `darwinConfigurations`
# of the flake here, next to the options they are read from.
{ config, lib, inputs, ... }:

{
  options.nixDarwin = {
    modules = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "The nix-darwin features of this configuration, keyed by feature name.";
    };

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "The nix-darwin system of the host.";
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


        };
      });
      default = { };
      description = "The nix-darwin hosts of this configuration.";
    };
  };

  config.flake.darwinConfigurations = lib.mapAttrs
    (name: host:
      inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          host.module
          inputs.home-manager.darwinModules.home-manager
        ];
      }
    )
    config.nixDarwin.configurations;
}
