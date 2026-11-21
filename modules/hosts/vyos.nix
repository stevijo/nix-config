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
  inherit (config.nixos.modules) base firewall sops vpp;
in
{
  config = {
    nixos.configurations.vyos = {
      sshTarget = "stevijo@vyos:2222";

      module = { config, ... }: {
        imports = [
          base
          firewall
          sops
          vpp
          ./vyos/_hardware-configuration.nix
        ];
      };
    };
  };
}
