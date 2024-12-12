{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  home.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
  ];

  programs.kitty = {
    enable = true;
    font = {
      name = "DroidSansM Nerd Font";
      size = 14;
    };
    settings = {
      # shell
      shell = "zsh";
      # Cursor
      cursor = "#C0CAF5";
      cursor_text_color = "#24283b";
      cursor_shape = "block";
      cursor_blink_interval = "-1";

      # Scrollback
      scrollback_lines = 10000;

      # Mouse
      mouse_hide_wait = "-1";
      url_color = "#73DACA";
      url_style = "single";

      #Terminal bell
      enable_audio_bell = "no";
      visual_bell_duration = 0;

      # Window layout
      window_padding_width = 0;
      confirm_os_window_close = 0;

      adjust_line_height = "105%";

      # Color scheme
      background = "#24283b";
      foreground = "#c0caf5";
      selection_background = "#2e3c64";
      selection_foreground = "#c0caf5";
      color0 = "#1d202f";
      color1 = "#f7768e";
      color2 = "#9ECE6A";
      color3 = "#E0AF68";
      color4 = "#7AA2F7";
      color5 = "#BB9AF7";
      color6 = "#7DCFFF";
      color7 = "#A9B1D6";
      color8 = "#414868";
      color9 = "#F7768E";
      color10 = "#9ECE6A";
      color11 = "#E0AF68";
      color12 = "#7AA2F7";
      color13 = "#BB9AF7";
      color14 = "#7DCFFF";
      color15 = "#C0CAF5";
      color16 = "#FF9E64";
      color17 = "#DB4B4B";

      # Advanced
      allow_remote_control = "no";
      shell_integration = "disabled";
      term = "xterm-256color";
    };
  };
}
