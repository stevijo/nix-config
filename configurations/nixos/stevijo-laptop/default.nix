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

  environment.etc.hosts.source = lib.mkForce config.sops.secrets.hosts-file.path;

  services.openssh.enable = true;
  services.gvfs.enable = true;
  services.blueman.enable = true;
  programs.steam = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
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

  users.users.stevijo = {
    extraGroups = [ "video" "docker" ];
  };
  # Enable home-manager for "stevijo" user
  home-manager.users."stevijo" = {
    imports = [ (self + "/configurations/home/stevijo@stevijo-laptop.nix") ];
  };
}