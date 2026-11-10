{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { ... }: {

    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
