# Steam + nix-ld for running unpatched dynamic binaries.
{ ... }:

{
  programs.steam = {
    enable = true;
  };
  programs.nix-ld.enable = true;
}
