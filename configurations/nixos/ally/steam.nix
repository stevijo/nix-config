# Steam session and the Joy-Stop/-Deck glue around it.
{ config, lib, pkgs, ... }:

let
  username = config.username;
in
{
  programs.steam = {
    enable = true;
    package = lib.mkForce (pkgs.jovianPackages.steam.override {
      # needed xorg libraries for nested gamescope
      extraPkgs = pkgs': with pkgs'; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib # Provides libstdc++.so.6
        libkrb5
        keyutils
      ];
    });
    protontricks.enable = true;
  };

  jovian.steam = {
    enable = true;
    autoStart = true;
    user = username;
    desktopSession = "plasma";
  };

  jovian.hardware.has.amd.gpu = true;
  jovian.steamos.enableZram = false;

  services.inputplumber.package = lib.mkForce pkgs.x20-inputplumber;

  jovian.decky-loader = {
    enable = true;
    user = username;
    extraPackages = with pkgs; [ 
        ryzenadj 
        iw
        python3
        getopt
        networkmanager 
        curl
        iproute2
        systemd
        sysctl
        kmod
        jovianPackages.steamos-manager
        util-linux
    ];
  };

  hardware.steam-hardware.enable = true;
  hardware.uinput.enable = true;

  xdg.portal.enable = true;
  services.flatpak.enable = true;

  # Steam CEF remote debugging for decky-loader
  systemd.tmpfiles.settings."steam-cef-remote-debugging"."${
    config.users.users.${username}.home
  }/.local/share/Steam/.cef-enable-remote-debugging".f =
    {
      user = username;
      group = "users";
    };
}
