# The SOPS-nix module, for hosts which decrypt secrets at build time.
{ inputs, ... }:

{
  nixos.modules.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
  };
}
