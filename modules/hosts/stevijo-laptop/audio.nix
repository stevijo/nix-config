{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { ... }: {

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        extraConfig."51-disable-a2dp-source" = {
          "monitor.bluez.properties" = {
            "bluez5.roles" = [ "a2dp_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
          };
        };
      };
    };
  };
}
