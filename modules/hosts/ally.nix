# The ASUS ROG Xbox Ally X20.
#
# It runs nixos-unstable, because the Jovian vendor packages are compiled
# against a specific nixpkgs revision.
#
# The host specific settings live in `modules/hosts/ally/`.
{ config, inputs, ... }:

let
  inherit (config.flake.modules.generic) base;
  inherit (config.flake.modules.nixos) decky-loader home-manager jovian sops;
  inherit (config.flake.modules.homeManager) linux stevijo;

  stateVersion = "26.05";
in
{
  config = {
    hosts.ally = {
      system = "nixos";
      platform = "x86_64-linux";
      nixpkgs = inputs.nixpkgs-unstable;
      homeManager = inputs.home-manager-unstable;
      sshTarget = "stevijo@ally";

      homeUsers."stevijo" = {
        inherit stateVersion;
        modules = [ linux stevijo ];
      };
    };

    flake.modules.nixos."nixosConfigurations/ally" = { config, ... }: {
      imports = [
        base
        decky-loader
        home-manager
        jovian
        sops
      ];

      home-manager.users."stevijo" = {
        home.stateVersion = stateVersion;
        imports = [
          linux
          stevijo
        ];
      };
    };
  };
}
