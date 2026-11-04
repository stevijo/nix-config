# Boot experience of the ASUS ROG Xbox Ally X20.
#
# A handheld should get into the Steam session as fast as possible, so the
# boot is covered by the SteamOS splash screen and the bootloader does not
# wait for a menu selection.
{ config, flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;

  packages = self + /packages;
in
{
  boot.plymouth = {
    enable = true;

    # The SteamOS splash.
    theme = "steamos";
    themePackages = [ (pkgs.callPackage "${packages}/plymouth-steamos.nix" { }) ];
  };

  # Boot the default entry right away instead of showing the menu for five
  # seconds. Set this to a non-zero value to get the bootloader menu back.
  boot.loader.timeout = 0;
}
