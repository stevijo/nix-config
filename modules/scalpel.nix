# The scalpel transformation, which rewrites files at build time.
{ inputs, ... }:

{
  nixos.modules.scalpel = {
    imports = [ inputs.scalpel.nixosModules.scalpel ];
  };
}
