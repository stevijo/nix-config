# The settings shared by every nix-darwin configuration.
#
# nix-darwin uses nixpkgs' module system, so the base module applies
# unchanged.
{ config, inputs, ... }:

{
  nixDarwin.modules.base = {
    imports = [
      config.nixos.modules.base
      inputs.mac-app-util.darwinModules.default
    ];
  };
}
