# The scalpel transformation, which rewrites files at build time.
{ inputs, ... }:

{
  flake.modules.nixos.scalpel = {
    imports = [ inputs.scalpel.nixosModules.scalpel ];
  };
}
