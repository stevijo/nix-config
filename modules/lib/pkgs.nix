# The package set of the per-system outputs, with the overlays of this
# configuration applied.
{ config, lib, inputs, ... }:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = lib.attrValues config.flake.overlays;
      config.allowUnfree = true;
    };
  };
}
