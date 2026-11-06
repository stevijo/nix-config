# User account and home-manager wiring.
{ config, flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = config.username;
in
{
  users.groups.tuning = { };

  users.users.${username} = {
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
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users.${username} = {
    imports = [ (self + "/configurations/home/stevijo@ally.nix") ];
  };
}
