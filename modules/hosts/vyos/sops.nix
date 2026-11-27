{ ... }:

{
  nixos.configurations.vyos.module = { ... }: {
    sops.defaultSopsFile = ./secrets.yaml;
    sops.age.sshKeyPaths = [
      "/home/stevijo/.ssh/id_ed25519"
    ];
    sops.secrets.asn = { };
    sops.secrets.bgp-password = { };
    sops.secrets.gateway-ipv4 = { };
    sops.secrets.host-ipv6 = { };
    sops.secrets.ipsec-psk = { };
    sops.secrets.local-ipv6 = { };
    sops.secrets.next-hop-ipv6 = { };
    sops.secrets.peer-asn = { };
    sops.secrets.peer-ipv6 = { };
    sops.secrets.peer-range = { };
    sops.secrets.route-target = { };
    sops.secrets.prefix-ipv6 = { };
    sops.secrets.prefix-lab-20 = { };
    sops.secrets.prefix-lab-30 = { };
    sops.secrets.prefix-lab-40 = { };
    sops.secrets.public-ipv4 = { };
    sops.secrets.public-ipv4-secondary = { };
    sops.secrets.public-ipv6 = { };
    sops.secrets.wg-endpoint = { };
    sops.secrets.wg0-private-key = { };
  };
}
