{
  # Kill focused window
  "$super+Shift+q" = "kill";
  # Change focus around
  "$super+h" = "focus left";
  "$super+j" = "focus down";
  "$super+k" = "focus up";
  "$super+l" = "focus right";
  # Or use arrow keys
  "$super+Left" = "focus left";
  "$super+Down" = "focus down";
  "$super+Up" = "focus up";
  "$super+Right" = "focus right";
  # Move the focused window with the same, but add Shift
  "$super+Shift+h" = "move left";
  "$super+Shift+j" = "move down";
  "$super+Shift+k" = "move up";
  "$super+Shift+l" = "move right";
  # Or use arrow keys
  "$super+Shift+Left" = "move left";
  "$super+Shift+Down" = "move down";
  "$super+Shift+Up" = "move up";
  "$super+Shift+Right" = "move right";
  # Splits
  "$super+b" = "split h";
  "$super+v" = "split v";
  # Next/previous workspace
  "$super+Tab" = "workspace back_and_forth";
  "$super+Shift+Tab" = "move container to workspace back_and_forth";
  # Toggle fullscreen mode
  "$super+f" = "fullscreen toggle";
  # Change container layout
  "$super+s" = "layout stacking";
  "$super+w" = "layout tabbed";
  "$super+e" = "layout toggle split";
  # Toggle floating mode
  "$super+Shift+space" = "floating toggle";
  # Swap focus between tiling / floating windows
  "$super+space" = "focus mode_toggle";
  # Focus the parent container
  "$super+a" = "focus parent";
  # Focus the child container
  #"$super+d" = "focus child";
  # Switch to workspace
  "$super+1" = "workspace $ws1";
  "$super+2" = "workspace $ws2";
  "$super+3" = "workspace $ws3";
  "$super+4" = "workspace $ws4";
  "$super+5" = "workspace $ws5";
  "$super+6" = "workspace $ws6";
  "$super+7" = "workspace $ws7";
  "$super+8" = "workspace $ws8";
  "$super+9" = "workspace $ws9";
  "$super+0" = "workspace $ws0";
  # Move focused container to workspace
  "$super+Shift+1" = "move container to workspace $ws1";
  "$super+Shift+2" = "move container to workspace $ws2";
  "$super+Shift+3" = "move container to workspace $ws3";
  "$super+Shift+4" = "move container to workspace $ws4";
  "$super+Shift+5" = "move container to workspace $ws5";
  "$super+Shift+6" = "move container to workspace $ws6";
  "$super+Shift+7" = "move container to workspace $ws7";
  "$super+Shift+8" = "move container to workspace $ws8";
  "$super+Shift+9" = "move container to workspace $ws9";
  "$super+Shift+0" = "move container to workspace $ws0";
  # Reload the configuration file
  "$super+Shift+c" = "reload";
  "$super+Shift+r" = "restart";
  # Exit sway (logs you out of your Wayland session)
  "$super+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
  # Most used applications
  "$super+Return" = "exec $terminal";
  # dmenu replacement with own script, there might something better
  "$super+d" = "exec env XDG_CURRENT_DESKTOP=GNOME rofi -show drun";
  # lock screen
  "$super+Shift+x" = "exec $Locker";
  # audio commands
  "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
  "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
  "XF86MonBrightnessUp" = "exec light -A 10";
  "XF86MonBrightnessDown" = "exec light -U 10";
  "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
  "XF86AudioPlay" = "exec playerctl play-pause";
  "XF86AudioPause" = "exec playerctl play-pause";
  "XF86AudioNext" = "exec playerctl next";
  "XF86AudioPrev" = "exec playerctl previous";
  "Print" = "exec grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') - | wl-copy";
  "Shift+Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
  "Ctrl+Print" = "exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | \"\(.x),\(.y) \(.width)x\(.height)\"' | slurp | grim -g - - | wl-copy";
  # Modes
  "$super+r" = "mode \"$resize\"";
  # Logout menu
  "$super+Control+Delete" = "exec nwg-bar";
}
