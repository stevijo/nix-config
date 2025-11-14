{
  perSystem = { self', pkgs, lib, ... }:
    let
      default = {
        inherit (self'.packages.activate) meta;
        type = "app";
        program = pkgs.writeShellApplication {
          name = "activate-home";
          
          text = ''
            set -e
            exit_code=0
            grep NAME=NixOS /etc/os-release 2> /dev/null || exit_code=$?
            if [[ $exit_code -eq 0 || "$OSTYPE" == "darwin"* || $# -ne 0 ]]; then
              ${lib.getExe self'.packages.no-sudo-activate} "$@";
            else
              ${lib.getExe self'.packages.no-sudo-activate} "$USER"@"$(hostname -s)";
            fi
          '';
        };
      };
    in
    {
      # Enables 'nix run' to activate home-manager config.
      apps.default = default;
      packages.default = default;
    };
}
