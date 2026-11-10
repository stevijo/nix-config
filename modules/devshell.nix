# The devshell, for working on this configuration.
{ ... }:

{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nix-config-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      packages = with pkgs; [
        sops
        ssh-to-age
        just
        nixd
      ];
    };
  };
}
