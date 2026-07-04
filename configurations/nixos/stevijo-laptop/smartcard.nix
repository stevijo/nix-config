# Smartcard / YubiKey wiring: gpg-agent, ssh-agent with PKCS#11 module,
# GVFS for mtp:// and similar, Blueman for bluetooth management.
{ pkgs, ... }:

{
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
}
