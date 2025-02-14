# Top-level flake glue to get our configuration working
{ self, inputs, lib, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  perSystem = { self', pkgs, system, ... }: {
    # For 'nix fmt'
    formatter = pkgs.nixpkgs-fmt;

    nixos-unified = {
      primary-inputs = [
        "nixpkgs"
        "nixpkgs-unstable"
        "home-manager"
        "nix-darwin"
        "nixos-unified"
        "nix-index-database"
      ];
    };
  };
}
