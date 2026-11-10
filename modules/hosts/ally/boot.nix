{ ... }:

{
  flake.modules.nixos."nixosConfigurations/ally" = { lib, pkgs, ... }: {

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Boot the default entry right away instead of showing the menu for five
    # seconds. Set this to a non-zero value to get the bootloader menu back.
    boot.loader.timeout = 0;

    boot.plymouth = {
      enable = true;
      theme = "steamos";
      themePackages = [ (pkgs.callPackage ../../packages/plymouth-steamos.pkg.nix { }) ];
    };
  };
}
