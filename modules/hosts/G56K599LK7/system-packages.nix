{ ... }:

{
  nixDarwin.configurations.G56K599LK7.module = { lib, pkgs, ... }: {

    fonts.packages = with pkgs; [
      nerd-fonts.droid-sans-mono
    ];

    environment.systemPackages = with pkgs; [
      kitty
      rectangle
      age-plugin-yubi25519
      age
    ];
  };
}
