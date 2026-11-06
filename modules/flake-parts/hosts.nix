# Wires the NixOS configurations in `configurations/nixos`.
#
# Replaces `nixos-unified`'s auto-wiring so that hosts with a `scalpel.nix`
# get the scalpel module and hosts in `unstableHosts` are built against
# `nixpkgs-unstable` (needed for the Jovian-NixOS vendor packages).
{ config, lib, inputs, self, ... }:

let
  inherit (self.nix-config.lib) scalpelFile forAllNixFiles;
  inherit (self.nixos-unified.lib) mkLinuxSystem specialArgsFor;

  # Hosts which are built against nixos-unstable.
  unstableHosts = [
    "ally"
  ];

  mkScalpel = sys: folder:
    sys.extendModules {
      modules = [
        inputs.scalpel.nixosModules.scalpel
        (folder + "/${scalpelFile}")
      ];
      specialArgs = { prev = sys; };
    };

  commonModule =
    { lib, ... }:
    {
      nix.settings = {
        max-jobs = lib.mkDefault "auto";
        experimental-features = lib.mkDefault "nix-command flakes";
      };
    };

  homeManagerModule = {
    imports = [ inputs.home-manager-unstable.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = specialArgsFor.nixos;
      sharedModules = [ homeManagerCommon ];
    };
  };

  homeManagerCommon =
    { config, pkgs, ... }:
    {
      home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"}/${config.home.username}";
    };

  # Mirrors `nixos-unified`'s `mkLinuxSystem`, but with the unstable nixpkgs.
  mkUnstableLinuxSystem =
    { home-manager ? false }: mod:
    inputs.nixpkgs-unstable.lib.nixosSystem {
      specialArgs = specialArgsFor.nixos;
      modules = [
        (inputs.nixos-unified + "/nix/modules/configurations")
        commonModule
        mod
      ]
      ++ lib.optional home-manager homeManagerModule;
    };

  hostName = path: lib.removeSuffix ".nix" (builtins.baseNameOf (toString path));

  mkHost = { path, scalpel ? false }:
    let
      sys =
        if builtins.elem (hostName path) unstableHosts then
          mkUnstableLinuxSystem { home-manager = true; } path
        else
          mkLinuxSystem { home-manager = true; } path;
    in
    if scalpel then mkScalpel sys path else sys;
in
{
  flake.nixosConfigurations = lib.mkForce (forAllNixFiles "${self}/configurations/nixos" mkHost);
}
