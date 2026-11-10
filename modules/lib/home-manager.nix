# Builds the standalone home-manager configurations of the hosts.
#
# They are exposed at the top level of the flake, because that is where the
# home-manager CLI looks for them: `--flake .#user@host` resolves to
# `homeConfigurations."user@host"`.
#
# Each configuration is built for the platform of its host, so that the
# home-manager modules see the right system (darwin vs. linux).
{ config, lib, inputs, ... }:

let
  pkgsFor = platform:
    import inputs.nixpkgs {
      system = platform;
      overlays = lib.attrValues config.flake.overlays;
      config.allowUnfree = true;
    };

  mkHomeConfiguration = host: userName: user:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor host.platform;
      modules = [
        ({ lib, ... }: {
          home.username = userName;
          home.stateVersion = user.stateVersion;
        })
      ] ++ user.modules;
    };
in
{
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    default = { };
    description = "The home-manager configurations of the hosts.";
  };

  config.flake.homeConfigurations = lib.listToAttrs (
    lib.concatLists (lib.map
      (hostName:
        let
          host = config.hosts.${hostName};
        in
        lib.mapAttrsToList
          (userName: user:
            lib.nameValuePair "${userName}@${hostName}" (mkHomeConfiguration host userName user)
          )
          host.homeUsers
      )
      (lib.attrNames config.hosts))
  );
}
