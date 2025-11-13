# Configuration common to all Linux systems
{ flake, ... }:

let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.linux-only
      ];
    }
    self.sharedModules.default
  ];
}
