{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.htop.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    initExtra = ''
      source <(kubectl completion zsh)
      source <(k9s completion zsh)
    '';
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "jump"
      ];
    };
  };
}
