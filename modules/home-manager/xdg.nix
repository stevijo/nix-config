{ ... }:

{
  homeManager.modules.gui = { ... }: {

    xdg.mime.enable = false;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
