{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, pkgs, ... }: {
    # The time of the machine, from the servers of VyOS, like the machine
    # which is in service. The machine serves the time to the clients of the
    # local networks as well.
    services.chrony = {
      enable = true;
      servers = [
        "time1.vyos.net"
        "time2.vyos.net"
        "time3.vyos.net"
      ];

      # The machine in service lets every client ask it for the time.
      extraConfig = ''
        allow all
      '';
    };

    services.telegraf = {
      enable = true;
      extraConfig = {
        agent = {
          interval = "10s";
          round_interval = true;
          metric_batch_size = 1000;
        };

        inputs = {
          cpu = {
            percpu = true;
            totalcpu = true;
          };
          mem = { };
          system = { };
          kernel = { };
          net = { };
        };

        outputs.prometheus_client = {
          listen = "192.168.178.1:9273";
        };
      };
    };

    virtualisation.podman.enable = true;

    services.fstrim.enable = true;

    systemd.services.blackbox-exporter = {
      description = "The exporter of the metrics of Prometheus";
      enable = true;

      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.podman}/bin/podman run \
            --name=blackbox-exporter \
            --replace \
            --network=host \
            --cap-drop=all \
            --cap-add=NET_RAW \
            --security-opt=no-new-privileges \
            quay.io/prometheus/blackbox-exporter:latest
        '';
        ExecStop = "${pkgs.podman}/bin/podman rm --force --ignore blackbox-exporter";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
