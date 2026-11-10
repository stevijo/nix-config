{ ... }:

{
  nixos.configurations.stevijo-laptop.module = { lib, pkgs, ... }: {

    hardware.ledger.enable = true;

    virtualisation.virtualbox.host.enable = true;

    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
}
