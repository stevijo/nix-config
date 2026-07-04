# System-level fonts and packages. age/yubikey for SOPS-nix decryption.
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
  ];

  environment.systemPackages = with pkgs; [
    kitty
    rectangle
    age-plugin-yubi25519
    age
  ];
}
