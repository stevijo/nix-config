{ ... }:

{
  nixos.configurations.router.module = { config, lib, pkgs, ... }: {

    nixpkgs.overlays = [
      (self: super: {
        strongswan = super.strongswan.overrideAttrs (oldAttrs: {
          configureFlags = oldAttrs.configureFlags ++ [
            "--enable-ikev1"
          ];
        });
      })
    ];

    environment.systemPackages = with pkgs; [
      strongswan
    ];

    services.strongswan-swanctl = {
      enable = true;
      strongswan.extraConfig = ''
         charon-systemd {
           journal {
             knl = 3
             ike = 3
           }
         }
         charon {
            i_dont_care_about_security_and_use_aggressive_mode_psk = yes
        }
      '';
      swanctl = {
        connections = {
          fritz = {
            version = 0;
            proposals = [
              "aes256-sha512-modp1024"
            ];
            local_addrs = [
              "10.32.32.5"
            ];
            local = {
              home = {
                id = "${config.sops.placeholder."remote-local"}";
                auth = "psk";
              };
            };
            remote = {
              fritz = {
                id = "${config.sops.placeholder."remote-fritz"}";
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
            home = {
              id = {
                "1" = "${config.sops.placeholder."remote-fritz"}";
                "2" = "${config.sops.placeholder."remote-local"}";
              };
              secret = "${config.sops.placeholder."ikev-fritz"}";
            };
          };
        };
      };
    };
  };
}
