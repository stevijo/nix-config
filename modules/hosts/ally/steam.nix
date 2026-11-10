{ ... }:

{
  nixos.configurations.ally.module = { config, lib, pkgs, ... }:
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

      jovian.decky-loader = {
        enable = true;
        enableFHSEnvironment = true;
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
    };
}
