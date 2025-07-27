{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  programs.direnv = {
    enable = true;
    config = {
      global = {
        log_filter = "^$";
      };
    };
    nix-direnv.enable = true;
  };
  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

}
