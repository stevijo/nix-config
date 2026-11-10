# Audio setup for the Steam session, using the vendor PipeWire builds.
#
# Merged into `nixos.modules.jovian`.
{ ... }:

{
  nixos.modules.jovian = { pkgs, ... }: {
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      package = pkgs.jovianPackages.pipewire;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.package = pkgs.jovianPackages.wireplumber;
    };

    # Point ALSA at the UCM configuration of the running system, which may
    # carry patches (see the tas2783 patch in the Ally X20 configuration).
    environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf}/share/alsa/ucm2";
  };
}
