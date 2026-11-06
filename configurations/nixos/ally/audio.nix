# Audio configuration of the ROG Xbox Ally X20.
#
# The speakers are driven by two TI TAS2783 amplifiers behind a SoundWire
# codec, which ALSA's UCM configuration does not know about yet. The patch
# is taken from ublue-os/bazzite (commit c500b43388e3).
{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./alsa-ucm-conf-tas2783.patch ];
      });
    })
  ];

  services.pipewire = {
    # prevent buffer underruns
    extraConfig.pipewire."99-min-quantum"."context.properties"."default.clock.min-quantum" = 512;

    # headroom and start delay for AMD SoundWire
    wireplumber.extraConfig."51-amdsoundwire-fix" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "~alsa_output.platform-amdsoundwire.*";
            }
          ];
          actions.update-props = {
            "session.suspend-timeout-seconds" = 0;
            "api.alsa.headroom" = 1024;
            "api.alsa.start-delay" = 500;
          };
        }
      ];
    };
  };
}
