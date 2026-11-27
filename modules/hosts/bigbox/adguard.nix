{ ... }:

{
  nixos.configurations.bigbox.module = { config, lib, pkgs, ... }: {
    virtualisation.podman.enable = true;

    environment.etc."adguardhome/AdGuardHome.yaml".source = pkgs.writeText "AdGuardHome.yaml" (
      lib.replaceStrings [
        "!!ipv6-cluster!!"
        "!!ipv6-eth1-2!!"
        "!!ipv6-proxmox!!"
        "!!prefix-be00-host!!"
        "!!prefix-dns64!!"
      ] [
        config.sops.placeholder."ipv6-cluster"
        config.sops.placeholder."ipv6-eth1-2"
        config.sops.placeholder."ipv6-proxmox"
        config.sops.placeholder."prefix-be00-host"
        config.sops.placeholder."prefix-dns64"
      ]
        (builtins.readFile ./AdGuardHome.yaml)
    );

    systemd.services.adguardhome = {
      description = "AdGuardHome, the resolver of the local networks";

      enable = true;

      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      preStart = ''
        ${pkgs.coreutils}/bin/install -d -m 0755 /var/lib/adguardhome/conf
        ${pkgs.coreutils}/bin/install -d -m 0755 /var/lib/adguardhome/work
        ${pkgs.coreutils}/bin/install -m 0644 /run/secrets/rendered/AdGuardHome.yaml /var/lib/adguardhome/conf/AdGuardHome.yaml
      '';

      serviceConfig = {
        ExecStart = ''
          ${pkgs.podman}/bin/podman run \
            --name=adguardhome \
            --replace \
            --network=host \
            --cap-drop=all \
            --cap-add=NET_BIND_SERVICE \
            --security-opt=no-new-privileges \
            -v /var/lib/adguardhome/conf:/opt/adguardhome/conf \
            -v /var/lib/adguardhome/work:/opt/adguardhome/work \
            docker.io/adguard/adguardhome:v0.107.76
        '';
        ExecStop = "${pkgs.podman}/bin/podman rm --force --ignore adguardhome";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
