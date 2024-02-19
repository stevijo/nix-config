{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  home.packages = with pkgs; [
    kubectl
    kubelogin
    kubernetes-helm
  ];

  programs.k9s = {
    enable = true;
  };
}
