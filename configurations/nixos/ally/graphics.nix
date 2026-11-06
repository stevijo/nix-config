# Graphics and desktop environment.
#
# The Steam Deck UI runs in a gamescope session, the desktop session it
# switches to is Plasma.
{ ... }:

{
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;

  hardware.graphics = {
    enable = true;
    # required for the 32bit Steam/Proton games
    enable32Bit = true;
  };
}
