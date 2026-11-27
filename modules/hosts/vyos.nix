# The faster-router: the router at the edge of the network.
#
# It routes between the internet, the server network and the tunnels of the
# home network, and it terminates the IPsec tunnel to the bigbox.
#
# The host specific settings live in `modules/hosts/vyos/`.
#
# The machine which runs it is the one of the remote Proxmox which is on the
# network of the office.
{ config, ... }:

let
  inherit (config.nixos.modules) base firewall sops tunnel vpp;
in
{
  config = {
    nixos.configurations.vyos = {
      sshTarget = "stevijo@vyos:2222";

      module = { config, lib, ... }: {
        imports = [
          base
          firewall
          sops
          tunnel
          vpp
          ./vyos/_hardware-configuration.nix
        ];

        # The processor of the packets tells systemd when it is ready, so the
        # unit of it waits for the notification of it: the network of systemd
        # starts after the processor of the packets has taken the card of the
        # provider from the kernel.
        systemd.services.vpp.serviceConfig.Type = lib.mkForce "notify";
      };
    };
  };
}
