{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  xdg.mime.enable = false;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
