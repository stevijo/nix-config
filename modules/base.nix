# The settings shared by every configuration: NixOS, nix-darwin and
# home-manager.
#
# nix-darwin shares nixpkgs' module system, so its base reuses the NixOS base
# unchanged.
{ config, inputs, lib, ... }:

let
  overlays = lib.attrValues config.flake.overlays;
  nixosBase = config.nixos.modules.base;
in
{
  nixDarwin.modules.base = {
    imports = [
      nixosBase
      inputs.mac-app-util.darwinModules.default
    ];
  };

  homeManager.modules.base = { config, lib, pkgs, ... }: {
    home.homeDirectory = lib.mkDefault "/${
      if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"
    }/${config.home.username}";

    news.display = "silent";
  };

  nixos.modules.base = { config, lib, pkgs, ... }: {
    options = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The name of the primary user of this system.";
      };
    };

    config = {
      nixpkgs = {
        config = {
          allowBroken = true;
          allowUnsupportedSystem = true;
          allowUnfree = true;
        };
        inherit overlays;
      };

      nix = {
        # The defaults, so that hosts which run a different nixpkgs (or a
        # different set of builders) can override them.
        nixPath = lib.mkDefault [ "nixpkgs=${inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
        registry.nixpkgs.flake = lib.mkDefault inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs

        settings = {
          max-jobs = lib.mkDefault "auto";
          experimental-features = lib.mkDefault "nix-command flakes";
          # I don't have an Intel mac.
          extra-platforms = lib.mkIf pkgs.stdenv.isDarwin "aarch64-darwin x86_64-darwin";
          # Nullify the registry for purity.
          flake-registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}'';
          trusted-users = lib.mkDefault [ "root" (if pkgs.stdenv.isDarwin then config.username else "@wheel") ];
          download-buffer-size = lib.mkDefault 524288000;
        };
      };
    };
  };
}
