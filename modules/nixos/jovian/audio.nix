# Audio setup for the Steam session.
#
# The Steam Deck UI talks to the sound card through PipeWire, so we use
# the vendor builds shipped by Jovian instead of the stock nixpkgs ones.
{ lib, pkgs, ... }:

{
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    package = pkgs.jovianPackages.pipewire;
    pulse.enable = true;
    alsa.enable = true;
    wireplumber.package = pkgs.jovianPackages.wireplumber;
  };

  # Point ALSA at the UCM configuration. The default location is the copy
  # shipped with alsa-lib; setting it explicitly makes sure the UCM
  # configuration of the running system is used, even when it was patched
  # (see the tas2783 patch in the ROG Xbox Ally X20 configuration).
  environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf}/share/alsa/ucm2";
}
