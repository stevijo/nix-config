# Builds the nix-darwin systems of the hosts.
{ config, lib, inputs, ... }:

{
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    default = { };
    description = "The nix-darwin configurations of the hosts.";
  };

  config.flake.darwinConfigurations = lib.mapAttrs
    (name: host:
      inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          config.flake.modules.darwin."darwinConfigurations/${name}"
          host.homeManager.darwinModules.home-manager
        ];
      }
    )
    (lib.filterAttrs (name: host: host.system == "nix-darwin") config.hosts);
}
