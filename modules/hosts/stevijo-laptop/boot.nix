{ ... }:

{

  nixos.configurations.stevijo-laptop.module = { pkgs, ... }: {

    boot = {
      plymouth.enable = true;
      consoleLogLevel = 3;

      kernelParams = [ "quiet" "splash" ];
    };

    services.displayManager.gdm = {
      enable = true;
    };

    services.displayManager.defaultSession = "sway";

  };
}
