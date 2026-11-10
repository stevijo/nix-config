{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { lib, pkgs, ... }: {

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        libGL
      ];
    };
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.i2c.enable = true;

    services.fwupd.enable = true;
  };
}
