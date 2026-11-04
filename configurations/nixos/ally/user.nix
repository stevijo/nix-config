# User account and home-manager wiring for the ASUS ROG Xbox Ally X20.
{ config, flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = config.username;
in
{
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
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "stevijo" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];


  home-manager.users.${username} = {
    imports = [ (self + "/configurations/home/stevijo@ally.nix") ];
  };
}
