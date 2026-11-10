{ ... }:

{
  flake.modules.nixos."nixosConfigurations/stevijo-laptop" = { lib, pkgs, ... }: {

    environment.systemPackages =
      let
        update-script = pkgs.writeShellScriptBin "update-tpm-keys" ''
          read -s -p "TPM Password: " password
          echo
          sudo env PASSWORD=$password ${pkgs.systemd}/bin/systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+2+4+7+9+11 /dev/nvme0n1p3
          sudo env PASSWORD=$password ${pkgs.systemd}/bin/systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+2+4+7+9+11 /dev/nvme0n1p2
        '';
      in
      with pkgs; [
        git
        restic
        nautilus
        lm_sensors
        acpi
        imagemagick
        nodejs_24
        python3
        gnome-control-center
        gnome-tweaks
        google-chrome
        alsa-utils
        sysstat
        firefox
        rclone
        tpm2-tss
        sbctl
        texmaker
        texliveFull
        prismlauncher
        gcc
        age-plugin-yubi25519
        age
        yubikey-manager
        yubioath-flutter
        pinentry-curses
        update-script
        android-tools
      ];
  };
}
