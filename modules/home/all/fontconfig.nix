{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  home.packages = with pkgs; [
    dejavu_fonts
  ];

  fonts.fontconfig.enable = true;
}
