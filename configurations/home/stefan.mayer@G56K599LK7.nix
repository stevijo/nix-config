{ flake, pkgs, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  pkcs11Whitelist = [
    "${pkgs.yubico-piv-tool}/lib/libykcs11.2.7.3.dylib"
  ];
in
{
  imports = [
    self.homeModules.default
    self.homeModules.common
    self.homeModules.darwin-only
  ];

  home.username = "stefan.mayer";
  home.stateVersion = "22.11";

  programs.zsh = {
    history = {
      path = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/stefan.mayer/.histfile";
    };
    envExtra =
      let
        cfg = config.services.ssh-agent;
        socketPath =
          if pkgs.stdenv.isDarwin then
            "$(${lib.getExe pkgs.getconf} DARWIN_USER_TEMP_DIR)/${cfg.socket}"
          else
            "$XDG_RUNTIME_DIR/${cfg.socket}";

        bashIntegration = ''
          export SSH_AUTH_SOCK=${socketPath}
        '';
      in
      ''
        # Make Nix and home-manager installed things available in PATH.
          export PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
          ${bashIntegration}
      '';
  };

  launchd.agents.ssh-agent =
    let
      cfg = config.services.ssh-agent;
    in
    lib.mkForce {
      enable = true;
      config = {
        ProgramArguments = [
          (lib.getExe pkgs.bash)
          "-c"
          ''${lib.getExe' cfg.package "ssh-agent"} -D -a "$(${lib.getExe pkgs.getconf} DARWIN_USER_TEMP_DIR)/${cfg.socket}"${
            lib.optionalString (
              cfg.defaultMaximumIdentityLifetime != null
            ) " -t ${toString cfg.defaultMaximumIdentityLifetime}"
          }${
            lib.optionalString (
              pkcs11Whitelist != [ ]
            ) " -P '${lib.concatStringsSep "," pkcs11Whitelist}'"
          }''
        ];
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        RunAtLoad = true;
      };
    };

  home.packages = with pkgs; [
    awscli2
    azure-cli
  ];

  programs.kitty.font.size = lib.mkForce 18;
}
