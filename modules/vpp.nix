# The VPP module, which is not in nixpkgs yet.
#
# It is taken from the pull request
# https://github.com/NixOS/nixpkgs/pull/461159 and lives in `modules/_vpp/`,
# where the import tree does not pick it up.
#
# The package of VPP is patched: the patches of VyOS and the ones of this
# configuration are applied to it. The overlay which does that is only added
# when the service is enabled, so that the systems which do not use VPP do
# not pull the package in, which is built from the sources.
{ ... }:

{
  nixos.modules.vpp = { config, lib, ... }: {
    imports = [ ./_vpp/vpp.nix ];

    nixpkgs.overlays = lib.mkIf config.services.vpp.enable [
      (import ./_vpp/overlay.nix)
    ];
  };
}
