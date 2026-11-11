{ pkgs }:
[
  { command = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE LD_LIBRARY_PATH XDG_DESKTOP_PORTAL_DIR"; always = false; }
]
