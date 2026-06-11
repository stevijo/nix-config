{ config, flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  dconf.enable = true;
  home.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
  };
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    font = {
      name = "DejaVuSans";
      size = 10;
    };
    cursorTheme = {
      name = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };
}
