# The packages of this configuration.
#
# The callPackage files live in `modules/packages/`. Their `.pkg.nix` suffix
# keeps them from being imported as modules of this configuration.
{ ... }:

{
  perSystem = { pkgs, ... }: {
    packages = {
      age-plugin-yubi25519 = pkgs.callPackage ./packages/age-plugin-yubi25519.pkg.nix { };
      plymouth-steamos = pkgs.callPackage ./packages/plymouth-steamos.pkg.nix { };
    };
  };
}
