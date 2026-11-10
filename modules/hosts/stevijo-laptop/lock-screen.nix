{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { lib, pkgs, ... }: {

    systemd.services.lock = {
      enable = true;
      description = "Lock the screen";
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      path = [
        "/run/current-system/sw"
        "/etc/profiles/per-user/stevijo"
      ];
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";
        Environment = "WAYLAND_DISPLAY=wayland-1";
        ExecStart = "${pkgs.bash}/bin/bash /home/stevijo/.config/sway/scripts/lock-screen";
        User = "stevijo";
      };
    };
    systemd.sleep.settings.Sleep.HibernateDelaySec = "30m";
    services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    services.logind.settings.Login.HandlePowerKey = "ignore";

    home-manager.sharedModules = [{
      wayland.windowManager.sway.config.output = {
        "eDP-1" = {
          scale = "1.3";
        };
        "*" = {
          bg = "~/Pictures/grogu.jpg fill";
        };
      };
    }];
  };
}
