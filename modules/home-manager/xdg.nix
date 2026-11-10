{ ... }:

{
  flake.modules.homeManager.xdg = { ... }: {

    xdg.mime.enable = false;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
