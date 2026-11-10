# The home-manager module, which runs home-manager inside the NixOS system.
{ ... }:

{
  nixos.modules.home-manager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
