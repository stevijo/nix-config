# Builds the NixOS systems of the hosts.
#
# The system of a host is the module of the host, plus the home-manager
# module matching its nixpkgs. A host may have an extension, which is
# applied afterwards and gets `prev` bound to the system without it.
{ config, lib, inputs, ... }:

{
  flake.nixosConfigurations = lib.mapAttrs
    (name: host:
      let
        nixpkgs = if host.nixpkgs == null then inputs.nixpkgs else host.nixpkgs;

        base = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            config.flake.modules.nixos."nixosConfigurations/${name}"
            host.homeManager.nixosModules.home-manager
          ];
        };

        extension = config.flake.modules.nixos."nixosExtensions/${name}" or null;
      in
      if extension == null then
        base
      else
        base.extendModules {
          modules = [ extension ];
          specialArgs = { prev = base; };
        }
    )
    (lib.filterAttrs (name: host: host.system == "nixos") config.hosts);
}
