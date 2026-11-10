# The hosts of this configuration.
#
# Every host is described by the module of the same name in
# `modules/hosts/<name>.nix`, its settings live in `modules/hosts/<name>/`.
{ lib, ... }:

{
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        system = lib.mkOption {
          type = lib.types.enum [ "nixos" "nix-darwin" ];
          description = "The kind of lower-level configuration to build for this host.";
        };

        platform = lib.mkOption {
          type = lib.types.str;
          default = "x86_64-linux";
          description = "The platform this host runs on.";
        };

        nixpkgs = lib.mkOption {
          type = lib.types.nullOr lib.types.attrs;
          default = null;
          description = ''
            The nixpkgs flake to build this host with. Defaults to the
            `nixpkgs` input.
          '';
        };

        homeManager = lib.mkOption {
          type = lib.types.attrs;
          description = ''
            The home-manager flake to use for this host. It has to match the
            nixpkgs of the host.
          '';
        };

        sshTarget = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "user@host used when activating this host remotely over SSH.";
        };

        localPrivilegeMode = lib.mkOption {
          type = lib.types.enum [ "nixos-rebuild-sudo" "sudo-nixos-rebuild" ];
          default = "nixos-rebuild-sudo";
          description = ''
            How local activation obtains root privileges.

            `nixos-rebuild-sudo` runs `nixos-rebuild` as the calling user with
            `--sudo`, letting nixos-rebuild invoke sudo for privileged steps.

            `sudo-nixos-rebuild` runs `nixos-rebuild` itself via sudo.
          '';
        };

        overrideInputs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Flake inputs to pin when activating this host remotely.";
        };

        homeUsers = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              stateVersion = lib.mkOption {
                type = lib.types.str;
                default = "26.05";
                description = "The home-manager state version of this user on this host.";
              };

              modules = lib.mkOption {
                type = lib.types.listOf lib.types.deferredModule;
                default = [ ];
                description = "The home-manager modules of this user on this host.";
              };
            };
          });
          default = { };
          description = "The home-manager users of this host, keyed by user name.";
        };
      };
    });
    default = { };
    description = "The hosts of this configuration.";
  };
}
