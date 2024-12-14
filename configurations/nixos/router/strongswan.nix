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
          remote_addrs = [
            "!!REMOTE-MASTERMIND!!"
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
        };
      };
    };
  };
}
