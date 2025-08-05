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
        self.homeModules.darwin-only
      ];
    }
    self.nixosModules.common
  ];
}
