# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, pkgs, config, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote
    self.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    ./configuration.nix
    (self + /modules/nixos/linux/windowmanager/sway)
    (self + /modules/nixos/linux/docker.nix)
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [
    "/home/stevijo/.ssh/id_ed25519"
  ];
  sops.secrets.hosts-file = {
    mode = "0444";
  };
  sops.secrets.wg0 = { };
  sops.secrets.prefix = { };

  environment.etc.hosts.source = lib.mkForce config.sops.secrets.hosts-file.path;

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.openssh.enable = true;
  services.gvfs.enable = true;
  services.blueman.enable = true;
  programs.steam = {
    enable = true;
  };
  programs.adb.enable = true;
  programs.nix-ld.enable = true;

  networking.wireguard.enable = true;
  networking.wg-quick.interfaces = {
    wg0 = {
      autostart = false;
      configFile = builtins.toString (pkgs.writeText "wg0.conf" ''
        [Interface]
        Address = 172.30.0.5/24
        Address = !!PREFIX!!:dead::5/64
        DNS = 192.168.178.1
        MTU = 1354
        PrivateKey = !!WG0!!
        [Peer]
        PublicKey = 3ToM7Pg2tvAalsORya45gR0TS2wHSo7E5Mx7om0QISE=
        Endpoint = router:51820
        PersistentKeepalive = 60
        AllowedIPs = 192.168.178.0/24, 192.168.2.0/24
      '');
    };
  };

  environment.systemPackages =
    let
      update-script = pkgs.writeShellScriptBin "update-tpm-keys" ''
        read -s -p "TPM Password: " password
        echo
        sudo env PASSWORD=$password ${pkgs.systemd}/bin/systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+2+4+7 /dev/nvme0n1p3
        sudo env PASSWORD=$password ${pkgs.systemd}/bin/systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+2+4+7 /dev/nvme0n1p2
      '';

    in
    with pkgs; [
      git
      restic
      nautilus
      lm_sensors
      acpi
      imagemagick
      nodejs_20
      python3
      gnome-control-center
      gnome-tweaks
      google-chrome
      alsa-utils
      sysstat
      firefox
      rclone
      tpm2-tss
      sbctl
      update-script
    ];

  environment.variables = {
    NIXOS_OZONE_WL = 1;
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    font-awesome
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.i2c.enable = true;

  services.fwupd.enable = true;
  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  systemd.services.lock = {
    enable = true;
    description = "Lock the screen";
    before = [ "systemd-suspend.service" ];
    wantedBy = [ "sleep.target" ];
    path = [
      "/run/current-system/sw"
      "/etc/profiles/per-user/stevijo"
    ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
      Environment = "WAYLAND_DISPLAY=wayland-1";
      ExecStart = "${pkgs.bash}/bin/bash /home/stevijo/.config/sway/scripts/lock-screen";
      User = "stevijo";
    };
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';
  services.logind.lidSwitch = "suspend-then-hibernate";
  home-manager.sharedModules = [{
    wayland.windowManager.sway.config.output = {
      "eDP-1" = {
        scale = "1.3";
      };
      "*" = {
        bg = "~/Pictures/grogu.jpg fill";
      };
    };
  }];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.allowHibernation = true;
  boot.zfs.forceImportRoot = false;
  networking.hostId = "2f6bdf89";
  boot.resumeDevice = "/dev/disk/by-uuid/b30200b1-b70d-4832-979e-be2a51413369";
  services.fstrim.enable = true;

  hardware.ledger.enable = true;

  users.users.stevijo = {
    extraGroups = [ "video" "docker" "adbusers" "wireshark" ];
  };
  # Enable home-manager for "stevijo" user
  home-manager.users."stevijo" = {
    imports = [ (self + "/configurations/home/stevijo@stevijo-laptop.nix") ];
  };
}
