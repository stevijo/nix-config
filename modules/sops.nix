# The SOPS-nix module, for hosts which decrypt secrets at build time.
{ inputs, ... }:

{
  nixos.modules.sops = { config, lib, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # The secrets are written by a service at every boot and not by the
    # activation, so that they are still there after a reboot.
    sops.useSystemdActivation = true;

    # The placeholder of a secret is written in the configurations
    # themselves, which are built before the templates are known, so the
    # placeholders are defined here and not only by the module of the
    # templates, which defines them when there are templates.
    sops.placeholder = lib.mapAttrs
      (
        name: _: "<SOPS:${builtins.hashString "sha256" name}:PLACEHOLDER>"
      )
      config.sops.secrets;
  };
}
