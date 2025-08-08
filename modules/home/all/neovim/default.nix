{ system, config, flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  cfg = config.java;
in
{
  options.java = {
    java21 = lib.mkOption {
      default = pkgs.temurin-bin;
      type = lib.types.path;
      description = ''
        Java21 Package
      '';
    };
    java17 = lib.mkOption {
      default = pkgs.temurin-bin;
      type = lib.types.path;
      description = ''
        Java17 Package
      '';
    };
  };
  config = {
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
      maven
      nodejs_24
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

        vim.g.palantirformat = "${./palantir-java-format.jar}"
      '';
    };

    home.sessionVariables =
      {
        EDITOR = "nvim";
        JAVA_HOME = cfg.java21;
        JAVA_VERSION = "JavaSE-21";
        JAVA_HOME_17 = cfg.java17;
        JAVA_HOME_21 = cfg.java21;
      };

    xdg.configFile.nvim = {
      source = ./config;
      recursive = true;
    };

  };
}
