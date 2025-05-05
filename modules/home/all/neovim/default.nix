{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  home.packages = with pkgs; [
    yaml-language-server
    helm-ls
    luarocks
    lua5_1
    unzip
    rustc
    cargo
    go
    gnumake
  ];
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = lazy-nvim;
        type = "lua";
        config = ''
          require("lazy").setup({
              spec = {
                  { import = "plugins" },
              },
              defaults = {
                  lazy = false,
              },
          })
        '';
      }
    ];
    extraPackages = with pkgs; [
      ripgrep
    ];
    extraLuaConfig = ''
      require("stevijo")
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
