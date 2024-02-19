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
    requires = [
      "vpp-main.service"
    ];
    after = [
      "vpp-main.service"
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
          dpd_delay = "30";
          dpd_timeout = "120";
          local_addrs = [
            "!!ROUTER-IP!!"
          ];
          local = {
            vpp = {
              id = "vpp";
              auth = "psk";
            };
          };
          remote = {
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
              local_ts = [ "10.12.0.1/32" ];
              remote_ts = [ "10.12.0.2/32" ];
              start_action = "start";
            };
          };
        };
        mastermind = {
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
              id = "!!REMOTE-MASTERMIND!!";
              auth = "psk";
            };
          };
          children = {
            tunnel = {
              esp_proposals = [
                "aes256gcm128-sha256-modp2048"
              ];
              mode = "tunnel";
              local_ts = [ "!!ROUTER-IP!!/32" ];
              remote_ts = [ "!!REMOTE-MASTERMIND!!/32" ];
              start_action = "start";
            };
          };
        };
        fritz = {
          proposals = [
            "aes256-sha512-modp1024"
          ];
          local_addrs = [
            "!!ROUTER-IP!!"
          ];
          local = {
            vpp = {
              id = "!!REMOTE-LOCAL!!";
              auth = "psk";
            };
          };
          remote = {
            fritz = {
              id = "!!REMOTE-FRITZ!!";
              auth = "psk";
            };
          };
          aggressive = true;
          children = {
            tunnel = {
              esp_proposals = [
                "aes256-sha512-modp1024"
              ];
              mode = "tunnel";
              local_ts = [ "192.168.178.0/24" ];
              remote_ts = [ "192.168.2.0/24" ];
              start_action = "start";
            };
          };
        };
      };
      secrets = {
        ike = {
          mastermind = {
            id = {
              "1" = "!!ROUTER-IP!!";
              "2" = "!!REMOTE-MASTERMIND!!";
            };
            secret = "!!IPSEC-MASTERMIND!!";
          };
          vyos = {
            id = {
              "1" = "vyos";
              "2" = "vpp";
            };
            secret = "!!IPSEC!!";
          };
          home = {
            id = {
              "1" = "!!REMOTE-FRITZ!!";
              "2" = "!!REMOTE-LOCAL!!";
            };
            secret = "!!IPSEC-FRITZ!!";
          };
        };
      };
    };
  };
}
