{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { ... }: {

    programs.steam = {
      enable = true;
    };
    programs.nix-ld.enable = true;
  };
}
