{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { ... }: {

    services.tlp.enable = true;
    powerManagement.enable = true;
    services.thermald.enable = true;
  };
}
