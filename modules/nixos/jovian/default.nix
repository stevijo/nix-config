# Jovian-NixOS integration: a Steam Deck like experience on x86_64 hardware.
#
# This brings in the Steam Deck UI (a gamescope session running the Steam
# client), the SteamOS flavoured system configuration and the vendor builds
# of pipewire, wireplumber, mesa and gamescope.
#
# The vendor packages are compiled against a specific nixpkgs revision, so
# hosts using this module have to run nixos-unstable.
#
# Device specific bits are set with the options of the `jovian.*` namespace,
# e.g. `jovian.hardware.has.amd.gpu`, `jovian.steam.user` and
# `jovian.steam.desktopSession`.
{ flake, ... }:

{
  imports = [
    flake.inputs.jovian.nixosModules.default
    ./audio.nix
  ];

  config = {
    # The Steam Deck UI. The user it is started for and the session it
    # switches to have to be set by the host.
    jovian.steam.enable = true;

    # The SteamOS flavoured system configuration: automount, zram swap,
    # bluetooth, power button handling, kernel command line, ...
    jovian.steamos.useSteamOSConfig = true;
  };
}
