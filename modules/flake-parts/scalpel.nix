{ self, lib, inputs, ... }:
let
  inherit (self.nix-config.lib) scalpelFile forAllNixFiles;
  mkScalpel = sys: folder:
    sys.extendModules {
      modules = [
        inputs.scalpel.nixosModules.scalpel
        (folder + "/${scalpelFile}")
      ];
      specialArgs = { prev = sys; };
    };
  inherit (self.nixos-unified.lib) mkLinuxSystem;
in
{
  flake.nixosConfigurations = lib.mkForce
    (forAllNixFiles "${self}/configurations/nixos"
      ({ path, scalpel ? false }:
        let
          sys = mkLinuxSystem { home-manager = true; } path;
        in
        if scalpel then
          mkScalpel sys path
        else
          sys
      ));

}
