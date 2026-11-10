# The settings shared by every nix-darwin configuration.
#
# nix-darwin uses nixpkgs' module system, so the base module applies
# unchanged.
{ config, inputs, ... }:

{
  flake.modules.darwin.base = {
    imports = [
      config.flake.modules.generic.base
      inputs.mac-app-util.darwinModules.default
    ];
  };
}
