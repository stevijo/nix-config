# The ASUS ROG Xbox Ally X20.
#
# It runs nixos-unstable, because the Jovian vendor packages are compiled
# against a specific nixpkgs revision.
#
# The host specific settings live in `modules/hosts/ally/`.
{ config, inputs, ... }:

let
  inherit (config.nixos.modules) base decky-loader home-manager jovian sops;
  inherit (config.homeManager.modules) linux stevijo;

  stateVersion = "26.05";
in
{
  config = {
    nixos.configurations.ally = {
      nixpkgs = inputs.nixpkgs-unstable;
      homeManager = inputs.home-manager-unstable;
      sshTarget = "stevijo@ally";
      module = { config, ... }: {
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
  };
}
