# The sway window manager, and the system side of it.
#
# The home-manager part of the sway configuration lives in
# `modules/home-manager/sway.nix`.
{ ... }:

{
  nixos.modules.sway = { pkgs, ... }: {
    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;

    security.polkit.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      kitty
      i3blocks
      fontconfig
      silver-searcher
      playerctl
      brightnessctl
      pulseaudio
      pipewire
      wl-clipboard
      xwayland
      xdg-desktop-portal
      xdg-desktop-portal-wlr
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako # notification system developed by swaywm maintainer
    ];
  };
}
