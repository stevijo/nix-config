{ ... }:

{
  nixos.configurations.router.module = { lib, pkgs, ... }: {


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
  };
}
