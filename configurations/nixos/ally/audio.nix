# Audio configuration of the ASUS ROG Xbox Ally X20.
#
# The speakers of the Ally X20 are driven by two TI TAS2783 amplifiers
# behind a SoundWire codec. ALSA's UCM configuration does not know about
# that codec yet, so the speaker codec is filtered out and the amplifier
# switches are never enabled.
#
# The patch is taken from ublue-os/bazzite (commit c500b43388e3).
{ lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./alsa-ucm-conf-tas2783.patch ];
      });
    })
  ];
}
