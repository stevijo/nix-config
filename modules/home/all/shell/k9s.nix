{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  home.packages = with pkgs; [
    kubectl
    kubelogin
    kubelogin-oidc
    kubernetes-helm
  ];

  programs.k9s = {
    enable = true;
  };
}
