# The SOPS-nix module, for hosts which decrypt secrets at build time.
{ inputs, ... }:

{
  flake.modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
  };
}
