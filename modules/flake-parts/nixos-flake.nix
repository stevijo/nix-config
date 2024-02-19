# Top-level flake glue to get our configuration working
{ self, inputs, lib, ... }:
let
  scalpelFile = "scalpel.nix";
  mapAttrsMaybe = f: attrs:
    lib.pipe attrs [
      (lib.mapAttrsToList f)
      (builtins.filter (x: x != null))
      builtins.listToAttrs
    ];
  forAllNixFiles = dir: f:
    if builtins.pathExists dir then
      lib.pipe dir [
        builtins.readDir
        (mapAttrsMaybe (fn: type:
          if type == "regular" then
            let name = lib.removeSuffix ".nix" fn; in
            lib.nameValuePair name (f { path = "${dir}/${fn}"; })
          else if type == "directory" && builtins.pathExists "${dir}/${fn}/default.nix" then
            if builtins.pathExists "${dir}/${fn}/${scalpelFile}" then
              lib.nameValuePair fn (f { path = "${dir}/${fn}"; scalpel = true; })
            else
              lib.nameValuePair fn (f { path = "${dir}/${fn}"; })
          else
            null
        ))
      ] else { };
  mkScalpel = sys: folder:
    sys.extendModules {
      modules = [
        inputs.scalpel.nixosModules.scalpel
        (folder + "/${scalpelFile}")
      ];
      specialArgs = { prev = sys; };
    };
in
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  flake.nixosConfigurations = lib.mkForce
    (forAllNixFiles "${self}/configurations/nixos"
      ({ path, scalpel ? false }:
        let
          sys = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } path;
        in
        if scalpel then
          mkScalpel sys path
        else
          sys
      ));


  perSystem = { self', pkgs, ... }: {
    # For 'nix fmt'
    formatter = pkgs.nixpkgs-fmt;

    # Enables 'nix run' to activate.
    packages.default = self'.packages.activate;

    nixos-unified = {
      primary-inputs = [
        "nixpkgs"
        "home-manager"
        "nix-darwin"
        "nixos-unified"
        "nix-index-database"
      ];
    };
  };
}
