# The home-manager module, which runs home-manager inside the NixOS system.
{ ... }:

{
  flake.modules.nixos.home-manager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
