# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;

  swan-log = pkgs.writeText "swan-log.conf" ''
    log {
        default = 3
        knl = 3
    }
  '';
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    self.nixosModules.default
    ./configuration.nix
    ./vpp.nix
    ./frr.nix
    ./strongswan.nix
    (self + /modules/nixos/linux/docker.nix)
    (self + /modules/nixos/linux/vpp)
  ];

  nixos-unified.sshTarget = "stevijo@router";
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [
    "/home/stevijo/.ssh/id_ed25519"
  ];
  sops.secrets.ikev2-password = { };
  sops.secrets.private-remote = { };
  sops.secrets.router-ip = { };
  sops.secrets.router-ip6 = { };
  sops.secrets.router-gateway = { };
  sops.secrets.remote = { };
  sops.secrets.prefix = { };
  sops.secrets.bgp-password = { };
  sops.secrets.asn = { };

  environment.systemPackages = with pkgs; [
    git
    acpi
    python3
    nodejs_20
    sysstat
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };
  networking.firewall.enable = false;

  services.fwupd.enable = true;

  users.users.stevijo = {
    extraGroups = [ "video" "docker" "vpp" ];
  };
  security.sudo.extraRules = [
    {
      users = [ "stevijo" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];
  # Enable home-manager for "stevijo" user
  home-manager.users."stevijo" = {
    imports = [ (self + "/configurations/home/stevijo@stevijo-laptop.nix") ];
  };
}