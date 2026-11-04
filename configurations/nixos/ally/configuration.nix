# Main system configuration of the ASUS ROG Xbox Ally X20.
#
# This host is built against nixos-unstable, see
# `modules/flake-parts/hosts.nix`.
{ config, flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = config.username;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  options = {
    username = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    username = "stevijo";

    nixpkgs = {
      config = {
        allowBroken = true;
        allowUnsupportedSystem = true;
        allowUnfree = true;
      };
      overlays = lib.attrValues self.overlays;
    };

    nix = {
      # This host runs nixos-unstable, so pin the registry and nixPath to
      # it as well.
      nixPath = [ "nixpkgs=${flake.inputs."nixpkgs-unstable"}" ];
      registry.nixpkgs.flake = flake.inputs."nixpkgs-unstable";

      settings = {
        max-jobs = 8;
        experimental-features = [ "nix-command flakes" ];
        trusted-users = [ "root" "@wheel" ];
        download-buffer-size = 524288000;
      };
    };

    boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxKernel.kernels.linux_7_3);

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "ally";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Prague";

    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "cs_CZ.UTF-8";
      LC_IDENTIFICATION = "cs_CZ.UTF-8";
      LC_MEASUREMENT = "cs_CZ.UTF-8";
      LC_MONETARY = "cs_CZ.UTF-8";
      LC_NAME = "cs_CZ.UTF-8";
      LC_NUMERIC = "cs_CZ.UTF-8";
      LC_PAPER = "cs_CZ.UTF-8";
      LC_TELEPHONE = "cs_CZ.UTF-8";
      LC_TIME = "cs_CZ.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "gb";
      variant = "";
    };

    # Configure console keymap
    console.keyMap = "uk";


    services.openssh.enable = true;

    # The Steam session is started for this user, the same one that is used
    # for the desktop session.
    jovian.hardware.has.amd.gpu = true;

    jovian.steam = {
      enable = true;
      autoStart = true;
      user = username;
      desktopSession = "plasma";
      environment = {
        PROTON_USE_NTSYNC = "1";
        ENABLE_HDR_WSI = "1";
        DXVK_HDR = "1";
        PROTON_ENABLE_AMD_AGS = "1";
        PROTON_ENABLE_NVAPI = "1";
        ENABLE_GAMESCOPE_WSI = "1";
        STEAM_MULTIPLE_XWAYLANDS = "1";
      };
    };

    xdg.portal.enable = true;
    services.flatpak.enable = true;

    jovian.decky-loader = {
      enable = true;
    };
    # enable Steam CEF remote debugging for decky-loader
    systemd.tmpfiles.settings."steam-cef-remote-debugging"."${
      config.users.users.${username}.home
    }/.local/share/Steam/.cef-enable-remote-debugging".f =
      {
        user = username;
        group = "users";
      };

    environment.systemPackages = with pkgs; [
      git
      kdePackages.kcron
      kdePackages.fcitx5-configtool
      kdePackages.applet-window-buttons6
      kdePackages.partitionmanager
      kdePackages.filelight
      kdePackages.kate
      kdePackages.kcharselect
      kdePackages.kcalc
      kdePackages.kcolorchooser
      kdePackages.kontrast
      kdePackages.arianna
      haruna
      krename
      gamescope-wsi
      mangohud
    ];

    # Firmware updates for the mainboard and the controllers.
    services.fwupd.enable = true;

    system.stateVersion = "26.05";
  };
}
