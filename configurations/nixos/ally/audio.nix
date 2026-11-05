# Audio configuration of the ASUS ROG Xbox Ally X20.
#
# The speakers of the Ally X20 are driven by two TI TAS2783 amplifiers
# behind a SoundWire codec. ALSA's UCM configuration does not know about
# that codec yet, so the speaker codec is filtered out and the amplifier
# switches are never enabled.
#
# The patch is taken from ublue-os/bazzite (commit c500b43388e3).
{ pkgs, config, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./alsa-ucm-conf-tas2783.patch ];
      });
    })
  ];

  # Restart the user PipeWire after the machine woke up again.
  #
  # This has to be a system-sleep hook and not a unit ordered after
  # "suspend.target": that one runs *before* the machine sleeps, not after
  # it woke up. The hook is called with "pre" before the sleep and with
  # "post" after the resume.
  #
  # With the tas2783 power up fix in the kernel, PipeWire recovers the
  # stream on its own, so this is only a fallback.
  environment.etc."systemd/system-sleep/50-restart-pipewire".source = pkgs.writeShellScript "restart-pipewire-after-resume" ''
    if [ "$1" = "post" ]; then
      ${pkgs.systemd}/bin/systemctl --user --machine="${config.username}@.host" \
        restart pipewire pipewire-pulse wireplumber || true
    fi
  '';

  services.pipewire = {

    # 1. Increase minimum quantum to prevent buffer underruns
    extraConfig.pipewire."99-min-quantum" = {
      "context.properties" = {
        "default.clock.min-quantum" = 512;
      };
    };

    # 2. Add headroom and start delay for AMD SoundWire
    wireplumber.extraConfig."51-amdsoundwire-fix" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "~alsa_output.platform-amdsoundwire.*";
            }
          ];
          actions = {
            update-props = {
              "session.suspend-timeout-seconds" = 0;
              "api.alsa.headroom" = 1024;
              "api.alsa.start-delay" = 500;
            };
          };
        }
      ];
    };
  };
}
