# The secrets of the router.
{ ... }:

{
  flake.modules.nixos."nixosConfigurations/router" = { ... }: {
    sops.defaultSopsFile = ./secrets.yaml;
    sops.age.sshKeyPaths = [
      "/home/stevijo/.ssh/id_ed25519"
    ];
    sops.secrets.ikev-fritz = { };
    sops.secrets.remote-fritz = { };
    sops.secrets.remote-local = { };
  };
}
