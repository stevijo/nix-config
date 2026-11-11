{ config, ... }:

{
  homeManager.configurations."stevijo@DESKTOP-HPTLRBM".module = { ... }: {
    imports = [
      config.homeManager.modules.stevijo
      config.homeManager.modules.base
      config.homeManager.modules.neovim
      config.homeManager.modules.shell
    ];

    home.username = "stevijo";

    home.stateVersion = "26.05";
  };
}
