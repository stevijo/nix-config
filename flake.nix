{
  description = "Personal NixOS, nix-darwin and home-manager configuration";

  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    scalpel.url = "github:polygon/scalpel";
    mac-app-util.url = "github:hraban/mac-app-util";

    # Software inputs
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Steam Deck like experience on regular x86_64 hardware.
    # Jovian ships vendor builds of pipewire/wireplumber/mesa/gamescope
    # which are only usable with the nixpkgs revision they were built
    # against, so it has to follow nixos-unstable.
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS/development";
    jovian.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Home-manager matching nixos-unstable, for the hosts which run it.
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  # The dendritic pattern: every file below `modules/` is a top-level
  # (flake-parts) module of this configuration. Directories whose name starts
  # with an underscore hold lower-level module content and are skipped.
  outputs = inputs:
    let
      lib = inputs.nixpkgs.lib;
      modulesPath = ./modules;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        # Declares the `flake.modules` option, in which the lower-level
        # modules of this configuration are stored.
        inputs.flake-parts.flakeModules.modules
      ] ++ lib.pipe modulesPath [
        lib.filesystem.listFilesRecursive
        (lib.filter (lib.hasSuffix ".nix"))
        # The callPackage files are not modules of this configuration.
        (lib.filter (path: !(lib.hasSuffix ".pkg.nix" (toString path))))
        # The directories whose name starts with an underscore hold
        # lower-level module content, which is not a module either.
        (lib.filter (
          path:
          lib.all
            (
              component: !(lib.hasPrefix "_" component)
            )
            (lib.path.subpath.components (lib.path.removePrefix modulesPath path))
        ))
      ];
    };
}
