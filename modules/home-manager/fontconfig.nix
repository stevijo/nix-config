{ ... }:

{
  flake.modules.homeManager.fontconfig = { pkgs, ... }: {

    home.packages = with pkgs; [
      dejavu_fonts
    ];

    fonts.fontconfig.enable = true;
  };
}
