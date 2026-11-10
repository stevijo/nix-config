{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { lib, pkgs, ... }: {

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };

    programs.ssh.startAgent = true;
    programs.ssh.agentPKCS11Whitelist =
      let
        pkcs11Path = "${pkgs.yubico-piv-tool}/lib/libykcs11.so.2.7.3";
      in
      pkcs11Path;

    services.gvfs.enable = true;
    services.blueman.enable = true;
  };
}
