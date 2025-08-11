# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{

  environment.systemPackages = with pkgs; [
    strongswan
  ];

  systemd.services.strongswan-swanctl = {
    path = with pkgs; [
      bintools
    ];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
    };
    requires = [
      "vpp-main.service"
      "frr.service"
    ];
    after = [
      "vpp-main.service"
      "frr.service"
    ];
  };
  services.strongswan-swanctl = {
    enable = true;
    strongswan.extraConfig = ''
       charon-systemd {
         journal {
           knl = 3
         }
       }
       charon {
          load_modular = yes
          i_dont_care_about_security_and_use_aggressive_mode_psk = yes
          plugins {
            include ${pkgs.strongswan}/etc/strongswan.d/charon/kernel-vpp.conf
            include ${pkgs.strongswan}/share/strongswan/templates/config/plugins/openssl.conf
            include ${pkgs.strongswan}/share/strongswan/templates/config/plugins/nonce.conf
            include ${pkgs.strongswan}/share/strongswan/templates/config/plugins/socket-default.conf
            include ${pkgs.strongswan}/share/strongswan/templates/config/plugins/vici.conf
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
          dpd_delay = "30";
          dpd_timeout = "120";
          local_addrs = [
            "10.13.0.5"
          ];
          remote_addrs = [
            "!!ROUTER!!"
          ];
          remote = {
            vpp = {
              id = "vpp";
              auth = "psk";
            };
          };
          local = {
            vyos = {
              id = "vyos";
              auth = "psk";
            };
          };
          children = {
            tunnel = {
              esp_proposals = [
                "aes256gcm128-sha256-modp2048"
              ];
              mode = "tunnel";
              local_ts = [ "10.12.0.3/32" ];
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
              "1" = "vyos";
              "2" = "vpp";
            };
            secret = "!!IPSEC!!";
          };
        };
      };
    };
  };
}
