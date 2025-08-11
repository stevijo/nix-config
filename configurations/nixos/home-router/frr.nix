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
      ip route 0.0.0.0/0 10.13.0.4 e0
      !
    '';
  };
}
