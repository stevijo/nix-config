{ ... }:

{
  nixos.configurations.ally.module = { ... }: {

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
  };
}
