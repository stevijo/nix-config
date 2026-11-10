{ inputs, ... }:

{
  flake.modules.nixos."nixosConfigurations/ally" = { config, lib, pkgs, ... }: {

    imports = [
      ./_hardware-configuration.nix
    ];

    config = {
      username = "stevijo";

      nix = {
        nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
        registry.nixpkgs.flake = inputs.nixpkgs-unstable;
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "router";
            systems = [ "x86_64-linux" "i686-linux" ];
            maxJobs = 8;
            speedFactor = 8;
            sshUser = "stevijo";
            sshKey = "/home/stevijo/.ssh/id_ed25519";
            supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
          }
        ];

        settings = {
          builders-use-substitutes = true;
          max-jobs = 0;
          experimental-features = [ "nix-command flakes" ];
          trusted-users = [ "root" "@wheel" ];
          download-buffer-size = 524288000;
        };
      };

      networking.hostName = "ally";
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.powersave = false;
      networking.firewall.enable = false;

      services.openssh.enable = true;
      services.fwupd.enable = true;

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

      i18n.inputMethod = {
        enable = true;
        type = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ table-chinese pinyin anthy hangul mozc ];
        ibus.panel = "${pkgs.kdePackages.plasma-desktop}/libexec/kimpanel-ibus-panel";
      };

      services.xserver.xkb = {
        layout = "gb";
        variant = "";
      };

      console.keyMap = "uk";

      programs.firefox.enable = true;
      programs.firefox.package = pkgs.firefox-bin;

      environment.systemPackages = with pkgs; [
        git
        acl
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
        iw
        python3
        wineWow64Packages.full
        winetricks
        lutris
        protonup-qt
        dxvk
        umu-launcher-unwrapped
        faugus-launcher
        (pkgs.bottles.override { removeWarningPopup = true; })
        heroic
      ];

      system.stateVersion = "26.05";
    };
  };
}
