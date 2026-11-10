# The user account of the Ally.
{ ... }:

{
  nixos.configurations.ally.module = { config, ... }: {
    users.groups.tuning = { };

    users.users.${config.username} = {
      isNormalUser = true;
      description = "Stefan Mayer";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "render"
        "input"
        "gamemode"
        "uinput"
        "led"
        "decky"
        "tuning"
      ];
    };

    security.sudo.extraRules = [
      {
        users = [ config.username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
