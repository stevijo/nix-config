# The settings shared by every home-manager configuration.
{ ... }:

{
  homeManager.modules.base = { config, lib, pkgs, ... }: {
    home.homeDirectory = lib.mkDefault "/${
      if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"
    }/${config.home.username}";

    news.display = "silent";
  };
}
