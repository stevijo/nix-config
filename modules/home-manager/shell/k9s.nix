{ ... }:

{
  flake.modules.homeManager.shell = { lib, pkgs, ... }: {

    home.packages = with pkgs; [
      kubectl
      kubelogin
      kubelogin-oidc
      kubernetes-helm
    ];

    programs.k9s = {
      enable = true;
    };
  };
}
