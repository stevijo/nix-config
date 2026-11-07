# SOPS-nix secrets and hosts file sourced from decrypted secret.
{ config, lib, ... }:

{
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [
    "/home/stevijo/.ssh/id_ed25519"
  ];
  sops.secrets.hosts-file = {
    mode = "0444";
  };

  environment.etc.hosts.source = lib.mkForce config.sops.secrets.hosts-file.path;
}
