{ lib, ... }:

{
  options.homeManager = {
    modules = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "The NixOS features of this configuration, keyed by feature name.";
    };
  };
}
