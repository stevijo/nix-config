{
  perSystem = { self', pkgs, lib, ... }: {
    # Enables 'nix run' to activate home-manager config.
    apps.default = {
      inherit (self'.packages.activate) meta;
      program = pkgs.writeShellApplication {
        name = "activate-home";

        text = ''
          set -e
          exit_code=0
          grep NAME=NixOS /etc/os-release || exit_code=$?
          if [[ $exit_code -ne 0 ]]; then
            ${lib.getExe self'.packages.activate} "$USER"@"$(hostname -s)";
          else
            ${lib.getExe self'.packages.activate};
          fi
        '';
      };
    };
  };
}
