{ ... }:

{
  nixos.configurations.bigbox.module = { ... }: {
    sops.defaultSopsFile = ./secrets.yaml;
    sops.age.sshKeyPaths = [
      "/home/stevijo/.ssh/id_ed25519"
    ];
    sops.secrets.cloud-networks = { };
    sops.secrets.gateway-ipv4 = { };
    sops.secrets.ipsec-psk = { };
    sops.secrets.ipv6-cluster = { };
    sops.secrets.ipv6-eth1-2 = { };
    sops.secrets.ipv6-eth1-3 = { };
    sops.secrets.ipv6-eth1-4 = { };
    sops.secrets.ipv6-host = { };
    sops.secrets.ipv6-proxmox = { };
    sops.secrets.peer-ipv4 = { };
    sops.secrets.prefix-be00 = { };
    sops.secrets.prefix-local = { };
    sops.secrets.prefix-be00-host = { };
    sops.secrets.prefix-be01 = { };
    sops.secrets.prefix-be02 = { };
    sops.secrets.prefix-dd00 = { };
    sops.secrets.prefix-dd01 = { };
    sops.secrets.prefix-dd02 = { };
    sops.secrets.prefix-dead = { };
    sops.secrets.prefix-dns64 = { };
    sops.secrets.prefix-lab-20 = { };
    sops.secrets.prefix-lab-30 = { };
    sops.secrets.prefix-lab-40 = { };
    sops.secrets.public-ipv4 = { };
    sops.secrets.wg-endpoint = { };
    sops.secrets.wg0-private-key = { };
    sops.secrets.wg1-private-key = { };
  };
}
