{ flake, ... }:

let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    {
      home-manager.sharedModules = [
        inputs.mac-app-util.homeManagerModules.default
        self.homeModules.default
        self.homeModules.darwin-only
      ];
    }
    self.sharedModules.default
  ];
}
