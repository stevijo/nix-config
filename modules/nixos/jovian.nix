# Jovian-NixOS integration: a Steam Deck like experience on x86_64 hardware.
#
# Brings in the Steam Deck UI, the SteamOS flavoured system configuration
# and the vendor builds of pipewire, wireplumber, mesa and gamescope. The
# vendor packages are compiled against a specific nixpkgs revision, so
# hosts using this module have to run nixos-unstable.
{ inputs, ... }:

{
  flake.modules.nixos.jovian = { ... }: {
    imports = [ inputs.jovian.nixosModules.default ];

    jovian.steam.enable = true;
    jovian.steamos.useSteamOSConfig = true;
  };
}
