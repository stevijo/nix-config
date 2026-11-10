{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { config, lib, ... }: {

    sops.defaultSopsFile = ./secrets.yaml;
    sops.age.sshKeyPaths = [
      "/home/stevijo/.ssh/id_ed25519"
    ];
    sops.secrets.hosts-file = {
      mode = "0444";
    };
    sops.secrets.wg0 = { };
    sops.secrets.prefix = { };

    environment.etc.hosts.source = lib.mkForce config.sops.secrets.hosts-file.path;
  };
}
