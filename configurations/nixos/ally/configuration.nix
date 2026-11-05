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

    boot.kernelPackages = pkgs.jovianPackages.linuxPackages;
    boot.kernelPatches = [
      {
        name = "0001-ASoC-amd-acpi-add-RC74XA-link0-tas2783-layout";
        patch = ./0001-ASoC-amd-acpi-add-RC74XA-link0-tas2783-layout.patch;
      }
      {
        name = "0002-ACPI-x86-quirk-ignore-acp-audio-config-flag-RC74XA";
        patch = ./0002-ACPI-x86-quirk-ignore-acp-audio-config-flag-RC74XA.patch;
      }
      {
        name = "0003-ASoC-sdw_utils-honor-empty-DisCo-port-lists";
        patch = ./0003-ASoC-sdw_utils-honor-empty-DisCo-port-lists.patch;
      }
      {
        name = "0004-ASoC-tas2783-sdw-keep-the-volume-settings-across-resets";
        patch = ./0004-ASoC-tas2783-sdw-keep-the-volume-settings-across-resets.patch;
      }
      {
        name = "0005-ASoC-tas2783-sdw-load-the-firmware-synchronously";
        patch = ./0005-ASoC-tas2783-sdw-load-the-firmware-synchronously.patch;
      }
      {
        name = "0006-ASoC-tas2783-sdw-refuse-playback-when-init-writes-failed";
        patch = ./0006-ASoC-tas2783-sdw-refuse-playback-when-init-writes-failed.patch;
      }
      {
        name = "0007-ASoC-tas2783-sdw-power-the-function-up-before-preparing-the-port";
        patch = ./0007-ASoC-tas2783-sdw-power-the-function-up-before-preparing-the-port.patch;
      }
      {
        name = "0010-hid-asus-ally-alias-LED-to-go_s-and-fix-mc_subled";
        patch = ./0010-hid-asus-ally-alias-LED-to-go_s-and-fix-mc_subled.patch;
      }
      {
        name = "0011-hid-asus-ally-add-effect-speed-mode-sysfs";
        patch = ./0011-hid-asus-ally-add-effect-speed-mode-sysfs.patch;
      }
      {
        name = "0013-hid-asus-ally-fix-use-after-free-on-interface-unbind";
        patch = ./0013-hid-asus-ally-fix-use-after-free-on-interface-unbind.patch;
      }
      {
        name = "0014-hid-asus-ally-scale-rumble-and-vibration-intensity-to-0-100";
        patch = ./0014-hid-asus-ally-scale-rumble-and-vibration-intensity-to-0-100.patch;
      }
      {
        name = "0016-HID-asus-ally-remap-QAM-and-AC-buttons-on-ROG-Xbox-Ally-X20";
        patch = ./0016-HID-asus-ally-remap-QAM-and-AC-buttons-on-ROG-Xbox-Ally-X20.patch;
      }
      {
        name = "0017-HID-asus-ally-reconfigure-the-MCU-only-once-on-resume";
        patch = ./0017-HID-asus-ally-reconfigure-the-MCU-only-once-on-resume.patch;
      }
      {
        name = "0018-HID-asus-ally-restore-the-gamepad-mode-on-resume";
        patch = ./0018-HID-asus-ally-restore-the-gamepad-mode-on-resume.patch;
      }
      {
        name = "0019-HID-asus-ally-propagate-ready-check-transport-errors";
        patch = ./0019-HID-asus-ally-propagate-ready-check-transport-errors.patch;
      }
      {
        name = "0020-asus-armoury-add-ROG-Xbox-Ally-X20-RC74XA-power-limits";
        patch = ./0020-asus-armoury-add-ROG-Xbox-Ally-X20-RC74XA-power-limits.patch;
      }
    ];
    boot.kernelModules = [
      "hid_nintendo"
      "hid_playstation"
      "iio_trig_hrtimer"
    ];

    boot.kernelParams = [
      "quiet"
      "splash"
      "amd_pstate=active"
      "rd.systemd.show_status=false"
      "amdgpu.gttsize=8128"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
    boot.consoleLogLevel = 0;

    services.udev.extraRules = ''
      # Enables manual GPU clock control in Steam
      # - /sys/class/drm/card0/device/power_dpm_force_performance_level
      # - /sys/class/drm/card0/device/power_dpm_state
      # - /sys/class/drm/card0/device/pp_od_clk_voltage
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage /sys/%p/power_dpm_state"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/brightness'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/brightness_scale'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/brightness_startup'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/effect'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/enabled'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/mode'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/multi_intensity'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/multi_intensity_startup'"
      SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w '/sys/class/leds/%k/speed'"

      # https://github.com/ublue-os/bazzite/blob/f5f033424281f88f0a132ec0561a5a5f002faf24/system_files/deck/shared/usr/lib/udev/rules.d/50-ally-fingerprint.rules
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{idVendor}=="1c7a", ATTR{idProduct}=="0588", ATTR{power/control}="auto"
    '';


    systemd.services.restart-inputplumber-after-resume = {
      enable = true;
      description = "Restart inputplumber";
      after = [ "suspend.target" ];
      wantedBy = [ "suspend.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl restart inputplumber";
      };
    };


    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "ally";
    networking.networkmanager.enable = true;
    networking.firewall.enable = false;

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

    hardware.steam-hardware.enable = true;
    hardware.uinput.enable = true;

    programs.steam = {
      enable = true;
      package = lib.mkForce (pkgs.jovianPackages.steam.override {
        # adds needed xorg library for nested gamescope
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
          keyutils # Add other libraries as needed
        ];
      });
      protontricks.enable = true;
    };

    services.inputplumber.package = lib.mkForce pkgs.x20-inputplumber;

    jovian.steam = {
      enable = true;
      autoStart = true;
      user = username;
      desktopSession = "plasma";
    };

    jovian.steamos.enableZram = false;

    xdg.portal.enable = true;
    services.flatpak.enable = true;

    jovian.decky-loader = {
      enable = true;
      user = username;
      extraPackages = with pkgs; [ ryzenadj ];
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
      acl
    ];

    programs.firefox.enable = true;
    programs.firefox.package = pkgs.firefox-bin;

    # Firmware updates for the mainboard and the controllers.
    services.fwupd.enable = true;

    system.stateVersion = "26.05";
  };
}
