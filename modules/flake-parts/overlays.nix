{ self, inputs, lib, ... }:

{
  perSystem = { system, ... }: {
    # Enables overlay for dev-shell and home-manager
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = lib.attrValues self.overlays;
      config.allowUnfree = true;
    };
  };
}
