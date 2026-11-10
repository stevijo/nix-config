# The activation script.
#
# `nix run .` activates the configuration of this machine, `nix run . <host>`
# the configuration of another host, over SSH if it is not this machine.
{ config, inputs, lib, ... }:

{
  perSystem = { pkgs, system, inputs', ... }:
    let
      # Like writeShellApplication, but for Nushell scripts.
      writeNushellApplication =
        { name
        , runtimeInputs ? [ ]
        , scriptDir
        , extraBuildCommand ? ""
        , meta
        }:
        let
          nixNuModule = pkgs.writeTextFile {
            name = "nix.nu";
            text = ''
              use std *
              let bins = '${builtins.toJSON (builtins.map (p: "${p}/bin") runtimeInputs)}' | from json
              log debug $"Adding runtime inputs to PATH: ($bins)"
              if $bins != [] {
                path add ...$bins
              }
            '';
          };
        in
        pkgs.runCommand name
          {
            inherit meta;
          } ''
          mkdir -p $out/bin
          cp ${scriptDir}/*.nu $out/bin/
          chmod -R a+w $out/bin
          cd $out/bin
          rm -f ${meta.mainProgram}
          echo "#!${pkgs.nushell}/bin/nu" >> ${meta.mainProgram}
          cat ${nixNuModule} >> ${meta.mainProgram}
          cat ${scriptDir}/${meta.mainProgram} >> ${meta.mainProgram}
          chmod a+x ${meta.mainProgram}
          ${extraBuildCommand}
        '';

      # The metadata of the hosts, which the activation script needs to
      # rebuild them.
      hosts = lib.mapAttrs
        (name: host: {
          inherit (host) sshTarget platform;
          system = host.platform;
        })
        (config.nixos.configurations // config.nixDarwin.configurations);

      # The data the activation script needs about the hosts.
      data = {
        inherit hosts;
        inherit system;
        cleanFlake = toString (lib.cleanSourceWith {
          name = "activate-flake";
          src = ./..;
        });
      };

      dataFile = pkgs.writeTextFile {
        name = "activate-data.json";
        text = builtins.toJSON data;
      };

      dataModule = pkgs.writeTextFile {
        name = "activate-data.nu";
        text = ''
          export def getData [] {
            open --raw ${dataFile} | from json
          }
        '';
      };

      activate = writeNushellApplication {
        name = "activate";
        scriptDir = ./activate;
        meta = {
          mainProgram = "activate.nu";
          description = "Activate NixOS/nix-darwin/home-manager configurations";
        };
        runtimeInputs = [
          pkgs.hostname
          inputs'.home-manager.packages.default
        ]
        ++ lib.optionals (!pkgs.stdenv.isDarwin) [
          pkgs.nixos-rebuild
        ]
        ++ lib.optionals (pkgs.stdenv.isDarwin) [
          inputs'.nix-darwin.packages.default # Provides darwin-rebuild
        ];
        extraBuildCommand = ''
          cp ${dataModule} activate-data.nu
        '';
      };

      # The same script, but running `nixos-rebuild` through `sudo`.
      noSudoActivate = activate.overrideAttrs (old: {
        buildCommand = old.buildCommand + ''
          ${pkgs.gnused}/bin/sed -i -E 's/(nixos-rebuild.*) --sudo/sudo \1/g' activate.nu
          ${pkgs.gnused}/bin/sed -i -E 's/#activate/#no-sudo-activate/g' activate.nu
        '';
      });
    in
    {
      packages.activate = activate;
      packages.no-sudo-activate = noSudoActivate;

      apps.default = {
        type = "app";
        program = "${noSudoActivate}/bin/activate.nu";
        meta.description = "Activate the configuration of this or another host";
      };
    };
}
