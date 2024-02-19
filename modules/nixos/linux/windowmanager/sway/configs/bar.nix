[
  {
    statusCommand = "i3blocks -c ~/.config/sway/i3blocks.conf";
    fonts = {
      names = [ "DejaVuSans" "Font Awesome 6 Free" ];
      size = 13.0;
    };

    colors = {
      focusedWorkspace = {
        background = "$bg-color";
        text = "$text-color";
        border = "$bg-color";
      };
      inactiveWorkspace = {
        background = "$inac-bg-color";
        border = "$inac-bg-color";
        text = "$inac-text-color";
      };
      urgentWorkspace = {
        background = "$urgent-bg-color";
        border = "$urgent-bg-color";
        text = "$text-color";
      };
      background = "$bg-color";
      separator = "#757575";
    };
  }
]
