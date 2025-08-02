# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  systemd.services.frr.requires = [
    "vpp-main.service"
  ];
  services.frr = {
    config = ''
      ip route 0.0.0.0/0 10.32.32.2 e0
      !
    '';
  };
}
