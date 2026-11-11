# The sway window manager: the system side (NixOS) and the user side
# (home-manager). The rest of the desktop around it (rofi, swayidle, the GTK
# theme, the XDG directories) lives next to this file and is merged into
# `homeManager.modules.sway` as well.
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

  homeManager.modules.sway = { pkgs, ... }: {

    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false;
      extraConfigEarly = ''
        set $gnomeschema org.gnome.desktop.interface

        # VARIABLES ARE SET HERE
        # Modifier default to Super key
        set $super Mod1
        # Default applications
        set $terminal kitty
        # Mode string to show on bar
        # locker command
        set $Locker ~/.config/sway/scripts/lock-screen
        # Workspace naming
        set $ws1 "1 "
        set $ws2 "2  " 
        set $ws3 "3  "
        set $ws4 "4 "
        set $ws5 "5 "
        set $ws6 "6 "
        set $ws7 "7 "
        set $ws8 "8 "
        set $ws9 "9 "
        set $ws0 "10 "

        set $bg-color 	     #2f343f
        set $inac-bg-color     #2f343f
        set $text-color        #f3f4f5
        set $inac-text-color   #676E7D
        set $urgent-bg-color   #E53935
        set $border-color      #2f343f
        set $indi-color        #00ff00
        set $urgent-text-color #f3f4f5          
        # Title bar colors
        #                         border            background        text                indicator     decoration_border
        client.focused            $bg-color         $bg-color         $text-color         $indi-color   $border-color
        client.unfocused          $bg-color         $inac-bg-color    $inac-text-color    $indi-color   $border-color
        client.focused_inactive   $bg-color         $inac-bg-color    $inac-text-color    $indi-color   $border-color
        client.urgent             $urgent-bg-color  $urgent-bg-color  $urgent-text-color  $indi-color   $border-color
      '';
      config = {
        floating = {
          modifier = "Mod1";
        };
        fonts = {
          names = [ "Cantarell Regular" ];
          size = 13.0;
        };
        colors = {
          focused = {
            border = "$bg-color";
            background = "$bg-color";
            childBorder = "$border-color";
            indicator = "$indi-color";
            text = "$text-color";
          };
          unfocused = {
            border = "$bg-color";
            background = "$inac-bg-color";
            childBorder = "$border-color";
            indicator = "$indi-color";
            text = "$inac-text-color";
          };
          focusedInactive = {
            border = "$bg-color";
            background = "$inac-bg-color";
            childBorder = "$border-color";
            indicator = "$indi-color";
            text = "$inac-text-color";
          };
          urgent = {
            border = "$urgent-bg-color";
            background = "$urgent-bg-color";
            childBorder = "$border-color";
            indicator = "$indi-color";
            text = "$urgent-text-color";
          };
        };
        focus = {
          followMouse = false;
        };
        input = {
          "*" = {
            xkb_layout = "de";
            tap = "enabled";
          };
        };
        bars = import ./_config/bar.nix;
        keybindings = import ./_config/keybindings.nix;
        modes = import ./_config/modes.nix;
        window = {
          commands = import ./_config/commands.nix;
          titlebar = true;
        };
        startup = import ./_config/startups.nix { inherit pkgs; };
      };
      wrapperFeatures = {
        gtk = false;
      };
    };

    xdg.configFile."sway/scripts".source = ./scripts;
    xdg.configFile."sway/i3blocks.conf".source = ./i3blocks.conf;

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "GNOME";
      # This might be a non nixos specific change only
      XDG_DESKTOP_PORTAL_DIR = "$HOME/.local/share/xdg-desktop-portal/portals";
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.nix-profile/share:$HOME/.share";
    };


  };
}
