{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { ... }: {

    programs.steam = {
      enable = true;
    };
    programs.nix-ld.enable = true;
  };
}
