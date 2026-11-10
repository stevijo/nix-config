{ ... }:

{
  homeManager.modules.gui = { pkgs, ... }: {

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 60;
          command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
          resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
        }
      ];
    };
  };
}
