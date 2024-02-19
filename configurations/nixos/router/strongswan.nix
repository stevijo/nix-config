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

  environment.systemPackages = with pkgs; [
    strongswan
  ];

  systemd.services.strongswan-swanctl = {
    path = with pkgs; [
      bintools
    ];
    requires = [
      "vpp-main.service"
    ];
    after = [
      "vpp-main.service"
    ];
  };
  services.strongswan-swanctl = {
    enable = true;
    includes = [
      swan-log
    ];
    strongswan.extraConfig = ''
       charon-systemd {
         journal {
           knl = 3
         }
       }
       charon {
          load_modular = yes
          plugins {
            include ${pkgs.strongswan}/etc/strongswan.d/charon/kernel-vpp.conf
            include ${pkgs.strongswan}/etc/strongswan.d/charon/openssl.conf
            include ${pkgs.strongswan}/etc/strongswan.d/charon/nonce.conf
            include ${pkgs.strongswan}/etc/strongswan.d/charon/socket-default.conf
            include ${pkgs.strongswan}/etc/strongswan.d/charon/vici.conf
          }
      }
    '';
    swanctl = {
      connections = {
        vyos = {
          proposals = [
            "aes256-sha256-modp2048"
          ];
          version = 2;
          local_addrs = [
            "!!ROUTER-IP!!"
          ];
          local = {
            vpp = {
              id = "!!ROUTER-IP!!";
              auth = "psk";
            };
          };
          remote = {
            vyos = {
              id = "!!REMOTE!!";
              auth = "psk";
            };
          };
          children = {
            tunnel = {
              esp_proposals = [
                "aes256gcm128-sha256-modp2048"
              ];
              mode = "tunnel";
              local_ts = [ "10.12.0.1/32" ];
              remote_ts = [ "10.12.0.2/32" ];
              start_action = "start";
            };
          };
        };
      };
      secrets = {
        ike = {
          vyos = {
            id = {
              "1" = "!!ROUTER-IP!!";
              "2" = "!!REMOTE!!";
            };
            secret = "!!IPSEC!!";
          };
        };
      };
    };
  };
}
