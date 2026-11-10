{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { lib, pkgs, ... }: {

    environment.variables = {
      NIXOS_OZONE_WL = 1;
    };

    fonts.packages = with pkgs; [
      cantarell-fonts
      dejavu_fonts
      font-awesome
    ];
  };
}
