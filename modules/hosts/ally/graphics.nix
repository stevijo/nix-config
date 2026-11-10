{ ... }:

{
  flake.modules.nixos."nixosConfigurations/ally" = { ... }: {

    services.desktopManager.plasma6.enable = true;
    programs.kdeconnect.enable = true;

    services.xserver.enable = true;
    services.xserver.displayManager.startx.enable = true;

    hardware.graphics = {
      enable = true;
      # required for the 32bit Steam/Proton games
      enable32Bit = true;
    };
  };
}
