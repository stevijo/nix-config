# Top-level flake glue to get our configuration working
{ self, inputs, lib, ... }:

let
  inherit (self.nix-config.lib) forAllNixFiles;
in
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  flake.sharedModules =
    forAllNixFiles "${self}/modules/shared" ({ path, ... }: path);

  perSystem = { self', pkgs, system, inputs', ... }: {
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

    packages.no-sudo-activate = self'.packages.activate.overrideAttrs (old: {
      buildCommand = old.buildCommand + ''
        ${pkgs.gnused}/bin/sed -i -E 's/(nixos-rebuild.*) --sudo/sudo \1/g' activate.nu;
        ${pkgs.gnused}/bin/sed -i -E 's/#activate/#no-sudo-activate/g' activate.nu;
      '';
    });
  };
}
