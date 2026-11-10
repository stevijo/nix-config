# The formatter of this configuration, for `nix fmt`.
{ ... }:

{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixpkgs-fmt;
  };
}
