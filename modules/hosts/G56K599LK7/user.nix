{ ... }:

{
  flake.modules.darwin."darwinConfigurations/G56K599LK7" = { ... }: {

    users.users."stefan.mayer".home = "/Users/stefan.mayer";
    username = "stefan.mayer";
    system.primaryUser = "stefan.mayer";
    system.defaults.dock.show-recents = false;
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
