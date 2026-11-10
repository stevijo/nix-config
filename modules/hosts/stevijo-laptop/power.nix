{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { ... }: {

    services.tlp.enable = true;
    powerManagement.enable = true;
    services.thermald.enable = true;
  };
}
