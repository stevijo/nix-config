# `nix run .#update` updates the primary flake inputs.
{ ... }:

{
  perSystem = { pkgs, lib, ... }: {
    packages.update = pkgs.writeShellApplication {
      name = "update";
      meta.description = "Update the primary flake inputs";
      text = ''
        nix flake update ${lib.concatStringsSep " " [
          "nixpkgs"
          "nixpkgs-unstable"
          "home-manager"
          "nix-darwin"
          "nix-index-database"
        ]}
      '';
    };
  };
}
