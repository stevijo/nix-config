# The home-manager module, which runs home-manager inside the nix-darwin
# system.
{ ... }:

{
  flake.modules.darwin.home-manager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
