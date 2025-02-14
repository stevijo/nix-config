{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    extraConfig = {
      font = "DroidSansM Nerd Font 12";
      display-drun = " ";
      show-icons = true;
      drun-display-format = "{name}";
      disable-history = false;
      sidebar-mode = false;
    };
    theme = ./style.rasi;
  };
}
