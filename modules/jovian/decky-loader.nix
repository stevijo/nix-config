# The Steam Deck Plugin Loader.
#
# As of 2023/07/16, the Decky Loader needs to run as root, even if you never
# use plugins that require it. It setuid's to the unprivileged user to
# run plugins. Running as non-root is unsupported and currently breaks:
#
# <https://github.com/SteamDeckHomebrew/decky-loader/issues/446#issuecomment-1637177368>
{ ... }:

{
  nixos.modules.jovian = { config, lib, pkgs, ... }:
    let
      inherit (lib)
        mkIf
        mkOption
        types
        ;
      cfg = config.jovian.decky-loader;

      package = cfg.package.overridePythonAttrs (old: {
        dependencies = old.dependencies ++ (cfg.extraPythonPackages old.passthru.python.pkgs);
      });
    in
    {
      options = {
        jovian = {
          decky-loader = {
            enableFHSEnvironment = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Allows plugins shipping with prebuilt binaries to function (e.g. PowerTools).
              '';
            };
          };
        };
      };

      config = mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf (cfg.user == "decky") {
            users.users.decky = {
              group = "decky";
              home = cfg.stateDir;
              isSystemUser = true;
            };
            users.groups.decky = { };
          })
          {
            systemd.services.decky-loader = lib.mkForce {
              description = "Steam Deck Plugin Loader";

              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];

              environment = {
                UNPRIVILEGED_USER = cfg.user;
                UNPRIVILEGED_PATH = cfg.stateDir;
                PLUGIN_PATH = "${cfg.stateDir}/plugins";
                LD_LIBRARY_PATH = lib.makeLibraryPath cfg.extraPackages;
              };

              path = cfg.extraPackages;

              preStart = ''
                mkdir -p "${cfg.stateDir}"
                chown -R "${cfg.user}:" "${cfg.stateDir}"
              '';

              serviceConfig =
                let
                  decky-loader =
                    if !cfg.enableFHSEnvironment then
                      "${package}"
                    else
                      pkgs.buildFHSEnv {
                        name = "decky-loader";
                        runScript = "${package}/bin/decky-loader";
                        targetPkgs = _: cfg.extraPackages;

                        extraBwrapArgs = [
                          "--bind /etc /etc"
                          "--bind ${cfg.stateDir}/plugins ${cfg.stateDir}/plugins"
                          "--bind /tmp /tmp"
                        ];
                      };
                in
                {
                  ExecStart = "${decky-loader}/bin/decky-loader";
                  KillMode = "control-group";
                  TimeoutStopSec = 45;
                };

            };

            # Steam CEF remote debugging for decky-loader
            systemd.tmpfiles.settings."steam-cef-remote-debugging"."${
              config.users.users.${cfg.user}.home
            }/.local/share/Steam/.cef-enable-remote-debugging".f =
              {
                user = cfg.user;
                group = "users";
              };

          }
        ]
      );
    };
}
