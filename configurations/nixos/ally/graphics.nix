# Graphics and desktop configuration of the ASUS ROG Xbox Ally X20.
#
# The Steam Deck UI runs in a gamescope session, the desktop session it
# switches to is Plasma -- the same desktop SteamOS uses.
{ ... }:

{
  services.desktopManager.plasma6.enable = true;

  hardware.graphics = {
    enable = true;
    # Required for the 32bit Steam/Proton games.
    enable32Bit = true;
  };
}
