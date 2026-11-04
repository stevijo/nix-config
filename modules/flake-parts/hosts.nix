# Wires the NixOS configurations in `configurations/nixos`.
#
# This replaces `nixos-unified`'s auto-wiring so that
#
#  - hosts with a `scalpel.nix` get the scalpel module, and
#  - hosts listed in `unstableHosts` are built against `nixpkgs-unstable`
#    instead of the primary `nixpkgs` input.
#
# The latter is needed for hosts using Jovian-NixOS: it ships vendor builds
# of pipewire, wireplumber, mesa and gamescope which are only usable with
# the nixpkgs revision they were built against (the vendor pipewire is
# based on 1.6.8, the stable release still carries 1.6.6).
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

  # The parts of `nixos-unified`'s `mkLinuxSystem` which are not exported.
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

  # Builds a host against nixos-unstable. This mirrors
  # `nixos-unified`'s `mkLinuxSystem`, but with the unstable nixpkgs.
  mkUnstableLinuxSystem =
    { home-manager ? false }: mod:
    inputs.nixpkgs-unstable.lib.nixosSystem {
      specialArgs = specialArgsFor.nixos;
      modules = [
        # The `nixos-unified` metadata module (sshTarget, overrideInputs, ...).
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
