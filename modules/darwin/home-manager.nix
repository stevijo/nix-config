# The home-manager module, which runs home-manager inside the nix-darwin
# system.
{ ... }:

{
  nixDarwin.modules.home-manager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
